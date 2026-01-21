import SwiftUI

/// Main composition workspace
struct CanvasView: View {
    @Environment(AppState.self) var appState
    @State private var showingSettings = false
    @State private var isPlaying = false
    @State private var currentTime: Double = 0

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.backgroundPrimary
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        // Canvas area
                        canvasArea(in: geometry.size)
                            .frame(maxHeight: geometry.size.height * 0.6)

                        Spacer()

                        // Playback controls
                        if let composition = appState.composition {
                            PlaybackControls(
                                isPlaying: $isPlaying,
                                currentTime: $currentTime,
                                duration: composition.duration(clips: appState.clips),
                                onSeek: { time in
                                    currentTime = time
                                }
                            )
                        }

                        // Settings panel
                        if showingSettings {
                            settingsPanel
                                .transition(.slideUp)
                        }
                    }
                }
            }
            .navigationTitle("Canvas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        appState.navigate(to: .contactSheet)
                    }
                    .foregroundColor(.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: Spacing.md) {
                        Button {
                            withAnimation(.smooth) {
                                showingSettings.toggle()
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.textPrimary)
                        }

                        Button("Export") {
                            appState.navigate(to: .export)
                        }
                        .foregroundColor(.stackAccent)
                    }
                }
            }
            .toolbarBackground(Color.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func canvasArea(in containerSize: CGSize) -> some View {
        guard let composition = appState.composition else {
            Text("No composition")
                .foregroundColor(.textSecondary)
            return
        }

        let canvasSize = composition.canvasSize.fittedSize(
            in: CGSize(
                width: containerSize.width - Spacing.lg * 2,
                height: containerSize.height * 0.55
            )
        )

        ZStack {
            // Canvas background
            Rectangle()
                .fill(Color.backgroundSecondary)
                .frame(width: canvasSize.width, height: canvasSize.height)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            // Video layers
            ForEach(composition.sortedStack) { layer in
                if let clip = appState.clip(for: layer) {
                    VideoLayerView(
                        layer: layer,
                        clip: clip,
                        canvasSize: canvasSize,
                        isSelected: appState.selectedLayerID == layer.id,
                        onSelect: {
                            appState.selectedLayerID = layer.id
                        },
                        onPositionChange: { newPosition in
                            updateLayerPosition(layer.id, position: newPosition)
                        },
                        onSizeChange: { newSize in
                            updateLayerSize(layer.id, size: newSize)
                        }
                    )
                }
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .clipShape(Rectangle())
        .contentShape(Rectangle())
        .onTapGesture {
            appState.selectedLayerID = nil
        }
        .padding(Spacing.lg)
    }

    private var settingsPanel: some View {
        UtilityPanel(isExpanded: $showingSettings) {
            if var composition = appState.composition {
                CanvasSettingsPanel(
                    canvasSize: Binding(
                        get: { composition.canvasSize },
                        set: { newValue in
                            composition.canvasSize = newValue
                            appState.composition = composition
                        }
                    ),
                    loopEnabled: Binding(
                        get: { composition.loopEnabled },
                        set: { newValue in
                            composition.loopEnabled = newValue
                            appState.composition = composition
                        }
                    ),
                    snapToGridEnabled: Binding(
                        get: { composition.snapToGridEnabled },
                        set: { newValue in
                            composition.snapToGridEnabled = newValue
                            appState.composition = composition
                        }
                    )
                )
            }
        }
    }

    private func updateLayerPosition(_ id: UUID, position: CGPoint) {
        guard var composition = appState.composition,
              let index = composition.layers.firstIndex(where: { $0.id == id }) else { return }
        composition.layers[index].position = position
        appState.composition = composition
    }

    private func updateLayerSize(_ id: UUID, size: CGSize) {
        guard var composition = appState.composition,
              let index = composition.layers.firstIndex(where: { $0.id == id }) else { return }
        composition.layers[index].size = size
        appState.composition = composition
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

    return CanvasView()
        .environment(appState)
}
