import SwiftUI

// MARK: - Primary Button (Accent)

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isEnabled: Bool
    let action: () -> Void

    init(_ title: String, icon: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
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

// MARK: - Secondary Button (White Border)

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
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

// MARK: - Icon Button

struct IconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    init(_ icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.5))
                .foregroundColor(.textPrimary)
                .frame(width: size, height: size)
                .background(Color.backgroundTertiary)
                .clipShape(Circle())
        }
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.stackBlack)
                .frame(width: 56, height: 56)
                .background(Color.stackAccent)
                .clipShape(Circle())
                .shadow(color: .stackAccent.opacity(0.4), radius: 12, y: 4)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Primary Button", icon: "plus") {}
        SecondaryButton("Secondary Button", icon: "xmark") {}
        IconButton("gear") {}
        FloatingActionButton(icon: "plus") {}
    }
    .padding()
    .background(Color.backgroundPrimary)
}
