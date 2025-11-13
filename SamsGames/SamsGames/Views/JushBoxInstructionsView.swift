//
//  JushBoxInstructionsView.swift
//  Sam's Games
//
//  Instructions for JushBox game
//

import SwiftUI

struct JushBoxInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.jushBox.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("JushBox")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Sliding-Stack Puzzle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "target",
                        text: "Sort all colored tiles into their own stacks by sliding them between adjacent chambers on the grid."
                    )

                    InstructionItem(
                        icon: "hand.tap",
                        text: "Tap a chamber to select it, then tap an adjacent chamber to slide the top tile to it."
                    )

                    InstructionItem(
                        icon: "sparkles",
                        text: "Special tiles: Golden tiles give you instant wins, while dragon tiles will reset the level if matched!"
                    )

                    InstructionItem(
                        icon: "checkmark.circle",
                        text: "Complete the puzzle when each chamber contains only one color of tiles stacked together."
                    )

                    InstructionItem(
                        icon: "lightbulb",
                        text: "Hint: Plan ahead to avoid blocking your moves. Use empty chambers strategically to rearrange tiles."
                    )
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    JushBoxInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
