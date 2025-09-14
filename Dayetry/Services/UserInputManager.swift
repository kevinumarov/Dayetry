import Foundation
import Combine

class UserInputManager: ObservableObject {
    @Published var journalingDone: Bool = false
    @Published var meditationDone: Bool = false
    @Published var deepWorkDetected: Bool = false
    @Published var negativeJournal: Bool = false
    @Published var positiveJournal: Bool = false
    @Published var gratitudeLogged: Bool = false
    @Published var deepConnectionDetected: Bool = false
    @Published var mindfulnessDone: Bool = false
    @Published var messageCount: Int = 0
    @Published var callDuration: Int = 0
    @Published var lastCheckInTime: Date = Date()
    
    private let persistenceManager = PersistenceManager.shared
    
    init() {
        loadTodaysData()
        setupDailyReset()
    }
    
    private func loadTodaysData() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "user_input_\(today.timeIntervalSince1970)"
        
        if let data = persistenceManager.load(forKey: key, as: UserInputData.self) {
            journalingDone = data.journalingDone
            meditationDone = data.meditationDone
            deepWorkDetected = data.deepWorkDetected
            negativeJournal = data.negativeJournal
            positiveJournal = data.positiveJournal
            gratitudeLogged = data.gratitudeLogged
            deepConnectionDetected = data.deepConnectionDetected
            mindfulnessDone = data.mindfulnessDone
            messageCount = data.messageCount
            callDuration = data.callDuration
        }
        
        if let lastCheckIn = persistenceManager.load(forKey: "last_check_in", as: Date.self) {
            lastCheckInTime = lastCheckIn
        }
    }
    
    private func saveTodaysData() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "user_input_\(today.timeIntervalSince1970)"
        
        let data = UserInputData(
            journalingDone: journalingDone,
            meditationDone: meditationDone,
            deepWorkDetected: deepWorkDetected,
            hoursSinceLastCheckIn: hoursSinceLastCheckIn,
            negativeJournal: negativeJournal,
            positiveJournal: positiveJournal,
            gratitudeLogged: gratitudeLogged,
            deepConnectionDetected: deepConnectionDetected,
            mindfulnessDone: mindfulnessDone,
            messageCount: messageCount,
            callDuration: callDuration,
            screenTimeSocialMedia: 0 // This will be provided by ScreenTimeManager
        )
        
        persistenceManager.save(data, forKey: key)
        persistenceManager.save(Date(), forKey: "last_check_in")
    }
    
    private func setupDailyReset() {
        // Reset data at midnight
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            let calendar = Calendar.current
            let now = Date()
            
            if calendar.component(.hour, from: now) == 0 && calendar.component(.minute, from: now) == 0 {
                self?.resetDailyData()
            }
        }
    }
    
    private func resetDailyData() {
        journalingDone = false
        meditationDone = false
        deepWorkDetected = false
        negativeJournal = false
        positiveJournal = false
        gratitudeLogged = false
        deepConnectionDetected = false
        mindfulnessDone = false
        messageCount = 0
        callDuration = 0
    }
    
    // MARK: - Public Methods
    func logJournaling(isPositive: Bool) {
        journalingDone = true
        if isPositive {
            positiveJournal = true
        } else {
            negativeJournal = true
        }
        saveTodaysData()
    }
    
    func logMeditation(duration: Int) {
        meditationDone = true
        mindfulnessDone = true
        saveTodaysData()
    }
    
    func logGratitude() {
        gratitudeLogged = true
        saveTodaysData()
    }
    
    func logDeepWork(duration: Int) {
        deepWorkDetected = true
        saveTodaysData()
    }
    
    func logSocialConnection(type: ConnectionType, duration: Int) {
        switch type {
        case .call:
            callDuration += duration
            deepConnectionDetected = duration > 10 // 10+ minute calls count as deep connection
        case .message:
            messageCount += 1
        case .inPerson:
            deepConnectionDetected = true
        }
        saveTodaysData()
    }
    
    func updateCheckIn() {
        lastCheckInTime = Date()
        saveTodaysData()
    }
    
    // MARK: - Computed Properties
    var hoursSinceLastCheckIn: Int {
        let hours = Date().timeIntervalSince(lastCheckInTime) / 3600
        return Int(hours)
    }
    
    var userInputData: UserInputData {
        return UserInputData(
            journalingDone: journalingDone,
            meditationDone: meditationDone,
            deepWorkDetected: deepWorkDetected,
            hoursSinceLastCheckIn: hoursSinceLastCheckIn,
            negativeJournal: negativeJournal,
            positiveJournal: positiveJournal,
            gratitudeLogged: gratitudeLogged,
            deepConnectionDetected: deepConnectionDetected,
            mindfulnessDone: mindfulnessDone,
            messageCount: messageCount,
            callDuration: callDuration,
            screenTimeSocialMedia: 0 // This will be updated by ScreenTimeManager
        )
    }
}

enum ConnectionType {
    case call
    case message
    case inPerson
}


