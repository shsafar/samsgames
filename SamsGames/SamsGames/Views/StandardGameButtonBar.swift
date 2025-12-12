//
//  StandardGameButtonBar.swift
//  Sam's Games
//
//  Standardized button bar for all games
//

import SwiftUI

struct StandardGameButtonBar: View {
    let onReset: () -> Void
    let onRevealHint: (() -> Void)?
    @Binding var soundEnabled: Bool

    var resetLabel: String = "RESET"
    var revealLabel: String = "REVEAL/HINT"
    var showReveal: Bool = true

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            // RESET Button (Orange)
            GameButton(
                label: resetLabel,
                backgroundColor: Color.orange.opacity(0.85),
                isEnabled: true,
                action: onReset
            )

            // REVEAL/HINT Button (Blue)
            GameButton(
                label: revealLabel,
                backgroundColor: Color.blue.opacity(0.85),
                isEnabled: showReveal && onRevealHint != nil,
                action: onRevealHint ?? {}
            )

            // SOUND Button (Green when ON, Purple when OFF)
            GameButton(
                label: soundEnabled ? "SOUND: ON" : "SOUND: OFF",
                backgroundColor: soundEnabled ? Color.green.opacity(0.85) : Color.purple.opacity(0.7),
                isEnabled: true,
                action: {
                    soundEnabled.toggle()
                }
            )

            // BLANK Placeholder (for future use in other games)
            GameButton(
                label: "",
                backgroundColor: .gray.opacity(0.2),
                isEnabled: false,
                action: {}
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.9))
    }
}

// MARK: - Individual Game Button

struct GameButton: View {
    let label: String
    let backgroundColor: Color
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isEnabled ? backgroundColor : Color.gray.opacity(0.3))
                )
        }
        .buttonStyle(InstantPressButtonStyle())
        .disabled(!isEnabled)
    }
}

// MARK: - Instant Press Button Style
struct InstantPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Sound ON, Reveal enabled
        StandardGameButtonBar(
            onReset: { print("Reset") },
            onRevealHint: { print("Reveal") },
            soundEnabled: .constant(true)
        )

        // Sound OFF, Reveal disabled
        StandardGameButtonBar(
            onReset: { print("Reset") },
            onRevealHint: nil,  // Grayed out
            soundEnabled: .constant(false),
            showReveal: false
        )
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
