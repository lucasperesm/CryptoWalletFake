import SwiftUI
import Charts
import CoreData
 
struct LiveCryptoView: View {
    let symbol: String
    @State private var viewModel = LiveCryptoViewModel()
    @State private var isConfigured = false
    @Environment(\.dismiss) private var dismiss
 
    init(symbol: String = "btcusdt") {
        self.symbol = symbol
    }
 
    var body: some View {
        
        let points = viewModel.points
        let _ = viewModel.selectedPeriod
        let _ = viewModel.socketError
 
        AppBackground {
            ScrollView {
                VStack(spacing: 20) {
                    header
 
                    periodTabBar
 
                    if let errorMessage = viewModel.socketError {
                        chartErrorView(message: errorMessage)
                    } else if points.count < 2 {
                        ProgressView("Aguardando dados do WebSocket...")
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else {
                        let minPrice = points.map(\.price).min() ?? 0
                        let maxPrice = points.map(\.price).max() ?? 0
                        let range = maxPrice - minPrice
                        let padding = max(range * 0.08, 10) // 8% do range, mínimo 10
                        
                        let minY = minPrice - padding
                        let maxY = maxPrice + padding

                        priceChartView(points: points, minY: minY, maxY: maxY)
                    }
 
                    marketDataSection
 
                    coinHoldingRow
                        .padding(.top, 32)
 
                    PrimaryButton(title: "Buy \(viewModel.coinName)", action: {})
                        .padding(.top, 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .safeAreaPadding(.top)
        }
        .onAppear {
            guard !isConfigured else { return }
            isConfigured = true
            viewModel.setup(symbol: symbol)
        }
        .onDisappear {
            viewModel.stopLiveUpdates()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
 
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .foregroundStyle(.white)
                    .font(.system(size: 20, weight: .semibold))
            }
            .padding(.top, 28)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(){
                HStack(spacing: 6) {
                    if let urlString = viewModel.coinImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        } placeholder: {
                            Image(systemName: viewModel.coinIconName)
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                        }
                    } else {
                        Image(systemName: viewModel.coinIconName)
                            .foregroundStyle(.white)
                            .font(.system(size: 20))
                    }
                    Text(viewModel.coinName)
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .padding(.bottom, 16)
 
            Text(viewModel.latestPrice.map { "$\($0.formatted(.number.precision(.fractionLength(2))))" } ?? "--")
                .foregroundStyle(.white)
                .font(.system(size: 27, weight: .bold))
 
            priceChangeView
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
 
    private var priceChangeView: some View {
        Group {
            if let change = viewModel.priceChange, let pct = viewModel.priceChangePercent {
                let isPositive = change >= 0
                let sign = isPositive ? "+" : "-"
                let color: Color = isPositive
                    ? .green
                    : Color(red: 225/255, green: 94/255, blue: 96/255)
                Text("\(sign)$\(abs(change), format: .number.precision(.fractionLength(2))) (\(sign)\(abs(pct), format: .number.precision(.fractionLength(2)))%)")
                    .foregroundStyle(color)
                    .font(.system(size: 16))
            } else {
                Text("--")
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 16))
            }
        }
    }
 
    private var coinHoldingRow: some View {
        HStack {
            HStack(spacing: 6) {
                if let urlString = viewModel.coinImageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    } placeholder: {
                        Image(systemName: viewModel.coinIconName)
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                    }
                } else {
                    Image(systemName: viewModel.coinIconName)
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                }
                Text(viewModel.coinName)
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium))
            }
            Spacer()
            Text(viewModel.holdingValueInUSD > 0
                 ? "$\(viewModel.holdingValueInUSD.formatted(.number.precision(.fractionLength(2))))"
                 : "--")
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .semibold))
        }
    }
 
    private func chartErrorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color(red: 225/255, green: 94/255, blue: 96/255))
            Text("Não foi possível carregar os dados")
                .foregroundStyle(.white)
                .font(.system(size: 15, weight: .semibold))
            Text(message)
                .foregroundStyle(Color.white.opacity(0.5))
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
 
    private func priceChartView(points: [CryptoPoint], minY: Double, maxY: Double) -> some View {
        let purple = Color(red: 83/255, green: 45/255, blue: 187/255)
        return Chart(points) { item in
            AreaMark(
                x: .value("Tempo", item.time),
                yStart: .value("Base", minY),
                yEnd: .value("Preco", item.price)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(
                .linearGradient(
                    stops: [
                        .init(color: purple.opacity(0x33 / 255.0), location: 0),
                        .init(color: purple.opacity(0),            location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            LineMark(
                x: .value("Tempo", item.time),
                y: .value("Preco", item.price)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(purple)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
        }
        .chartYScale(domain: minY...maxY)
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 5)) { value in
                AxisValueLabel {
                    if let price = value.as(Double.self) {
                        Text(price, format: .number.precision(.fractionLength(0)))
                            .font(.caption2)
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisValueLabel(format: xLabelFormat, centered: false)
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.7))
            }
        }
        .frame(height: 260)
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }
 
    private var marketDataSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("MARKET DATA")
                .font(.system(size: 14.57))
                .foregroundStyle(Color(red: 141/255, green: 141/255, blue: 141/255))
 
            Rectangle()
                .fill(Color(red: 167/255, green: 152/255, blue: 170/255))
                .frame(height: 1)
                .padding(.horizontal, -16)
                .padding(.top, 8)
 
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MARKET CAP")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 141/255, green: 141/255, blue: 141/255))
                    Text(viewModel.marketCapFormatted)
                        .font(.system(size: 17.73))
                        .foregroundStyle(.white)
                }
 
                VStack(alignment: .leading, spacing: 4) {
                    Text("24H VOLUME")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 141/255, green: 141/255, blue: 141/255))
                    Text(viewModel.volume24hFormatted)
                        .font(.system(size: 17.73))
                        .foregroundStyle(.white)
                }
 
                Spacer()
            }
            .padding(.top, 8)
        }
    }
 
    private var xLabelFormat: Date.FormatStyle {
        switch viewModel.selectedPeriod {
        case .realtime:
            return .dateTime.hour().minute()
        case .oneDay:
            return .dateTime.hour().minute()
        case .oneWeek:
            return .dateTime.weekday(.abbreviated)
        case .oneMonth, .threeMonths, .sixMonths:
            return .dateTime.month(.abbreviated).day()
        }
    }
 
    private var periodTabBar: some View {
        let tabColor = Color(red: 167/255, green: 152/255, blue: 170/255)
        return HStack(spacing: 0) {
            ForEach(ChartPeriod.allCases, id: \.self) { period in
                Button(period.rawValue) {
                    viewModel.selectPeriod(period)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(viewModel.selectedPeriod == period ? Color.white : tabColor)
                .font(.system(size: 13, weight: viewModel.selectedPeriod == period ? .semibold : .regular))
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(tabColor)
                .frame(height: 1)
        }
    }
}
 
struct LiveCryptoView_Previews: PreviewProvider {
    static var previews: some View {
        LiveCryptoView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
