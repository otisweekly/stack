import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch appState.currentTab {
                case .create:
                    CreateFlowView()
                case .library:
                    LibraryView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar
            StackTabBar()
        }
        .background(Color.backgroundPrimary)
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Create Flow View

struct CreateFlowView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        switch appState.currentScreen {
        case .import_:
            ImportView()
        case .contactSheet:
            ContactSheetView()
        case .canvas:
            CanvasView()
        case .export:
            ExportView()
        }
    }
}

// MARK: - Placeholder Views

struct LibraryView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "square.stack")
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)

            Text("Library")
                .font(.fujiHeadline)
                .foregroundColor(.textPrimary)

            Text("Your saved compositions will appear here")
                .font(.fujiBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tabBarPadding()
    }
}

// MARK: - Tab Bar

struct StackTabBar: View {
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var state = appState

        HStack(spacing: 0) {
            ForEach(AppState.Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    icon: tab.icon,
                    label: tab.label,
                    isSelected: appState.currentTab == tab
                ) {
                    HapticsService.shared.selection()
                    state.currentTab = tab
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.bar)
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .padding(.bottom, 8)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.fujiCaptionSmall)
            }
            .foregroundColor(isSelected ? .stackAccent : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
