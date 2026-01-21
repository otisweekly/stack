import SwiftUI

/// Bottom tab bar with liquid glass capsule style
struct StackTabBar: View {
    @Binding var selectedTab: Tab

    enum Tab: String, CaseIterable {
        case create = "plus.square"
        case library = "square.stack"
        case settings = "gearshape"

        var label: String {
            switch self {
            case .create: return "Create"
            case .library: return "Library"
            case .settings: return "Settings"
            }
        }

        var filledIcon: String {
            switch self {
            case .create: return "plus.square.fill"
            case .library: return "square.stack.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    icon: tab.rawValue,
                    filledIcon: tab.filledIcon,
                    label: tab.label,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.quick) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(.bar)
        .clipShape(Capsule())
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.xs)
    }
}

struct TabBarButton: View {
    let icon: String
    let filledIcon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? filledIcon : icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.fujiCaptionSmall)
            }
            .foregroundColor(isSelected ? .stackAccent : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        VStack {
            Spacer()
            StackTabBar(selectedTab: .constant(.create))
        }
    }
}
