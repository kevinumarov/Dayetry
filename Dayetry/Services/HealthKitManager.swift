import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var sleepHours: Double = 0.0
    @Published var stepCount: Int = 0
    @Published var didWorkout: Bool = false
    @Published var activeEnergyBurned: Double = 0.0
    @Published var restingHeartRate: Double = 0.0
    
    // Health data types we want to read
    private let typesToRead: Set<HKObjectType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]
    
    init() {
        checkHealthKitAvailability()
    }
    
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        requestAuthorization()
    }
    
    func requestAuthorization() {
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.fetchAllHealthData()
                } else if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchAllHealthData() {
        guard isAuthorized else { return }
        
        fetchSleepData()
        fetchStepCount()
        fetchWorkoutData()
        fetchActiveEnergyBurned()
        fetchRestingHeartRate()
    }
    
    // MARK: - Sleep Data
    private func fetchSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            
            guard let samples = samples as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let sleepSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue || $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue || $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
            
            let totalSleepTime = sleepSamples.reduce(0) { total, sample in
                return total + sample.endDate.timeIntervalSince(sample.startDate)
            }
            
            DispatchQueue.main.async {
                self?.sleepHours = totalSleepTime / 3600 // Convert seconds to hours
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Step Count
    private func fetchStepCount() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            
            guard let result = result, let sum = result.sumQuantity(), error == nil else {
                print("Error fetching step count: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Workout Data
    private func fetchWorkoutData() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Error fetching workout data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.didWorkout = !workouts.isEmpty
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Active Energy Burned
    private func fetchActiveEnergyBurned() {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            
            guard let result = result, let sum = result.sumQuantity(), error == nil else {
                print("Error fetching active energy: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.activeEnergyBurned = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Resting Heart Rate
    private func fetchRestingHeartRate() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: now)! // Last 7 days
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            
            guard let samples = samples as? [HKQuantitySample], let sample = samples.first, error == nil else {
                print("Error fetching resting heart rate: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.restingHeartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Computed Properties for Energy System
    var healthData: HealthData {
        return HealthData(
            sleepHours: sleepHours,
            stepCount: stepCount,
            didWorkout: didWorkout,
            hydrationCount: calculateHydrationScore(),
            dietScore: calculateDietScore(),
            stressScore: calculateStressScore()
        )
    }
    
    // Helper methods for calculated metrics
    private func calculateHydrationScore() -> Int {
        // Estimate based on activity level - this could be enhanced with actual hydration tracking
        let baseHydration = 6
        let activityBonus = stepCount > 8000 ? 2 : (stepCount > 5000 ? 1 : 0)
        return min(baseHydration + activityBonus, 10)
    }
    
    private func calculateDietScore() -> Double {
        // Estimate based on activity and time of day - this could be enhanced with nutrition data
        let hour = Calendar.current.component(.hour, from: Date())
        let baseScore = 7.0
        let timeBonus = (hour >= 7 && hour <= 9) || (hour >= 12 && hour <= 14) || (hour >= 18 && hour <= 20) ? 1.0 : 0.0
        return min(baseScore + timeBonus, 10.0)
    }
    
    private func calculateStressScore() -> Double {
        // Estimate based on heart rate and activity - lower is better for stress
        let baseStress = 3.0
        let heartRateStress = restingHeartRate > 80 ? 2.0 : (restingHeartRate > 70 ? 1.0 : 0.0)
        let activityRelief = didWorkout ? -1.0 : 0.0
        return max(baseStress + heartRateStress + activityRelief, 1.0)
    }
}
