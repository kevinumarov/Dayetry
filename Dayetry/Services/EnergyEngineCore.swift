//
//  EnergyEngineCore.swift
//  Dayetry
//
//  Created by Kevin Umarov 
//

import Foundation
import Combine
import SwiftData

class EnergyEngineCore: ObservableObject {
    private let configManager = EnergyConfigManager()
    private let crossEnergyCalculator = CrossEnergyCalculator()
    private var evaluationTimer: Timer?
    private var modelContext: ModelContext
    private var energyLogDataManager: EnergyLogDataManager
    
    // Real data managers
    @Published var healthKitManager = HealthKitManager()
    @Published var userInputManager = UserInputManager()
    
    // Screen Time Manager (conditional based on iOS version)
    private var screenTimeManager: Any?
    
    @Published var currentEnergies: EnergySnapshot?
    @Published var isCalculating = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.energyLogDataManager = EnergyLogDataManager(modelContext: modelContext)
        
        // Initialize Screen Time Manager based on iOS version
        if #available(iOS 15.0, *) {
            self.screenTimeManager = ScreenTimeManager()
        } else {
            self.screenTimeManager = ScreenTimeManagerFallback()
        }
        
        configManager.loadConfiguration()
        setupBindings()
    }
    
    private func setupBindings() {
        // Refresh energy calculations when health data updates
        healthKitManager.$sleepHours
            .combineLatest(healthKitManager.$stepCount, healthKitManager.$didWorkout)
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.evaluateEnergies()
            }
            .store(in: &cancellables)
        
        // Refresh when user input changes
        userInputManager.$journalingDone
            .combineLatest(userInputManager.$meditationDone, userInputManager.$gratitudeLogged)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.evaluateEnergies()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Methods
    func startScheduledEvaluations() {
        stopScheduledEvaluations()
        
        let config = configManager.config?.evaluationSchedule
        let frequency = TimeInterval(config?.frequencyMinutes ?? 60) * 60
        
        evaluationTimer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] _ in
            self?.evaluateEnergies()
        }
        
        // Initial evaluation
        evaluateEnergies()
    }
    
    func stopScheduledEvaluations() {
        evaluationTimer?.invalidate()
        evaluationTimer = nil
    }
    
    func evaluateEnergies() {
        guard !isCalculating else { return }
        
        isCalculating = true
        
        Task {
            let energies = await calculateAllEnergies()
            
            await MainActor.run {
                self.currentEnergies = energies
                self.isCalculating = false
            }
        }
    }
    
    // MARK: - Energy Calculations
    private func calculateAllEnergies() async -> EnergySnapshot {
        let inputs = await gatherInputs()
        
        // Calculate individual energies
        let mentalEnergy = calculateMentalEnergy(inputs: inputs)
        let physicalEnergy = calculatePhysicalEnergy(inputs: inputs)
        let financialEnergy = calculateFinancialEnergy(inputs: inputs)
        let emotionalEnergy = calculateEmotionalEnergy(inputs: inputs)
        
        // Apply cross-energy influences
        let adjustedEnergies = crossEnergyCalculator.applyCrossEnergyInfluences(
            mental: mentalEnergy,
            physical: physicalEnergy,
            financial: financialEnergy,
            emotional: emotionalEnergy,
            config: configManager.config?.crossEnergyDependencies ?? [:]
        )
        
        // Calculate prime energy score
        let primeScore = calculatePrimeEnergyScore(energies: adjustedEnergies)
        
        return EnergySnapshot(
            timestamp: Date(),
            mentalEnergy: adjustedEnergies.mental,
            physicalEnergy: adjustedEnergies.physical,
            financialEnergy: adjustedEnergies.financial,
            emotionalEnergy: adjustedEnergies.emotional,
            primeEnergyScore: primeScore
        )
    }
    
    private func calculateMentalEnergy(inputs: EnergyInputs) -> Double {
        guard let config = configManager.config?.energyEngines["mental"] else { 
            print("⚠️ Mental energy config not found, returning default 50.0")
            return 50.0 
        }
        
        var energy = 100.0
        
        // Apply base decay
        let hoursSinceWake = inputs.timeData.hoursSinceWake
        let decayRate = config.baseDecay.ratePerHour
        let maxDecayHours = Double(config.baseDecay.maxHours)
        let decayHours = min(hoursSinceWake, maxDecayHours)
        energy -= decayHours * decayRate * 100
        
        // Apply drain factors
        for (factorName, factorConfig) in config.drainFactors {
            let shouldApply = shouldApplyFactor(factorName: factorName, inputs: inputs, config: factorConfig)
            if shouldApply {
                energy -= factorConfig.impact
                logEnergyEvent(energyType: .mental, eventType: .drain, eventDescription: factorConfig.description, impact: -factorConfig.impact)
            }
        }
        
        // Apply boost factors
        for (factorName, factorConfig) in config.boostFactors {
            let shouldApply = shouldApplyBoostFactor(factorName: factorName, inputs: inputs, config: factorConfig)
            if shouldApply {
                energy += factorConfig.impact
                logEnergyEvent(energyType: .mental, eventType: .boost, eventDescription: factorConfig.description, impact: factorConfig.impact)
            }
        }
        
        let finalEnergy = max(0, min(100, energy))
        return finalEnergy
    }
    
    private func calculatePhysicalEnergy(inputs: EnergyInputs) -> Double {
        guard let config = configManager.config?.energyEngines["physical"] else { return 50.0 }
        
        var energy = 100.0
        
        // Apply base decay
        let hoursSinceWake = inputs.timeData.hoursSinceWake
        let decayRate = config.baseDecay.ratePerHour
        let maxDecayHours = Double(config.baseDecay.maxHours)
        let decayHours = min(hoursSinceWake, maxDecayHours)
        energy -= decayHours * decayRate * 100
        
        // Apply drain factors
        for (factorName, factorConfig) in config.drainFactors {
            let shouldApply = shouldApplyFactor(factorName: factorName, inputs: inputs, config: factorConfig)
            if shouldApply {
                energy -= factorConfig.impact
                logEnergyEvent(energyType: .physical, eventType: .drain, eventDescription: factorConfig.description, impact: -factorConfig.impact)
            }
        }
        
        // Apply boost factors
        for (factorName, factorConfig) in config.boostFactors {
            let shouldApply = shouldApplyBoostFactor(factorName: factorName, inputs: inputs, config: factorConfig)
            if shouldApply {
                energy += factorConfig.impact
                logEnergyEvent(energyType: .physical, eventType: .boost, eventDescription: factorConfig.description, impact: factorConfig.impact)
            }
        }
        
        return max(0, min(100, energy))
    }
    
    private func calculateFinancialEnergy(inputs: EnergyInputs) -> Double {
        guard let config = configManager.config?.energyEngines["financial"] else { return 50.0 }
        
        var energy = 100.0
        
        // Apply base decay
        let hoursSinceWake = inputs.timeData.hoursSinceWake
        let decayRate = config.baseDecay.ratePerHour
        let maxDecayHours = Double(config.baseDecay.maxHours)
        let decayHours = min(hoursSinceWake, maxDecayHours)
        energy -= decayHours * decayRate * 100
        
        // Apply drain factors
        for (factorName, factorConfig) in config.drainFactors {
            let shouldApply = shouldApplyFactor(factorName: factorName, inputs: inputs, config: factorConfig)
            if shouldApply {
                energy -= factorConfig.impact
                logEnergyEvent(energyType: .financial, eventType: .drain, eventDescription: factorConfig.description, impact: -factorConfig.impact)
            }
        }
        
        // Apply boost factors
        for (factorName, factorConfig) in config.boostFactors {
            let shouldApply = shouldApplyBoostFactor(factorName: factorName, inputs: inputs, config: factorConfig)
            if shouldApply {
                energy += factorConfig.impact
                logEnergyEvent(energyType: .financial, eventType: .boost, eventDescription: factorConfig.description, impact: factorConfig.impact)
            }
        }
        
        return max(0, min(100, energy))
    }
    
    private func calculateEmotionalEnergy(inputs: EnergyInputs) -> Double {
        guard let config = configManager.config?.energyEngines["emotional"] else { return 50.0 }
        
        var energy = 100.0
        
        // Apply base decay
        let hoursSinceWake = inputs.timeData.hoursSinceWake
        let decayRate = config.baseDecay.ratePerHour
        let maxDecayHours = Double(config.baseDecay.maxHours)
        let decayHours = min(hoursSinceWake, maxDecayHours)
        energy -= decayHours * decayRate * 100
        
        // Apply drain factors
        for (factorName, factorConfig) in config.drainFactors {
            let shouldApply = shouldApplyFactor(factorName: factorName, inputs: inputs, config: factorConfig)
            if shouldApply {
                energy -= factorConfig.impact
                logEnergyEvent(energyType: .emotional, eventType: .drain, eventDescription: factorConfig.description, impact: -factorConfig.impact)
            }
        }
        
        // Apply boost factors
        for (factorName, factorConfig) in config.boostFactors {
            let shouldApply = shouldApplyBoostFactor(factorName: factorName, inputs: inputs, config: factorConfig)
            if shouldApply {
                energy += factorConfig.impact
                logEnergyEvent(energyType: .emotional, eventType: .boost, eventDescription: factorConfig.description, impact: factorConfig.impact)
            }
        }
        
        return max(0, min(100, energy))
    }
    
    private func calculatePrimeEnergyScore(energies: (mental: Double, physical: Double, financial: Double, emotional: Double)) -> Double {
        guard let weights = configManager.config?.primeScoreWeights else {
            return (energies.mental + energies.physical + energies.financial + energies.emotional) / 4
        }
        
        return (energies.mental * weights.mental) +
               (energies.physical * weights.physical) +
               (energies.financial * weights.financial) +
               (energies.emotional * weights.emotional)
    }
    
    // MARK: - Input Gathering (Now using real data!)
    private func gatherInputs() async -> EnergyInputs {
        // Get real health data from HealthKit
        let healthData = await MainActor.run { healthKitManager.healthData }
        
        // Get real app usage data from Screen Time
        let appUsageData: AppUsageData
        if #available(iOS 15.0, *), let manager = screenTimeManager as? ScreenTimeManager {
            appUsageData = await MainActor.run { manager.appUsageData }
        } else if let manager = screenTimeManager as? ScreenTimeManagerFallback {
            appUsageData = await MainActor.run { manager.appUsageData }
        } else {
            // Fallback
            appUsageData = AppUsageData(appSwitchCount: 20, screenTimeMinutes: 120, shortFormContentMinutes: 15, recentBreakMinutes: 10)
        }
        
        // Get real user input data
        var userInputData = await MainActor.run { userInputManager.userInputData }
        
        // Update social media time from screen time data
        if #available(iOS 15.0, *), let manager = screenTimeManager as? ScreenTimeManager {
            let socialMediaTime = await MainActor.run { manager.socialMediaMinutes }
            userInputData = UserInputData(
                journalingDone: userInputData.journalingDone,
                meditationDone: userInputData.meditationDone,
                deepWorkDetected: userInputData.deepWorkDetected,
                hoursSinceLastCheckIn: userInputData.hoursSinceLastCheckIn,
                negativeJournal: userInputData.negativeJournal,
                positiveJournal: userInputData.positiveJournal,
                gratitudeLogged: userInputData.gratitudeLogged,
                deepConnectionDetected: userInputData.deepConnectionDetected,
                mindfulnessDone: userInputData.mindfulnessDone,
                messageCount: userInputData.messageCount,
                callDuration: userInputData.callDuration,
                screenTimeSocialMedia: socialMediaTime
            )
        }
        
        // Calculate time data
        let currentTime = Date()
        let calendar = Calendar.current
        let wakeTime = calendar.date(byAdding: .hour, value: -8, to: currentTime) ?? currentTime
        let hoursSinceWake = currentTime.timeIntervalSince(wakeTime) / 3600
        
        let timeData = TimeData(
            currentTime: currentTime,
            wakeTime: wakeTime,
            hoursSinceWake: max(hoursSinceWake, 0)
        )
        
        // Financial data remains mock for now (as requested)
        let financialData = FinancialData(
            spentToday: 25000.0,
            budgetLimit: 50000.0,
            earnedToday: 0.0,
            targetIncome: 100000.0,
            intentionalSpending: true,
            didReflect: true
        )
        
        return EnergyInputs(
            timeData: timeData,
            healthData: healthData,
            appUsageData: appUsageData,
            userInputData: userInputData,
            financialData: financialData
        )
    }
    
    // MARK: - Factor Application Logic
    private func shouldApplyFactor(factorName: String, inputs: EnergyInputs, config: FactorConfig) -> Bool {
        switch factorName {
        case "app_switching":
            return Double(inputs.appUsageData.appSwitchCount) >= (config.threshold ?? 0)
        case "screen_time":
            return Double(inputs.appUsageData.screenTimeMinutes) >= (config.threshold ?? 0)
        case "short_form_content":
            return Double(inputs.appUsageData.shortFormContentMinutes) >= (config.threshold ?? 0)
        case "insufficient_break":
            return Double(inputs.appUsageData.recentBreakMinutes) < (config.threshold ?? 0)
        case "poor_sleep":
            return inputs.healthData.sleepHours < (config.threshold ?? 0)
        case "low_activity":
            return Double(inputs.healthData.stepCount) < (config.threshold ?? 0)
        case "no_workout":
            return !inputs.healthData.didWorkout
        case "poor_hydration":
            return Double(inputs.healthData.hydrationCount) < (config.threshold ?? 0)
        case "poor_diet":
            return inputs.healthData.dietScore < (config.threshold ?? 0)
        case "high_stress":
            return inputs.healthData.stressScore > (config.threshold ?? 0)
        case "overspending":
            return inputs.financialData.spentToday > inputs.financialData.budgetLimit
        case "no_income":
            return inputs.financialData.earnedToday < (config.threshold ?? 0)
        case "unintentional_spending":
            return !inputs.financialData.intentionalSpending
        case "no_reflection":
            return !inputs.financialData.didReflect
        case "long_check_in_gap":
            return Double(inputs.userInputData.hoursSinceLastCheckIn) > (config.threshold ?? 0)
        case "negative_journal":
            return inputs.userInputData.negativeJournal
        case "no_positive_journal":
            return !inputs.userInputData.positiveJournal
        case "no_gratitude":
            return !inputs.userInputData.gratitudeLogged
        case "no_connection":
            return !inputs.userInputData.deepConnectionDetected
        case "excessive_social_media":
            return Double(inputs.userInputData.screenTimeSocialMedia) > (config.threshold ?? 0)
        default:
            return false
        }
    }
    
    private func shouldApplyBoostFactor(factorName: String, inputs: EnergyInputs, config: FactorConfig) -> Bool {
        switch factorName {
        case "meditation":
            return inputs.userInputData.meditationDone
        case "journaling":
            return inputs.userInputData.journalingDone
        case "deep_work":
            return inputs.userInputData.deepWorkDetected
        case "workout":
            return inputs.healthData.didWorkout
        case "good_sleep":
            return inputs.healthData.sleepHours >= (config.threshold ?? 0)
        case "high_activity":
            return Double(inputs.healthData.stepCount) >= (config.threshold ?? 0)
        case "good_hydration":
            return Double(inputs.healthData.hydrationCount) >= (config.threshold ?? 0)
        case "good_diet":
            return inputs.healthData.dietScore >= (config.threshold ?? 0)
        case "low_stress":
            return inputs.healthData.stressScore <= (config.threshold ?? 0)
        case "under_budget":
            return inputs.financialData.spentToday < inputs.financialData.budgetLimit
        case "income_earned":
            return inputs.financialData.earnedToday > 0
        case "intentional_spending":
            return inputs.financialData.intentionalSpending
        case "reflection_done":
            return inputs.financialData.didReflect
        case "recent_check_in":
            return Double(inputs.userInputData.hoursSinceLastCheckIn) <= (config.threshold ?? 0)
        case "positive_journal":
            return inputs.userInputData.positiveJournal
        case "gratitude_logged":
            return inputs.userInputData.gratitudeLogged
        case "deep_connection":
            return inputs.userInputData.deepConnectionDetected
        case "mindfulness_practice":
            return inputs.userInputData.meditationDone
        default:
            return false
        }
    }
    
    // MARK: - Energy Logging
    private func logEnergyEvent(energyType: EnergyType, eventType: EnergyEventType, eventDescription: String, impact: Double) {
        let log = EnergyLog(
            timestamp: Date(),
            energyType: energyType.rawValue,
            eventType: eventType,
            eventDescription: eventDescription,
            impact: impact,
            source: LogSource.automatic.rawValue
        )
        
        modelContext.insert(log)
        try? modelContext.save()
    }
    
    // MARK: - Manual Energy Logging
    func logManualEnergyEvent(energyType: EnergyType, eventType: EnergyEventType, eventDescription: String, impact: Double) {
        let log = EnergyLog(
            timestamp: Date(),
            energyType: energyType.rawValue,
            eventType: eventType,
            eventDescription: eventDescription,
            impact: impact,
            source: LogSource.manual.rawValue
        )
        
        modelContext.insert(log)
        try? modelContext.save()
    }
    
    // MARK: - Debug/Test Methods
    func testEnergyCalculations() {
        print("🧪 Testing Energy Calculations...")
        print("📊 Config loaded: \(configManager.config != nil)")
        print("📊 Number of engines: \(configManager.config?.energyEngines.count ?? 0)")
        
        Task {
            let inputs = await gatherInputs()
            print("📊 Sample inputs gathered")
            print("  - Sleep hours: \(inputs.healthData.sleepHours)")
            print("  - Step count: \(inputs.healthData.stepCount)")
            print("  - Screen time: \(inputs.appUsageData.screenTimeMinutes)")
            print("  - Journaling done: \(inputs.userInputData.journalingDone)")
            
            let mental = calculateMentalEnergy(inputs: inputs)
            let physical = calculatePhysicalEnergy(inputs: inputs)
            let financial = calculateFinancialEnergy(inputs: inputs)
            let emotional = calculateEmotionalEnergy(inputs: inputs)
            
            print("📊 Calculated energies:")
            print("  - Mental: \(mental)%")
            print("  - Physical: \(physical)%")
            print("  - Financial: \(financial)%")
            print("  - Emotional: \(emotional)%")
        }
    }
}
