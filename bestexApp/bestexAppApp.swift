import SwiftUI
import SwiftData
import FirebaseCore

@main
struct bestexAppApp: App {
    // Initialize Firebase
    init() {
        FirebaseApp.configure()
    }

    // SwiftData model container setup (no change)
    var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema([Girl.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
