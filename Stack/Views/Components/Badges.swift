import SwiftUI

// MARK: - Duration Badge

struct DurationBadge: View {
    let text: String

    init(duration: TimeInterval) {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        self.text = String(format: "%d:%02d", minutes, seconds)
    }

    init(text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.mono)
            .foregroundColor(.stackWhite)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xs))
    }
}

// MARK: - Media Type Badge

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

// MARK: - Selection Checkbox

struct SelectionCheckbox: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.stackAccent : Color.clear)
                .frame(width: 24, height: 24)

            Circle()
                .stroke(isSelected ? Color.stackAccent : Color.white, lineWidth: 2)
                .frame(width: 24, height: 24)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.stackBlack)
            }
        }
    }
}

// MARK: - Layer Badge

struct LayerBadge: View {
    let index: Int

    var body: some View {
        Text("\(index)")
            .font(.fujiLabelSmall)
            .foregroundColor(.stackBlack)
            .frame(width: 24, height: 24)
            .background(Color.stackAccent)
            .clipShape(Circle())
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            DurationBadge(duration: 65)
            DurationBadge(text: "IMG")
        }

        HStack(spacing: 10) {
            MediaTypeBadge(isVideo: true)
            MediaTypeBadge(isVideo: false)
        }

        HStack(spacing: 10) {
            SelectionCheckbox(isSelected: true)
            SelectionCheckbox(isSelected: false)
        }

        HStack(spacing: 10) {
            LayerBadge(index: 1)
            LayerBadge(index: 2)
            LayerBadge(index: 3)
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
