//
//  SmartSuggestionsEngine.swift
//  Dayetry
//
//  Created by Kevin Umarov on 13.09.2025
//

import Foundation
import SwiftData

@MainActor
class SmartSuggestionsEngine: ObservableObject {
    @Published var suggestions: [EnergySuggestion] = []
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func generateSuggestions(
        currentEnergies: EnergySnapshot?,
        recentLogs: [EnergyLog]
    ) {
        var newSuggestions: [EnergySuggestion] = []
        
        guard let energies = currentEnergies else { return }
        
        // Rapid energy drop detection
        newSuggestions.append(contentsOf: detectRapidDrops(energies))
        
        // Missed habits detection
        newSuggestions.append(contentsOf: detectMissedHabits(recentLogs))
        
        // Multi-energy fatigue detection
        newSuggestions.append(contentsOf: detectMultiEnergyFatigue(energies))
        
        // Pattern-based suggestions
        newSuggestions.append(contentsOf: generatePatternBasedSuggestions(recentLogs))
        
        // Time-based suggestions
        newSuggestions.append(contentsOf: generateTimeBasedSuggestions(energies))
        
        // Cross-energy suggestions
        newSuggestions.append(contentsOf: generateCrossEnergySuggestions(energies))
        
        suggestions = newSuggestions
    }
    
    // MARK: - Detection Methods
    private func detectRapidDrops(_ energies: EnergySnapshot) -> [EnergySuggestion] {
        var suggestions: [EnergySuggestion] = []
        
        // Check for rapid drops in any energy type
        if energies.mentalEnergy < 30 {
            suggestions.append(EnergySuggestion(
                title: "Mental Energy Low",
                description: "Your mental energy is critically low. Consider taking a break or doing a mindfulness exercise.",
                category: .recovery,
                priority: .high,
                actionType: .takeBreak,
                icon: "brain.head.profile",
                color: "7C3AED"
            ))
        }
        
        if energies.physicalEnergy < 30 {
            suggestions.append(EnergySuggestion(
                title: "Physical Energy Low",
                description: "Your physical energy is low. Consider light exercise or a short walk to boost it.",
                category: .recovery,
                priority: .high,
                actionType: .exercise,
                icon: "figure.run",
                color: "059669"
            ))
        }
        
        if energies.financialEnergy < 30 {
            suggestions.append(EnergySuggestion(
                title: "Financial Energy Low",
                description: "Your financial energy is low. Consider reviewing your budget or financial goals.",
                category: .recovery,
                priority: .medium,
                actionType: .reflection,
                icon: "dollarsign.circle",
                color: "DC2626"
            ))
        }
        
        if energies.emotionalEnergy < 30 {
            suggestions.append(EnergySuggestion(
                title: "Emotional Energy Low",
                description: "Your emotional energy is low. Consider journaling or connecting with loved ones.",
                category: .recovery,
                priority: .high,
                actionType: .journaling,
                icon: "heart",
                color: "F59E0B"
            ))
        }
        
        return suggestions
    }
    
    private func detectMissedHabits(_ logs: [EnergyLog]) -> [EnergySuggestion] {
        var suggestions: [EnergySuggestion] = []
        
        // Check for missed meditation
        let lastMeditation = logs.last { $0.eventDescription.contains("meditation") }
        if lastMeditation == nil || Date().timeIntervalSince(lastMeditation!.timestamp) > 86400 {
            suggestions.append(EnergySuggestion(
                title: "Missed Meditation",
                description: "You haven't meditated today. Even 5 minutes can help boost your mental energy.",
                category: .optimization,
                priority: .medium,
                actionType: .meditation,
                icon: "brain.head.profile",
                color: "7C3AED"
            ))
        }
        
        // Check for missed exercise
        let lastExercise = logs.last { $0.eventDescription.contains("workout") || $0.eventDescription.contains("exercise") }
        if lastExercise == nil || Date().timeIntervalSince(lastExercise!.timestamp) > 86400 {
            suggestions.append(EnergySuggestion(
                title: "Missed Exercise",
                description: "You haven't exercised today. A short walk or workout can boost your physical energy.",
                category: .optimization,
                priority: .medium,
                actionType: .exercise,
                icon: "figure.run",
                color: "059669"
            ))
        }
        
        // Check for missed journaling
        let lastJournaling = logs.last { $0.eventDescription.contains("journaling") || $0.eventDescription.contains("reflection") }
        if lastJournaling == nil || Date().timeIntervalSince(lastJournaling!.timestamp) > 86400 {
            suggestions.append(EnergySuggestion(
                title: "Missed Journaling",
                description: "You haven't journaled today. Reflecting on your day can help process emotions.",
                category: .optimization,
                priority: .low,
                actionType: .journaling,
                icon: "heart",
                color: "F59E0B"
            ))
        }
        
        return suggestions
    }
    
    private func detectMultiEnergyFatigue(_ energies: EnergySnapshot) -> [EnergySuggestion] {
        var suggestions: [EnergySuggestion] = []
        
        let lowEnergyCount = [energies.mentalEnergy, energies.physicalEnergy, energies.financialEnergy, energies.emotionalEnergy]
            .filter { $0 < 40 }.count
        
        if lowEnergyCount >= 3 {
            suggestions.append(EnergySuggestion(
                title: "Multi-Energy Fatigue",
                description: "Multiple energy types are low. Consider a comprehensive recovery approach: rest, nutrition, and reflection.",
                category: .recovery,
                priority: .high,
                actionType: .takeBreak,
                icon: "exclamationmark.triangle",
                color: "FF6B6B"
            ))
        }
        
        return suggestions
    }
    
