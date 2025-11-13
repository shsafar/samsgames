//
//  ShapeType.swift
//  WordInShapes
//
//  Core shape types used in the game
//

import Foundation

enum ShapeType: String, CaseIterable, Codable {
    case pentagon = "Pentagon"
    case hexagon = "Hexagon"
    case square = "Square"
    case triangle = "Triangle"
    case rectangle = "Rectangle"
    case rightTriangle = "RightTriangle"
    case circle = "Circle"

    var pointCount: Int {
        switch self {
        case .triangle, .rightTriangle:
            return 3
        case .square, .rectangle:
            return 4
        case .pentagon:
            return 5
        case .hexagon:
            return 6
        case .circle:
            return 1
        }
    }

    var imageName: String {
        return self.rawValue
    }
}
