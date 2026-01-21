import SwiftUI

/// Floating action button with teal accent
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
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        FloatingActionButton(icon: "plus") {
            print("Tapped")
        }
    }
}
