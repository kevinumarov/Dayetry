//
//  CalendarView.swift
//  Dayetry
//
//  Created by Assistant on 2024.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingAddEvent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                calendarHeader
                
                // Calendar Grid
                calendarGrid
                
                // Selected Date Events
                selectedDateEvents
            }
        }
        .background(Color(hex: "EEF2FF").ignoresSafeArea())
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(viewModel: viewModel)
        }
        .sheet(item: $viewModel.selectedEvent) { event in
            EventDetailView(event: event, viewModel: viewModel)
        }
    }
    
    // MARK: - Calendar Header
    private var calendarHeader: some View {
        VStack(spacing: 20) {
            // Title
            HStack {
                Text("Calendar")
                    .font(.custom("PPMori-SemiBold", size: 36))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    showingAddEvent = true
                }) {
                    Image.icon(AssetManager.Icons.plus)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color(hex: "381E72"))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            
            // Month Navigation
            HStack {
                Button(action: viewModel.goToPreviousMonth) {
                    Image.icon(AssetManager.Icons.chevronLeft)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.3))
                        )
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(viewModel.monthYearString)
                        .font(.custom("PPMori-SemiBold", size: 24))
                        .foregroundColor(.black)
                    
                    Text(viewModel.selectedDateString)
                        .font(.custom("PPMori-Regular", size: 16))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: viewModel.goToNextMonth) {
                    Image.icon(AssetManager.Icons.chevronRight)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.3))
                        )
                }
            }
            .padding(.horizontal, 16)
            
            // Today Button
            Button(action: viewModel.goToToday) {
                Text("Today")
                    .font(.custom("PPMori-SemiBold", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(hex: "381E72"))
                    )
            }
        }
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        VStack(spacing: 0) {
            // Weekday Headers
            HStack {
                ForEach(viewModel.weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.custom("PPMori-SemiBold", size: 14))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            // Calendar Days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(viewModel.generateCalendarDays()) { day in
                    CalendarDayView(day: day, viewModel: viewModel)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.25))
                .background(.ultraThinMaterial)
                .blur(radius: 0.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
                )
        )
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Selected Date Events
    private var selectedDateEvents: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Events")
                    .font(.custom("PPMori-SemiBold", size: 20))
                    .foregroundColor(.black)
                Spacer()
                Text("\(viewModel.eventsForSelectedDate().count) events")
                    .font(.custom("PPMori-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            
            if viewModel.eventsForSelectedDate().isEmpty {
                VStack(spacing: 16) {
                    Image.icon(AssetManager.Icons.calendar)
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No events today")
                        .font(.custom("PPMori-Regular", size: 16))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showingAddEvent = true
                    }) {
                        Text("Add Event")
                            .font(.custom("PPMori-SemiBold", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "381E72"))
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.eventsForSelectedDate()) { event in
                        EventCardView(event: event) {
                            viewModel.selectedEvent = event
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let day: CalendarDay
    let viewModel: CalendarViewModel
    
    var body: some View {
        Button(action: {
            viewModel.selectDate(day.date)
        }) {
            VStack(spacing: 4) {
                Text("\(day.dayNumber)")
                    .font(.custom("PPMori-SemiBold", size: 16))
                    .foregroundColor(day.isCurrentMonth ? (day.isToday ? .white : .black) : .gray.opacity(0.3))
                
                // Event indicators
                if !day.events.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(day.events.prefix(3), id: \.id) { event in
                            Circle()
                                .fill(Color(hex: event.color))
                                .frame(width: 4, height: 4)
                        }
                        if day.events.count > 3 {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(day.isToday ? Color(hex: "381E72") : (day.isSelected ? Color(hex: "381E72").opacity(0.2) : Color.clear))
            )
            .overlay(
                Circle()
                    .stroke(day.isSelected && !day.isToday ? Color(hex: "381E72") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event Card View
struct EventCardView: View {
    let event: CalendarEvent
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Event type indicator
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: event.color))
                    .frame(width: 4, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.custom("PPMori-SemiBold", size: 16))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    if let description = event.description {
                        Text(description)
                            .font(.custom("PPMori-Regular", size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Text(event.eventType.rawValue)
                            .font(.custom("PPMori-Regular", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: event.color))
                            )
                        
                        Spacer()
                        
                        Text(formatEventTime(event))
                            .font(.custom("PPMori-Regular", size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image.icon(AssetManager.Icons.chevronRight)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func formatEventTime(_ event: CalendarEvent) -> String {
        let formatter = DateFormatter()
        if event.isAllDay {
            return "All Day"
        } else {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: event.startDate)
        }
    }
}

#Preview {
    CalendarView()
}
