//
//  DayetryApp.swift
//  Dayetry
//
//  Created by Kevin Umarov on 11/11/24.
//

import SwiftUI
import SwiftData

@main
struct DayetryApp: App {
    @StateObject private var appState = AppState()
    
    // SwiftData Model Container
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: EnergyLog.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .modelContainer(modelContainer)
        }
    }
}
