import SwiftUI

struct ContactSheetView: View {
    @Environment(AppState.self) var appState
    @State private var selectedIDs: Set<UUID> = []

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    HapticsService.shared.light()
                    appState.currentScreen = .import_
                    appState.mediaItems = []
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.fujiBody)
                    .foregroundColor(.textPrimary)
                }

                Spacer()

                Text("Select Media")
                    .font(.fujiHeadline)
                    .foregroundColor(.textPrimary)

                Spacer()

                Button {
                    HapticsService.shared.medium()
                    createComposition()
                } label: {
                    Text("Done")
                        .font(.fujiLabel)
                        .foregroundColor(selectedIDs.count >= 1 ? .stackAccent : .textDisabled)
                }
                .disabled(selectedIDs.count < 1)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)

            Divider()
                .background(Color.border)

            // Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: Spacing.xs) {
                    ForEach(appState.mediaItems) { item in
                        ThumbnailCell(
                            item: item,
                            isSelected: selectedIDs.contains(item.id)
                        ) {
                            toggleSelection(item.id)
                        }
                    }
                }
                .padding(Spacing.xs)
            }

            Divider()
                .background(Color.border)

            // Footer
            VStack(spacing: Spacing.md) {
                Text("\(selectedIDs.count) selected")
                    .font(.fujiBodySmall)
                    .foregroundColor(.textSecondary)

                PrimaryButton("Continue to Canvas", isEnabled: selectedIDs.count >= 1) {
                    HapticsService.shared.medium()
                    createComposition()
                }
                .padding(.horizontal, Spacing.md)
            }
            .padding(.vertical, Spacing.md)
            .background(.ultraThinMaterial)
        }
        .background(Color.backgroundPrimary)
        .tabBarPadding()
        .onAppear {
            // Select all by default
            selectedIDs = Set(appState.mediaItems.map(\.id))
        }
    }

    private func toggleSelection(_ id: UUID) {
        HapticsService.shared.light()
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func createComposition() {
        let selectedItems = appState.mediaItems.filter { selectedIDs.contains($0.id) }
        var composition = Composition.empty()

        for (index, item) in selectedItems.enumerated() {
            let layer = MediaLayer.from(media: item, zIndex: index)
            composition.addLayer(layer)
        }

        appState.composition = composition
        appState.currentScreen = .canvas
        HapticsService.shared.success()
    }
}

// MARK: - Thumbnail Cell

struct ThumbnailCell: View {
    let item: MediaItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Thumbnail
                if let thumbnailURL = item.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderView
                        case .empty:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }

                // Overlays
                VStack {
                    HStack {
                        // Media type badge
                        MediaTypeBadge(isVideo: item.isVideo)
                            .padding(Spacing.xxs)

                        Spacer()

                        // Selection checkbox
                        SelectionCheckbox(isSelected: isSelected)
                            .padding(Spacing.xxs)
                    }

                    Spacer()

                    HStack {
                        Spacer()

                        // Duration badge
                        DurationBadge(text: item.formattedDuration)
                            .padding(Spacing.xxs)
                    }
                }
            }
            .aspectRatio(9/16, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(isSelected ? Color.stackAccent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.backgroundTertiary)
            .overlay(
                Image(systemName: item.isVideo ? "video" : "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.textSecondary)
            )
    }
}

#Preview {
    ContactSheetView()
        .environment(AppState())
}
