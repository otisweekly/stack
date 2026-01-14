import SwiftUI

struct CanvasView: View {
    @Environment(AppState.self) var appState
    @State private var viewModel: CompositionViewModel?
    @State private var showingUtilityPanel = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()

                if let vm = viewModel {
                    VStack(spacing: 0) {
                        // Header
                        canvasHeader(viewModel: vm)

                        // Canvas area
                        canvasArea(in: geometry.size, viewModel: vm)
                            .frame(maxHeight: .infinity)

                        // Playback controls
                        PlaybackControlsView(viewModel: vm)

                        // Utility panel toggle
                        if showingUtilityPanel {
                            UtilityPanelContent(viewModel: vm, isExpanded: $showingUtilityPanel)
                                .transition(.slideUp)
                        }
                    }
                    .tabBarPadding()
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .stackAccent))
                }
            }
        }
        .onAppear {
            if let composition = appState.composition {
                viewModel = CompositionViewModel(
                    composition: composition,
                    mediaItems: appState.mediaItems
                )
            }
        }
        .onChange(of: viewModel?.composition) { _, newComposition in
            if let newComposition = newComposition {
                appState.composition = newComposition
            }
        }
    }

    @ViewBuilder
    private func canvasHeader(viewModel: CompositionViewModel) -> some View {
        HStack {
            Button {
                HapticsService.shared.light()
                appState.currentScreen = .contactSheet
            } label: {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.fujiBody)
                .foregroundColor(.textPrimary)
            }

            Spacer()

            Button {
                HapticsService.shared.light()
                showingUtilityPanel.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20))
                    .foregroundColor(.textPrimary)
            }

            Spacer()

            Button {
                HapticsService.shared.medium()
                appState.currentScreen = .export
            } label: {
                Text("Export")
                    .font(.fujiLabel)
                    .foregroundColor(.stackAccent)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    @ViewBuilder
    private func canvasArea(in containerSize: CGSize, viewModel: CompositionViewModel) -> some View {
        let canvasSize = viewModel.composition.canvasSize.fittedSize(
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
                        .stroke(Color.border, lineWidth: 1)
                )

            // Media layers
            ForEach(viewModel.composition.sortedLayers) { layer in
                if let item = viewModel.mediaItem(for: layer) {
                    MediaLayerView(
                        layer: layer,
                        item: item,
                        canvasSize: canvasSize,
                        isSelected: viewModel.selectedLayerID == layer.id,
                        onSelect: { viewModel.selectLayer(layer.id) },
                        onPositionChange: { viewModel.updateLayerPosition(layer.id, position: $0) },
                        onSizeChange: { viewModel.updateLayerSize(layer.id, size: $0) },
                        onDelete: { viewModel.deleteLayer(layer.id) },
                        onBringToFront: { viewModel.bringToFront(layer.id) },
                        onSendToBack: { viewModel.sendToBack(layer.id) }
                    )
                }
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectLayer(nil)
        }
    }
}

// MARK: - Utility Panel Content

struct UtilityPanelContent: View {
    @Bindable var viewModel: CompositionViewModel
    @Binding var isExpanded: Bool

    var body: some View {
        UtilityPanel(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Canvas Size
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Canvas Size")
                        .font(.fujiLabel)
                        .foregroundColor(.textPrimary)

                    HStack(spacing: Spacing.xs) {
                        ForEach(CanvasSize.allCases) { size in
                            Button {
                                viewModel.updateCanvasSize(size)
                            } label: {
                                Text(size.displayName)
                                    .font(.fujiLabelSmall)
                                    .foregroundColor(viewModel.composition.canvasSize == size ? .stackBlack : .textPrimary)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(viewModel.composition.canvasSize == size ? Color.stackAccent : Color.backgroundTertiary)
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                            }
                        }
                    }
                }

                // Loop toggle
                HStack {
                    Text("Loop Media")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Toggle("", isOn: $viewModel.composition.loopMedia)
                        .tint(.stackAccent)
                }
            }
        }
    }
}

#Preview {
    CanvasView()
        .environment(AppState())
}
