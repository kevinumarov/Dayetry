import SwiftUI

enum TabItem: String, CaseIterable, Identifiable {
    case energy = "Energy"
    case arsenal = "Arsenal"
    case calendar = "Calendar"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .energy: return AssetManager.Icons.energy
        case .arsenal: return AssetManager.Icons.arsenal
        case .calendar: return AssetManager.Icons.calendar
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var body: some View {
        HStack {
            ForEach(TabItem.allCases) { tab in
                Spacer()
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image.icon(tab.icon)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.4))
                            .shadow(color: selectedTab == tab ? .white.opacity(0.7) : .clear, radius: selectedTab == tab ? 8 : 0)
                        if selectedTab == tab {
                            Text(tab.rawValue)
                                .font(.custom("PPMori-SemiBold", size: 13))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(
            Color.black
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.energy))
        .background(Color.gray)
} 