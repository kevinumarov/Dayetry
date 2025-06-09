import Foundation
import Combine

class ArsenalViewModel: BaseViewModel {
    @Published var arsenalData: String = ""
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    func setupBindings() {
        // Add Combine logic here
    }
} 