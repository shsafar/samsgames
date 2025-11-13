//
//  GameGrid.swift
//  WordInShapes
//
//  Main game grid model (7x7)
//

import Foundation

class GameGrid: ObservableObject {
    @Published var cells: [LetterCell]
    @Published var formedShapes: [WordShape]
    @Published var selectedPositions: [GridPosition]

    let gridSize = 7

    init() {
        self.cells = []
        self.formedShapes = []
        self.selectedPositions = []
        initializeGrid()
    }

    private func initializeGrid() {
        cells = []
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let position = GridPosition(row: row, column: col)
                cells.append(LetterCell(position: position))
            }
        }
    }

    func cell(at position: GridPosition) -> LetterCell? {
        guard position.isValid() else { return nil }
        return cells[position.index]
    }

    func updateCell(at position: GridPosition, letter: String) {
        guard position.isValid() else { return }
        cells[position.index].setLetter(letter)
    }

    func selectCell(at position: GridPosition) {
        guard position.isValid() else { return }
        cells[position.index].select()
        if !selectedPositions.contains(position) {
            selectedPositions.append(position)
        }
    }

    func deselectCell(at position: GridPosition) {
        guard position.isValid() else { return }
        cells[position.index].deselect()
        selectedPositions.removeAll { $0 == position }
    }

    func clearSelection() {
        for i in 0..<cells.count {
            cells[i].deselect()
        }
        selectedPositions.removeAll()
    }

    func addShape(_ shape: WordShape) {
        formedShapes.append(shape)
        // Mark cells as part of this shape
        for position in shape.positions {
            if position.isValid() {
                cells[position.index].isPartOfShape = true
                cells[position.index].shapeId = shape.id
            }
        }
    }

    func reset() {
        initializeGrid()
        formedShapes.removeAll()
        selectedPositions.removeAll()
    }

    var totalScore: Int {
        return formedShapes.reduce(0) { $0 + $1.score }
    }

    var isComplete: Bool {
        // Game is complete when all non-empty cells are part of shapes
        return cells.filter { !$0.isEmpty }.allSatisfy { $0.isPartOfShape }
    }
}
