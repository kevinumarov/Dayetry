import Foundation

class EnergyConfigManager: ObservableObject {
    @Published var config: EnergyConfig?
    
    func loadConfiguration() {
        guard let url = Bundle.main.url(forResource: "energy_engine_config", withExtension: "json") else {
            print("❌ Could not find energy_engine_config.json")
            return
        }
        
        print("📁 Found config file at: \(url)")
        
        do {
            let data = try Data(contentsOf: url)
            print("📄 Config file size: \(data.count) bytes")
            let decoder = JSONDecoder()
            self.config = try decoder.decode(EnergyConfig.self, from: data)
            print("✅ Successfully loaded energy config with \(config?.energyEngines.count ?? 0) engines")
        } catch {
            print("❌ Error loading energy config: \(error)")
        }
    }
}
