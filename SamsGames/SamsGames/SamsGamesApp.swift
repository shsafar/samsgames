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

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        }
    }
}
