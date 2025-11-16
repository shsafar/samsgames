//
//  DoubleBubbleInstructionsView.swift
//  Sam's Games
//
//  Instructions for Double Bubble game
//

import SwiftUI

struct DoubleBubbleInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    Image(systemName: GameType.doubleBubble.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Double Bubble")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Pop bubbles to form words")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "bubble.left.and.bubble.right",
                        text: "Tap two bubbles to pop them and create a letter fragment (like AT or TO)."
                    )

                    InstructionItem(
                        icon: "sparkles",
                        text: "Fragments automatically merge into real words from the dictionary for points!"
                    )

                    InstructionItem(
                        icon: "target",
                        text: "Watch the TARGET word at the top - forming it gives you bonus points."
                    )

                    InstructionItem(
                        icon: "exclamationmark.triangle",
                        text: "The daily puzzle ends when you reach 12 fragments. Merge them quickly!"
                    )

                    InstructionItem(
                        icon: "star.fill",
                        text: "Longer words score more points. Combine fragments strategically!"
                    )
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
    }
}

// Reusable instruction item component
struct DoubleBubbleInstructionItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    DoubleBubbleInstructionsView()
}
