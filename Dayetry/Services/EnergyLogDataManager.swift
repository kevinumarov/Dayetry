import Foundation
import SwiftData

class EnergyLogDataManager {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchEnergyLogs(for date: Date) -> [EnergyLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<EnergyLog> { log in
            log.timestamp >= startOfDay && log.timestamp < endOfDay
        }
        
        var descriptor = FetchDescriptor<EnergyLog>(predicate: predicate)
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func fetchRecentEnergyLogs(limit: Int = 50) -> [EnergyLog] {
        var descriptor = FetchDescriptor<EnergyLog>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
