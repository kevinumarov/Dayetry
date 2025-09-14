import SwiftUI

struct MainView: View {
    @State private var selectedTab: TabItem = .energy
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .energy:
                    EnergyDashboardView()
                case .arsenal:
                    ArsenalView()
                case .calendar:
                    CalendarView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainView()
}
