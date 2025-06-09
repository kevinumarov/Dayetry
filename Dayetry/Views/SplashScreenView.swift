import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Dayetry")
                .font(.ppmoriSemiBold(40))
                .fontWeight(.heavy)
                .foregroundColor(.white)
        }
        .onAppear {
            appState.hideSplash(after: 2)
        }
    }
}

#Preview {
    SplashScreenView().environmentObject(AppState())
}


