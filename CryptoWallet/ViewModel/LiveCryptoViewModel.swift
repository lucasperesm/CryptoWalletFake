import Foundation
import CoreData
import Observation

enum ChartPeriod: String, CaseIterable {
    case realtime    = "Tempo Real"
    case oneDay      = "1D"
    case oneWeek     = "1W"
    case oneMonth    = "1M"
    case threeMonths = "3M"
    case sixMonths   = "6M"

    var binanceInterval: String? {
        switch self {
        case .realtime:      return nil
        case .oneDay:        return "5m"
        case .oneWeek:       return "1h"
        case .oneMonth:      return "4h"
        case .threeMonths:   return "1d"
        case .sixMonths:     return "1d"
        }
    }

    var limit: Int? {
        switch self {
        case .realtime:      return nil
        case .oneDay:        return 288   // 5m × 288 = 24 h
        case .oneWeek:       return 168   // 1h × 168 = 7 d
        case .oneMonth:      return 180   // 4h × 180 ≈ 30 d
        case .threeMonths:   return 90    // 1d × 90  ≈ 3 m
        case .sixMonths:     return 180   // 1d × 180 ≈ 6 m
        }
    }
}

@Observable
final class LiveCryptoViewModel {
    private(set) var points: [CryptoPoint] = []
    private(set) var selectedPeriod: ChartPeriod = .realtime
    private(set) var socketError: String? = nil
    var holdingInput: String = ""
    private(set) var selectedSymbol: String = "BTCUSDT"
    private(set) var marketCap: Double? = nil
    private(set) var volume24h: Double? = nil
    private(set) var coinImageURL: String? = nil

    private let socket = BinanceWebSocketManager()
    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    func setup(symbol: String = "btcusdt") {
        selectedSymbol = symbol.uppercased()
        loadHoldingAmount()
        selectPeriod(.realtime)
        fetchMarketData()
    }

    func stopLiveUpdates() {
        timeoutTask?.cancel()
        socket.disconnect()
    }

    func selectPeriod(_ period: ChartPeriod) {
        selectedPeriod = period
        points.removeAll()
        socketError = nil
        if period == .realtime {
            startLiveUpdates(symbol: selectedSymbol.lowercased())
        } else {
            socket.disconnect()
            if let interval = period.binanceInterval, let limit = period.limit {
                fetchHistorical(interval: interval, limit: limit)
            }
        }
    }

    var latestPrice: Double? {
        points.last?.price
    }

    var priceChange: Double? {
        guard let first = points.first?.price, let last = points.last?.price else { return nil }
        return last - first
    }

    var priceChangePercent: Double? {
        guard let first = points.first?.price, let change = priceChange, first != 0 else { return nil }
        return (change / first) * 100
    }

    var coinName: String {
        let sym = selectedSymbol.replacingOccurrences(of: "USDT", with: "")
        switch sym {
        case "BTC": return "Bitcoin"
        case "ETH": return "Ethereum"
        case "BNB": return "BNB"
        default: return sym
        }
    }

    var coinIconName: String {
        let sym = selectedSymbol.replacingOccurrences(of: "USDT", with: "")
        switch sym {
        case "BTC": return "bitcoinsign.circle.fill"
        case "ETH": return "e.circle.fill"
        case "BNB": return "b.circle.fill"
        default: return "dollarsign.circle.fill"
        }
    }

    private var coinGeckoId: String {
        let sym = selectedSymbol.replacingOccurrences(of: "USDT", with: "")
        switch sym {
        case "BTC": return "bitcoin"
        case "ETH": return "ethereum"
        case "BNB": return "binancecoin"
        default: return sym.lowercased()
        }
    }

    func fetchMarketData() {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=\(coinGeckoId)&order=market_cap_desc&per_page=1&page=1&sparkline=false"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self, let data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                   let coinData = json.first {
                    DispatchQueue.main.async {
                        self.marketCap = coinData["market_cap"] as? Double
                        self.volume24h = coinData["total_volume"] as? Double
                        self.coinImageURL = coinData["image"] as? String
                    }
                }
            } catch {
                print("Error fetching market data:", error)
            }
        }.resume()
    }

    var marketCapFormatted: String { formatLargeNumber(marketCap) }
    var volume24hFormatted: String { formatLargeNumber(volume24h) }

    private func formatLargeNumber(_ value: Double?) -> String {
        guard let value else { return "--" }
        if value >= 1_000_000_000_000 {
            return String(format: "$%.2fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.2fM", value / 1_000_000)
        } else {
            return "$\(value.formatted(.number.precision(.fractionLength(2))))"
        }
    }

    var holdingValueInUSD: Double {
        guard let amount = Double(holdingInput), let latestPrice else { return 0 }
        return amount * latestPrice
    }

    func saveHoldingAmount() {
        let amount = Double(holdingInput) ?? 0

        let request = CryptoHolding.fetchRequest()
        request.predicate = NSPredicate(format: "symbol == %@", selectedSymbol)
        request.fetchLimit = 1

        do {
            let entity = try context.fetch(request).first ?? CryptoHolding(context: context)
            entity.symbol = selectedSymbol
            entity.amount = amount
            try context.save()
        } catch {
            print("Error saving CoreData holding:", error)
        }
    }

    private func loadHoldingAmount() {
        let request = CryptoHolding.fetchRequest()
        request.predicate = NSPredicate(format: "symbol == %@", selectedSymbol)
        request.fetchLimit = 1

        do {
            if let holding = try context.fetch(request).first {
                holdingInput = String(format: "%.6f", holding.amount)
            } else {
                holdingInput = "0"
            }
        } catch {
            print("Error loading CoreData holding:", error)
            holdingInput = "0"
        }
    }

    private var timeoutTask: Task<Void, Never>? = nil

    private func startLiveUpdates(symbol: String) {
        points.removeAll()
        socketError = nil
        timeoutTask?.cancel()

        socket.onError = { [weak self] errorMessage in
            guard let self else { return }
            self.timeoutTask?.cancel()
            self.socketError = errorMessage
        }

        socket.onPriceUpdate = { [weak self] price in
            guard let self else { return }
            self.timeoutTask?.cancel()

            let point = CryptoPoint(time: Date(), price: price)
            self.points.append(point)

            if self.points.count > 40 {
                self.points.removeFirst()
            }
        }

        socket.connect(symbol: symbol)

        timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(5))
            guard let self, !Task.isCancelled else { return }
            await MainActor.run {
                if self.points.isEmpty && self.socketError == nil {
                    self.socketError = "Tempo esgotado. Tente novamente mais tarde."
                    self.socket.disconnect()
                }
            }
        }
    }

    private func fetchHistorical(interval: String, limit: Int) {
        let urlString = "https://api.binance.com/api/v3/klines?symbol=\(selectedSymbol)&interval=\(interval)&limit=\(limit)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self, let data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [[Any]] ?? []
                let parsed: [CryptoPoint] = json.compactMap { row in
                    guard row.count >= 7,
                          let closeTimeMsRaw = row[6] as? NSNumber,
                          let closeStr = row[4] as? String,
                          let price = Double(closeStr) else { return nil }
                    let time = Date(timeIntervalSince1970: closeTimeMsRaw.doubleValue / 1000)
                    return CryptoPoint(time: time, price: price)
                }
                DispatchQueue.main.async {
                    self.points = parsed
                }
            } catch {
                print("Error parsing klines:", error)
            }
        }.resume()
    }
}
