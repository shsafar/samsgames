//
//  WordListService.swift
//  WordInShapes
//
//  Built-in word list for puzzle generation
//

import Foundation

class WordListService {
    static let shared = WordListService()

    private init() {}

    // Organized by word length for efficient lookup
    private let wordsByLength: [Int: [String]] = [
        3: ["CAT", "DOG", "BAT", "RAT", "HAT", "SUN", "RUN", "FUN", "BIG", "PIG",
            "HOT", "POT", "COT", "BOX", "FOX", "RED", "BED", "LED", "BEE", "SEE",
            "TEA", "PEA", "SEA", "SKY", "TRY", "FLY", "ICE", "AGE", "ACE", "APE"],

        4: ["WORD", "PLAY", "GAME", "TIME", "LOVE", "HATE", "FISH", "BIRD", "TREE", "LEAF",
            "STAR", "MOON", "RAIN", "SNOW", "WIND", "FIRE", "ROCK", "GOLD", "BLUE", "PINK",
            "FAST", "SLOW", "JUMP", "SING", "DARK", "LAZY", "BUSY", "EASY", "HARD", "SOFT"],

        5: ["APPLE", "GRAPE", "PEACH", "LEMON", "MELON", "BREAD", "WATER", "HOUSE", "MUSIC", "LIGHT",
            "HAPPY", "SMILE", "LAUGH", "DANCE", "PIANO", "PLANT", "BEACH", "OCEAN", "RIVER", "CLOUD",
            "GREEN", "BROWN", "WHITE", "BLACK", "SWEET", "FRESH", "QUIET", "CRAZY", "BRAVE", "SMART"],

        6: ["PURPLE", "ORANGE", "YELLOW", "SILVER", "GOLDEN", "BRIDGE", "CASTLE", "GARDEN", "FOREST", "DESERT",
            "SPRING", "SUMMER", "WINTER", "AUTUMN", "MONDAY", "FRIDAY", "CIRCLE", "SQUARE", "DRAGON", "WIZARD",
            "PLANET", "GALAXY", "KNIGHT", "PRINCE", "BEAUTY", "FLOWER", "BUTTER", "CHEESE", "COOKIE", "CHOCOLATE"],

        7: ["RAINBOW", "DIAMOND", "EMERALD", "CRYSTAL", "BALLOON", "BLANKET", "CHICKEN", "KITCHEN", "BEDROOM", "MORNING",
            "EVENING", "HOLIDAY", "JANUARY", "OCTOBER", "AWESOME", "PERFECT", "FREEDOM", "HARMONY", "JOURNEY", "PARTNER",
            "MYSTERY", "FANTASY", "SCIENCE", "HISTORY", "PICTURE", "PROBLEM", "THOUGHT", "BELIEVE", "COMFORT", "FRIENDS"]
    ]

    /// Get a random word of specific length (supports seeded random)
    func randomWord(length: Int, useSeededRandom: Bool = false) -> String? {
        guard let words = wordsByLength[length], !words.isEmpty else {
            return nil
        }

        if useSeededRandom {
            // Use seeded random for daily puzzle consistency
            let randomIndex = Int(drand48() * Double(words.count))
            return words[randomIndex]
        } else {
            return words.randomElement()
        }
    }

    /// Get all words of specific length
    func words(ofLength length: Int) -> [String] {
        return wordsByLength[length] ?? []
    }

    /// Get a random word from any available length
    func randomWord(useSeededRandom: Bool = false) -> String {
        let allWords = wordsByLength.values.flatMap { $0 }

        if useSeededRandom {
            let randomIndex = Int(drand48() * Double(allWords.count))
            return allWords[randomIndex]
        } else {
            return allWords.randomElement() ?? "WORD"
        }
    }

    /// Get available word lengths
    var availableLengths: [Int] {
        return Array(wordsByLength.keys).sorted()
    }

    /// Total word count
    var totalWords: Int {
        return wordsByLength.values.reduce(0) { $0 + $1.count }
    }
}
