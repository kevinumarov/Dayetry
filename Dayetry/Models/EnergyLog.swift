//
//  EnergyLog.swift
//  Dayetry
//
//  Created by Assistant on 2024.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class EnergyLog {
    var id: UUID
    var timestamp: Date
    var energyType: String // "mental", "physical", "financial", "emotional"
    var eventType: EnergyEventType  // drain or boost
    var eventDescription: String
    var impact: Double     // e.g. +6, -10
    var source: String     // "automatic", "manual", "detected"
    var category: String?  // Optional categorization
    
    init(timestamp: Date, energyType: String, eventType: EnergyEventType, eventDescription: String, impact: Double, source: String = "automatic", category: String? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.energyType = energyType
        self.eventType = eventType
        self.eventDescription = eventDescription
        self.impact = impact
        self.source = source
        self.category = category
    }
}

// MARK: - Supporting Enums
enum EnergyType: String, CaseIterable, Codable {
    case mental = "mental"
    case physical = "physical"
    case financial = "financial"
    case emotional = "emotional"
    
    var displayName: String {
        switch self {
        case .mental: return "Mental Energy"
        case .physical: return "Physical Energy"
        case .financial: return "Financial Energy"
        case .emotional: return "Emotional Energy"
        }
    }
    
    var icon: String {
        switch self {
        case .mental: return "brain.head.profile"
        case .physical: return "figure.run"
        case .financial: return "dollarsign.circle"
        case .emotional: return "heart"
        }
    }
    
    var color: String {
        switch self {
        case .mental: return "7C3AED"
        case .physical: return "059669"
        case .financial: return "DC2626"
        case .emotional: return "F59E0B"
        }
    }
}

enum EnergyEventType: String, CaseIterable, Codable {
    case drain = "drain"
    case boost = "boost"
    
    var icon: String {
        switch self {
        case .drain: return "arrow.down.circle.fill"
        case .boost: return "arrow.up.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .drain: return .red
        case .boost: return .green
        }
    }
}

enum LogSource: String, CaseIterable, Codable {
    case automatic = "automatic"
    case manual = "manual"
    case detected = "detected"
}
