import SwiftUI
import SwiftData

@main
struct ComposeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedDraft.self)
    }
}

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SwiftUI.Tab("Compose", systemImage: "pencil.and.outline", value: 0) {
                NewDraftView()
            }
            SwiftUI.Tab("History", systemImage: "clock.arrow.circlepath", value: 1) {
                DraftListView()
            }
        }
        .tint(Theme.accent)
    }
}
