import SwiftUI

struct ArsenalView: View {
    @StateObject private var viewModel = ArsenalViewModel()
    var body: some View {
        VStack {
            Image(AssetManager.Icons.arsenal)
                .resizable()
                .frame(width: 60, height: 60)
            Text("Arsenal")
                .font(.title)
        }
        .navigationTitle("Arsenal")
    }
}

#Preview {
    ArsenalView()
} 