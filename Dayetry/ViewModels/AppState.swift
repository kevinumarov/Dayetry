import Foundation
import UIKit
import Combine

class AppState: ObservableObject {
    @Published var showSplash: Bool = true
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.showSplash = true
            }
            .store(in: &cancellables)
    }
    
    func hideSplash(after seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            self?.showSplash = false
        }
    }
} 
