//
//  WordInShapesInstructionsView.swift
//  Sam's Games
//
//  Instructions for Word In Shapes game
//

import SwiftUI

struct WordInShapesInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.wordInShapes.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Word In Shapes")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Find Hidden Words")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "square.grid.3x3",
                        text: "Find words hidden within the geometric shapes on the grid."
                    )

                    InstructionItem(
                        icon: "hand.draw",
                        text: "Click and drag to select letters in any direction - horizontally, vertically, or diagonally."
                    )

                    InstructionItem(
                        icon: "checkmark.seal",
                        text: "When you find a valid word, it will be highlighted and added to your score."
                    )

                    InstructionItem(
                        icon: "clock",
                        text: "Race against the clock to find all the hidden words before time runs out!"
                    )

                    InstructionItem(
                        icon: "lightbulb",
                        text: "Hint: Look for common word patterns and scan each shape systematically."
                    )
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

// MARK: - Simple Info View

struct WordInShapesInfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Popup content
            VStack(spacing: 0) {
                // Title
                Text("Words In Shapes")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Find words hidden in colorful shapes!")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)

                    Text("• Tap letters to form words")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Text("• Complete all target words to win")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Divider
                Divider()

                // OK Button
                Button(action: {
                    dismiss()
                }) {
                    Text("OK")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.purple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .frame(width: 300)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
}

#Preview {
    WordInShapesInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
