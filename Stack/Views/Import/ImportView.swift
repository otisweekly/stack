import SwiftUI
import PhotosUI

/// Entry point screen for importing media
struct ImportView: View {
    @Environment(AppState.self) var appState
    @State private var showingPicker = false
    @State private var isLoading = false
    @State private var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Import icon
            Image(systemName: "video.badge.plus")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.textSecondary)

            // Title
            Text("Stack")
                .font(.fujiDisplay)
                .foregroundColor(.textPrimary)

            // Subtitle
            Text("Create video collages that move together")
                .font(.fujiBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Spacer()

            // Import button
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 12,
                matching: .any(of: [.videos, .images]),
                preferredItemEncoding: .current
            ) {
                HStack(spacing: Spacing.xs) {
                    if isLoading {
                        ProgressView()
                            .tint(.stackBlack)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(isLoading ? "Importing..." : "Import Media")
                        .font(.fujiLabel)
                }
                .foregroundColor(.stackBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.stackAccent)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
            .disabled(isLoading)
            .padding(.horizontal, Spacing.xl)

            Spacer()
                .frame(height: Spacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
        .onChange(of: selectedItems) { oldValue, newValue in
            if !newValue.isEmpty {
                handleSelection(newValue)
            }
        }
    }

    private func handleSelection(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }

        isLoading = true
        HapticsService.shared.medium()

        Task {
            var clips: [VideoClip] = []

            for item in items {
                do {
                    let clip = try await loadClip(from: item)
                    clips.append(clip)
                } catch {
                    print("Failed to load item: \(error)")
                }
            }

            await MainActor.run {
                isLoading = false
                selectedItems = []

                if !clips.isEmpty {
                    appState.clips = clips
                    appState.navigate(to: .contactSheet)
                    HapticsService.shared.success()
                } else {
                    HapticsService.shared.error()
                }
            }
        }
    }

    private func loadClip(from item: PhotosPickerItem) async throws -> VideoClip {
        // Check if it's a video
        if let movie = try? await item.loadTransferable(type: VideoTransferable.self) {
            return VideoClip(
                url: movie.url,
                thumbnailURL: nil,  // Would generate thumbnail here
                duration: 10.0,     // Would get actual duration from AVAsset
                isVideo: true,
                size: CGSize(width: 1920, height: 1080)
            )
        }

        // Check if it's an image
        if let imageData = try? await item.loadTransferable(type: Data.self) {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".jpg")
            try imageData.write(to: tempURL)

            return VideoClip(
                url: tempURL,
                thumbnailURL: tempURL,
                duration: 1.0,  // Default image duration
                isVideo: false,
                size: CGSize(width: 1920, height: 1080)
            )
        }

        throw ImportError.unsupportedFormat
    }
}

enum ImportError: Error {
    case unsupportedFormat
    case loadFailed
}

/// Transferable type for video files
struct VideoTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".mov")
            try FileManager.default.copyItem(at: received.file, to: tempURL)
            return VideoTransferable(url: tempURL)
        }
    }
}

#Preview {
    ImportView()
        .environment(AppState())
}
