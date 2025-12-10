//
//  WordStacksInstructionsView.swift
//  Sam's Games
//
//  Instructions for WordStacks game
//

import SwiftUI

struct WordStacksInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("WordStacks")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("The Word-Building Shape-Stacking Puzzle")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 10)

                // How to Play
                VStack(alignment: .leading, spacing: 16) {
                    Text("🎮 HOW TO PLAY")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)

                    instructionRow(number: "1", text: "Each shape has several lettered nodes. Some letters are already shown. Empty nodes are yours to fill.")

                    instructionRow(number: "2", text: "A clue appears next to the shape. Your job is to fill in the missing letters to form a word that matches the clue.")

                    instructionRow(number: "3", text: "Use the custom keyboard at the bottom to enter letters into the empty nodes.")

                    instructionRow(number: "4", text: "When you complete a word correctly, the shape glows green and locks in. A new shape appears above it, continuing the stack.")

                    instructionRow(number: "5", text: "Shared nodes link shapes together. Sometimes a letter at the top of one shape becomes part of the next shape.")

                    instructionRow(number: "6", text: "Solve all 21 words to complete the puzzle!")
                }
                .padding(.bottom, 10)

                // Controls
                VStack(alignment: .leading, spacing: 12) {
                    Text("🎯 CONTROLS")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)

                    controlRow(icon: "keyboard", text: "Custom Keyboard - Tap empty nodes, then use keyboard to enter letters")
                    controlRow(icon: "arrow.clockwise", text: "New Game - Start a fresh puzzle")
                    controlRow(icon: "arrow.uturn.backward", text: "Restart - Reset current puzzle")
                    controlRow(icon: "eye", text: "Reveal - Auto-fill the current word")
                    controlRow(icon: "speaker.wave.2", text: "Sound Toggle - Turn sounds on/off")
                }
                .padding(.bottom, 10)

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("✨ FEATURES")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)

                    featureRow(icon: "📚", text: "Fun word clues and vocabulary building")
                    featureRow(icon: "🎨", text: "Beautiful shapes and smooth animations")
                    featureRow(icon: "🔊", text: "Success sounds and victory fanfare")
                    featureRow(icon: "🎆", text: "Fireworks celebration when you complete all 21 words")
                    featureRow(icon: "🧠", text: "Great for vocabulary, spelling, and problem-solving")
                }
            }
            .padding(20)
        }
    }

    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number + ".")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.blue)
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
                .foregroundColor(.blue)
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
        WordStacksInstructionsView()
    }
}
