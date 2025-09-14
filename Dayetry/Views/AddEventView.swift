//
//  AddEventView.swift
//  Dayetry
//
//  Created by Assistant on 2024.
//

import SwiftUI

struct AddEventView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600) // 1 hour later
    @State private var selectedEventType: EventType = .personal
    @State private var isAllDay = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Add Event")
                            .font(.custom("PPMori-SemiBold", size: 28))
                            .foregroundColor(.black)
                        
                        Text("Schedule your energy activities")
                            .font(.custom("PPMori-Regular", size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.custom("PPMori-SemiBold", size: 16))
                                .foregroundColor(.black)
                            
                            TextField("Event title", text: $title)
                                .font(.custom("PPMori-Regular", size: 16))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.custom("PPMori-SemiBold", size: 16))
                                .foregroundColor(.black)
                            
                            TextField("Event description (optional)", text: $description, axis: .vertical)
                                .font(.custom("PPMori-Regular", size: 16))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                                .lineLimit(3...6)
                        }
                        
                        // Event Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Type")
                                .font(.custom("PPMori-SemiBold", size: 16))
                                .foregroundColor(.black)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(EventType.allCases, id: \.self) { eventType in
                                    EventTypeButton(
                                        eventType: eventType,
                                        isSelected: selectedEventType == eventType
                                    ) {
                                        selectedEventType = eventType
                                    }
                                }
                            }
                        }
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.custom("PPMori-SemiBold", size: 16))
                                .foregroundColor(.black)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        
                        // All Day Toggle
                        HStack {
                            Text("All Day")
                                .font(.custom("PPMori-SemiBold", size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isAllDay)
                                .tint(Color(hex: "381E72"))
                        }
                        .padding(.vertical, 8)
                        
                        // Time Selection (if not all day)
                        if !isAllDay {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Start Time")
                                        .font(.custom("PPMori-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("End Time")
                                        .font(.custom("PPMori-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                    
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color(hex: "EEF2FF").ignoresSafeArea())
            .navigationBarHidden(true)
            .overlay(
                // Custom Navigation Bar
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image.icon(AssetManager.Icons.chevronLeft)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Button(action: saveEvent) {
                            Text("Save")
                                .font(.custom("PPMori-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "381E72"))
                                )
                        }
                        .disabled(title.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            )
        }
    }
    
    private func saveEvent() {
        let calendar = Calendar.current
        let startDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime),
                                       minute: calendar.component(.minute, from: startTime),
                                       second: 0,
                                       of: selectedDate) ?? selectedDate
        
        let endDateTime = isAllDay ? startDateTime : calendar.date(bySettingHour: calendar.component(.hour, from: endTime),
                                                                 minute: calendar.component(.minute, from: endTime),
                                                                 second: 0,
                                                                 of: selectedDate) ?? startDateTime
        
        let event = CalendarEvent(
            title: title,
            description: description.isEmpty ? nil : description,
            startDate: startDateTime,
            endDate: endDateTime,
            eventType: selectedEventType,
            isAllDay: isAllDay,
            color: selectedEventType.color
        )
        
        viewModel.addEvent(event)
        dismiss()
    }
}

struct EventTypeButton: View {
    let eventType: EventType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image.icon(eventType.icon)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(isSelected ? .white : Color(hex: eventType.color))
                
                Text(eventType.rawValue)
                    .font(.custom("PPMori-SemiBold", size: 14))
                    .foregroundColor(isSelected ? .white : Color(hex: eventType.color))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: eventType.color) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(hex: eventType.color), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddEventView(viewModel: CalendarViewModel())
}