    private func generatePatternBasedSuggestions(_ logs: [EnergyLog]) -> [EnergySuggestion] {
        var suggestions: [EnergySuggestion] = []
        
        // Analyze recent patterns
        let recentDrains = logs.filter { $0.eventType == .drain && Calendar.current.isDateInToday($0.timestamp) }
        let recentBoosts = logs.filter { $0.eventType == .boost && Calendar.current.isDateInToday($0.timestamp) }
        
        if recentDrains.count > recentBoosts.count * 2 {
            suggestions.append(EnergySuggestion(
                title: "Energy Drain Pattern",
                description: "You've had more energy drains than boosts today. Consider what activities are draining your energy.",
                category: .patternAlert,
                priority: .medium,
                actionType: .reflection,
                icon: "chart.line.downtrend.xyaxis",
                color: "FF6B6B"
            ))
        }
        
        // Find top energy boost
        if let topBoost = recentBoosts.max(by: { $0.impact < $1.impact }) {
            suggestions.append(EnergySuggestion(
                title: "Energy Boost Success",
                description: "\(topBoost.eventDescription) has been boosting your energy. Consider doing more of this activity.",
                category: .opportunity,
                priority: .low,
                actionType: .keepGoing,
                icon: "chart.line.uptrend.xyaxis",
                color: "4CAF50"
            ))
        }
        
        return suggestions
    }
    
    private func generateTimeBasedSuggestions(_ energies: EnergySnapshot) -> [EnergySuggestion] {
        var suggestions: [EnergySuggestion] = []
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Morning suggestions
        if hour >= 6 && hour < 12 {
            if energies.mentalEnergy < 60 {
                suggestions.append(EnergySuggestion(
                    title: "Morning Mental Boost",
                    description: "Start your day with a mental energy boost. Consider meditation or planning your priorities.",
                    category: .optimization,
                    priority: .medium,
                    actionType: .meditation,
                    icon: "sunrise",
                    color: "FFA726"
                ))
            }
        }
        
        // Afternoon suggestions
        if hour >= 12 && hour < 18 {
            if energies.physicalEnergy < 50 {
                suggestions.append(EnergySuggestion(
                    title: "Afternoon Energy Boost",
                    description: "Your physical energy is low. Consider a short walk or light exercise to recharge.",
                    category: .optimization,
                    priority: .medium,
                    actionType: .exercise,
                    icon: "figure.walk",
                    color: "4CAF50"
                ))
            }
        }
        
        // Evening suggestions
        if hour >= 18 {
            if energies.emotionalEnergy < 60 {
                suggestions.append(EnergySuggestion(
                    title: "Evening Reflection",
                    description: "End your day with emotional processing. Consider journaling or gratitude practice.",
                    category: .optimization,
                    priority: .low,
                    actionType: .journaling,
                    icon: "moon",
                    color: "9C27B0"
                ))
            }
        }
        
        return suggestions
    }
    
    private func generateCrossEnergySuggestions(_ energies: EnergySnapshot) -> [EnergySuggestion] {
        var suggestions: [EnergySuggestion] = []
        
        // Mental to Emotional connection
        if energies.mentalEnergy < 40 && energies.emotionalEnergy < 50 {
            suggestions.append(EnergySuggestion(
                title: "Mental-Emotional Connection",
                description: "Low mental energy is affecting your emotional state. Try mindfulness or deep breathing.",
                category: .recovery,
                priority: .medium,
                actionType: .meditation,
                icon: "brain.head.profile",
                color: "7C3AED"
            ))
        }
        
        // Physical to Mental connection
        if energies.physicalEnergy < 40 && energies.mentalEnergy < 50 {
            suggestions.append(EnergySuggestion(
                title: "Physical-Mental Connection",
                description: "Low physical energy is affecting your mental clarity. Try light exercise or a walk.",
                category: .recovery,
                priority: .medium,
                actionType: .exercise,
                icon: "figure.run",
                color: "059669"
            ))
        }
        
        // Financial to Emotional connection
        if energies.financialEnergy < 40 && energies.emotionalEnergy < 50 {
            suggestions.append(EnergySuggestion(
                title: "Financial-Emotional Connection",
                description: "Financial stress is affecting your emotional well-being. Consider budgeting or financial planning.",
                category: .recovery,
                priority: .medium,
                actionType: .reflection,
                icon: "dollarsign.circle",
                color: "DC2626"
            ))
        }
        
        return suggestions
    }
}

// MARK: - Supporting Structures
struct EnergySuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: SuggestionCategory
    let priority: SuggestionPriority
    let actionType: SuggestionAction
    let icon: String
    let color: String
    let timestamp = Date()
}

enum SuggestionCategory: String, CaseIterable, Codable {
    case recovery = "recovery"
    case optimization = "optimization"
    case patternAlert = "patternAlert"
    case opportunity = "opportunity"
    
    var displayName: String {
        switch self {
        case .recovery: return "Recovery"
        case .optimization: return "Optimization"
        case .patternAlert: return "Pattern Alert"
        case .opportunity: return "Opportunity"
        }
    }
}

enum SuggestionPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum SuggestionAction: String, CaseIterable, Codable {
    case meditation = "meditation"
    case exercise = "exercise"
    case journaling = "journaling"
    case reflection = "reflection"
    case takeBreak = "break"
    case keepGoing = "continue"
    
    var displayName: String {
        switch self {
        case .meditation: return "Meditation"
        case .exercise: return "Exercise"
        case .journaling: return "Journaling"
        case .reflection: return "Reflection"
        case .takeBreak: return "Take a Break"
        case .keepGoing: return "Continue"
        }
    }
}
