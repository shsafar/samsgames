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
    @StateObject private var themeManager = AppThemeManager()
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
                        .environmentObject(themeManager)
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
