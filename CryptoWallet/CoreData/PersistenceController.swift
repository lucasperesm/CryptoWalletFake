import CoreData
 
struct PersistenceController {
    static let shared = PersistenceController()
 
    let container: NSPersistentContainer
 
    init() {
        container = NSPersistentContainer(name: "Model")
 
        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        }
       
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Erro Core Data: \(error), \(error.userInfo)")
            }
        }
    }
}
