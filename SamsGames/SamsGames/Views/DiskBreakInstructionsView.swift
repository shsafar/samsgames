//
//  DiskBreakInstructionsView.swift
//  Sam's Games
//
//  Instructions for DiskBreak game
//

import SwiftUI

struct DiskBreakInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.diskBreak.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "circle.grid.cross")
                            .font(.system(size: 40))
                            .foregroundColor(.cyan)
                            .frame(width: 60, height: 60)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("DiskBreak")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Spatial Logic Puzzle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "target",
                        text: "Rebuild broken disks by dragging scattered fragments back to their original positions. Each disk is cut by random chords creating unique puzzles every time."
                    )

                    InstructionItem(
                        icon: "hand.tap",
                        text: "Study the cracks before the disk breaks! After pressing 'Break Disk', the cracks will flash several times to help you memorize the pattern."
                    )

                    InstructionItem(
                        icon: "hand.drag",
                        text: "Drag pieces from the tray at the bottom and drop them onto the disk outline. Pieces snap into place when positioned correctly near their original location."
                    )

                    InstructionItem(
                        icon: "questionmark.circle",
                        text: "Need help? Tap 'Hint' to briefly show the original crack lines. This helps identify where pieces belong, but costs 5 points in Easy mode and 10 points in harder levels."
                    )

                    InstructionItem(
                        icon: "star.fill",
                        text: "Three difficulty levels:\n• Level 1: 5 chords, no time limit, perfect for learning\n• Level 2: 7 chords, 90-second timer, more fragments\n• Level 3: 2 disks at once with same color, 90 seconds!"
                    )

                    InstructionItem(
                        icon: "clock",
                        text: "Beat the clock in Levels 2 & 3! You have 90 seconds to complete the puzzle. Finish early to earn time bonus points - 1 bonus point for every 5 seconds remaining."
                    )

                    InstructionItem(
                        icon: "lightbulb",
                        text: "Pro tip: Look for corner pieces and edge pieces first. In Level 3, remember that both disks share the same gradient color - use shape and position to tell them apart!"
                    )
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    DiskBreakInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
