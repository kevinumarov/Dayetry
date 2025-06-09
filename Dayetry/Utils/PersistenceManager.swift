import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func save<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }
    
    func load<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        if let data = defaults.data(forKey: key), let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
    
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
} 