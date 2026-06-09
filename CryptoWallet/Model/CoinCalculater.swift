import Foundation

struct CoinCalculator {
    static func decimalAmount(from string: String) -> Double? {
        let formatted = string.replacingOccurrences(of: ",", with: ".")
        return Double(formatted)
    }
    
    static func cryptoAmount(fromBRL amountBRL: String, coinValue: Double) -> String {
        guard let amount = decimalAmount(from: amountBRL), amount > 0 else {
            return "0"
        }
        
        let cryptoAmount = amount / coinValue
        return String(format: "%.6f", cryptoAmount)
    }
    
    static func balanceAfterFiat(currentBalance: Double, amountBRL: String, isBuy: Bool) -> String {
        guard let amount = decimalAmount(from: amountBRL) else {
            return formatBRL(currentBalance)
        }
        
        let newBalance = isBuy ? currentBalance - amount : currentBalance + amount
        return formatBRL(newBalance)
    }
    
    static func balanceAfterCrypto(amountBRL: String, coinValue: Double, symbol: String, isBuy: Bool) -> String {
        guard let cryptoAmount = decimalAmount(from: amountBRL).map({ $0 / coinValue }) else {
            return "0 \(symbol)"
        }
        
        let newBalance = isBuy ? cryptoAmount : -cryptoAmount
        return String(format: "%.6f", newBalance) + " " + symbol
    }
    
    private static func formatBRL(_ value: Double) -> String {
        return String(format: "R$ %.2f", value)
            .replacingOccurrences(of: ".", with: ",")
    }
}


