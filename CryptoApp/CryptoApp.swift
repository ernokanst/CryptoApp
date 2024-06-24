import SwiftUI
import SwiftData

@main
struct CryptoApp: App {
    let container: ModelContainer

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }

    init() {
        do {
            container = try ModelContainer(for: Coin.self)
        } catch {
            fatalError("Failed to create ModelContainer for Coin.")
        }
    }
}