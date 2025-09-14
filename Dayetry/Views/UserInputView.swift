import SwiftUI

struct UserInputView: View {
    @ObservedObject var userInputManager: UserInputManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var journalText: String = ""
    @State private var meditationMinutes: Int = 0
    @State private var showingJournalSheet = false
    @State private var showingMeditationSheet = false
    @State private var showingGratitudeSheet = false
    @State private var showingDeepWorkSheet = false
    @State private var showingConnectionSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    dailyActivitiesSection
                    
                    wellnessSection
                    
                    socialSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Daily Check-in")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        userInputManager.updateCheckIn()
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingJournalSheet) {
            JournalingView(userInputManager: userInputManager)
        }
        .sheet(isPresented: $showingMeditationSheet) {
            MeditationView(userInputManager: userInputManager)
        }
        .sheet(isPresented: $showingGratitudeSheet) {
            GratitudeView(userInputManager: userInputManager)
        }
        .sheet(isPresented: $showingDeepWorkSheet) {
            DeepWorkView(userInputManager: userInputManager)
        }
        .sheet(isPresented: $showingConnectionSheet) {
            SocialConnectionView(userInputManager: userInputManager)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How's your day going?")
                .font(.custom("PPMori-SemiBold", size: 24))
                .foregroundColor(.primary)
            
            Text("Track your activities to help Dayetry calculate your energy levels")
                .font(.custom("PPMori-Regular", size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dailyActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Activities")
                .font(.custom("PPMori-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ActivityCard(
                    icon: "book.fill",
                    title: "Journaling",
                    isCompleted: userInputManager.journalingDone,
                    action: { showingJournalSheet = true }
                )
                
                ActivityCard(
                    icon: "brain.head.profile",
                    title: "Meditation",
                    isCompleted: userInputManager.meditationDone,
                    action: { showingMeditationSheet = true }
                )
            }
        }
    }
    
    private var wellnessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wellness")
                .font(.custom("PPMori-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ActivityCard(
                    icon: "heart.fill",
                    title: "Gratitude",
                    isCompleted: userInputManager.gratitudeLogged,
                    action: { showingGratitudeSheet = true }
                )
                
                ActivityCard(
                    icon: "desktopcomputer",
                    title: "Deep Work",
                    isCompleted: userInputManager.deepWorkDetected,
                    action: { showingDeepWorkSheet = true }
                )
            }
        }
    }
    
    private var socialSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Social Connection")
                .font(.custom("PPMori-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            ActivityCard(
                icon: "person.2.fill",
                title: "Social Connection",
                subtitle: userInputManager.deepConnectionDetected ? "Deep connection made" : "Log your social interactions",
                isCompleted: userInputManager.deepConnectionDetected,
                action: { showingConnectionSheet = true }
            )
        }
    }
}

struct ActivityCard: View {
    let icon: String
    let title: String
    var subtitle: String?
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isCompleted ? .green : .blue)
                    
                    Spacer()
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("PPMori-SemiBold", size: 16))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom("PPMori-Regular", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(height: 100)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Individual Activity Views

struct JournalingView: View {
    @ObservedObject var userInputManager: UserInputManager
    @Environment(\.dismiss) private var dismiss
    @State private var journalText: String = ""
    @State private var isPositive: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How are you feeling today?")
                    .font(.custom("PPMori-SemiBold", size: 24))
                    .multilineTextAlignment(.center)
                
                Picker("Mood", selection: $isPositive) {
                    Text("Positive").tag(true)
                    Text("Challenging").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextEditor(text: $journalText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .frame(minHeight: 200)
                
                Button("Save Journal Entry") {
                    userInputManager.logJournaling(isPositive: isPositive)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(journalText.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct MeditationView: View {
    @ObservedObject var userInputManager: UserInputManager
    @Environment(\.dismiss) private var dismiss
    @State private var minutes: Int = 5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How long did you meditate?")
                    .font(.custom("PPMori-SemiBold", size: 24))
                    .multilineTextAlignment(.center)
                
                Picker("Minutes", selection: $minutes) {
                    ForEach(1...60, id: \.self) { minute in
                        Text("\(minute) min").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 200)
                
                Button("Log Meditation") {
                    userInputManager.logMeditation(duration: minutes)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Meditation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct GratitudeView: View {
    @ObservedObject var userInputManager: UserInputManager
    @Environment(\.dismiss) private var dismiss
    @State private var gratitudeItems: [String] = ["", "", ""]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("What are you grateful for today?")
                    .font(.custom("PPMori-SemiBold", size: 24))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { index in
                        TextField("Gratitude \(index + 1)", text: $gratitudeItems[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Button("Save Gratitude") {
                    userInputManager.logGratitude()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(gratitudeItems.allSatisfy { $0.isEmpty })
                
                Spacer()
            }
            .padding()
            .navigationTitle("Gratitude")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct DeepWorkView: View {
    @ObservedObject var userInputManager: UserInputManager
    @Environment(\.dismiss) private var dismiss
    @State private var hours: Int = 1
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How long did you focus on deep work?")
                    .font(.custom("PPMori-SemiBold", size: 24))
                    .multilineTextAlignment(.center)
                
                Picker("Hours", selection: $hours) {
                    ForEach(1...8, id: \.self) { hour in
                        Text("\(hour) hour\(hour > 1 ? "s" : "")").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 200)
                
                Button("Log Deep Work") {
                    userInputManager.logDeepWork(duration: hours * 60)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Deep Work")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct SocialConnectionView: View {
    @ObservedObject var userInputManager: UserInputManager
    @Environment(\.dismiss) private var dismiss
    @State private var connectionType: ConnectionType = .call
    @State private var duration: Int = 15
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Log your social connections")
                    .font(.custom("PPMori-SemiBold", size: 24))
                    .multilineTextAlignment(.center)
                
                Picker("Connection Type", selection: $connectionType) {
                    Text("Phone Call").tag(ConnectionType.call)
                    Text("Text Message").tag(ConnectionType.message)
                    Text("In Person").tag(ConnectionType.inPerson)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if connectionType != .message {
                    VStack {
                        Text("Duration")
                            .font(.custom("PPMori-Medium", size: 16))
                        
                        Picker("Duration", selection: $duration) {
                            ForEach([5, 10, 15, 30, 60, 120], id: \.self) { minutes in
                                Text("\(minutes) min").tag(minutes)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 150)
                    }
                }
                
                Button("Log Connection") {
                    userInputManager.logSocialConnection(type: connectionType, duration: duration)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Social Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    UserInputView(userInputManager: UserInputManager())
}
