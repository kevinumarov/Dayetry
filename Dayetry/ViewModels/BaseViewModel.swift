import Foundation
import Combine

protocol BaseViewModel: ObservableObject {
    var cancellables: Set<AnyCancellable> { get set }
    func setupBindings()
}

extension BaseViewModel {
    func setupBindings() {
        // Default implementation is empty
    }
} 