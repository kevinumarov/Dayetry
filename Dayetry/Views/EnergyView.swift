import SwiftUI
import SwiftData

struct EnergyView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var energySystem: EnergyEngineCore
    @State private var showingUserInput = false
    
    init() {
        // Initialize with model context
        let context = ModelContext(try! ModelContainer(for: EnergyLog.self))
        _energySystem = StateObject(wrappedValue: EnergyEngineCore(modelContext: context))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                headerSection
                
                if let energies = energySystem.currentEnergies {
                    energyCardsSection(energies: energies)
                } else {
                    loadingSection
                }
                
                quickActionsSection
            }
            .padding(.horizontal, 16)
        }
        .background(Color(hex: "EEF2FF").ignoresSafeArea())
        .onAppear {
            energySystem.startScheduledEvaluations()
        }
        .sheet(isPresented: $showingUserInput) {
            UserInputView(userInputManager: energySystem.userInputManager)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dayetry")
                        .font(.custom("PPMori-SemiBold", size: 36))
                        .foregroundColor(.black)
                    
                    if let energies = energySystem.currentEnergies {
                        Text("Prime Energy: \(Int(energies.primeEnergyScore))%")
                            .font(.custom("PPMori-Regular", size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingUserInput = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 24)
        }
    }
    
    private func energyCardsSection(energies: EnergySnapshot) -> some View {
        VStack(spacing: 24) {
            EnergyModuleCard(
                iconName: "mentalEnergy",
                title: "Mental Energy",
                subtitle: getEnergySubtitle(for: energies.mentalEnergy, type: "mental"),
                valueText: "\(Int(energies.mentalEnergy))%",
                progress: energies.mentalEnergy / 100.0,
                timeText: getTimeText(for: "mental"),
                valueIsCurrency: false,
                valueUnit: nil,
                secondaryValue: nil
            )
            
            EnergyModuleCard(
                iconName: "physicalEnergy",
                title: "Physical Energy",
                subtitle: getEnergySubtitle(for: energies.physicalEnergy, type: "physical"),
                valueText: "\(Int(energies.physicalEnergy))%",
                progress: energies.physicalEnergy / 100.0,
                timeText: getTimeText(for: "physical"),
                valueIsCurrency: false,
                valueUnit: nil,
                secondaryValue: nil
            )
            
            EnergyModuleCard(
                iconName: "financialEnergy",
                title: "Financial Energy",
                subtitle: getEnergySubtitle(for: energies.financialEnergy, type: "financial"),
                valueText: "\(Int(energies.financialEnergy))%",
                progress: energies.financialEnergy / 100.0,
                timeText: getTimeText(for: "financial"),
                valueIsCurrency: false,
                valueUnit: nil,
                secondaryValue: nil
            )
            
            EnergyModuleCard(
                iconName: "emotionalEnergy",
                title: "Emotional Energy",
                subtitle: getEnergySubtitle(for: energies.emotionalEnergy, type: "emotional"),
                valueText: "\(Int(energies.emotionalEnergy))%",
                progress: energies.emotionalEnergy / 100.0,
                timeText: getTimeText(for: "emotional"),
                valueIsCurrency: false,
                valueUnit: nil,
                secondaryValue: nil
            )
        }
        .padding(.horizontal, 8)
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Calculating your energy levels...")
                .font(.custom("PPMori-Medium", size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.custom("PPMori-SemiBold", size: 20))
                .foregroundColor(.black)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionButton(
                    icon: "book.fill",
                    title: "Journal",
                    isCompleted: energySystem.userInputManager.journalingDone
                ) {
                    showingUserInput = true
                }
                
                QuickActionButton(
                    icon: "brain.head.profile",
                    title: "Meditate",
                    isCompleted: energySystem.userInputManager.meditationDone
                ) {
                    showingUserInput = true
                }
                
                QuickActionButton(
                    icon: "heart.fill",
                    title: "Gratitude",
                    isCompleted: energySystem.userInputManager.gratitudeLogged
                ) {
                    showingUserInput = true
                }
                
                QuickActionButton(
                    icon: "desktopcomputer",
                    title: "Deep Work",
                    isCompleted: energySystem.userInputManager.deepWorkDetected
                ) {
                    showingUserInput = true
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Helper Methods
    private func getEnergySubtitle(for level: Double, type: String) -> String {
        switch level {
        case 80...100:
            return getHighEnergyMessage(for: type)
        case 60..<80:
            return getGoodEnergyMessage(for: type)
        case 40..<60:
            return getMediumEnergyMessage(for: type)
        case 20..<40:
            return getLowEnergyMessage(for: type)
        default:
            return getCriticalEnergyMessage(for: type)
        }
    }
    
    private func getHighEnergyMessage(for type: String) -> String {
        switch type {
        case "mental": return "Your mind is sharp and focused"
        case "physical": return "Your body is ready to conquer the world"
        case "financial": return "Your finances are well managed"
        case "emotional": return "You're feeling emotionally balanced"
        default: return "Energy levels are excellent"
        }
    }
    
    private func getGoodEnergyMessage(for type: String) -> String {
        switch type {
        case "mental": return "Good mental clarity and focus"
        case "physical": return "Feeling strong and energetic"
        case "financial": return "Financial situation is stable"
        case "emotional": return "Emotionally stable and positive"
        default: return "Energy levels are good"
        }
    }
    
    private func getMediumEnergyMessage(for type: String) -> String {
        switch type {
        case "mental": return "Mental energy could use a boost"
        case "physical": return "Consider some light exercise"
        case "financial": return "Keep an eye on your spending"
        case "emotional": return "Take time for self-care"
        default: return "Energy levels are moderate"
        }
    }
    
    private func getLowEnergyMessage(for type: String) -> String {
        switch type {
        case "mental": return "Time for a mental break"
        case "physical": return "Your body needs rest or movement"
        case "financial": return "Review your financial habits"
        case "emotional": return "Consider reaching out to someone"
        default: return "Energy levels need attention"
        }
    }
    
    private func getCriticalEnergyMessage(for type: String) -> String {
        switch type {
        case "mental": return "Mental fatigue detected - rest needed"
        case "physical": return "Physical energy critically low"
        case "financial": return "Financial stress may be affecting you"
        case "emotional": return "Emotional support recommended"
        default: return "Critical energy levels"
        }
    }
    
    private func getTimeText(for type: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "Updated \(formatter.string(from: Date()))"
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : .blue)
                
                Text(title)
                    .font(.custom("PPMori-Medium", size: 14))
                    .foregroundColor(.primary)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EnergyView()
}
