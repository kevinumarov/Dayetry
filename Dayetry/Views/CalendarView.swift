import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    var body: some View {
        VStack {
            Image(AssetManager.Icons.calendar)
                .resizable()
                .frame(width: 60, height: 60)
            Text("Calendar")
                .font(.title)
        }
        .navigationTitle("Calendar")
    }
}

#Preview {
    CalendarView()
} 