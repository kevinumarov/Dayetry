//
//  EnergyConfig.swift
//  Dayetry
//
//  Created by Assistant on 2024.
//

import Foundation

// MARK: - Main Configuration Structure
struct EnergyConfig: Codable {
    let version: String
    let lastUpdated: String
    let energyEngines: [String: EnergyEngineConfig]
    let crossEnergyDependencies: [String: CrossEnergyDependency]
    let evaluationSchedule: EvaluationSchedule
    let primeScoreWeights: PrimeScoreWeights
    
    enum CodingKeys: String, Codv  ingKey {
        case version
        case lastUpdated = "last_updated"
        case energyEngines = "energy_engines"
        case crossEnergyDependencies = "cross_energy_dependencies"
        case evaluationSchedule = "evaluation_schedule"
        case primeScoreWeights = "prime_score_weights"
    }
}

// MARK: - Energy Engine Configuration
struct EnergyEngineConfig: Codable {
    let baseDecay: BaseDecayConfig
    let drainFactors: [String: FactorConfig]
    let boostFactors: [String: FactorConfig]
    
    enum CodingKeys: String, CodingKey {
        case baseDecay = "base_decay"
        case drainFactors = "drain_factors"
        case boostFactors = "boost_factors"
    }
}

struct BaseDecayConfig: Codable {
    let ratePerHour: Double
    let maxHours: Int
    
    enum CodingKeys: String, CodingKey {
        case ratePerHour = "rate_per_hour"
        case maxHours = "max_hours"
    }
}

struct FactorConfig: Codable {
    let threshold: Double?
    let impact: Double
    let description: String
}

// MARK: - Cross Energy Dependencies
struct CrossEnergyDependency: Codable {
    let threshold: Double
    let impact: Double
    let description: String
}

// MARK: - Evaluation Schedule
struct EvaluationSchedule: Codable {
    let frequencyMinutes: Int
    let peakHours: [Int]
    let offHours: [Int]
    
    enum CodingKeys: String, CodingKey {
        case frequencyMinutes = "frequency_minutes"
        case peakHours = "peak_hours"
        case offHours = "off_hours"
    }
}

// MARK: - Prime Score Weights
struct PrimeScoreWeights: Codable {
    let mental: Double
    let physical: Double
    let financial: Double
    let emotional: Double
    
    enum CodingKeys: String, CodingKey {
        case mental
        case physical
        case financial
        case emotional
    }
}

// MARK: - Energy Snapshot
struct EnergySnapshot: Identifiable {
    let id = UUID()
    let timestamp: Date
    let mentalEnergy: Double
    let physicalEnergy: Double
    let financialEnergy: Double
    let emotionalEnergy: Double
    let primeEnergyScore: Double
    
    var total: Double {
        return (mentalEnergy + physicalEnergy + financialEnergy + emotionalEnergy) / 4.0
    }
}

// MARK: - Energy Input Data
struct EnergyInputs {
    let timeData: TimeData
    let healthData: HealthData
    let appUsageData: AppUsageData
    let userInputData: UserInputData
    let financialData: FinancialData
}

struct TimeData {
    let currentTime: Date
    let wakeTime: Date
    let hoursSinceWake: Double
}

struct HealthData {
    let sleepHours: Double
    let stepCount: Int
    let didWorkout: Bool
    let hydrationCount: Int
    let dietScore: Double
    let stressScore: Double
}

struct AppUsageData {
    let appSwitchCount: Int
    let screenTimeMinutes: Int
    let shortFormContentMinutes: Int
    let recentBreakMinutes: Int
}

struct UserInputData: Codable {
    let journalingDone: Bool
    let meditationDone: Bool
    let deepWorkDetected: Bool
    let hoursSinceLastCheckIn: Int
    let negativeJournal: Bool
    let positiveJournal: Bool
    let gratitudeLogged: Bool
    let deepConnectionDetected: Bool
    let mindfulnessDone: Bool
    let messageCount: Int
    let callDuration: Int
    let screenTimeSocialMedia: Int
}

struct FinancialData {
    let spentToday: Double
    let budgetLimit: Double
    let earnedToday: Double
    let targetIncome: Double
    let intentionalSpending: Bool
    let didReflect: Bool
}
