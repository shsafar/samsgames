//
//  SamsGamesApp.swift
//  Sam's Games
//
//  Unified daily puzzle game collection
//  Created: 2025
//

import SwiftUI

@main
struct SamsGamesApp: App {
    @StateObject private var dailyPuzzleManager = DailyPuzzleManager()
    @StateObject private var statisticsManager = StatisticsManager()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView(isPresented: $showSplash)
                        .transition(.opacity)
                } else {
                    MainMenuView()
                        .environmentObject(dailyPuzzleManager)
                        .environmentObject(statisticsManager)
                        .transition(.opacity)
                }
            }
        }
    }
}
