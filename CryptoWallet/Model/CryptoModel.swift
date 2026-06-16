import Foundation

struct CryptoPoint: Identifiable {
    let id = UUID()
    let time: Date
    let price: Double
}

struct BinanceTrade: Codable {
    let price: String

    enum CodingKeys: String, CodingKey {
        case price = "c"
    }
}
