//
//  GameViewModel.swift
//  WordInShapes
//
//  Main game logic and state management (NO DATABASE VERSION)
//

import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var grid: GameGrid
    @Published var gameState: GameState = .notStarted
    @Published var elapsedTime: Int = 0
    @Published var currentWord: String = ""
    @Published var message: String = ""
    @Published var foundWords: Set<String> = []

    // Completion callback for daily puzzle integration
    var onGameCompleted: (() -> Void)?

    private var timer: Timer?
    private let wordList = WordListService.shared
    private let coordinator = CoordinateGenerator.shared
    private let validator = WordValidator.shared
    private var cancellables = Set<AnyCancellable>()
    private var gameSeed: Int?
    private var hasRecordedCompletion = false

    init(seed: Int? = nil) {
        self.grid = GameGrid()
        self.gameSeed = seed

        // If seed provided, set random seed for consistent puzzle generation
        if let seed = seed {
            srand48(seed)
        }
    }

    // MARK: - Game State

    enum GameState {
        case notStarted
        case playing
        case paused
        case completed
    }

    // MARK: - Game Control

    func startNewGame() {
        grid.reset()
        foundWords.removeAll()
        generatePuzzle()
        gameState = .playing
        elapsedTime = 0
        startTimer()
        message = "Find all the words in the shapes!"
    }

    func pauseGame() {
        gameState = .paused
        stopTimer()
    }

    func resumeGame() {
        gameState = .playing
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Puzzle Generation (NO DATABASE)

    private func generatePuzzle() {
        var occupiedPositions = Set<GridPosition>()
        var usedWords = Set<String>()  // Prevent duplicates
        let targetShapeCount = 10  // Try to place 10 words

        var placedShapes = 0
        var attemptCount = 0
        let maxAttempts = 100

        while placedShapes < targetShapeCount && attemptCount < maxAttempts {
            attemptCount += 1

            // Get random word length (use seeded random if seed provided)
            let wordLength = gameSeed != nil ? Int(drand48() * 4) + 3 : Int.random(in: 3...6)

            // Get a random word of that length (use seeded random if seed provided)
            guard let word = wordList.randomWord(length: wordLength, useSeededRandom: gameSeed != nil) else {
                continue
            }

            // Skip if word already used
            if usedWords.contains(word) {
                continue
            }

            // Select appropriate shape for word length
            let shapeType = getShapeForWordLength(wordLength)

            // Generate coordinates for this shape
            guard let coordinates = coordinator.generateCoordinates(
                for: shapeType,
                wordLength: word.count,
                occupiedPositions: occupiedPositions
            ) else {
                continue
            }

            // Verify we have enough coordinates
            guard coordinates.count == word.count else {
                continue
            }

            // Place the word on the grid
            let letters = Array(word)
            for (index, position) in coordinates.enumerated() {
                let letter = String(letters[index])
                grid.updateCell(at: position, letter: letter)
                occupiedPositions.insert(position)
            }

            // Create and add the shape
            let shape = WordShape(word: word, shapeType: shapeType, positions: coordinates)
            grid.addShape(shape)

            usedWords.insert(word)  // Mark word as used
            placedShapes += 1

            print("Placed word #\(placedShapes): \(word) as \(shapeType.rawValue)")
        }

        print("Puzzle generated with \(placedShapes) words")

        // Fill all empty cells with random letters
        fillEmptyCellsWithRandomLetters()

        // If we didn't place enough shapes, that's okay - game will still work
        if placedShapes == 0 {
            message = "Failed to generate puzzle. Try again!"
            gameState = .notStarted
        }
    }

    private func getShapeForWordLength(_ length: Int) -> ShapeType {
        switch length {
        case 3:
            return .triangle  // 3 letters = Triangle icon
        case 4:
            return .square    // 4 letters = Square icon
        case 5:
            return .pentagon  // 5 letters = Pentagon icon
        case 6:
            return .hexagon   // 6 letters = Hexagon icon
        default:
            return .square
        }
    }

    private func fillEmptyCellsWithRandomLetters() {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let alphabetArray = Array(alphabet)

        for row in 0..<7 {
            for col in 0..<7 {
                let position = GridPosition(row: row, column: col)
                if let cell = grid.cell(at: position), cell.isEmpty {
                    // Use seeded random if seed provided
                    let randomLetter: String
                    if gameSeed != nil {
                        let randomIndex = Int(drand48() * Double(alphabetArray.count))
                        randomLetter = String(alphabetArray[randomIndex])
                    } else {
                        randomLetter = String(alphabet.randomElement()!)
                    }
                    grid.updateCell(at: position, letter: randomLetter)
                }
            }
        }
    }

    // MARK: - Word Selection

    func selectPosition(_ position: GridPosition) {
        guard gameState == .playing else { return }

        // Don't allow selecting empty cells
        guard let cell = grid.cell(at: position), !cell.isEmpty else { return }

        grid.selectCell(at: position)
        updateCurrentWord()
    }

    func deselectPosition(_ position: GridPosition) {
        grid.deselectCell(at: position)
        updateCurrentWord()
    }

    func clearSelection() {
        grid.clearSelection()
        currentWord = ""
    }

    private func updateCurrentWord() {
        currentWord = grid.selectedPositions.compactMap { position in
            grid.cell(at: position)?.letter
        }.joined()

        // Auto-submit when word is formed
        if !currentWord.isEmpty {
            autoSubmitWord()
        }
    }

    private func autoSubmitWord() {
        guard gameState == .playing else { return }

        // Check if word matches any target shape
        if checkWordMatch() != nil {
            if foundWords.contains(currentWord) {
                message = "You already found '\(currentWord)'!"
            } else {
                message = "Perfect! You found '\(currentWord)'! ⭐"
                foundWords.insert(currentWord)
                checkGameCompletion()
            }

            // Auto-clear selection if correct
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.clearSelection()
            }
        }

        // Clear message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.message = ""
        }
    }

    func submitWord() {
        guard !currentWord.isEmpty else { return }
        guard gameState == .playing else { return }

        // Check if word matches any target shape
        if let matchedShape = checkWordMatch() {
            if foundWords.contains(currentWord) {
                message = "You already found '\(currentWord)'!"
            } else {
                message = "Perfect! You found '\(currentWord)' in a \(matchedShape.shapeType.rawValue)! ⭐"
                foundWords.insert(currentWord)
                checkGameCompletion()
            }
        } else if validator.isValidWord(currentWord) {
            message = "'\(currentWord)' is valid, but not part of this puzzle."
        } else {
            message = "'\(currentWord)' is not a valid word."
        }

        // Clear message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.message = ""
        }

        clearSelection()
    }

    private func checkWordMatch() -> WordShape? {
        // Check if current word matches any target word (forward or backward)
        for shape in grid.formedShapes {
            let targetWord = shape.word
            let reversedWord = String(targetWord.reversed())

            // Check if selected word matches (forward or backward)
            if currentWord == targetWord || currentWord == reversedWord {
                // CRITICAL: Verify word length matches shape requirements
                guard isValidLengthForShape(wordLength: currentWord.count, shapeType: shape.shapeType) else {
                    continue  // Skip if word length doesn't match shape
                }

                // Verify the selected positions form a valid shape pattern
                if isValidShapePattern(positions: grid.selectedPositions, shapeType: shape.shapeType) {
                    // Make letters disappear at selected positions
                    makeLettersDisappear(at: grid.selectedPositions)
                    return shape
                }
            }
        }

        return nil
    }

    private func isValidLengthForShape(wordLength: Int, shapeType: ShapeType) -> Bool {
        switch shapeType {
        case .triangle:
            return wordLength == 3
        case .square:
            return wordLength == 4
        case .pentagon:
            return wordLength == 5
        case .hexagon:
            return wordLength == 6
        case .rectangle:
            return wordLength == 6
        case .rightTriangle:
            return wordLength == 3 || wordLength == 5
        case .circle:
            return wordLength >= 4 && wordLength <= 8
        }
    }

    private func isValidShapePattern(positions: [GridPosition], shapeType: ShapeType) -> Bool {
        guard positions.count >= 3 else { return false }

        let sortedPositions = positions.sorted { pos1, pos2 in
            if pos1.row == pos2.row {
                return pos1.column < pos2.column
            }
            return pos1.row < pos2.row
        }

        switch shapeType {
        case .rectangle:
            return isRectangleOrLine(sortedPositions)
        case .square:
            return isSquare(sortedPositions)
        case .triangle, .rightTriangle:
            return isTriangle(sortedPositions)
        case .pentagon:
            return isPentagon(sortedPositions)
        case .hexagon:
            return isHexagon(sortedPositions)
        case .circle:
            return isCircleOrAdjacent(sortedPositions)
        }
    }

    private func isRectangleOrLine(_ positions: [GridPosition]) -> Bool {
        // Rectangle must be a NON-SQUARE 2D shape
        let rows = Set(positions.map { $0.row })
        let cols = Set(positions.map { $0.column })

        // Must have at least 2 rows AND 2 columns (not a line!)
        guard rows.count >= 2 && cols.count >= 2 else {
            return false  // Reject lines
        }

        let minRow = rows.min()!
        let maxRow = rows.max()!
        let minCol = cols.min()!
        let maxCol = cols.max()!

        let rowSpan = maxRow - minRow + 1
        let colSpan = maxCol - minCol + 1

        // Rectangle must NOT be square (different dimensions)
        guard rowSpan != colSpan else {
            return false  // Reject squares
        }

        // Check if forms a rectangular pattern (all positions in grid)
        for pos in positions {
            if pos.row < minRow || pos.row > maxRow || pos.column < minCol || pos.column > maxCol {
                return false
            }
        }

        // Must be mostly filled (at least 50% of rectangle area)
        let area = rowSpan * colSpan
        return positions.count >= area / 2
    }

    private func isSquare(_ positions: [GridPosition]) -> Bool {
        guard positions.count == 4 else { return false }

        let rows = Set(positions.map { $0.row })
        let cols = Set(positions.map { $0.column })

        // Must be EXACTLY 2 rows and 2 columns (2x2 grid = Square)
        guard rows.count == 2 && cols.count == 2 else { return false }

        // Verify it's actually a 2x2 grid (all 4 corners filled)
        let minRow = rows.min()!
        let maxRow = rows.max()!
        let minCol = cols.min()!
        let maxCol = cols.max()!

        // Check all 4 positions are the corners of the square
        let expectedPositions = Set([
            GridPosition(row: minRow, column: minCol),
            GridPosition(row: minRow, column: maxCol),
            GridPosition(row: maxRow, column: minCol),
            GridPosition(row: maxRow, column: maxCol)
        ])

        return Set(positions) == expectedPositions
    }

    private func isTriangle(_ positions: [GridPosition]) -> Bool {
        guard positions.count == 3 else { return false }
        // Any 3 adjacent positions count as triangle
        return areAllAdjacent(positions)
    }

    private func isPentagon(_ positions: [GridPosition]) -> Bool {
        guard positions.count == 5 else { return false }

        // Pentagon must be in a specific pattern (not just any 5 adjacent)
        let rows = Set(positions.map { $0.row })
        let cols = Set(positions.map { $0.column })

        // Must span multiple rows AND columns (2D shape)
        guard rows.count >= 2 && cols.count >= 2 else { return false }

        // Check if it forms a cross/plus shape OR pentagon-like pattern
        return areAllAdjacent(positions) && rows.count <= 3 && cols.count <= 3
    }

    private func isHexagon(_ positions: [GridPosition]) -> Bool {
        guard positions.count == 6 else { return false }
        return areAllAdjacent(positions)
    }

    private func isCircleOrAdjacent(_ positions: [GridPosition]) -> Bool {
        return areAllAdjacent(positions)
    }

    private func areConsecutive(_ numbers: [Int]) -> Bool {
        for i in 0..<(numbers.count - 1) {
            if numbers[i+1] - numbers[i] != 1 {
                return false
            }
        }
        return true
    }

    private func isDiagonal(_ positions: [GridPosition]) -> Bool {
        // DIAGONAL LINES ARE NOT VALID SHAPES - Always return false
        return false
    }

    private func areAllAdjacent(_ positions: [GridPosition]) -> Bool {
        // Check if all positions are connected (each touches at least one other)
        var visited = Set<GridPosition>()
        var queue = [positions[0]]
        visited.insert(positions[0])

        while !queue.isEmpty {
            let current = queue.removeFirst()

            for pos in positions {
                if !visited.contains(pos) && areAdjacent(current, pos) {
                    visited.insert(pos)
                    queue.append(pos)
                }
            }
        }

        return visited.count == positions.count
    }

    private func areAdjacent(_ pos1: GridPosition, _ pos2: GridPosition) -> Bool {
        let rowDiff = abs(pos1.row - pos2.row)
        let colDiff = abs(pos1.column - pos2.column)

        // Adjacent if within 1 step (including diagonal)
        return rowDiff <= 1 && colDiff <= 1 && (rowDiff + colDiff > 0)
    }

    private func makeLettersDisappear(at positions: [GridPosition]) {
        for position in positions {
            grid.updateCell(at: position, letter: "*")  // Make cell empty
        }
    }

    private func checkGameCompletion() {
        if foundWords.count == grid.formedShapes.count && !hasRecordedCompletion {
            hasRecordedCompletion = true
            gameState = .completed
            stopTimer()
            message = "🎉 Congratulations! Puzzle completed in \(formattedTime)!"

            // Trigger completion callback for daily puzzle tracking
            onGameCompleted?()
        }
    }

    // MARK: - Helper Methods

    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: String {
        return "\(foundWords.count)/\(grid.formedShapes.count) words found"
    }

    var targetWords: [String] {
        return grid.formedShapes.map { $0.word }.sorted()
    }
}
