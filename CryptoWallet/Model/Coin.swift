import Foundation

struct Coin: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let value: Double
    let percentage: Double
    let icon: String
    
    //todo - add CodingKeys na integração com Binance (se necessário)
}
