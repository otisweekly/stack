import SwiftUI

/// Settings panel for canvas configuration
struct CanvasSettingsPanel: View {
    @Binding var canvasSize: CanvasSize
    @Binding var loopEnabled: Bool
    @Binding var snapToGridEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Settings")
                .font(.fujiHeadline)
                .foregroundColor(.textPrimary)

            // Canvas Size
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Canvas Size")
                    .font(.fujiLabel)
                    .foregroundColor(.textSecondary)

                Picker("Canvas Size", selection: $canvasSize) {
                    ForEach(CanvasSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.segmented)
                .tint(.stackAccent)
            }

            // Loop Videos Toggle
            Toggle(isOn: $loopEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Loop Videos")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)
                    Text("Continuously replay videos")
                        .font(.fujiCaption)
                        .foregroundColor(.textSecondary)
                }
            }
            .tint(.stackAccent)

            // Snap to Grid Toggle
            Toggle(isOn: $snapToGridEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Snap to Grid")
                        .font(.fujiBody)
                        .foregroundColor(.textPrimary)
                    Text("Align layers to grid")
                        .font(.fujiCaption)
                        .foregroundColor(.textSecondary)
                }
            }
            .tint(.stackAccent)
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        VStack {
            Spacer()
            UtilityPanel(isExpanded: .constant(true)) {
                CanvasSettingsPanel(
                    canvasSize: .constant(.portrait9x16),
                    loopEnabled: .constant(true),
                    snapToGridEnabled: .constant(false)
                )
            }
        }
    }
}
