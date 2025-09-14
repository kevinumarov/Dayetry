//
//  CalendarModels.swift
//  Dayetry
//
//  Created by Assistant on 2024.
//

import Foundation
import SwiftUI

// MARK: - Calendar Models
struct CalendarEvent: BaseModel {
    let id: UUID
    let title: String
    let description: String?
    let startDate: Date
    let endDate: Date
    let eventType: EventType
    let isAllDay: Bool
    let color: String
    
    init(title: String, description: String? = nil, startDate: Date, endDate: Date, eventType: EventType = .personal, isAllDay: Bool = false, color: String = "381E72") {
        self.id = UUID()
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.eventType = eventType
        self.isAllDay = isAllDay
        self.color = color
    }
}

enum EventType: String, CaseIterable, Codable {
    case personal = "Personal"
    case work = "Work"
    case health = "Health"
    case financial = "Financial"
    case energy = "Energy"
    case emotional = "Emotional"
    
    var icon: String {
        switch self {
        case .personal: return "User"
        case .work: return "Briefcase"
        case .health: return "Heart"
        case .financial: return "Dollar Circle"
        case .energy: return "Dashboard"
        case .emotional: return "Heart"
        }
    }
    
    var color: String {
        switch self {
        case .personal: return "381E72"
        case .work: return "2563EB"
        case .health: return "059669"
        case .financial: return "DC2626"
        case .energy: return "7C3AED"
        case .emotional: return "F59E0B"
        }
    }
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let events: [CalendarEvent]
    
    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // Sunday or Saturday
    }
}
