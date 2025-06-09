import Foundation
import Combine

class CalendarViewModel: BaseViewModel {
    @Published var calendarData: String = ""
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    func setupBindings() {
        // Add Combine logic here
    }
} 