import Foundation

protocol BaseModel: Identifiable, Codable {
    var id: UUID { get }
}

extension BaseModel {
    var id: UUID { UUID() }
} 