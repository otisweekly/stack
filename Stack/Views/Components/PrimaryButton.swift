import SwiftUI

/// Primary action button with teal accent background
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isEnabled: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.fujiLabel)
            }
            .foregroundColor(isEnabled ? .stackBlack : .stackBlack.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(isEnabled ? Color.stackAccent : Color.stackAccent.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        PrimaryButton("Import Media", icon: "plus") {
            print("Tapped")
        }

        PrimaryButton("Continue", isEnabled: true) {
            print("Tapped")
        }

        PrimaryButton("Disabled", isEnabled: false) {
            print("Tapped")
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
