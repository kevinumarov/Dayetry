//
//  CalendarViewModel.swift
//  Dayetry
//
//  Created by Kevin Umarov
//

import Foundation
import Combine
import SwiftUI

class CalendarViewModel: BaseViewModel {
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var events: [CalendarEvent] = []
    @Published var showingEventDetail = false
    @Published var selectedEvent: CalendarEvent?
    @Published var showingAddEvent = false
    
    var cancellables = Set<AnyCancellable>()
    
    private let persistenceManager = PersistenceManager.shared
    
    init() {
        setupBindings()
        loadEvents()
        generateSampleEvents()
    }
    
    func setupBindings() {
        // Load events when selected date changes
        $selectedDate
            .sink { [weak self] _ in
                self?.loadEvents()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Date Navigation
    func goToPreviousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    func goToNextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    func goToToday() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = Date()
            selectedDate = Date()
        }
    }
    
    // MARK: - Calendar Data Generation
    func generateCalendarDays() -> [CalendarDay] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        // Get the first day of the week for the start of month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysToSubtract = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfMonth) ?? startOfMonth
        
        var days: [CalendarDay] = []
        var currentDate = startDate
        
        // Generate 42 days (6 weeks)
        for _ in 0..<42 {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month)
            let isToday = calendar.isDateInToday(currentDate)
            let isSelected = calendar.isDate(currentDate, inSameDayAs: selectedDate)
            let dayEvents = eventsForDate(currentDate)
            
            let day = CalendarDay(
                date: currentDate,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                isSelected: isSelected,
                events: dayEvents
            )
            
            days.append(day)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    // MARK: - Event Management
    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date) ||
            calendar.isDate(event.endDate, inSameDayAs: date) ||
            (event.isAllDay && calendar.isDate(date, inSameDayAs: event.startDate))
        }
    }
    
    func eventsForSelectedDate() -> [CalendarEvent] {
        return eventsForDate(selectedDate)
    }
    
    func addEvent(_ event: CalendarEvent) {
        events.append(event)
        saveEvents()
    }
    
    func updateEvent(_ event: CalendarEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveEvents()
        }
    }
    
    func deleteEvent(_ event: CalendarEvent) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    func selectDate(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = date
        }
    }
    
    // MARK: - Persistence
    func saveEvents() {
        persistenceManager.save(events, forKey: "calendar_events")
    }
    
    private func loadEvents() {
        if let loadedEvents = persistenceManager.load(forKey: "calendar_events", as: [CalendarEvent].self) {
            events = loadedEvents
        }
    }
    
    // MARK: - Sample Data
    private func generateSampleEvents() {
        if events.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            
            let sampleEvents = [
                CalendarEvent(
                    title: "Morning Energy Check",
                    description: "Review mental and physical energy levels",
                    startDate: calendar.date(byAdding: .hour, value: 9, to: today) ?? today,
                    endDate: calendar.date(byAdding: .hour, value: 10, to: today) ?? today,
                    eventType: .energy,
                    color: EventType.energy.color
                ),
                CalendarEvent(
                    title: "Team Meeting",
                    description: "Weekly team standup",
                    startDate: calendar.date(byAdding: .day, value: 1, to: calendar.date(byAdding: .hour, value: 14, to: today) ?? today) ?? today,
                    endDate: calendar.date(byAdding: .day, value: 1, to: calendar.date(byAdding: .hour, value: 15, to: today) ?? today) ?? today,
                    eventType: .work,
                    color: EventType.work.color
                ),
                CalendarEvent(
                    title: "Gym Session",
                    description: "Physical energy boost",
                    startDate: calendar.date(byAdding: .day, value: 2, to: calendar.date(byAdding: .hour, value: 18, to: today) ?? today) ?? today,
                    endDate: calendar.date(byAdding: .day, value: 2, to: calendar.date(byAdding: .hour, value: 19, to: today) ?? today) ?? today,
                    eventType: .health,
                    color: EventType.health.color
                ),
                CalendarEvent(
                    title: "Budget Review",
                    description: "Weekly financial energy assessment",
                    startDate: calendar.date(byAdding: .day, value: 3, to: calendar.date(byAdding: .hour, value: 10, to: today) ?? today) ?? today,
                    endDate: calendar.date(byAdding: .day, value: 3, to: calendar.date(byAdding: .hour, value: 11, to: today) ?? today) ?? today,
                    eventType: .financial,
                    color: EventType.financial.color
                ),
                CalendarEvent(
                    title: "Meditation Session",
                    description: "Emotional energy recharge and mindfulness",
                    startDate: calendar.date(byAdding: .day, value: 4, to: calendar.date(byAdding: .hour, value: 7, to: today) ?? today) ?? today,
                    endDate: calendar.date(byAdding: .day, value: 4, to: calendar.date(byAdding: .hour, value: 8, to: today) ?? today) ?? today,
                    eventType: .emotional,
                    color: EventType.emotional.color
                )
            ]
            
            events = sampleEvents
            saveEvents()
        }
    }
    
    // MARK: - Date Formatting
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }
    
    var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.shortWeekdaySymbols
    }
}


