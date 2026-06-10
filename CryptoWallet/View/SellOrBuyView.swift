
import Foundation
import SwiftUI

struct SellOrBuyView: View {
    enum Mode { case buy, sell
        var title: String {
            switch self { case .buy: return "Buy"; case .sell: return "Sell" }
        }
    }

    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = WalletViewModel()
    @State private var selectedCoin: CoinModel?
    @State private var marketCapText: String = "--"
    @State private var amountInBRL: String = ""
    @State private var showFeedback: Bool = false

    let mode: Mode

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 24) {
                    headerTitle
                    coinSelector
                    marketInfoView
                    mainCard
                    PrimaryButton(title: "Confirm", action: { showFeedback = true })
                }
                .padding(14)
            }
        }
        .onAppear {
            if selectedCoin == nil { selectedCoin = viewModel.coins.first }
            loadMarketCapIfNeeded()
        }
        .onChange(of: selectedCoin) { _ in loadMarketCapIfNeeded() }
        .fullScreenCover(isPresented: $showFeedback) {
            FeedbackView(mode: mode, coin: selectedCoin, amountInBRL: amountInBRL) { dismiss() }
        }
    }

    private var headerTitle: some View {
        Text(mode.title)
            .font(.title2).bold()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.top, 90)
    }

    private var coinSelector: some View {
        CoinSelector(coins: viewModel.coins, selectedCoin: $selectedCoin)
    }

    private var marketInfoView: some View {
        Group {
            if selectedCoin != nil {
                HStack {
                    Text("MARKET CAP")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(marketCapText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var mainCard: some View {
        VStack(spacing: 20) {
            balanceBefore
            Divider().overlay(Color.white.opacity(0.15))
            amountInBRLField
            amountInCryptoField
            Divider().overlay(Color.white.opacity(0.15))
            balanceAfter
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(colors: [Color(red: 99/255, green: 57/255, blue: 249/255).opacity(0.08), Color(red: 88/255, green: 52/255, blue: 190/255).opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        )
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    private var balanceBefore: some View {
        VStack(spacing: 12) {
            Text("Balance before")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(marketCapText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Market cap")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(selectedCoinPrice)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Crypto balance")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }

    private var amountInBRLField: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Amount in R$")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                HStack(spacing: 6) {
                    TextField("0,00", text: $amountInBRL, prompt: Text("0,00").foregroundColor(.white.opacity(0.4)))
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .tint(.white)
                        .multilineTextAlignment(.trailing)
                    Text("R$")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .frame(maxWidth: 140)
                .background(RoundedRectangle(cornerRadius: 22).fill(Color(red: 88/255, green: 52/255, blue: 190/255).opacity(0.35)))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.15), lineWidth: 1))
            }
            .frame(height: 44)
        }
    }

    private var amountInCryptoField: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Amount in \(selectedCoinName)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                HStack(spacing: 6) {
                    if amountInBRL.isEmpty {
                        Text("0,00").font(.system(size: 14, weight: .semibold)).foregroundColor(.white.opacity(0.4))
                    } else {
                        Text(CoinCalculator.cryptoAmount(fromBRL: amountInBRL, coinValue: selectedCoin?.value ?? 1))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .frame(maxWidth: 140)
                .background(RoundedRectangle(cornerRadius: 22).fill(Color(red: 88/255, green: 52/255, blue: 190/255).opacity(0.35)))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.15), lineWidth: 1))
            }
            .frame(height: 44)
        }
    }

    private var balanceAfter: some View {
        VStack(spacing: 12) {
            Text("Balance after")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(CoinCalculator.balanceAfterFiat(currentBalance: 1074.32, amountBRL: amountInBRL, isBuy: mode == .buy))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Fiat balance")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(CoinCalculator.balanceAfterCrypto(amountBRL: amountInBRL, coinValue: selectedCoin?.value ?? 1, currentOwned: selectedCoin?.amountOwned ?? 0, symbol: selectedCoin?.name ?? "ETH", isBuy: mode == .buy))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Crypto balance")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }

    // MARK: - Helpers
    private var selectedCoinName: String { selectedCoin?.name ?? "ETH" }
    private var selectedCoinPrice: String { selectedCoin.map { String(format: "R$ %.2f", $0.value) } ?? "--" }

    private func loadMarketCapIfNeeded() {
        guard let coin = selectedCoin else { marketCapText = "--"; return }
        let coinId = coinGeckoId(for: coin.symbol)
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=\(coinId)&order=market_cap_desc&per_page=1&page=1&sparkline=false"
        guard let url = URL(string: urlString) else { marketCapText = "--"; return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]], let coinData = json.first, let marketCap = coinData["market_cap"] as? Double {
                    DispatchQueue.main.async { marketCapText = formatLargeNumber(marketCap) }
                }
            } catch { print("Error loading market cap:", error) }
        }.resume()
    }

    private func coinGeckoId(for symbol: String) -> String {
        switch symbol.uppercased() {
        case "BTC": return "bitcoin"
        case "ETH": return "ethereum"
        case "BNB": return "binancecoin"
        default: return symbol.lowercased()
        }
    }

    private func formatLargeNumber(_ value: Double?) -> String {
        guard let value else { return "--" }
        if value >= 1_000_000_000_000 { return String(format: "$%.2fT", value / 1_000_000_000_000) }
        if value >= 1_000_000_000 { return String(format: "$%.2fB", value / 1_000_000_000) }
        if value >= 1_000_000 { return String(format: "$%.2fM", value / 1_000_000) }
        return "$\(value.formatted(.number.precision(.fractionLength(2))))"
    }
}

#Preview {
    SellOrBuyView(mode: .buy)
}









