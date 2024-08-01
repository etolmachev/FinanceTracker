import SwiftUI
import CoreData

@main
struct FinanceTrackerApp: App {
    let persistentContainer = NSPersistentContainer(name: "Model")

    init() {
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let context = PersistenceController.shared.container.viewContext

        // Проверьте, есть ли уже данные
        let fetchRequest: NSFetchRequest<Month> = Month.fetchRequest()
        if let count = try? context.count(for: fetchRequest), count == 0 {
            // Нет данных - создайте начальные данные
            let month = Month(context: context)
            month.monthYear = "08/2024"
            month.previousMonthBalance = 0.0
            try? context.save()
        }

        return true
    }
}
