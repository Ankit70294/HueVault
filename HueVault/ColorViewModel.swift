import Foundation
import CoreData
import Network
import FirebaseFirestore

class ColorViewModel: ObservableObject {
    @Published var colors: [ColorEntity] = []
    @Published var isOnline = false
    private let context = PersistenceController.shared.container.viewContext
    private let monitor = NWPathMonitor()
    private let db = Firestore.firestore()
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let wasOnline = self.isOnline
                self.isOnline = path.status == .satisfied
                print("Network status changed - Was: \(wasOnline), Now: \(self.isOnline)")
                if !wasOnline && self.isOnline {
                    print("Triggering syncUnsyncedColors due to online transition")
                    PersistenceController.shared.syncUnsyncedColors()
                }
            }
        }
        monitor.start(queue: .global())
    }
    
    func generateColor() {
        let hexCode = String(format: "#%06X", arc4random_uniform(0xFFFFFF))
        let color = ColorEntity(context: context)
        color.hexCode = hexCode
        color.timestamp = Date()
        color.synced = false
        do {
            try context.save()
            fetchColors()
            print("Generated color: \(hexCode), synced: \(color.synced)")
            if isOnline {
                print("Online - Triggering immediate sync")
                PersistenceController.shared.syncUnsyncedColors()
            } else {
                print("Offline - Color marked as unsynced")
            }
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    func fetchColors() {
        let request: NSFetchRequest<ColorEntity> = ColorEntity.fetchRequest()
        if let fetchedColors = try? context.fetch(request) {
            self.colors = fetchedColors
            print("Fetched \(fetchedColors.count) colors, unsynced count: \(fetchedColors.filter { $0.synced == false }.count)")
        }
    }
    
    init() {
        fetchColors()
        startMonitoring()
    }
}
