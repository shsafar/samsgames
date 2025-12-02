//
//  AtomicNailsInstructionsView.swift
//  Sam's Games
//
//  Instructions for Atomic Nails game
//

import SwiftUI

struct AtomicNailsInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Game Icon and Title
                HStack {
                    if let icon = GameType.atomicNails.customIcon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "scope")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                            .frame(width: 60, height: 60)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Atomic Nails")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Precision Puzzle Game")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 10)

                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    InstructionItem(
                        icon: "target",
                        text: "Welcome to Atomic Nails! A glowing atomic core sits inside a larger energy ring. Your mission: match each nail to the exact hidden hole on the ring by its length, angle, and orientation."
                    )

                    InstructionItem(
                        icon: "hand.drag",
                        text: "Drag the Nail: Grab each nail by its round head and drag it toward the ring. While dragging, the nail automatically rotates to point toward the core, so the orientation always looks correct!"
                    )

                    InstructionItem(
                        icon: "checkmark.circle",
                        text: "Perfect Match = Success: If the nail's length, angle, and hole position all match perfectly, it snaps into place, turns green, and locks! Every correct nail earns you +10 points."
                    )

                    InstructionItem(
                        icon: "xmark.circle",
                        text: "Wrong Placement: If any detail doesn't match (wrong length, wrong angle, or wrong hole), the nail pops back to the pile at the bottom. You'll lose 5 points for each wrong attempt. Too short? You'll see 'Nope!' appear!"
                    )

                    InstructionItem(
                        icon: "exclamationmark.triangle",
                        text: "Beware of Decoys! Some nails in the pile are fake - they don't belong to any hole on the ring. Placing a decoy costs you 5 points and shows 'Decoy!' as a warning. Watch for unusual lengths!"
                    )

                    InstructionItem(
                        icon: "burst.fill",
                        text: "DANGER - Explosion Hazard! If a nail is TOO LONG and its tip pierces through the atomic core (inner circle), the core will EXPLODE! This resets the entire puzzle and you must start over. Be very careful with long nails!"
                    )

                    InstructionItem(
                        icon: "eye",
                        text: "Reveal Holes Tool: Stuck? Tap 'Reveal Holes' to briefly show all hole locations on the ring for 3 seconds. Use it wisely - it's your best hint when you're unsure!"
                    )

                    InstructionItem(
                        icon: "gamecontroller",
                        text: "Scoring System:\n• Correct nail placement: +10 points\n• Wrong nail attempt: -5 points\n• Decoy nail attempt: -5 points\n\nTry to maximize your score by making fewer mistakes!"
                    )

                    InstructionItem(
                        icon: "star.fill",
                        text: "Three Difficulty Levels:\n• Level 1: 5 nails, no time limit - perfect for learning!\n• Level 2: 10 nails, 120-second timer - moderate challenge\n• Level 3: 14 nails, 90-second timer - expert precision test!"
                    )

                    InstructionItem(
                        icon: "lightbulb",
                        text: "Pro Tips:\n• Look carefully at nail lengths before dragging\n• Use the Reveal Holes button when stuck\n• Decoys are usually very short or very long\n• NEVER try a nail that looks too long - it might explode the core!\n• In timed levels, work quickly but carefully!"
                    )

                    InstructionItem(
                        icon: "trophy.fill",
                        text: "Victory: When all real nails are correctly placed, the inner core glows with a spinning atomic animation and you see a congratulations popup! Your precision wins the day!"
                    )
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    AtomicNailsInstructionsView()
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
}
