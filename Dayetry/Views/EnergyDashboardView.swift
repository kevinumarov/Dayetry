//
//  EnergyDashboardView.swift
//  Dayetry
//
//  Created by Assistant on 2024.
//

import SwiftUI
import SwiftData

struct EnergyDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var energySystem: EnergyEngineCore
    @StateObject private var suggestionsEngine: SmartSuggestionsEngine
    
    @Query(sort: [SortDescriptor(\EnergyLog.timestamp, order: .reverse)]) 
    var allLogs: [EnergyLog]
    
    var todayLogs: [EnergyLog] {
        allLogs.filter { Calendar.current.isDateInToday($0.timestamp) }
    }
    
    init() {
        // This is a workaround for @StateObject initialization with parameters
        let context = ModelContext(try! ModelContainer(for: EnergyLog.self))
        _energySystem = StateObject(wrappedValue: EnergyEngineCore(modelContext: context))
        _suggestionsEngine = StateObject(wrappedValue: SmartSuggestionsEngine(modelContext: context))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Energy Summary Cards
                if let energies = energySystem.currentEnergies {
                    energySummarySection(energies: energies)
                } else {
                    loadingSection
                }
                
                // Energy Timeline
                energyTimelineSection
                
                // Smart Suggestions
                smartSuggestionsSection
                
                // Weekly Trend (placeholder)
                weeklyTrendSection
            }
            .padding()
        }
        .onAppear {
            energySystem.testEnergyCalculations() // Debug test
            energySystem.startScheduledEvaluations()
            suggestionsEngine.generateSuggestions(
                currentEnergies: energySystem.currentEnergies,
                recentLogs: todayLogs
            )
        }
    }
}

// MARK: - Header Section
extension EnergyDashboardView {
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Energy Dashboard")
                        .font(.custom("PPMori-SemiBold", size: 28))
                        .foregroundColor(.primary)
                    
                    Text("Track your energy levels across all dimensions")
                        .font(.custom("PPMori-Regular", size: 16))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Add manual energy log
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Energy Summary Section
extension EnergyDashboardView {
    private func energySummarySection(energies: EnergySnapshot) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Energy Levels")
                .font(.custom("PPMori-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                energyCard(
                    title: "Mental",
                    value: energies.mentalEnergy,
                    color: "7C3AED",
                    icon: "brain.head.profile"
                )
                
                energyCard(
                    title: "Physical",
                    value: energies.physicalEnergy,
                    color: "059669",
                    icon: "figure.run"
                )
                
                energyCard(
                    title: "Financial",
                    value: energies.financialEnergy,
                    color: "DC2626",
                    icon: "dollarsign.circle"
                )
                
                energyCard(
                    title: "Emotional",
                    value: energies.emotionalEnergy,
                    color: "F59E0B",
                    icon: "heart"
                )
            }
        }
    }
    
    private func energyCard(title: String, value: Double, color: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: color))
                
                Spacer()
                
                Text("\(Int(value))%")
                    .font(.custom("PPMori-SemiBold", size: 24))
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.custom("PPMori-Medium", size: 16))
                .foregroundColor(.secondary)
            
            ProgressView(value: value / 100)
                .progressViewStyle(EnergyProgressStyle(color: color))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Energy Timeline Section
extension EnergyDashboardView {
    private var energyTimelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Energy Events")
                .font(.custom("PPMori-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            if todayLogs.isEmpty {
                emptyTimelineView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(todayLogs.prefix(10), id: \.id) { log in
                        energyEventRow(log: log)
                    }
                }
            }
        }
    }
    
    private var emptyTimelineView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No energy events today")
                .font(.custom("PPMori-Medium", size: 16))
                .foregroundColor(.secondary)
            
            Text("Start logging your activities to see energy patterns")
                .font(.custom("PPMori-Regular", size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func energyEventRow(log: EnergyLog) -> some View {
        HStack(spacing: 12) {
            // Event type icon
            Image(systemName: log.eventType == .boost ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.title3)
                .foregroundColor(log.eventType == .boost ? .green : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.eventDescription)
                    .font(.custom("PPMori-Medium", size: 16))
                    .foregroundColor(.primary)
                
                HStack {
                    Text(log.energyType.capitalized)
                        .font(.custom("PPMori-Regular", size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(log.impact > 0 ? "+" : "")\(Int(log.impact))")
                        .font(.custom("PPMori-SemiBold", size: 14))
                        .foregroundColor(log.eventType == .boost ? .green : .red)
                }
            }
            
            Spacer()
            
            Text(log.timestamp, style: .time)
                .font(.custom("PPMori-Regular", size: 12))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Smart Suggestions Section
extension EnergyDashboardView {
    private var smartSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Smart Suggestions")
                .font(.custom("PPMori-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            if suggestionsEngine.suggestions.isEmpty {
                emptySuggestionsView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(suggestionsEngine.suggestions.prefix(5), id: \.id) { suggestion in
                        suggestionRow(suggestion: suggestion)
                    }
                }
            }
        }
    }
    
    private var emptySuggestionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No suggestions available")
                .font(.custom("PPMori-Medium", size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private func suggestionRow(suggestion: EnergySuggestion) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: suggestion.icon)
                .font(.title3)
                .foregroundColor(Color(hex: suggestion.color))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.custom("PPMori-SemiBold", size: 16))
                    .foregroundColor(.primary)
                
                Text(suggestion.description)
                    .font(.custom("PPMori-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Weekly Trend Section
extension EnergyDashboardView {
    private var weeklyTrendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Energy Trends")
                .font(.custom("PPMori-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                Text("📊 Coming Soon")
                    .font(.custom("PPMori-Medium", size: 16))
                    .foregroundColor(.secondary)
                
                Text("Weekly trend analysis and correlation insights")
                    .font(.custom("PPMori-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
}

// MARK: - Loading Section
extension EnergyDashboardView {
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Calculating energy levels...")
                .font(.custom("PPMori-Medium", size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    EnergyDashboardView()
}
