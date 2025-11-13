//
//  LetterCell.swift
//  WordInShapes
//
//  Represents a single cell in the game grid
//

import Foundation

struct LetterCell: Identifiable, Codable {
    let id: UUID
    let position: GridPosition
    var letter: String  // Single character or "*" for empty
    var isSelected: Bool
    var isPartOfShape: Bool
    var shapeId: UUID?

    init(position: GridPosition, letter: String = "*") {
        self.id = UUID()
        self.position = position
        self.letter = letter
        self.isSelected = false
        self.isPartOfShape = false
        self.shapeId = nil
    }

    var isEmpty: Bool {
        return letter == "*"
    }

    mutating func select() {
        isSelected = true
    }

    mutating func deselect() {
        isSelected = false
    }

    mutating func setLetter(_ newLetter: String) {
        self.letter = newLetter.uppercased()
    }
}
