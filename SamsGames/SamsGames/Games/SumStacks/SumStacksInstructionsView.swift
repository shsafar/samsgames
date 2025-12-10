//
//  SumStacksInstructionsView.swift
//  Sam's Games
//
//  Instructions for SumStacks game
//

import SwiftUI

struct SumStacksInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("SumStacks")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("The Addictive Shape-Stacking Number Puzzle")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 10)

                // How to Play
                VStack(alignment: .leading, spacing: 16) {
                    Text("🎮 HOW TO PLAY")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)

                    instructionRow(number: "1", text: "Each shape has several numbered nodes (1–9). Some numbers are already shown. One or more nodes are blank — those are yours to fill.")

                    instructionRow(number: "2", text: "A target total appears next to the shape. Your job is to enter the missing numbers so the sum of ALL nodes equals the target.")

                    instructionRow(number: "3", text: "When your total is correct, the shape glows green and locks in. A brand-new shape appears above it, continuing the stack.")

                    instructionRow(number: "4", text: "Shared nodes link shapes together. Sometimes a number at the top of one shape becomes part of the next shape — adding strategy and excitement.")

                    instructionRow(number: "5", text: "Solve all 21 shapes to complete the puzzle!")
                }
                .padding(.bottom, 10)

                // Controls
                VStack(alignment: .leading, spacing: 12) {
                    Text("🎯 CONTROLS")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)

                    controlRow(icon: "arrow.clockwise", text: "New Game - Start a fresh puzzle")
                    controlRow(icon: "arrow.uturn.backward", text: "Restart - Reset current puzzle")
                    controlRow(icon: "eye", text: "Reveal - Auto-fill the current shape")
                }
                .padding(.bottom, 10)

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("✨ FEATURES")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)

                    featureRow(icon: "🧮", text: "Fast, rewarding logic challenges")
                    featureRow(icon: "🎨", text: "Relaxing visuals and smooth animations")
                    featureRow(icon: "📚", text: "Unique stacking progression")
                    featureRow(icon: "🧠", text: "Great for focus, memory, and quick-math skills")
                }
            }
            .padding(20)
        }
    }

    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number + ".")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.orange)
                .frame(width: 24, alignment: .leading)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func controlRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.orange)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 20))
                .frame(width: 24)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SumStacksInstructionsView()
    }
}
