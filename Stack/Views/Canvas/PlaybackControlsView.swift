import SwiftUI
import AVFoundation

struct PlaybackControlsView: View {
    @Bindable var viewModel: CompositionViewModel
    @State private var sliderValue: Double = 0

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Transport controls
            HStack(spacing: Spacing.xl) {
                Button {
                    HapticsService.shared.light()
                    // Seek backward 5 seconds
                    let newTime = max(0, viewModel.currentTime.seconds - 5)
                    viewModel.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
                } label: {
                    Image(systemName: "gobackward.5")
                        .font(.system(size: 20))
                }

                Button {
                    viewModel.togglePlay()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                }

                Button {
                    HapticsService.shared.light()
                    // Seek forward 5 seconds
                    let newTime = min(viewModel.totalDuration, viewModel.currentTime.seconds + 5)
                    viewModel.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
                } label: {
                    Image(systemName: "goforward.5")
                        .font(.system(size: 20))
                }
            }
            .foregroundColor(.textPrimary)

            // Timeline slider
            HStack(spacing: Spacing.sm) {
                Text(viewModel.currentTime.displayString)
                    .font(.mono)
                    .foregroundColor(.textSecondary)
                    .frame(width: 45, alignment: .trailing)

                Slider(
                    value: $sliderValue,
                    in: 0...max(viewModel.totalDuration, 1),
                    onEditingChanged: { editing in
                        if !editing {
                            viewModel.seek(to: CMTime(seconds: sliderValue, preferredTimescale: 600))
                        }
                    }
                )
                .tint(.stackAccent)

                Text(viewModel.totalDuration.displayString)
                    .font(.mono)
                    .foregroundColor(.textSecondary)
                    .frame(width: 45, alignment: .leading)
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.md)
        .background(.ultraThinMaterial)
        .onChange(of: viewModel.currentTime) { _, newTime in
            sliderValue = newTime.seconds
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()

        VStack {
            Spacer()
            PlaybackControlsView(
                viewModel: CompositionViewModel(
                    composition: .empty(),
                    mediaItems: []
                )
            )
        }
    }
}
