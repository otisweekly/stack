import SwiftUI

/// Main content view with navigation between screens
struct ContentView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimary
                .ignoresSafeArea()

            // Main content based on current screen
            VStack(spacing: 0) {
                screenContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Tab bar (only on main screens)
                if shouldShowTabBar {
                    StackTabBar(selectedTab: Binding(
                        get: { appState.selectedTab },
                        set: { appState.selectedTab = $0 }
                    ))
                }
            }
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        switch appState.currentScreen {
        case .importMedia:
            ImportView()

        case .contactSheet:
            ContactSheetView()

        case .canvas:
            CanvasView()

        case .export:
            ExportView()
        }
    }

    private var shouldShowTabBar: Bool {
        switch appState.currentScreen {
        case .importMedia:
            return true
        case .contactSheet, .canvas, .export:
            return false
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
