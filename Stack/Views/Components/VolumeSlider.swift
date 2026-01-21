import SwiftUI

/// Volume slider for audio mixer with thumbnail preview
struct VolumeSlider: View {
    @Binding var volume: Float  // 0.0 to 1.0
    let thumbnailURL: URL?

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Thumbnail
            ZStack {
                if let url = thumbnailURL {
                    AsyncImage(url: url) { image in
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
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            .overlay(
                // Mute indicator
                Group {
                    if volume == 0 {
                        Image(systemName: "speaker.slash.fill")
                            .foregroundColor(.stackWhite)
                            .padding(Spacing.xxs)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            )

            // Volume slider
            Slider(value: Binding(
                get: { Double(volume) },
                set: { volume = Float($0) }
            ), in: 0...1)
                .tint(.stackAccent)
                .frame(width: 80)

            // Percentage
            Text("\(Int(volume * 100))%")
                .font(.fujiCaptionSmall)
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        HStack(spacing: Spacing.md) {
            VolumeSlider(volume: .constant(0.8), thumbnailURL: nil)
            VolumeSlider(volume: .constant(0), thumbnailURL: nil)
            VolumeSlider(volume: .constant(1.0), thumbnailURL: nil)
        }
    }
}
