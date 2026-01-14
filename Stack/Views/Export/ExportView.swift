import SwiftUI

struct ExportView: View {
    @Environment(AppState.self) var appState
    @State private var settings = ExportSettings()
    @State private var isExporting = false
    @State private var exportProgress: Double = 0
    @State private var exportError: String?
    @State private var showingError = false
    @State private var showingSuccess = false

    private var duration: TimeInterval {
        appState.composition?.calculateDuration(with: appState.mediaItems) ?? 0
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        HapticsService.shared.light()
                        appState.currentScreen = .canvas
                    } label: {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)
                    }

                    Spacer()

                    Text("Export")
                        .font(.fujiHeadline)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    // Spacer for alignment
                    Text("Back")
                        .font(.fujiBody)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Preview
                        previewSection

                        // Resolution picker
                        resolutionSection

                        // Info
                        infoSection
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.lg)
                }

                // Export button
                VStack(spacing: Spacing.md) {
                    PrimaryButton("Export Video", icon: "square.and.arrow.up") {
                        startExport()
                    }
                }
                .padding(Spacing.md)
                .background(.ultraThinMaterial)
            }
            .tabBarPadding()

            // Export progress overlay
            if isExporting {
                ExportProgressOverlay(
                    progress: exportProgress,
                    onCancel: cancelExport
                )
            }
        }
        .alert("Export Failed", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportError ?? "Unknown error occurred")
        }
        .alert("Export Complete", isPresented: $showingSuccess) {
            Button("Done") {
                appState.reset()
                appState.currentTab = .create
            }
        } message: {
            Text("Your video has been saved to your photo library.")
        }
    }

    // MARK: - Preview Section

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Preview")
                .font(.fujiLabel)
                .foregroundColor(.textSecondary)

            // Canvas preview
            if let composition = appState.composition {
                let previewSize = composition.canvasSize.fittedSize(
                    in: CGSize(width: UIScreen.main.bounds.width - Spacing.md * 2, height: 300)
                )

                ZStack {
                    Rectangle()
                        .fill(Color.backgroundSecondary)

                    // Layers preview
                    ForEach(composition.sortedLayers) { layer in
                        if let item = appState.mediaItem(for: layer) {
                            PreviewLayerView(layer: layer, item: item, canvasSize: previewSize)
                        }
                    }
                }
                .frame(width: previewSize.width, height: previewSize.height)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(Color.border, lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Resolution Section

    private var resolutionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Resolution")
                .font(.fujiLabel)
                .foregroundColor(.textSecondary)

            VStack(spacing: 0) {
                ForEach(ExportResolution.allCases) { resolution in
                    Button {
                        HapticsService.shared.light()
                        settings.resolution = resolution
                    } label: {
                        HStack {
                            Circle()
                                .fill(settings.resolution == resolution ? Color.stackAccent : Color.clear)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(settings.resolution == resolution ? Color.stackAccent : Color.textSecondary, lineWidth: 2)
                                )

                            Text(resolution.displayName)
                                .font(.fujiBody)
                                .foregroundColor(.textPrimary)

                            Spacer()

                            if let size = appState.composition?.canvasSize.pixelSize(for: resolution) {
                                Text("\(Int(size.width))x\(Int(size.height))")
                                    .font(.fujiBodySmall)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding(Spacing.md)
                    }

                    if resolution != ExportResolution.allCases.last {
                        Divider()
                            .background(Color.border)
                    }
                }
            }
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Details")
                .font(.fujiLabel)
                .foregroundColor(.textSecondary)

            VStack(spacing: Spacing.sm) {
                HStack {
                    Text("Duration")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text(duration.displayString)
                        .font(.mono)
                        .foregroundColor(.textSecondary)
                }

                Divider()
                    .background(Color.border)

                HStack {
                    Text("Estimated Size")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text(settings.formattedEstimatedSize(duration: duration))
                        .font(.fujiBody)
                        .foregroundColor(.textSecondary)
                }

                Divider()
                    .background(Color.border)

                HStack {
                    Text("Layers")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text("\(appState.composition?.layers.count ?? 0)")
                        .font(.fujiBody)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(Spacing.md)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
    }

    // MARK: - Export Actions

    private func startExport() {
        guard let composition = appState.composition else { return }

        HapticsService.shared.medium()
        isExporting = true
        exportProgress = 0

        Task {
            do {
                _ = try await ExportService.shared.export(
                    composition: composition,
                    mediaItems: appState.mediaItems,
                    settings: settings
                ) { progress in
                    Task { @MainActor in
                        exportProgress = progress
                    }
                }

                await MainActor.run {
                    isExporting = false
                    HapticsService.shared.success()
                    showingSuccess = true
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportError = error.localizedDescription
                    HapticsService.shared.error()
                    showingError = true
                }
            }
        }
    }

    private func cancelExport() {
        ExportService.shared.cancel()
        isExporting = false
        HapticsService.shared.warning()
    }
}

// MARK: - Preview Layer View

struct PreviewLayerView: View {
    let layer: MediaLayer
    let item: MediaItem
    let canvasSize: CGSize

    private var frame: CGRect {
        layer.pixelFrame(in: canvasSize)
    }

    var body: some View {
        if let thumbnailURL = item.thumbnailURL {
            AsyncImage(url: thumbnailURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.backgroundTertiary
            }
            .frame(width: frame.width, height: frame.height)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xs))
            .position(x: layer.position.x * canvasSize.width, y: layer.position.y * canvasSize.height)
        }
    }
}

// MARK: - Export Progress Overlay

struct ExportProgressOverlay: View {
    let progress: Double
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                Text("Exporting Video")
                    .font(.fujiHeadline)
                    .foregroundColor(.textPrimary)

                VStack(spacing: Spacing.sm) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .stackAccent))
                        .frame(width: 200)

                    Text("\(Int(progress * 100))%")
                        .font(.mono)
                        .foregroundColor(.textSecondary)
                }

                SecondaryButton("Cancel") {
                    onCancel()
                }
                .frame(width: 120)
            }
            .padding(Spacing.xl)
            .liquidGlassBordered()
        }
    }
}

#Preview {
    ExportView()
        .environment(AppState())
}
