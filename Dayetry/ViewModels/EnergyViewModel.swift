import Foundation
import Combine

class EnergyViewModel: BaseViewModel {
    @Published var energyData: String = ""
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    func setupBindings() {
        // Add Combine logic here
    }
} 