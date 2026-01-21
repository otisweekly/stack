import SwiftUI

@main
struct StackApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(.dark)  // Force dark mode
        }
    }
}
