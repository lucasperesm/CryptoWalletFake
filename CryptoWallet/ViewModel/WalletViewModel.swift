import Foundation
internal import Combine

class WalletViewModel: ObservableObject {
    
    @Published var totalBalance: Double = 20802
    @Published var profit: Double = 1234.56
    @Published var profitPercentage: Double = 4.12
    
    @Published var coins: [Coin] = [
        Coin(name: "ETH", symbol: "Ethereum", value: 10545.25, percentage: 49, icon: "e.circle"),
        Coin(name: "BTC", symbol: "Bitcoin", value: 262515.351, percentage: 10, icon: "bitcoinsign.circle"),
        Coin(name: "BNB", symbol: "Binance", value: 42, percentage: 1, icon: "b.circle"),
        Coin(name: "USD", symbol: "Dollar", value: 2478, percentage: 9, icon: "dollarsign.circle")
    ]
}
