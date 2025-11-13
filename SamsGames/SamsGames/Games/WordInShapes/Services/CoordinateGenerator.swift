//
//  CoordinateGenerator.swift
//  WordInShapes
//
//  Generates random valid coordinates for shapes on the 7x7 grid
//

import Foundation

class CoordinateGenerator {
    static let shared = CoordinateGenerator()

    private init() {}

    /// Generate random coordinates for a shape pattern
    func generateCoordinates(for shape: ShapeType, wordLength: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Try multiple times to find valid coordinates
        let maxAttempts = 50

        for _ in 0..<maxAttempts {
            if let coordinates = tryGenerateCoordinates(for: shape, wordLength: wordLength, occupiedPositions: occupiedPositions) {
                return coordinates
            }
        }

        return nil
    }

    private func tryGenerateCoordinates(for shape: ShapeType, wordLength: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Start from a random position (uses seeded random if srand48 was called)
        let startRow = Int(drand48() * 7)
        let startCol = Int(drand48() * 7)
        let start = GridPosition(row: startRow, column: startCol)

        guard !occupiedPositions.contains(start) else { return nil }

        switch shape {
        case .square:
            return generateSquare(from: start, length: wordLength, occupiedPositions: occupiedPositions)
        case .rectangle:
            return generateRectangle(from: start, length: wordLength, occupiedPositions: occupiedPositions)
        case .triangle:
            return generateTriangle(from: start, length: wordLength, occupiedPositions: occupiedPositions)
        case .pentagon:
            return generatePentagon(from: start, length: wordLength, occupiedPositions: occupiedPositions)
        case .hexagon:
            return generateHexagon(from: start, length: wordLength, occupiedPositions: occupiedPositions)
        case .circle:
            return generateCircle(from: start, length: wordLength, occupiedPositions: occupiedPositions)
        case .rightTriangle:
            return generateRightTriangle(from: start, length: wordLength, occupiedPositions: occupiedPositions)
        }
    }

    // MARK: - Shape Generators

    private func generateSquare(from start: GridPosition, length: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Square: 4 positions in a square pattern
        guard length == 4 else { return nil }

        let patterns: [[GridPosition]] = [
            // 2x2 square
            [start,
             GridPosition(row: start.row, column: start.column + 1),
             GridPosition(row: start.row + 1, column: start.column),
             GridPosition(row: start.row + 1, column: start.column + 1)]
        ]

        return patterns.first { isValidPattern($0, occupiedPositions: occupiedPositions) }
    }

    private func generateRectangle(from start: GridPosition, length: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Rectangle: NON-SQUARE rectangular shape (must be longer in one dimension)
        guard length >= 4 && length <= 7 else { return nil }

        var patterns: [[GridPosition]] = []

        // Try different rectangle dimensions (NOT square!)
        if length == 4 {
            // 1x4 or 4x1 rectangle (NOT 2x2 - that's Square!)
            // Skip 4-letter rectangles to avoid confusion with squares
            return nil
        } else if length == 6 {
            // 2x3 rectangle
            patterns.append([
                start,
                GridPosition(row: start.row, column: start.column + 1),
                GridPosition(row: start.row, column: start.column + 2),
                GridPosition(row: start.row + 1, column: start.column),
                GridPosition(row: start.row + 1, column: start.column + 1),
                GridPosition(row: start.row + 1, column: start.column + 2)
            ])

            // 3x2 rectangle
            patterns.append([
                start,
                GridPosition(row: start.row, column: start.column + 1),
                GridPosition(row: start.row + 1, column: start.column),
                GridPosition(row: start.row + 1, column: start.column + 1),
                GridPosition(row: start.row + 2, column: start.column),
                GridPosition(row: start.row + 2, column: start.column + 1)
            ])
        } else {
            // For 5 or 7 letters, use L-shapes or irregular rectangles
            // 5 letters: L-shape
            patterns.append([
                start,
                GridPosition(row: start.row, column: start.column + 1),
                GridPosition(row: start.row, column: start.column + 2),
                GridPosition(row: start.row + 1, column: start.column),
                GridPosition(row: start.row + 1, column: start.column + 1)
            ])
        }

        return patterns.first { isValidPattern($0, occupiedPositions: occupiedPositions) }
    }

    private func generateTriangle(from start: GridPosition, length: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Triangle: 3 positions forming a triangle
        guard length == 3 else { return nil }

        let patterns: [[GridPosition]] = [
            // Upward triangle
            [start,
             GridPosition(row: start.row + 1, column: start.column - 1),
             GridPosition(row: start.row + 1, column: start.column + 1)],

            // Downward triangle
            [start,
             GridPosition(row: start.row - 1, column: start.column - 1),
             GridPosition(row: start.row - 1, column: start.column + 1)],

            // Right triangle
            [start,
             GridPosition(row: start.row - 1, column: start.column + 1),
             GridPosition(row: start.row + 1, column: start.column + 1)]
        ]

        return patterns.first { isValidPattern($0, occupiedPositions: occupiedPositions) }
    }

