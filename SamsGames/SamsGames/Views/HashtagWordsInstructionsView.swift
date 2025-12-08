//
//  HashtagWordsInstructionsView.swift
//  Sam's Games
//
//  Instructions for Hashtag Words game
//

import SwiftUI

struct HashtagWordsInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.hashtagWords.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "number")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                            .frame(width: 60, height: 60)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hashtag Words")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Word Grid Puzzle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "target",
                        text: "Fill in the missing letters in the hashtag (#) grid to complete 4 intersecting words. The grid forms a hashtag shape where words cross each other."
                    )

                    InstructionItem(
                        icon: "hand.tap",
                        text: "Tap any empty cell to select it, then use the on-screen keyboard to enter a letter. You can also use your device keyboard if available."
                    )

                    InstructionItem(
                        icon: "thermometer",
                        text: "Heat meter feedback: Watch the meter change from COLD to WARM to HOT to ALMOST as you fill in correct letters. When all words are complete, it shows DONE!"
                    )

                    InstructionItem(
                        icon: "clock.fill",
                        text: "Beat the timer! You have 60 seconds for Easy and Medium levels, and 45 seconds for Hard level. The timer starts as soon as you begin."
                    )

                    InstructionItem(
                        icon: "questionmark.circle",
                        text: "Use hints when stuck! Tap the info (i) button to reveal a correct letter. Easy has 5 hints, Medium has 4 hints, and Hard has 3 hints."
                    )

                    InstructionItem(
                        icon: "star.fill",
                        text: "Three difficulty levels: Easy (5-letter words), Medium (fewer starting letters), and Hard (mix of 4 and 5-letter words with # fillers)."
                    )

                    InstructionItem(
                        icon: "lightbulb",
                        text: "Strategy tip: Focus on cells where two words intersect - getting the shared letter right helps complete both words at once!"
                    )
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

struct InstructionItem: View {
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
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    HashtagWordsInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
