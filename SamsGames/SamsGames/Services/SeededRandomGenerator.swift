//
//  SeededRandomGenerator.swift
//  Sam's Games
//
//  Seeded random number generator for deterministic puzzle generation
//

import Foundation

/// A random number generator that produces deterministic results from a seed
/// Uses Linear Congruential Generator (LCG) algorithm
struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    /// Initialize with a seed value
    /// - Parameter seed: The seed for random generation (same seed = same sequence)
    init(seed: UInt64) {
        self.state = seed
    }

    /// Generate the next random number
    mutating func next() -> UInt64 {
        // LCG constants (from Numerical Recipes)
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - Convenience Extensions

extension SeededRandomGenerator {
    /// Create a generator from an Int seed
    init(seed: Int) {
        self.init(seed: UInt64(bitPattern: Int64(seed)))
    }

    /// Generate a random integer in a range
    mutating func randomInt(in range: ClosedRange<Int>) -> Int {
        return Int.random(in: range, using: &self)
    }

    /// Generate a random boolean
    mutating func randomBool() -> Bool {
        return Bool.random(using: &self)
    }

    /// Generate a random double between 0 and 1
    mutating func randomDouble() -> Double {
        return Double.random(in: 0..<1, using: &self)
    }
}

// MARK: - Array Shuffling Extension

extension Array {
    /// Shuffle array using a seeded random generator
    mutating func shuffle(using generator: inout SeededRandomGenerator) {
        for i in indices.dropFirst().reversed() {
            let offset = Int.random(in: 0...i, using: &generator)
            swapAt(i, offset)
        }
    }

    /// Return shuffled copy using a seeded random generator
    func shuffled(using generator: inout SeededRandomGenerator) -> [Element] {
        var copy = self
        copy.shuffle(using: &generator)
        return copy
    }
}
