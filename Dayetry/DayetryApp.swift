//
//  DayetryApp.swift
//  Dayetry
//
//  Created by Kevin Umarov on 11/11/24.
//

import SwiftUI

@main
struct DayetryApp: App {
    @StateObject private var appState = AppState()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
