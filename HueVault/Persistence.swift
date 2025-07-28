import CoreData
import FirebaseFirestore

struct PersistenceController {
    static let shared = PersistenceController()
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newColor = ColorEntity(context: viewContext)
            newColor.hexCode = String(format: "#%06X", arc4random_uniform(0xFFFFFF))
            newColor.timestamp = Date()
            newColor.synced = false
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    private let db = Firestore.firestore()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HueVault")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func syncUnsyncedColors() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<ColorEntity> = ColorEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "synced == NO")
        
        do {
            let unsyncedColors = try context.fetch(fetchRequest)
            print("Found \(unsyncedColors.count) unsynced colors to sync")
            for color in unsyncedColors {
                let data: [String: Any] = [
                    "hexCode": color.hexCode ?? "",
                    "timestamp": Timestamp(date: color.timestamp ?? Date()),
                    "userID": UUID().uuidString
                ]
                print("Attempting to sync color: \(color.hexCode ?? "")")
                db.collection("colors").addDocument(data: data) { error in
                    if let error = error {
                        print("Sync error for \(color.hexCode ?? ""): \(error.localizedDescription)")
                    } else {
                        print("Sync successful for \(color.hexCode ?? "")")
                        color.synced = true
                        do {
                            try context.save()
                            print("Context saved after syncing \(color.hexCode ?? "")")
                        } catch {
                            let nsError = error as NSError
                            print("Failed to save context after sync: \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            }
        } catch {
            let nsError = error as NSError
            print("Fetch error: \(nsError), \(nsError.userInfo)")
        }
    }
}
