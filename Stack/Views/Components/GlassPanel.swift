import SwiftUI

// MARK: - Glass Panel

struct GlassPanel<Content: View>: View {
    let cornerRadius: CGFloat
    let content: () -> Content

    init(cornerRadius: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
    }
}

// MARK: - Glass Card

struct GlassCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }
}

// MARK: - Utility Panel (Slide up from bottom)

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
        .cornerRadius(CornerRadius.xl, corners: [.topLeft, .topRight])
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 50 {
                        withAnimation(.smooth) {
                            isExpanded = false
                        }
                    } else if value.translation.height < -50 {
                        withAnimation(.smooth) {
                            isExpanded = true
                        }
                    }
                }
        )
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()

        VStack(spacing: 20) {
            GlassPanel {
                Text("Glass Panel")
                    .padding()
            }

            GlassCard {
                Text("Glass Card")
            }
        }
        .padding()
    }
}
