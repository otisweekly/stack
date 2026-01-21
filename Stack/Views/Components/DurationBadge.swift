import SwiftUI

/// Badge displaying video duration in MM:SS format
struct DurationBadge: View {
    let duration: TimeInterval

    private var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        Text(formattedDuration)
            .font(.mono)
            .foregroundColor(.stackWhite)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        VStack(spacing: Spacing.md) {
            DurationBadge(duration: 12)
            DurationBadge(duration: 65)
            DurationBadge(duration: 185)
        }
    }
}
