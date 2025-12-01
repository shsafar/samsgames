//
//  WaterTableInstructionsView.swift
//  Sam's Games
//
//  Instructions for WaterTable game
//

import SwiftUI

struct WaterTableInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.waterTable.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("WaterTable")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Pin Rebuilding Logic Puzzle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "target",
                        text: "Welcome to WaterTable! Your mission is to rebuild the pins exactly right so they touch the water floor at the correct depth. But there's a catch - the pins are broken into pieces, and some pieces don't even belong!"
                    )

                    InstructionItem(
                        icon: "hand.tap",
                        text: "Getting Started: Tap the 'Break' button to shatter the pins into fragments. All pieces fall into the water, mixing the real pieces with decoy pieces that don't belong to any pin."
                    )

                    InstructionItem(
                        icon: "hand.drag",
                        text: "Rebuilding Pins: Drag fragments from the water onto the pins above. Each pin needs to be built to exactly match its hidden target depth - not too short, not too long, but just right!"
                    )

                    InstructionItem(
                        icon: "checkmark.circle",
                        text: "Visual Feedback: When a pin reaches the correct depth, it turns green and sprays water like a fountain! Build all pins correctly to win the puzzle."
                    )

                    InstructionItem(
                        icon: "exclamationmark.triangle",
                        text: "Watch Out for Decoys! About 30% of the pieces floating in the water are decoys that don't belong to any pin. Placing a decoy piece costs you 5 points and shows 'DICORY' as a warning."
                    )

                    InstructionItem(
                        icon: "lightbulb",
                        text: "Smart Strategy: Use the 'Reveal' button (costs 5 points) to see the correct stacking order with blue dashed outlines. In Hard mode, tap 'Show Targets' (costs 15 points) to temporarily reveal the hidden depth numbers."
                    )

                    InstructionItem(
                        icon: "gamecontroller",
                        text: "Scoring System:\n• Correct piece: +10 points\n• Every 3 correct pieces in a row: +20 combo bonus\n• Decoy piece: -5 points and breaks combo\n• Using Reveal: -5 points\n• Using Show Targets: -15 points"
                    )

                    InstructionItem(
                        icon: "star.fill",
                        text: "Three Difficulty Levels:\n• Level 1: 3 pins, no time limit - perfect for learning!\n• Level 2: 5 pins, 90-second timer - more challenging\n• Level 3: 7 pins, 120-second timer - expert level!"
                    )
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    WaterTableInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
