import SwiftUI

/// Badge indicating media type (video or image)
struct MediaTypeBadge: View {
    let isVideo: Bool

    var body: some View {
        Image(systemName: isVideo ? "video.fill" : "photo.fill")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.stackWhite)
            .padding(6)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        HStack(spacing: Spacing.lg) {
            MediaTypeBadge(isVideo: true)
            MediaTypeBadge(isVideo: false)
        }
    }
}
