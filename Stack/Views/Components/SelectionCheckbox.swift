import SwiftUI

/// Circular checkbox with teal accent when selected
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

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        HStack(spacing: Spacing.lg) {
            SelectionCheckbox(isSelected: false)
            SelectionCheckbox(isSelected: true)
        }
    }
}
