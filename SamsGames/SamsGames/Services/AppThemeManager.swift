//
//  AppThemeManager.swift
//  Sam's Games
//
//  Manages app-wide dark mode settings
//

import SwiftUI

class AppThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    init() {
        // Load saved preference, default to system setting
        if UserDefaults.standard.object(forKey: "isDarkMode") != nil {
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        } else {
            // Default to system appearance
            self.isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }

    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }
}
