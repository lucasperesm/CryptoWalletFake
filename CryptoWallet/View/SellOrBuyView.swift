import Foundation
import SwiftUI
 
struct SellOrBuyView: View {
    enum Mode { case buy, sell
        var title: String {
            switch self { case .buy: return "Buy"; case .sell: return "Sell" }
        }
    }
 
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WalletViewModel
    @Binding var selectedView: MenuOption
    @State private var selectedCoin: CoinModel?
    @State private var marketCapText: String = "--"
    @State private var amountInBRL: String = ""
    @State private var showFeedback: Bool = false
    @State private var errorMessage: String = ""
    @State private var liveCoinPrice: Double?
 
    let mode: Mode
 
    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 24) {
                    headerTitle
                    coinSelector
                    marketInfoView
                    mainCard
                    PrimaryButton(title: "Confirm", action: processTransaction)
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
                .padding(14)
            }
        }
        .onAppear {
            if selectedCoin == nil { selectedCoin = viewModel.coins.first }
            loadMarketCapIfNeeded()
            fetchLivePriceIfNeeded()
        }
        .onChange(of: selectedCoin) { _ in
            loadMarketCapIfNeeded()
            fetchLivePriceIfNeeded()
        }
        .onChange(of: viewModel.coins) { _ in
            // Atualizar a moeda selecionada com os dados mais recentes do viewModel
            if let symbol = selectedCoin?.symbol, let updatedCoin = viewModel.coins.first(where: { $0.symbol == symbol }) {
                selectedCoin = updatedCoin
            }
        }
        .onChange(of: amountInBRL) { newValue in
            let masked = CoinCalculator.maskedBRLInput(from: newValue)
            if masked != newValue {
                amountInBRL = masked
            }
        }
        .fullScreenCover(isPresented: $showFeedback) {
            FeedbackView(mode: mode, coin: selectedCoin, amountInBRL: amountInBRL) {
                selectedView = .wallet
            }
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
                VStack(spacing: 8) {
                    HStack {
                        Text("MARKET CAP")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(marketCapText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
 
                    HStack {
                        Text("LIVE PRICE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(selectedCoinLivePrice)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
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
                    Text(selectedCoinOwnedAmount)
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
                        Text(CoinCalculator.cryptoAmount(fromBRL: amountInBRL, coinValue: effectiveCoinPrice))
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
                    Text(
                        CoinCalculator.balanceAfterFiat(
                            currentBalance: viewModel.fiatBalance,
                            amountBRL: amountInBRL,
                            isBuy: mode == .buy,
                            currentOwned: selectedCoin?.amountOwned ?? 0,
                            coinValue: effectiveCoinPrice
                        )
                    )
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Fiat balance")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(CoinCalculator.balanceAfterCrypto(amountBRL: amountInBRL, coinValue: effectiveCoinPrice, currentOwned: selectedCoin?.amountOwned ?? 0, symbol: selectedCoin?.name ?? "ETH", isBuy: mode == .buy))
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
    private var selectedCoinSymbol: String { selectedCoin?.symbol ?? "ETH" }
    private var effectiveCoinPrice: Double { liveCoinPrice ?? selectedCoin?.value ?? 1 }
    private var selectedCoinOwnedAmount: String { formatCryptoForDisplay(selectedCoin?.amountOwned ?? 0) + " " + selectedCoinSymbol }
    private var selectedCoinLivePrice: String { formatBRL(effectiveCoinPrice) }
   
    private func formatCryptoForDisplay(_ value: Double) -> String {
        let formatted = String(format: "%.6f", value)
        // Remove trailing zeros
        let trimmed = formatted.replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
        // Remove ponto final se for número inteiro
        return trimmed.hasSuffix(".") ? String(trimmed.dropLast()) : trimmed
    }
 
    private func formatBRL(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "R$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
 
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
 
    private func processTransaction() {
        errorMessage = ""
 
        guard let coin = selectedCoin else {
            errorMessage = "Selecione uma moeda"
            return
        }
 
        guard
            let amountBRL = CoinCalculator.decimalAmount(from: amountInBRL),
            amountBRL > 0
        else {
            errorMessage = "Informe um valor valido"
            return
        }
 
        let amountInCrypto = amountBRL / effectiveCoinPrice
 
        if mode == .buy {
            let success = viewModel.buyCoin(symbol: coin.symbol, name: coin.name, amountToBuy: amountInCrypto, amountBRL: amountBRL)
            guard success else {
                errorMessage = "Saldo fiat insuficiente para compra"
                return
            }
        } else {
            let amountToSell = min(amountInCrypto, coin.amountOwned)
            guard amountToSell > 0 else {
                errorMessage = "Voce nao possui saldo dessa moeda para vender"
                return
            }
 
            let amountBRLToCredit = amountToSell * effectiveCoinPrice
            let success = viewModel.sellCoin(symbol: coin.symbol, amountToSell: amountToSell, amountBRL: amountBRLToCredit)
            guard success else {
                errorMessage = "Nao foi possivel concluir a venda"
                return
            }
        }
 
        if let updatedCoin = viewModel.coins.first(where: { $0.symbol == coin.symbol }) {
            selectedCoin = updatedCoin
        }
 
        showFeedback = true
    }
 
    private func fetchLivePriceIfNeeded() {
        guard let coin = selectedCoin else {
            liveCoinPrice = nil
            return
        }
 
        let symbol = "\(coin.symbol.uppercased())USDT"
        guard let url = URL(string: "https://api.binance.com/api/v3/ticker/price?symbol=\(symbol)") else {
            liveCoinPrice = nil
            return
        }
 
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data, error == nil else { return }
 
            do {
                if
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let priceText = json["price"] as? String,
                    let price = Double(priceText)
                {
                    DispatchQueue.main.async {
                        liveCoinPrice = price
                    }
                }
            } catch {
                print("Error loading live Binance price:", error)
            }
        }.resume()
    }
}
 
#Preview {
    @State var selectedView = MenuOption.buy
    SellOrBuyView(viewModel: WalletViewModel(), selectedView: $selectedView, mode: .buy)
}
 
