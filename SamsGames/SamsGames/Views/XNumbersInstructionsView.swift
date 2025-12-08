//
//  XNumbersInstructionsView.swift
//  Sam's Games
//
//  Instructions for X-Numbers game
//

import SwiftUI

struct XNumbersInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.xNumbers.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("X-Numbers")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Cross-Sum Puzzle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "target",
                        text: "Fill the grid with numbers so that each row and column adds up to the target sum shown."
                    )

                    InstructionItem(
                        icon: "hand.tap",
                        text: "Tap a cell to select it, then tap a number from the keypad to fill it in."
                    )

                    InstructionItem(
                        icon: "arrow.uturn.backward",
                        text: "Use the undo button if you make a mistake, or tap a filled cell to clear it."
                    )

                    InstructionItem(
                        icon: "checkmark.circle",
                        text: "When all cells are filled correctly and match the target sums, you've solved the puzzle!"
                    )

                    InstructionItem(
                        icon: "lightbulb",
                        text: "Hint: Start with rows or columns that have fewer empty cells to solve them faster."
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
    XNumbersInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
