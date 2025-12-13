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

struct InstructionItem: View {
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

// MARK: - Simple Time Limits Info View

struct XNumbersTimeLimitsView: View {
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
                Text("Time Limits by Level")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Level 1: No time limit")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)

                    Text("• Level 2: 60 seconds")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)

                    Text("• Level 3: 90 seconds")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
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
                        .foregroundColor(.blue)
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

// MARK: - Background Clear View for FullScreenCover

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    XNumbersInstructionsView()
}