    private func generatePentagon(from start: GridPosition, length: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Pentagon: TRUE 2D pentagon pattern (5 positions forming pentagon shape)
        guard length == 5 else { return nil }

        let patterns: [[GridPosition]] = [
            // Pentagon: Top point + 4 base positions
            [GridPosition(row: start.row, column: start.column + 1),      // Top center
             GridPosition(row: start.row + 1, column: start.column),      // Left
             GridPosition(row: start.row + 1, column: start.column + 1),  // Center
             GridPosition(row: start.row + 1, column: start.column + 2),  // Right
             GridPosition(row: start.row + 2, column: start.column + 1)], // Bottom

            // Pentagon: Cross/Plus shape
            [start,
             GridPosition(row: start.row - 1, column: start.column),      // Up
             GridPosition(row: start.row + 1, column: start.column),      // Down
             GridPosition(row: start.row, column: start.column - 1),      // Left
             GridPosition(row: start.row, column: start.column + 1)]      // Right
        ]

        return patterns.first { isValidPattern($0, occupiedPositions: occupiedPositions) }
    }

    private func generateHexagon(from start: GridPosition, length: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Hexagon: 6 positions in a hexagon-like pattern
        guard length == 6 else { return nil }

        let patterns: [[GridPosition]] = [
            // Hexagon pattern (2x3 grid)
            [start,
             GridPosition(row: start.row, column: start.column + 1),
             GridPosition(row: start.row, column: start.column + 2),
             GridPosition(row: start.row + 1, column: start.column),
             GridPosition(row: start.row + 1, column: start.column + 1),
             GridPosition(row: start.row + 1, column: start.column + 2)],

            // Hexagon pattern (ring)
            [start,
             GridPosition(row: start.row, column: start.column + 1),
             GridPosition(row: start.row + 1, column: start.column + 1),
             GridPosition(row: start.row + 2, column: start.column + 1),
             GridPosition(row: start.row + 2, column: start.column),
             GridPosition(row: start.row + 1, column: start.column - 1)]
        ]

        return patterns.first { isValidPattern($0, occupiedPositions: occupiedPositions) }
    }

    private func generateCircle(from start: GridPosition, length: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Circle: positions forming a circular pattern
        guard length >= 4 && length <= 8 else { return nil }

        if length == 4 {
            return generateSquare(from: start, length: length, occupiedPositions: occupiedPositions)
        }

        // For other lengths, create a circular-ish pattern
        var positions = [start]
        var current = start

        let directions = [
            (0, 1),   // right
            (1, 0),   // down
            (0, -1),  // left
            (-1, 0),  // up
            (1, 1),   // diagonal down-right
            (-1, 1)   // diagonal up-right
        ]

        for i in 1..<length {
            let direction = directions[i % directions.count]
            current = GridPosition(row: current.row + direction.0, column: current.column + direction.1)
            positions.append(current)
        }

        return isValidPattern(positions, occupiedPositions: occupiedPositions) ? positions : nil
    }

    private func generateRightTriangle(from start: GridPosition, length: Int, occupiedPositions: Set<GridPosition>) -> [GridPosition]? {
        // Right triangle: TRUE L-shape (2D pattern, NOT a line!)
        guard length == 3 || length == 5 else { return nil }

        var patterns: [[GridPosition]] = []

        if length == 3 {
            // 3-letter L-shapes
            patterns.append([
                start,
                GridPosition(row: start.row + 1, column: start.column),
                GridPosition(row: start.row + 1, column: start.column + 1)
            ])

            patterns.append([
                start,
                GridPosition(row: start.row, column: start.column + 1),
                GridPosition(row: start.row + 1, column: start.column + 1)
            ])
        } else if length == 5 {
            // 5-letter L-shapes (proper 2D L)
            patterns.append([
                start,
                GridPosition(row: start.row, column: start.column + 1),
                GridPosition(row: start.row + 1, column: start.column + 1),
                GridPosition(row: start.row + 2, column: start.column + 1),
                GridPosition(row: start.row + 2, column: start.column + 2)
            ])

            patterns.append([
                start,
                GridPosition(row: start.row + 1, column: start.column),
                GridPosition(row: start.row + 2, column: start.column),
                GridPosition(row: start.row + 2, column: start.column + 1),
                GridPosition(row: start.row + 2, column: start.column + 2)
            ])
        }

        return patterns.first { isValidPattern($0, occupiedPositions: occupiedPositions) }
    }

    // MARK: - Validation

    private func isValidPattern(_ positions: [GridPosition], occupiedPositions: Set<GridPosition>) -> Bool {
        // Check all positions are valid and not occupied
        for position in positions {
            if !position.isValid() || occupiedPositions.contains(position) {
                return false
            }
        }
        return true
    }
}
