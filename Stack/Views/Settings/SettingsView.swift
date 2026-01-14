import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var state = appState

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Header
                Text("Settings")
                    .font(.fujiDisplay)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Spacing.md)

                // Audio Mixer Section
                if let composition = appState.composition, !composition.layers.isEmpty {
                    AudioMixerSection(appState: appState)
                }

                // Defaults Section
                DefaultsSection(settings: $state.settings)

                // About Section
                AboutSection()
            }
            .padding(.top, Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundPrimary)
        .tabBarPadding()
        .onChange(of: appState.settings) { _, _ in
            appState.saveSettings()
        }
    }
}

// MARK: - Audio Mixer Section

struct AudioMixerSection: View {
    let appState: AppState

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Audio Mixer")
                .font(.fujiHeadline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)

            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(appState.composition?.layers ?? []) { layer in
                    if let item = appState.mediaItem(for: layer) {
                        AudioMixerCell(
                            layer: layer,
                            item: item,
                            onVolumeChange: { volume in
                                appState.setVolume(volume, for: layer.id)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

struct AudioMixerCell: View {
    let layer: MediaLayer
    let item: MediaItem
    let onVolumeChange: (Float) -> Void

    @State private var volume: Float

    init(layer: MediaLayer, item: MediaItem, onVolumeChange: @escaping (Float) -> Void) {
        self.layer = layer
        self.item = item
        self.onVolumeChange = onVolumeChange
        self._volume = State(initialValue: layer.audioVolume)
    }

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Thumbnail
            ZStack {
                if let thumbnailURL = item.thumbnailURL {
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

                // Mute indicator
                if volume == 0 {
                    Color.black.opacity(0.5)
                    Image(systemName: "speaker.slash.fill")
                        .foregroundColor(.stackWhite)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))

            // Volume control (only for videos)
            if item.isVideo {
                Slider(value: $volume, in: 0...1)
                    .tint(.stackAccent)
                    .frame(width: 80)
                    .onChange(of: volume) { _, newVolume in
                        onVolumeChange(newVolume)
                    }

                Text("\(Int(volume * 100))%")
                    .font(.fujiCaptionSmall)
                    .foregroundColor(.textSecondary)
            } else {
                Text("IMG")
                    .font(.fujiCaptionSmall)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Defaults Section

struct DefaultsSection: View {
    @Binding var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Defaults")
                .font(.fujiHeadline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)

            VStack(spacing: Spacing.sm) {
                // Image Duration
                HStack {
                    Text("Image Duration")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Picker("", selection: $settings.defaultImageDuration) {
                        Text("0.5s").tag(0.5)
                        Text("1s").tag(1.0)
                        Text("2s").tag(2.0)
                        Text("3s").tag(3.0)
                        Text("5s").tag(5.0)
                    }
                    .pickerStyle(.menu)
                    .tint(.stackAccent)
                }

                Divider()
                    .background(Color.border)

                // Default Canvas Size
                HStack {
                    Text("Default Canvas")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Picker("", selection: $settings.defaultCanvasSize) {
                        ForEach(CanvasSize.allCases) { size in
                            Text(size.displayName).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.stackAccent)
                }

                Divider()
                    .background(Color.border)

                // Loop Media
                HStack {
                    Text("Loop Media")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Toggle("", isOn: $settings.loopMediaByDefault)
                        .tint(.stackAccent)
                }
            }
            .padding(Spacing.md)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - About Section

struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("About")
                .font(.fujiHeadline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Version")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text("1.0.0")
                        .font(.fujiBody)
                        .foregroundColor(.textSecondary)
                }

                Divider()
                    .background(Color.border)

                HStack {
                    Text("Made with")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text("SwiftUI + AVFoundation")
                        .font(.fujiBody)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(Spacing.md)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .padding(.horizontal, Spacing.md)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
