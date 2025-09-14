import Foundation
import DeviceActivity
import FamilyControls
import Combine

@available(iOS 15.0, *)
class ScreenTimeManager: ObservableObject {
    private let deviceActivityCenter = DeviceActivityCenter()
    
    @Published var isAuthorized = false
    @Published var screenTimeMinutes: Int = 0
    @Published var appSwitchCount: Int = 0
    @Published var shortFormContentMinutes: Int = 0
    @Published var socialMediaMinutes: Int = 0
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                await MainActor.run {
                    self.isAuthorized = true
                    self.fetchScreenTimeData()
                }
            } catch {
                print("Screen Time authorization failed: \(error.localizedDescription)")
                await MainActor.run {
                    self.isAuthorized = false
                    // Fallback to estimated data
                    self.useEstimatedScreenTimeData()
                }
            }
        }
    }
    
    private func fetchScreenTimeData() {
        // Note: DeviceActivity API is quite restricted and mainly works with scheduled monitoring
        // For a real implementation, you'd need to set up DeviceActivityMonitor
        // For now, we'll use estimated data based on time patterns
        useEstimatedScreenTimeData()
    }
    
    private func useEstimatedScreenTimeData() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let dayOfWeek = calendar.component(.weekday, from: Date())
        
        // Estimate screen time based on time of day and day of week
        let baseScreenTime = estimateBaseScreenTime(hour: hour, dayOfWeek: dayOfWeek)
        let estimatedSwitches = estimateAppSwitches(screenTime: baseScreenTime)
        let estimatedShortForm = estimateShortFormContent(hour: hour)
        let estimatedSocialMedia = estimateSocialMediaTime(hour: hour, dayOfWeek: dayOfWeek)
        
        DispatchQueue.main.async {
            self.screenTimeMinutes = baseScreenTime
            self.appSwitchCount = estimatedSwitches
            self.shortFormContentMinutes = estimatedShortForm
            self.socialMediaMinutes = estimatedSocialMedia
        }
    }
    
    private func estimateBaseScreenTime(hour: Int, dayOfWeek: Int) -> Int {
        let hoursSinceWake = max(hour - 7, 0) // Assuming 7 AM wake time
        
        // Base screen time per hour varies by time of day
        let screenTimePerHour: Int
        switch hour {
        case 7...9: screenTimePerHour = 15  // Morning routine
        case 10...12: screenTimePerHour = 25 // Work/productive time
        case 13...14: screenTimePerHour = 20 // Lunch break
        case 15...17: screenTimePerHour = 30 // Afternoon work
        case 18...20: screenTimePerHour = 35 // Evening leisure
        case 21...23: screenTimePerHour = 40 // Night leisure
        default: screenTimePerHour = 10
        }
        
        // Weekend adjustment
        let weekendMultiplier = (dayOfWeek == 1 || dayOfWeek == 7) ? 1.3 : 1.0
        
        return Int(Double(hoursSinceWake * screenTimePerHour) * weekendMultiplier)
    }
    
    private func estimateAppSwitches(screenTime: Int) -> Int {
        // Estimate app switches based on screen time (roughly 1 switch per 4 minutes)
        return max(screenTime / 4, 0)
    }
    
    private func estimateShortFormContent(hour: Int) -> Int {
        // Short form content (TikTok, Instagram Reels, etc.) peaks in evening
        switch hour {
        case 7...11: return Int.random(in: 5...15)
        case 12...17: return Int.random(in: 10...25)
        case 18...23: return Int.random(in: 20...45)
        default: return Int.random(in: 0...5)
        }
    }
    
    private func estimateSocialMediaTime(hour: Int, dayOfWeek: Int) -> Int {
        let baseTime: Int
        switch hour {
        case 7...9: baseTime = Int.random(in: 10...20)
        case 10...12: baseTime = Int.random(in: 5...15)
        case 13...14: baseTime = Int.random(in: 15...25)
        case 15...17: baseTime = Int.random(in: 10...20)
        case 18...23: baseTime = Int.random(in: 25...45)
        default: baseTime = Int.random(in: 0...5)
        }
        
        // Weekend adjustment
        let weekendMultiplier = (dayOfWeek == 1 || dayOfWeek == 7) ? 1.4 : 1.0
        return Int(Double(baseTime) * weekendMultiplier)
    }
    
    // MARK: - Computed Properties for Energy System
    var appUsageData: AppUsageData {
        return AppUsageData(
            appSwitchCount: appSwitchCount,
            screenTimeMinutes: screenTimeMinutes,
            shortFormContentMinutes: shortFormContentMinutes,
            recentBreakMinutes: calculateRecentBreakMinutes()
        )
    }
    
    private func calculateRecentBreakMinutes() -> Int {
        // Estimate break time based on current screen time patterns
        let hour = Calendar.current.component(.hour, from: Date())
        let recentActivity = screenTimeMinutes
        
        // If low recent activity, assume they're taking breaks
        if recentActivity < 30 {
            return Int.random(in: 15...30)
        } else if recentActivity < 60 {
            return Int.random(in: 5...15)
        } else {
            return Int.random(in: 0...5)
        }
    }
}

// Fallback for older iOS versions
class ScreenTimeManagerFallback: ObservableObject {
    @Published var isAuthorized = false
    @Published var screenTimeMinutes: Int = 0
    @Published var appSwitchCount: Int = 0
    @Published var shortFormContentMinutes: Int = 0
    @Published var socialMediaMinutes: Int = 0
    
    init() {
        // Use time-based estimation for older devices
        useTimeBasedEstimation()
    }
    
    private func useTimeBasedEstimation() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let hoursSinceWake = max(hour - 7, 0)
        
        screenTimeMinutes = hoursSinceWake * 20 // 20 minutes per hour average
        appSwitchCount = hoursSinceWake * 8 // 8 switches per hour
        shortFormContentMinutes = Int.random(in: 10...30)
        socialMediaMinutes = Int.random(in: 15...40)
    }
    
    var appUsageData: AppUsageData {
        return AppUsageData(
            appSwitchCount: appSwitchCount,
            screenTimeMinutes: screenTimeMinutes,
            shortFormContentMinutes: shortFormContentMinutes,
            recentBreakMinutes: Int.random(in: 5...20)
        )
    }
}
