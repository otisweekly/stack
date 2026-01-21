import SwiftUI

/// Sliding utility panel from bottom with drag handle
struct UtilityPanel<Content: View>: View {
    @Binding var isExpanded: Bool
    let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.md)

            // Content
            content()
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .background(Color.glassTint)
        .cornerRadius(CornerRadius.xl, corners: [.topLeft, .topRight])
        .gesture(
            DragGesture()
                .onEnded { value in
                    withAnimation(.smooth) {
                        if value.translation.height > 50 {
                            isExpanded = false
                        } else if value.translation.height < -50 {
                            isExpanded = true
                        }
                    }
                }
        )
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        VStack {
            Spacer()
            UtilityPanel(isExpanded: .constant(true)) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Settings")
                        .font(.fujiHeadline)
                        .foregroundColor(.textPrimary)

                    HStack {
                        Text("Canvas Size")
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Text("9:16")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
    }
}
