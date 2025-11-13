//
//  GridPosition.swift
//  WordInShapes
//
//  Represents a position in the 7x7 game grid
//

import Foundation

struct GridPosition: Hashable, Codable {
    let row: Int
    let column: Int

    var index: Int {
        return row * 7 + column
    }

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    init(index: Int) {
        self.row = index / 7
        self.column = index % 7
    }

    func isValid() -> Bool {
        return row >= 0 && row < 7 && column >= 0 && column < 7
    }

    func isAdjacent(to position: GridPosition) -> Bool {
        let rowDiff = abs(row - position.row)
        let colDiff = abs(column - position.column)
        return (rowDiff <= 1 && colDiff <= 1) && !(rowDiff == 0 && colDiff == 0)
    }
}
