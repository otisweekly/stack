import SwiftUI

/// Export configuration and progress screen
struct ExportView: View {
    @Environment(AppState.self) var appState
    @State private var exportSettings = ExportSettings()
    @State private var showingExportProgress = false

    private var estimatedDuration: TimeInterval {
        appState.composition?.duration(clips: appState.clips) ?? 0
    }

    private var estimatedFileSizeMB: Double {
        guard let composition = appState.composition else { return 0 }
        return exportSettings.estimatedFileSizeMB(
            duration: estimatedDuration,
            canvasSize: composition.canvasSize
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                // Preview area
                previewArea

                // Settings
                settingsSection

                Spacer()

                // Export button
                PrimaryButton("Export Video", icon: "square.and.arrow.up") {
                    startExport()
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Export Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        appState.navigate(to: .canvas)
                    }
                    .foregroundColor(.textPrimary)
                }
            }
            .toolbarBackground(Color.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingExportProgress) {
                ExportProgressView(
                    progress: appState.exportProgress,
                    onCancel: cancelExport
                )
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var previewArea: some View {
        ZStack {
            if let composition = appState.composition {
                let previewSize = composition.canvasSize.fittedSize(
                    in: CGSize(width: 280, height: 200)
                )

                Rectangle()
                    .fill(Color.backgroundSecondary)
                    .frame(width: previewSize.width, height: previewSize.height)
                    .overlay(
                        Rectangle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .overlay {
                        // Layer previews
                        ForEach(composition.sortedStack) { layer in
                            if let clip = appState.clip(for: layer) {
                                previewLayer(layer: layer, clip: clip, canvasSize: previewSize)
                            }
                        }
                    }
            }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundPrimary)
    }

    @ViewBuilder
    private func previewLayer(layer: VideoLayer, clip: VideoClip, canvasSize: CGSize) -> some View {
        let frame = layer.pixelFrame(in: canvasSize)

        ZStack {
            if let thumbnailURL = clip.thumbnailURL {
                AsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.backgroundTertiary
                }
            } else {
                Color.backgroundTertiary
            }
        }
        .frame(width: frame.width, height: frame.height)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .position(
            x: layer.position.x * canvasSize.width,
            y: layer.position.y * canvasSize.height
        )
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Resolution picker
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Resolution")
                    .font(.fujiLabel)
                    .foregroundColor(.textSecondary)

                ForEach(ExportResolution.allCases) { resolution in
                    resolutionOption(resolution)
                }
            }
            .padding(.horizontal, Spacing.lg)

            // Info section
            VStack(alignment: .leading, spacing: Spacing.xs) {
                infoRow(label: "Estimated Size", value: String(format: "~%.0f MB", estimatedFileSizeMB))
                infoRow(label: "Duration", value: formatDuration(estimatedDuration))

                if let composition = appState.composition {
                    let res = exportSettings.resolution == .uhd4K
                        ? composition.canvasSize.resolution4K
                        : composition.canvasSize.resolution1080p
                    infoRow(label: "Output Size", value: "\(Int(res.width))×\(Int(res.height))")
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func resolutionOption(_ resolution: ExportResolution) -> some View {
        Button {
            exportSettings.resolution = resolution
            HapticsService.shared.light()
        } label: {
            HStack {
                Circle()
                    .fill(exportSettings.resolution == resolution ? Color.stackAccent : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(
                                exportSettings.resolution == resolution ? Color.stackAccent : Color.textSecondary,
                                lineWidth: 2
                            )
                    )

                VStack(alignment: .leading) {
                    Text(resolution.displayName)
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)

                    if let composition = appState.composition {
                        let res = resolution == .uhd4K
                            ? composition.canvasSize.resolution4K
                            : composition.canvasSize.resolution1080p
                        Text("\(Int(res.width))×\(Int(res.height))")
                            .font(.fujiCaption)
                            .foregroundColor(.textSecondary)
                    }
                }

                Spacer()
            }
            .padding(Spacing.sm)
            .background(Color.backgroundSecondary)
            .cornerRadius(CornerRadius.md)
        }
        .buttonStyle(.plain)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.fujiBody)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.mono)
                .foregroundColor(.textPrimary)
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    private func startExport() {
        HapticsService.shared.medium()
        appState.isExporting = true
        appState.exportProgress = 0
        showingExportProgress = true

        // Simulate export progress
        Task {
            for i in 1...100 {
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
                await MainActor.run {
                    appState.exportProgress = Double(i) / 100.0
                }
            }

            await MainActor.run {
                appState.isExporting = false
                showingExportProgress = false
                HapticsService.shared.success()
            }
        }
    }

    private func cancelExport() {
        appState.isExporting = false
        showingExportProgress = false
        HapticsService.shared.warning()
    }
}

/// Export progress modal
struct ExportProgressView: View {
    let progress: Double
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Exporting Video")
                .font(.fujiHeadline)
                .foregroundColor(.textPrimary)

            // Progress bar
            VStack(spacing: Spacing.sm) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.backgroundTertiary)
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(Color.stackAccent)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)

                Text("\(Int(progress * 100))%")
                    .font(.mono)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, Spacing.xl)

            SecondaryButton("Cancel") {
                onCancel()
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
    }
}

#Preview {
    let appState = AppState()
    let clip1 = VideoClip(url: URL(fileURLWithPath: "/test1.mov"), duration: 12, size: CGSize(width: 1920, height: 1080))
    let clip2 = VideoClip(url: URL(fileURLWithPath: "/test2.mov"), duration: 8, size: CGSize(width: 1920, height: 1080))
    appState.clips = [clip1, clip2]
    var composition = Composition.empty()
    composition.addLayer(VideoLayer.from(clip: clip1, zIndex: 0))
    composition.addLayer(VideoLayer.from(clip: clip2, zIndex: 1))
    appState.composition = composition

    return ExportView()
        .environment(appState)
}
