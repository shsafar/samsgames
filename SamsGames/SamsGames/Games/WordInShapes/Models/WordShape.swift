//
//  WordShape.swift
//  WordInShapes
//
//  Represents a word formed in a geometric shape
//

import Foundation

struct WordShape: Identifiable, Codable {
    let id: UUID
    let word: String
    let shapeType: ShapeType
    let positions: [GridPosition]
    let letters: [String]

    init(word: String, shapeType: ShapeType, positions: [GridPosition]) {
        self.id = UUID()
        self.word = word.uppercased()
        self.shapeType = shapeType
        self.positions = positions
        self.letters = Array(word.uppercased()).map { String($0) }
    }

    var length: Int {
        return word.count
    }

    func contains(position: GridPosition) -> Bool {
        return positions.contains(position)
    }

    var score: Int {
        // Score based on word length and shape complexity
        let baseScore = word.count * 10
        let shapeBonus = shapeType.pointCount * 5
        return baseScore + shapeBonus
    }
}
