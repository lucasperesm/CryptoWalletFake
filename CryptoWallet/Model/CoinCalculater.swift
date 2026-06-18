import Foundation
 
struct CoinCalculator {
    static func decimalAmount(from string: String) -> Double? {
        let raw = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
 
        let cleaned = raw.replacingOccurrences(of: "[^0-9,.-]", with: "", options: .regularExpression)
        guard !cleaned.isEmpty else { return nil }
 
        let decimalSeparator: Character? = {
            let lastComma = cleaned.lastIndex(of: ",")
            let lastDot = cleaned.lastIndex(of: ".")
 
            switch (lastComma, lastDot) {
            case let (comma?, dot?):
                return comma > dot ? "," : "."
            case (_?, nil):
                return ","
            case (nil, _?):
                return "."
            default:
                return nil
            }
        }()
 
        let normalized: String
        if let decimalSeparator {
            let splitParts = cleaned.split(separator: decimalSeparator, omittingEmptySubsequences: false)
            if splitParts.count > 1 {
                let integerPart = splitParts.dropLast().joined().replacingOccurrences(of: "[^0-9-]", with: "", options: .regularExpression)
                let fractionPart = String(splitParts.last ?? "").replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                normalized = integerPart + "." + fractionPart
            } else {
                normalized = cleaned.replacingOccurrences(of: ",", with: ".")
            }
        } else {
            normalized = cleaned.replacingOccurrences(of: "[^0-9-]", with: "", options: .regularExpression)
        }
 
        return Double(normalized)
    }
 
    static func maskedBRLInput(from string: String) -> String {
        let digits = string.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard !digits.isEmpty, let value = Double(digits) else { return "" }
 
        let number = value / 100.0
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
 
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
   
    static func cryptoAmount(fromBRL amountBRL: String, coinValue: Double) -> String {
        guard let amount = decimalAmount(from: amountBRL), amount > 0, coinValue > 0 else {
            return "0"
        }
       
        let cryptoAmount = amount / coinValue
        return formatCryptoAmount(cryptoAmount)
    }
   
    private static func formatCryptoAmount(_ value: Double) -> String {
        let formatted = String(format: "%.6f", value)
        let trimmed = formatted.replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
        return trimmed.hasSuffix(".") ? String(trimmed.dropLast()) : trimmed
    }
   
    static func balanceAfterFiat(currentBalance: Double, amountBRL: String, isBuy: Bool) -> String {
        guard let amount = decimalAmount(from: amountBRL) else {
            return formatBRL(currentBalance)
        }
 
        let newBalance = isBuy ? currentBalance - amount : currentBalance + amount
        return formatBRL(newBalance)
    }
 
    static func balanceAfterFiat(currentBalance: Double, amountBRL: String, isBuy: Bool, currentOwned: Double, coinValue: Double) -> String {
        guard let amount = decimalAmount(from: amountBRL) else {
            return formatBRL(currentBalance)
        }
 
        let effectiveAmount: Double
        if isBuy {
            effectiveAmount = amount
        } else {
            let maxSellableBRL = max(0, currentOwned) * max(coinValue, 0)
            effectiveAmount = min(amount, maxSellableBRL)
        }
 
        let newBalance = isBuy ? currentBalance - effectiveAmount : currentBalance + effectiveAmount
        return formatBRL(newBalance)
    }
   
    static func balanceAfterCrypto(amountBRL: String, coinValue: Double, currentOwned: Double, symbol: String, isBuy: Bool) -> String {
        guard let amount = decimalAmount(from: amountBRL), coinValue > 0 else {
            return formatCryptoAmount(currentOwned) + " " + symbol
        }
 
        let cryptoAmount = amount / coinValue
        let newBalance: Double
        if isBuy {
            newBalance = currentOwned + cryptoAmount
        } else {
            newBalance = max(0, currentOwned - cryptoAmount)
        }
 
        return formatCryptoAmount(newBalance) + " " + symbol
    }
   
    private static func formatBRL(_ value: Double) -> String {
        return String(format: "R$ %.2f", value)
            .replacingOccurrences(of: ".", with: ",")
    }
}
