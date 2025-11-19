//
//  DiamondStackInstructionsView.swift
//  Sam's Games
//
//  Instructions for Diamond Stack game
//

import SwiftUI

struct DiamondStackInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.diamondStack.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                            .frame(width: 60, height: 60)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Diamond Stack")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Triangle Sum Puzzle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "target",
                        text: "Fill in the empty circles with numbers 1-9 so that each triangle's three corners add up to the sum shown in its center."
                    )

                    InstructionItem(
                        icon: "hand.tap",
                        text: "Tap an empty circle to select it, then use the keypad to enter a number. Tap 'Start Game' to begin the 60-second timer."
                    )

                    InstructionItem(
                        icon: "paintbrush.fill",
                        text: "Color feedback: Orange means some triangles are correct, green means all triangles touching that circle are correct."
                    )

                    InstructionItem(
                        icon: "eye.fill",
                        text: "Use the 'Reveal' button (3 uses) to show the correct number for a selected circle. Each reveal costs 5 points."
                    )

                    InstructionItem(
                        icon: "star.fill",
                        text: "Three levels: Pyramid (L1), Diamond (L2), and Hourglass (L3) - each with increasing complexity!"
                    )

                    InstructionItem(
                        icon: "lightbulb",
                        text: "Hint: Start with circles that belong to multiple triangles - if you get those right, other triangles become easier to solve."
                    )
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    DiamondStackInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
