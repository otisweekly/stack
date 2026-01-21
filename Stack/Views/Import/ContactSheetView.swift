import SwiftUI

/// Grid view for selecting imported media
struct ContactSheetView: View {
    @Environment(AppState.self) var appState
    @State private var selectedIDs: Set<UUID> = []

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: Spacing.xs) {
                        ForEach(appState.clips) { clip in
                            ThumbnailCell(
                                thumbnailURL: clip.thumbnailURL,
                                duration: clip.duration,
                                isVideo: clip.isVideo,
                                isSelected: selectedIDs.contains(clip.id)
                            ) {
                                toggleSelection(clip.id)
                            }
                        }
                    }
                    .padding(Spacing.xs)
                }

                // Footer
                footerView
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Select Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        appState.navigate(to: .importMedia)
                    }
                    .foregroundColor(.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        createComposition()
                    }
                    .foregroundColor(.stackAccent)
                    .disabled(selectedIDs.count < 1)
                }
            }
            .toolbarBackground(Color.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            // Select all by default
            selectedIDs = Set(appState.clips.map(\.id))
        }
    }

    private var footerView: some View {
        VStack(spacing: Spacing.md) {
            Text("\(selectedIDs.count) item\(selectedIDs.count == 1 ? "" : "s") selected")
                .font(.fujiBody)
                .foregroundColor(.textSecondary)

            PrimaryButton("Continue to Canvas", isEnabled: selectedIDs.count >= 1) {
                createComposition()
            }
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
    }

    private func toggleSelection(_ id: UUID) {
        HapticsService.shared.light()
        withAnimation(.quick) {
            if selectedIDs.contains(id) {
                selectedIDs.remove(id)
            } else {
                selectedIDs.insert(id)
            }
        }
    }

    private func createComposition() {
        let selectedClips = appState.clips.filter { selectedIDs.contains($0.id) }
        var composition = Composition.empty()

        // Distribute layers across the canvas with some variety
        for (index, clip) in selectedClips.enumerated() {
            var layer = VideoLayer.from(clip: clip, zIndex: index)

            // Distribute positions in a grid-like pattern
            let row = index / 3
            let col = index % 3
            let xOffset = 0.25 + CGFloat(col) * 0.25
            let yOffset = 0.25 + CGFloat(row) * 0.2

            layer.position = CGPoint(
                x: min(0.85, max(0.15, xOffset)),
                y: min(0.85, max(0.15, yOffset))
            )

            composition.addLayer(layer)
        }

        appState.composition = composition
        appState.navigate(to: .canvas)
        HapticsService.shared.success()
    }
}

#Preview {
    let appState = AppState()
    appState.clips = [
        VideoClip(url: URL(fileURLWithPath: "/test1.mov"), duration: 12, size: CGSize(width: 1920, height: 1080)),
        VideoClip(url: URL(fileURLWithPath: "/test2.mov"), duration: 8, size: CGSize(width: 1920, height: 1080)),
        VideoClip(url: URL(fileURLWithPath: "/test3.jpg"), duration: 1, isVideo: false, size: CGSize(width: 1920, height: 1080)),
    ]

    return ContactSheetView()
        .environment(appState)
}
