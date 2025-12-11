//
//  StandardGameInfoBar.swift
//  Sam's Games
//
//  Standardized game info bar for all games
//

import SwiftUI

struct StandardGameInfoBar: View {
    // Metric values (nil = inactive/gray)
    let time: String?
    let score: (value: Int, label: String)?  // Customizable label: "Score", "Solved", "Words", etc.
    let moves: Int?
    let streak: Int?
    let hints: Int?
    let penalty: (value: Int, label: String)?  // Customizable label: "Penalty", "Miss", etc.

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            // TIME
            MetricDisplay(
                label: "Time:",
                value: time ?? "0:00",
                isActive: time != nil
            )

            Divider()
                .frame(height: 20)
                .padding(.horizontal, 8)

            // SCORE (customizable label)
            MetricDisplay(
                label: "\(score?.label ?? "Score"):",
                value: "\(score?.value ?? 0)",
                isActive: score != nil,
                valueColor: (score?.value ?? 0) < 0 ? .red : nil
            )

            Divider()
                .frame(height: 20)
                .padding(.horizontal, 8)

            // MOVES
            MetricDisplay(
                label: "Moves:",
                value: moves != nil ? "\(moves!)" : "--",
                isActive: moves != nil
            )

            Divider()
                .frame(height: 20)
                .padding(.horizontal, 8)

            // STREAK
            MetricDisplay(
                label: "Streak:",
                value: streak != nil ? "\(streak!)" : "--",
                isActive: streak != nil
            )

            Divider()
                .frame(height: 20)
                .padding(.horizontal, 8)

            // HINTS
            MetricDisplay(
                label: "Hints:",
                value: hints != nil ? "\(hints!)" : "--",
                isActive: hints != nil
            )

            Divider()
                .frame(height: 20)
                .padding(.horizontal, 8)

            // PENALTY (customizable label)
            MetricDisplay(
                label: "\(penalty?.label ?? "Penalty"):",
                value: "\(penalty?.value ?? 0)",
                isActive: penalty != nil
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(colorScheme == .dark ? Color(white: 0.15) : Color(UIColor.systemGray6))
    }
}

// MARK: - Individual Metric Display

struct MetricDisplay: View {
    let label: String
    let value: String
    let isActive: Bool
    var valueColor: Color? = nil  // Optional custom color for value

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isActive ? Color(red: 0.6, green: 0.4, blue: 0.2) : .gray.opacity(0.4))

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor ?? (isActive ? .primary : .gray.opacity(0.4)))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // SumStacks example (Time + Score active)
        StandardGameInfoBar(
            time: "0:17",
            score: (2, "Score"),
            moves: nil,
            streak: nil,
            hints: nil,
            penalty: nil
        )

        // Full game example (all metrics active)
        StandardGameInfoBar(
            time: "2:34",
            score: (150, "Score"),
            moves: 25,
            streak: 5,
            hints: 3,
            penalty: (2, "Penalty")
        )

        // WordStacks example (Time + Words + Streak active)
        StandardGameInfoBar(
            time: "0:48",
            score: (5, "Words"),
            moves: nil,
            streak: 3,
            hints: nil,
            penalty: nil
        )
    }
    .padding()
}
