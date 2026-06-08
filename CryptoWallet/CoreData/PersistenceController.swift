import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Model")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Erro Core Data: \(error), \(error.userInfo)")
            }
        }
    }
}
