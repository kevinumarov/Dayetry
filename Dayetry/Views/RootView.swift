import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        Group {
            if appState.showSplash {
                SplashScreenView()
            } else {
                MainView()
            }
        }
    }
}

#Preview {
    RootView().environmentObject(AppState())
} 