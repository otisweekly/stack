import SwiftUI

/// Secondary action button with white border outline
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.fujiLabel)
            }
            .foregroundColor(.stackWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.stackWhite, lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        SecondaryButton("Cancel") {
            print("Tapped")
        }

        SecondaryButton("Back", icon: "chevron.left") {
            print("Tapped")
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
