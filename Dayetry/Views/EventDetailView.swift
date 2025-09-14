//
//  EventDetailView.swift
//  Dayetry
//
//  Created by Assistant on 2024.
//

import SwiftUI

struct EventDetailView: View {
    let event: CalendarEvent
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        // Event Type Indicator
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: event.color))
                                .frame(width: 4, height: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.eventType.rawValue)
                                    .font(.custom("PPMori-SemiBold", size: 16))
                                    .foregroundColor(Color(hex: event.color))
                                
                                Text(formatEventDate())
                                    .font(.custom("PPMori-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Title
                        Text(event.title)
                            .font(.custom("PPMori-SemiBold", size: 28))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Description
                        if let description = event.description {
                            Text(description)
                                .font(.custom("PPMori-Regular", size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    // Event Details
                    VStack(spacing: 20) {
                        // Time Information
                        VStack(spacing: 16) {
                            HStack {
                                Image.icon(AssetManager.Icons.clock)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Time")
                                        .font(.custom("PPMori-SemiBold", size: 16))
                                        .foregroundColor(.black)
                                    
                                    Text(formatEventTime())
                                        .font(.custom("PPMori-Regular", size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            
                            if !event.isAllDay {
                                HStack {
                                    Image.icon(AssetManager.Icons.calendar)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.gray)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Duration")
                                            .font(.custom("PPMori-SemiBold", size: 16))
                                            .foregroundColor(.black)
                                        
                                        Text(formatEventDuration())
                                            .font(.custom("PPMori-Regular", size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.25))
                                .background(.ultraThinMaterial)
                                .blur(radius: 0.5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        // Energy Impact
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Energy Impact")
                                .font(.custom("PPMori-SemiBold", size: 18))
                                .foregroundColor(.black)
                            
                            Text(getEnergyImpactDescription())
                                .font(.custom("PPMori-Regular", size: 14))
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(hex: event.color).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color(hex: event.color).opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingEditView = true
                        }) {
                            HStack {
                                Image.icon(AssetManager.Icons.edit)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.white)
                                
                                Text("Edit Event")
                                    .font(.custom("PPMori-SemiBold", size: 16))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "381E72"))
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image.icon(AssetManager.Icons.cross)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.red)
                                
                                Text("Delete Event")
                                    .font(.custom("PPMori-SemiBold", size: 16))
                                    .foregroundColor(.red)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
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
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            )
        }
        .sheet(isPresented: $showingEditView) {
            EditEventView(event: event, viewModel: viewModel)
        }
        .alert("Delete Event", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteEvent(event)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
    }
    
    private func formatEventDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: event.startDate)
    }
    
    private func formatEventTime() -> String {
        if event.isAllDay {
            return "All Day"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let startTime = formatter.string(from: event.startDate)
            let endTime = formatter.string(from: event.endDate)
            return "\(startTime) - \(endTime)"
        }
    }
    
    private func formatEventDuration() -> String {
        let duration = event.endDate.timeIntervalSince(event.startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func getEnergyImpactDescription() -> String {
        switch event.eventType {
        case .personal:
            return "Personal activities help maintain mental well-being and work-life balance. This event contributes to your overall life satisfaction and personal growth."
        case .work:
            return "Work events can impact both mental and physical energy. Proper planning and breaks can help maintain productivity throughout the day."
        case .health:
            return "Health activities directly boost physical energy and overall well-being. Regular health events contribute to long-term energy sustainability."
        case .financial:
            return "Financial planning and management activities help reduce stress and provide mental clarity about your financial future and security."
        case .energy:
            return "Energy-focused activities help you understand and optimize your personal energy levels across mental, physical, and financial dimensions."
        case .emotional:
            return "Emotional activities help maintain mental health and emotional balance. This event contributes to your emotional well-being and resilience."
        }
    }
}

#Preview {
    EventDetailView(
        event: CalendarEvent(
            title: "Morning Energy Check",
            description: "Review mental and physical energy levels",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            eventType: .energy
        ),
        viewModel: CalendarViewModel()
    )
}
