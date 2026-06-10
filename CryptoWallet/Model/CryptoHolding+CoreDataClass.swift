import Foundation
import CoreData

@objc(CryptoHolding)
final class CryptoHolding: NSManagedObject {
    @NSManaged var symbol: String
    @NSManaged var amount: Double
}

extension CryptoHolding {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CryptoHolding> {
        NSFetchRequest<CryptoHolding>(entityName: "CryptoHolding")
    }
}
