//
//  WordStacksInstructionsView.swift
//  Sam's Games
//
//  Instructions for WordStacks game
//

import SwiftUI

struct WordStacksInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.wordStacks.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                            .frame(width: 60, height: 60)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("WordStacks")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Shape-Based Word Puzzle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Introduction
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "sparkles",
                        text: "Welcome to WordStacks! A fresh word-puzzle challenge that blends logic, geometry, and vocabulary. Every word becomes a shape - build a tower of interconnected word-shapes through shared letters. No grids, just pure geometric word construction!"
                    )

                    InstructionItem(
                        icon: "square.3.layers.3d",
                        text: "Word Shapes:\n• 3-letter words = Triangle ▲\n• 4-letter words = Square ■\n• 5-letter words = Pentagon ⬟\n• 6-letter words = Hexagon ⬡\n\nEach word forms its geometric shape with letters placed at the vertices."
                    )

                    InstructionItem(
                        icon: "text.cursor",
                        text: "How to Play: Tap any empty node (circle) and type a letter. The clue is shown to the right of each shape to help you solve the word. Fixed letters are already filled in to guide you."
                    )

                    InstructionItem(
                        icon: "checkmark.circle",
                        text: "Instant Feedback: Correct letters turn green immediately. Wrong letters flash red until you fix them. When all letters are correct, the entire shape turns green!"
                    )

                    InstructionItem(
                        icon: "arrow.up.circle.fill",
                        text: "Stacking Mechanic: After solving a word, a new shape appears ABOVE it. One letter glows orange - this is the shared letter that connects the two shapes. The tower grows upward!"
                    )

                    InstructionItem(
                        icon: "rotate.3d",
                        text: "Smart Auto-Rotation: Each shape automatically rotates so the tower always builds upward, never downward or sideways. The shared letter is always positioned at the bottom of the new shape."
                    )

                    InstructionItem(
                        icon: "scroll",
                        text: "Smooth Scrolling: As your tower grows, the game automatically scrolls to keep the active word visible. You can also scroll manually to view previous words."
                    )

                    InstructionItem(
                        icon: "lightbulb.fill",
                        text: "Helpful Buttons:\n• REVEAL: Shows the complete word if you're stuck\n• NEXT WORD: Loads the next word in the sequence (must solve current word first)"
                    )

                    InstructionItem(
                        icon: "clock",
                        text: "Time Challenge: You have 120 seconds (2 minutes) to solve as many words as possible. The timer starts when you begin and counts down. Race against time!"
                    )

                    InstructionItem(
                        icon: "trophy",
                        text: "Goal: Solve up to 21 stacked shapes! Each completion adds to your tower. When you reach 21 words, you'll see a congratulations celebration!"
                    )

                    InstructionItem(
                        icon: "paintpalette",
                        text: "Visual Design: The game features a beautiful orange-and-green color scheme inspired by the 3D app icon. Shared letters glow orange, solved shapes turn green, and the geometric patterns create a stunning visual tower."
                    )

                    InstructionItem(
                        icon: "star.fill",
                        text: "Pro Tips:\n• Read the clue carefully before typing\n• Look for the orange shared letter when a new shape appears\n• Use REVEAL sparingly to maintain the challenge\n• Scroll down to review previous words if needed\n• Work quickly but accurately to beat the timer!"
                    )

                    InstructionItem(
                        icon: "heart.fill",
                        text: "Why It's Unique: Unlike traditional crosswords or word searches, WordStacks creates a vertical tower of geometric shapes. It feels like solving a puzzle AND building a structure at the same time!"
                    )
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

private struct InstructionItem: View {
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
    WordStacksInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
