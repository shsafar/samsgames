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

#Preview {
    WordInShapesInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
