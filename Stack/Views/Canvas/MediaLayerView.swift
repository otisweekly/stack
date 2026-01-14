import SwiftUI

struct MediaLayerView: View {
    let layer: MediaLayer
    let item: MediaItem
    let canvasSize: CGSize
    let isSelected: Bool
    let onSelect: () -> Void
    let onPositionChange: (CGPoint) -> Void
    let onSizeChange: (CGSize) -> Void
    let onDelete: () -> Void
    let onBringToFront: () -> Void
    let onSendToBack: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var showContextMenu = false

    private var pixelFrame: CGRect {
        layer.pixelFrame(in: canvasSize)
    }

    var body: some View {
        ZStack {
            // Media content
            mediaContent
                .frame(
                    width: pixelFrame.width * currentScale,
                    height: pixelFrame.height * currentScale
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xs))

            // Selection border
            if isSelected {
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .stroke(Color.stackAccent, lineWidth: 2)
                    .frame(
                        width: pixelFrame.width * currentScale,
                        height: pixelFrame.height * currentScale
                    )

                // Resize handles
                ResizeHandlesView(
                    frameSize: CGSize(
                        width: pixelFrame.width * currentScale,
                        height: pixelFrame.height * currentScale
                    )
                )
            }
        }
        .position(
            x: layer.position.x * canvasSize.width + dragOffset.width,
            y: layer.position.y * canvasSize.height + dragOffset.height
        )
        .gesture(tapGesture)
        .gesture(dragGesture)
        .gesture(magnificationGesture)
        .contextMenu {
            Button {
                onBringToFront()
            } label: {
                Label("Bring to Front", systemImage: "square.3.layers.3d.top.filled")
            }

            Button {
                onSendToBack()
            } label: {
                Label("Send to Back", systemImage: "square.3.layers.3d.bottom.filled")
            }

            Divider()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .zIndex(Double(layer.zIndex))
    }

    @ViewBuilder
    private var mediaContent: some View {
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
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.backgroundTertiary)
            .overlay(
                Image(systemName: item.isVideo ? "video.fill" : "photo.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.textSecondary)
            )
    }

    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                onSelect()
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let newPosition = CGPoint(
                    x: layer.position.x + value.translation.width / canvasSize.width,
                    y: layer.position.y + value.translation.height / canvasSize.height
                )
                onPositionChange(newPosition)
                dragOffset = .zero
                HapticsService.shared.light()
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                currentScale = value
            }
            .onEnded { value in
                let newSize = CGSize(
                    width: layer.size.width * value,
                    height: layer.size.height * value
                )
                onSizeChange(newSize)
                currentScale = 1.0
                HapticsService.shared.light()
            }
    }
}

// MARK: - Resize Handles

struct ResizeHandlesView: View {
    let frameSize: CGSize
    let handleSize: CGFloat = 12

    var body: some View {
        ZStack {
            // Corner handles
            ForEach(Corner.allCases, id: \.self) { corner in
                Circle()
                    .fill(Color.stackAccent)
                    .frame(width: handleSize, height: handleSize)
                    .position(position(for: corner))
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
    }

    private func position(for corner: Corner) -> CGPoint {
        switch corner {
        case .topLeft:
            return CGPoint(x: 0, y: 0)
        case .topRight:
            return CGPoint(x: frameSize.width, y: 0)
        case .bottomLeft:
            return CGPoint(x: 0, y: frameSize.height)
        case .bottomRight:
            return CGPoint(x: frameSize.width, y: frameSize.height)
        }
    }

    enum Corner: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()

        ResizeHandlesView(frameSize: CGSize(width: 200, height: 300))
    }
}
