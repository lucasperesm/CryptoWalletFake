import Foundation

struct CoinModel: Identifiable {
    let id: UUID
    let name: String
    let symbol: String
    let value: Double
    let percentage: Double
    let icon: String
    let amountOwned: Double // quantidade possuída
    
    //todo - add CodingKeys na integração com Binance (se necessário)
}
