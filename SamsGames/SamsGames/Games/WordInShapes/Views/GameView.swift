
//  GameView.swift
//  WordInShapes
//
//  Main game board view
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // Top bar with time and back button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.purple)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Time")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(viewModel.formattedTime)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Progress")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(viewModel.progress)
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Game Grid
                GameGridView(viewModel: viewModel)
                    .padding(.horizontal)

                // Current Word Display (above word list)
                if !viewModel.currentWord.isEmpty {
                    Text(viewModel.currentWord)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }

                // Word List - Target words to find
                WordListView(viewModel: viewModel)
                    .padding(.horizontal)

                // Message Display
                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.purple.opacity(0.8))
                        .cornerRadius(8)
                }

                Spacer()

                // Action Buttons (reduced by half)
                HStack(spacing: 15) {
                    Button(action: {
                        viewModel.clearSelection()
                    }) {
                        Text("Clear")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 70, height: 35)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        viewModel.submitWord()
                    }) {
                        Text("Submit")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 70, height: 35)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.currentWord.isEmpty)
                    .opacity(viewModel.currentWord.isEmpty ? 0.5 : 1.0)
                }
                .padding(.bottom, 8)
            }
        }
        .navigationBarHidden(true)
    }
}

struct GameGridView: View {
    @ObservedObject var viewModel: GameViewModel

    let gridSpacing: CGFloat = 3
    let cellSize: CGFloat = 38  // Reduced from 45 to 38

    var body: some View {
        GeometryReader { geometry in
            let columns = Array(repeating: GridItem(.fixed(cellSize), spacing: gridSpacing), count: 7)

            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(viewModel.grid.cells) { cell in
                    LetterCellView(cell: cell) {
                        handleCellTap(cell)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func handleCellTap(_ cell: LetterCell) {
        if cell.isSelected {
            viewModel.deselectPosition(cell.position)
        } else if !cell.isEmpty {
            viewModel.selectPosition(cell.position)
        }
    }
}

struct LetterCellView: View {
    let cell: LetterCell
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background circle
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: cell.isSelected ? 3 : 1)
                    )

                // Letter text
                if !cell.isEmpty {
                    Text(cell.letter)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var backgroundColor: Color {
        if cell.isEmpty {
            // Empty cells (after word found) show as green
            return Color.green.opacity(0.4)
        } else if cell.isSelected {
            // Selected cells show as blue
            return Color.blue.opacity(0.6)
        } else {
            // All other cells (with letters) show as gray
            return Color.gray.opacity(0.4)
        }
    }

    private var borderColor: Color {
        cell.isSelected ? .blue : .gray
    }

    private var textColor: Color {
        cell.isSelected ? .white : .black
    }
}

// Word List View - Shows target words with shape icons
struct WordListView: View {
    @ObservedObject var viewModel: GameViewModel

    // Helper function to get shape icon based on word length
    // Returns SF Symbol name as fallback if asset not found
    private func shapeIconForWord(_ word: String) -> String {
        switch word.count {
        case 3:
            return "triangle.fill"  // SF Symbol fallback
        case 4:
            return "square.fill"    // SF Symbol fallback
        case 5:
            return "pentagon.fill"  // SF Symbol fallback
        case 6:
            return "hexagon.fill"   // SF Symbol fallback
        default:
            return "square.fill"
        }
    }

    // Check if custom shape asset exists, otherwise use SF Symbol
    private func isSystemIcon(_ iconName: String) -> Bool {
        return iconName.contains(".fill")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Find these words:")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(viewModel.grid.formedShapes) { shape in
                    HStack(spacing: 6) {
                        // Shape icon based on word length
                        let iconName = shapeIconForWord(shape.word)

                        if isSystemIcon(iconName) {
                            // Use SF Symbol
                            Image(systemName: iconName)
                                .font(.system(size: 16))
                                .foregroundColor(.purple)
                                .frame(width: 18, height: 18)
                                .opacity(viewModel.foundWords.contains(shape.word) ? 0.3 : 1.0)
                        } else {
                            // Use custom asset image
                            Image(iconName)
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .opacity(viewModel.foundWords.contains(shape.word) ? 0.3 : 1.0)
                        }

                        // Word text
                        Text(shape.word)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(viewModel.foundWords.contains(shape.word) ? .green : .primary)
                            .strikethrough(viewModel.foundWords.contains(shape.word))
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(viewModel.foundWords.contains(shape.word) ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                }
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
}
