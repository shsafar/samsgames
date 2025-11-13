//
//  WordValidator.swift
//  WordInShapes
//
//  Validates words using iOS built-in dictionary
//

import Foundation
import UIKit

class WordValidator {
    static let shared = WordValidator()

    private let textChecker = UITextChecker()

    private init() {}

    func isValidWord(_ word: String) -> Bool {
        guard word.count >= 3 else { return false }

        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(
            in: word.lowercased(),
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )

        return misspelledRange.location == NSNotFound
    }

    func suggestCorrections(for word: String) -> [String] {
        let range = NSRange(location: 0, length: word.utf16.count)
        let guesses = textChecker.guesses(
            forWordRange: range,
            in: word.lowercased(),
            language: "en"
        )
        return guesses ?? []
    }
}
