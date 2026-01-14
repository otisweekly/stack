import SwiftUI

struct ImportView: View {
    @Environment(AppState.self) var appState
    @State private var viewModel = ImportViewModel()

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Icon and text
                VStack(spacing: Spacing.lg) {
                    Image(systemName: "video.badge.plus")
                        .font(.system(size: 64))
                        .foregroundColor(.textSecondary)

                    VStack(spacing: Spacing.sm) {
                        Text("Stack")
                            .font(.fujiDisplay)
                            .foregroundColor(.textPrimary)

                        Text("Create video collages that move together")
                            .font(.fujiBody)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                // Import button
                PrimaryButton("Import Media", icon: "plus") {
                    HapticsService.shared.medium()
                    viewModel.showingPicker = true
                }
                .padding(.horizontal, Spacing.xl)

                Spacer()
            }
            .tabBarPadding()

            // Loading overlay
            if viewModel.state.isLoading {
                LoadingOverlay(state: viewModel.state)
            }
        }
        .sheet(isPresented: $viewModel.showingPicker) {
            MediaPicker(selectionLimit: 12) { results in
                Task {
                    await viewModel.handlePickerResults(results)
                }
            } onDismiss: {
                viewModel.reset()
            }
        }
        .onChange(of: viewModel.state) { _, newState in
            if case .loaded(let items) = newState {
                appState.mediaItems = items
                appState.currentScreen = .contactSheet
                viewModel.reset()
            }
        }
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    let state: ImportState

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .stackAccent))
                    .scaleEffect(1.5)

                if case .loading(let progress, let loaded, let total) = state {
                    VStack(spacing: Spacing.sm) {
                        Text("Importing Media")
                            .font(.fujiHeadlineSmall)
                            .foregroundColor(.textPrimary)

                        Text("\(loaded) of \(total)")
                            .font(.fujiBody)
                            .foregroundColor(.textSecondary)

                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .stackAccent))
                            .frame(width: 200)
                    }
                }
            }
            .padding(Spacing.xl)
            .liquidGlassBordered()
        }
    }
}

#Preview {
    ImportView()
        .environment(AppState())
}
