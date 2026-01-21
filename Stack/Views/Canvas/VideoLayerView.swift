import SwiftUI

/// Individual video layer on the canvas with drag and resize gestures
struct VideoLayerView: View {
    let layer: VideoLayer
    let clip: VideoClip
    let canvasSize: CGSize
    let isSelected: Bool
    let onSelect: () -> Void
    let onPositionChange: (CGPoint) -> Void
    let onSizeChange: (CGSize) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0

    private var pixelFrame: CGRect {
        layer.pixelFrame(in: canvasSize)
    }

    var body: some View {
        ZStack {
            // Video/Image content
            contentView
                .frame(
                    width: pixelFrame.width * currentScale,
                    height: pixelFrame.height * currentScale
                )
                .clipped()
                .cornerRadius(CornerRadius.sm)

            // Selection border
            if isSelected {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.stackAccent, lineWidth: 2)
                    .frame(
                        width: pixelFrame.width * currentScale,
                        height: pixelFrame.height * currentScale
                    )

                // Resize handles
                ResizeHandlesOverlay(
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
        .zIndex(Double(layer.zIndex))
    }

    @ViewBuilder
    private var contentView: some View {
        if let thumbnailURL = clip.thumbnailURL {
            AsyncImage(url: thumbnailURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                placeholderView
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        ZStack {
            Color.backgroundTertiary
            Image(systemName: clip.isVideo ? "video.fill" : "photo.fill")
                .font(.system(size: 24))
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Gestures

    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                onSelect()
                HapticsService.shared.selection()
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

/// Corner and edge resize handles
struct ResizeHandlesOverlay: View {
    let frameSize: CGSize
    private let handleSize: CGFloat = 12

    var body: some View {
        ZStack {
            // Corner handles
            ForEach(corners, id: \.self) { corner in
                Circle()
                    .fill(Color.stackAccent)
                    .frame(width: handleSize, height: handleSize)
                    .position(position(for: corner))
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
    }

    private var corners: [Corner] {
        [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    private enum Corner: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    private func position(for corner: Corner) -> CGPoint {
        switch corner {
        case .topLeft: return CGPoint(x: 0, y: 0)
        case .topRight: return CGPoint(x: frameSize.width, y: 0)
        case .bottomLeft: return CGPoint(x: 0, y: frameSize.height)
        case .bottomRight: return CGPoint(x: frameSize.width, y: frameSize.height)
        }
    }
}

#Preview {
    let clip = VideoClip(
        url: URL(fileURLWithPath: "/test.mov"),
        duration: 10,
        size: CGSize(width: 1920, height: 1080)
    )
    let layer = VideoLayer(
        clipID: clip.id,
        position: CGPoint(x: 0.5, y: 0.5),
        size: CGSize(width: 0.4, height: 0.4),
        zIndex: 0
    )

    return ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        VideoLayerView(
            layer: layer,
            clip: clip,
            canvasSize: CGSize(width: 300, height: 533),
            isSelected: true,
            onSelect: {},
            onPositionChange: { _ in },
            onSizeChange: { _ in }
        )
    }
}
