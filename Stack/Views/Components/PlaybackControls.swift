import SwiftUI

/// Playback transport controls with play/pause, scrubber, and timecode
struct PlaybackControls: View {
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    let duration: Double
    let onSeek: (Double) -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Transport controls
            HStack(spacing: Spacing.xl) {
                Button(action: { onSeek(max(0, currentTime - 5)) }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 20))
                }

                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28))
                }

                Button(action: { onSeek(min(duration, currentTime + 5)) }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                }
            }
            .foregroundColor(.textPrimary)

            // Timeline scrubber
            HStack(spacing: Spacing.sm) {
                Text(formatTime(currentTime))
                    .font(.mono)
                    .foregroundColor(.textSecondary)
                    .frame(width: 50, alignment: .trailing)

                Slider(value: $currentTime, in: 0...max(duration, 0.01)) { editing in
                    if !editing {
                        onSeek(currentTime)
                    }
                }
                .tint(.stackAccent)

                Text(formatTime(duration))
                    .font(.mono)
                    .foregroundColor(.textSecondary)
                    .frame(width: 50, alignment: .leading)
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(Spacing.md)
        .background(Color.backgroundSecondary)
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        VStack {
            Spacer()
            PlaybackControls(
                isPlaying: .constant(false),
                currentTime: .constant(15),
                duration: 30,
                onSeek: { _ in }
            )
        }
    }
}
