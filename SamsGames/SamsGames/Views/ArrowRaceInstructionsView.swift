import SwiftUI

struct ArrowRaceInstructionsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Arrow Race")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Race to the finish against the app!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)

                // Instructions
                ArrowRaceInstructionItem(
                    number: 1,
                    title: "Objective",
                    description: "Roll the dice and race your blue token from cell 1 to the final cell before the orange app token reaches it."
                )

                ArrowRaceInstructionItem(
                    number: 2,
                    title: "How to Play",
                    description: "Tap the dice to roll (1-6). Your token moves forward exactly the number shown. Then the app automatically rolls and moves."
                )

                ArrowRaceInstructionItem(
                    number: 3,
                    title: "Green Arrows ⬆️",
                    description: "Landing on a green arrow automatically moves you UP to a higher cell - a boost toward victory!"
                )

                ArrowRaceInstructionItem(
                    number: 4,
                    title: "Red Arrows ⬇️",
                    description: "Landing on a red arrow automatically slides you DOWN to a lower cell - a setback in your race!"
                )

                ArrowRaceInstructionItem(
                    number: 5,
                    title: "Exact Roll Required",
                    description: "You must roll the exact number needed to land on the final cell. If your roll exceeds it, you stay in place and lose your turn."
                )

                ArrowRaceInstructionItem(
                    number: 6,
                    title: "Three Difficulty Levels",
                    description: "🟢 Level 1: 5×5 board (25 cells) - Quick game\n🟡 Level 2: 7×7 board (49 cells) - Medium challenge\n🔴 Level 3: 10×10 board (100 cells) - Epic race!"
                )

                ArrowRaceInstructionItem(
                    number: 7,
                    title: "Daily Puzzle",
                    description: "Each day features a unique board with different arrow placements. Levels rotate: Monday=L1, Tuesday=L2, Wednesday=L3, then repeat."
                )

                // Tips Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("💡 Tips")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    ArrowRaceTipItem(tip: "Green arrows can help you leap ahead - try to land on them strategically")
                    ArrowRaceTipItem(tip: "Watch out for red arrows near the finish - they can send you far back!")
                    ArrowRaceTipItem(tip: "The app opponent plays automatically and fairly - same rules apply")
                    ArrowRaceTipItem(tip: "Arrow placements change daily, so each day is a new challenge!")
                }
                .padding()
                .background(Color.orange.opacity(0.15))
                .cornerRadius(10)
            }
            .padding()
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
    }
}

struct ArrowRaceInstructionItem: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.orange)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ArrowRaceTipItem: View {
    let tip: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.orange)
                .font(.headline)

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    ArrowRaceInstructionsView()
}
