import SwiftUI

struct TraceWizInstructionsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("TraceWiz")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Follow the line without crossing it!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)

                    // Instructions
                    TraceWizInstructionItem(
                        number: 1,
                        title: "Objective",
                        description: "Follow the black line from start to finish within 30 seconds without crossing it or straying too far away."
                    )

                    TraceWizInstructionItem(
                        number: 2,
                        title: "How to Play",
                        description: "Tap 'Start' and wait for the countdown. When you see 'GO!', draw with your finger along the green tolerance zone, following the black line as it reveals."
                    )

                    TraceWizInstructionItem(
                        number: 3,
                        title: "Green Zone",
                        description: "The light green area shows your tolerance zone. Stay within this zone and follow the black line closely."
                    )

                    TraceWizInstructionItem(
                        number: 4,
                        title: "Avoid Crossing",
                        description: "Never let your blue line cross the black line! If you touch or cross it, the game ends immediately."
                    )

                    TraceWizInstructionItem(
                        number: 5,
                        title: "Stay Close",
                        description: "Don't stray too far from the black line. If you go outside the green tolerance zone, you'll be eliminated."
                    )

                    TraceWizInstructionItem(
                        number: 6,
                        title: "Reach the Finish",
                        description: "Follow the line all the way to the green FINISH line at the bottom. Reaching it before time runs out means victory!"
                    )

                    TraceWizInstructionItem(
                        number: 7,
                        title: "Difficulty Levels",
                        description: "🟢 Easy: Large tolerance zone, slower speed\n🟡 Medium: Moderate tolerance, moderate speed\n🔴 Hard: Small tolerance zone, faster speed"
                    )

                    TraceWizInstructionItem(
                        number: 8,
                        title: "Daily Puzzle",
                        description: "Each day features a unique path with a specific difficulty level. Everyone gets the same puzzle each day!"
                    )

                    // Tips Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 Tips")
                            .font(.headline)
                            .padding(.top, 10)

                        TraceWizTipItem(tip: "Keep your finger steady and follow the arrow at the tip of the black line")
                        TraceWizTipItem(tip: "The page scrolls automatically - don't try to scroll manually")
                        TraceWizTipItem(tip: "Stay in the middle of the green zone for best results")
                        TraceWizTipItem(tip: "Practice makes perfect - try multiple times to improve!")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TraceWizInstructionItem: View {
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
                .background(Color.blue)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TraceWizTipItem: View {
    let tip: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.headline)
                .foregroundColor(.blue)

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
