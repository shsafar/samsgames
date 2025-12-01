//
//  GameInstructionsView.swift
//  Sam's Games
//
//  Master view for displaying game-specific instructions
//

import SwiftUI

struct GameInstructionsView: View {
    @Environment(\.dismiss) var dismiss
    let gameType: GameType

    var body: some View {
        NavigationView {
            ZStack {
                // Dark background matching settings menu
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                // Game-specific instructions
                switch gameType {
                case .xNumbers:
                    XNumbersInstructionsView()
                case .wordInShapes:
                    WordInShapesInstructionsView()
                case .jushBox:
                    JushBoxInstructionsView()
                case .doubleBubble:
                    DoubleBubbleInstructionsView()
                case .diamondStack:
                    DiamondStackInstructionsView()
                case .hashtagWords:
                    HashtagWordsInstructionsView()
                case .traceWiz:
                    TraceWizInstructionsView()
                case .arrowRace:
                    ArrowRaceInstructionsView()
                case .diskBreak:
                    DiskBreakInstructionsView()
                case .waterTable:
                    WaterTableInstructionsView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("How to Play")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    GameInstructionsView(gameType: .xNumbers)
}
