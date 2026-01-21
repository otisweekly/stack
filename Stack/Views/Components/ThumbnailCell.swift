import SwiftUI

/// Thumbnail cell for contact sheet grid
struct ThumbnailCell: View {
    let thumbnailURL: URL?
    let duration: TimeInterval
    let isVideo: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GeometryReader { geometry in
                ZStack {
                    // Thumbnail image
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
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .cornerRadius(CornerRadius.sm)
                .overlay(
                    // Selection border
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .stroke(isSelected ? Color.stackAccent : Color.clear, lineWidth: 2)
                )
                .overlay(alignment: .topLeading) {
                    // Media type badge
                    MediaTypeBadge(isVideo: isVideo)
                        .padding(Spacing.xxs)
                }
                .overlay(alignment: .topTrailing) {
                    // Selection checkbox
                    if isSelected {
                        SelectionCheckbox(isSelected: true)
                            .padding(Spacing.xxs)
                            .transition(.pop)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    // Duration or IMG badge
                    Group {
                        if isVideo {
                            DurationBadge(duration: duration)
                        } else {
                            Text("IMG")
                                .font(.mono)
                                .foregroundColor(.stackWhite)
                                .padding(.horizontal, Spacing.xs)
                                .padding(.vertical, Spacing.xxs)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                        }
                    }
                    .padding(Spacing.xxs)
                }
            }
            .aspectRatio(9/16, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        HStack(spacing: Spacing.xs) {
            ThumbnailCell(
                thumbnailURL: nil,
                duration: 12,
                isVideo: true,
                isSelected: false,
                onTap: {}
            )
            .frame(width: 100)

            ThumbnailCell(
                thumbnailURL: nil,
                duration: 0,
                isVideo: false,
                isSelected: true,
                onTap: {}
            )
            .frame(width: 100)
        }
        .padding()
    }
}
