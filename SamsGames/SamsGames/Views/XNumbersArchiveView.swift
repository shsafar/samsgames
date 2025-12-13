//
//  XNumbersArchiveView.swift
//  Sam's Games
//
//  Generic archive view for any game (NYT Games style)
//

import SwiftUI

struct XNumbersArchiveView: View {
    let gameType: GameType

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedDate: Date?
    @State private var showPaywall = false

    // Brand color for the game
    private var brandColor: Color {
        switch gameType {
        case .sumStacks: return Color.orange
        case .wordStacks: return Color.mint
        case .xNumbers: return Color.blue
        case .wordInShapes: return Color.purple
        case .jushBox: return Color.green
        case .doubleBubble: return Color.pink
        case .diamondStack: return Color.indigo
        case .hashtagWords: return Color.teal
        case .traceWiz: return Color.cyan
        case .arrowRace: return Color.red
        case .diskBreak: return Color.yellow
        case .waterTable: return Color.blue.opacity(0.7)
        case .atomicNails: return Color.gray
        }
    }

    private var calendar: Calendar {
        Calendar.current
    }

    // Get the current week (S M T W T F S)
    private var weekDates: [Date?] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) // 1 = Sunday, 7 = Saturday

        var dates: [Date?] = []
        // Start from Sunday (weekday 1)
        for day in 1...7 {
            let daysToAdd = day - weekday
            if let date = calendar.date(byAdding: .day, value: daysToAdd, to: today) {
                // Only show dates up to today
                if date <= today {
                    dates.append(date)
                } else {
                    dates.append(nil)
                }
            } else {
                dates.append(nil)
            }
        }
        return dates
    }

    var body: some View {
        // If subscribed, show archive view directly
        if subscriptionManager.isSubscribedOrTestMode {
            ArchiveView(filterGameType: gameType)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        } else {
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    // Header
                    headerView

                    // Calendar week view
                    calendarWeekView
                        .padding(.top, 50)
                        .padding(.horizontal, 20)

                    Spacer()

                    // Subscription paywall overlay (centered)
                    subscriptionOverlay

                    Spacer()
                }
                .background(Color.white)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("The \(gameType.rawValue) Archive")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }

            Text("Choose a puzzle by date and solve.")
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    // MARK: - Calendar Week View

    private var calendarWeekView: some View {
        HStack(spacing: 8) {
            ForEach(0..<7) { index in
                VStack(spacing: 8) {
                    // Day letter (S M T W T F S)
                    Text(dayLetter(for: index))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))

                    // Date box
                    if let date = weekDates[index] {
                        dateBox(for: date)
                    } else {
                        emptyDateBox()
                    }
                }
            }
        }
    }

    private func dayLetter(for index: Int) -> String {
        ["S", "M", "T", "W", "T", "F", "S"][index]
    }

    private func dateBox(for date: Date) -> some View {
        let isCompleted = statisticsManager.isCompleted(for: gameType, on: date)
        let isToday = calendar.isDateInToday(date)

        // Debug print
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        print("📅 \(gameType.rawValue) \(formatter.string(from: date)): completed=\(isCompleted), today=\(isToday)")

        return ZStack {
            // Background box
            RoundedRectangle(cornerRadius: 8)
                .fill(isCompleted ? Color.green.opacity(0.2) : (isToday ? brandColor : brandColor))
                .frame(width: 44, height: 44)

            // Icon/Checkmark
            if isCompleted {
                // Green circle with white checkmark (for ALL completed, including today)
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            } else if isToday {
                // Today indicator (white checkmark on brand color) - only if NOT completed
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            } else {
                // Use game's custom icon for incomplete past days
                if let customIcon = gameType.customIcon, let _ = UIImage(named: customIcon) {
                    Image(customIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: gameType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func emptyDateBox() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.clear)
            .frame(width: 44, height: 44)
    }

    // MARK: - Subscription Overlay

    private var subscriptionOverlay: some View {
        VStack(spacing: 24) {
            Text("Access our archives with a subscription.")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Text("Explore over 390 past puzzles from all Sam's Games.")
                .font(.system(size: 18))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Subscribe button
            Button(action: {
                showPaywall = true
            }) {
                Text("Subscribe")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .cornerRadius(25)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Preview

struct XNumbersArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        XNumbersArchiveView(gameType: .xNumbers)
            .environmentObject(DailyPuzzleManager())
            .environmentObject(StatisticsManager())
    }
}
