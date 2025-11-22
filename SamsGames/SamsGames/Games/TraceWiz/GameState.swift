import Foundation
import SwiftUI

// MARK: - Game Constants
struct GameConstants {
    static let roundTime: TimeInterval = 30.0
    static let countdownTime: TimeInterval = 5.0
    static let lineWidth: CGFloat = 6.0
    static let clearance: CGFloat = 24.0
    static let margin: CGFloat = 60.0
    static let pathStep: CGFloat = 18.0
    static let safeDistance: CGFloat = 120.0

    // Difficulty settings
    struct Difficulty {
        let name: String
        let speed: CGFloat // pixels per second of black line reveal
        let maxDistanceFromLine: CGFloat // Maximum allowed distance from black line
        let minProgressBehind: CGFloat // Maximum distance player can be behind the revealed line

        static let easy = Difficulty(
            name: "Easy",
            speed: 150,                // 150px/sec - ensures 4500px total path for 30 seconds
            maxDistanceFromLine: 120,  // Very forgiving - can be 120px away
            minProgressBehind: 600     // Super lenient - can be 600px behind
        )

        static let medium = Difficulty(
            name: "Medium",
            speed: 150,                // 150px/sec - matches easy for 30-second gameplay (was 200)
            maxDistanceFromLine: 150,  // More forgiving - increased from 100 to 150px
            minProgressBehind: 500     // More lenient - increased from 400 to 500px
        )

        static let hard = Difficulty(
            name: "Hard",
            speed: 250,                // 250px/sec - ensures 7500px total path
            maxDistanceFromLine: 80,   // Must stay closer (80px)
            minProgressBehind: 300     // Must keep up better (300px behind max)
        )
    }
}

// MARK: - Game Phase
enum GamePhase: String {
    case idle = "Idle"
    case countdown = "Countdown"
    case running = "Running"
    case paused = "Paused"
    case ended = "Ended"
}

// MARK: - Player Model
struct Player {
    let id = UUID()
    let color: Color
    var points: [CGPoint] = []
    var isDrawing: Bool = false
    var isEliminated: Bool = false
    var eliminationReason: String?

    init(color: Color) {
        self.color = color
    }

    mutating func reset() {
        points = []
        isDrawing = false
        isEliminated = false
        eliminationReason = nil
    }
}

// MARK: - Path Segment
struct PathSegment {
    let start: CGPoint
    let end: CGPoint
    let length: CGFloat
    let accumulatedLength: CGFloat

    init(start: CGPoint, end: CGPoint, accumulatedLength: CGFloat) {
        self.start = start
        self.end = end
        self.length = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
        self.accumulatedLength = accumulatedLength + length
    }
}

// MARK: - Main Game State
class TraceWizGameState: ObservableObject {
    // Published properties for UI updates
    @Published var phase: GamePhase = .idle
    @Published var countdownTime: TimeInterval = GameConstants.countdownTime
    @Published var roundTime: TimeInterval = 0
    @Published var player: Player = Player(color: .blue)
    @Published var difficulty: GameConstants.Difficulty = .medium

    // Path properties
    @Published var pathPoints: [CGPoint] = []
    @Published var segments: [PathSegment] = []
    @Published var revealedLength: CGFloat = 0
    @Published var revealedSegmentCount: Int = 0
    @Published var startingPoint: CGPoint = .zero
    @Published var endLine: CGPoint = .zero // Finish line position

    // Canvas size
    var canvasSize: CGSize = .zero

    // Seeded random for daily puzzle
    private var seed: UInt32
    private var seededRandom: () -> Double

    // Timer
    private var gameTimer: Timer?
    private var lastUpdateTime: Date?

    // Completion tracking
    var gameCompleted: Bool = false
    var gameWon: Bool = false

    // MARK: - Initialization with seed
    init(seed: Int) {
        // Safely convert to UInt32 by taking modulo to ensure it fits
        let safeSeed = UInt32(abs(seed) % Int(UInt32.max))
        self.seed = safeSeed
        self.seededRandom = Self.mulberry32(safeSeed)
    }

    // Mulberry32 seeded random number generator
    private static func mulberry32(_ seed: UInt32) -> () -> Double {
        var state = seed
        return {
            state &+= 0x6D2B79F5
            var z = state
            z = (z ^ (z >> 15)) &* (z | 1)
            z ^= z &+ (z ^ (z >> 7)) &* (z | 61)
            let result = z ^ (z >> 14)
            return Double(result) / Double(UInt32.max)
        }
    }

    // MARK: - Game Control Methods
    func startGame() {
        guard phase == .idle else { return }

        phase = .countdown
        countdownTime = GameConstants.countdownTime
        player.reset()
        gameCompleted = false
        gameWon = false

        // Reset path reveal for the game
        revealedLength = 200 // Start with more visible portion
        revealedSegmentCount = 0
        updateRevealedSegments()

        startGameTimer()
    }

    func resetGame() {
        stopGameTimer()

        phase = .idle
        countdownTime = GameConstants.countdownTime
        roundTime = 0
        player.reset()
        revealedLength = 200 // Keep some visibility after reset
        revealedSegmentCount = 0
        updateRevealedSegments()
        gameCompleted = false
        gameWon = false
    }

    func generateNewPath() {
        guard canvasSize != .zero else {
            print("❌ TraceWiz: generateNewPath() - canvasSize is zero!")
            return
        }
        print("✅ TraceWiz: generateNewPath() - canvasSize: \(canvasSize)")
        // Reset the seeded random for consistent path generation
        self.seededRandom = Self.mulberry32(self.seed)
        generatePath(in: canvasSize)
        print("✅ TraceWiz: Path generated with \(segments.count) segments, startingPoint: \(startingPoint)")
    }

    // MARK: - Timer Management
    private func startGameTimer() {
        lastUpdateTime = Date()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            self.updateGame()
        }
    }

    private func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    private func updateGame() {
        let now = Date()
        let deltaTime = now.timeIntervalSince(lastUpdateTime ?? now)
        lastUpdateTime = now

        switch phase {
        case .countdown:
            countdownTime -= deltaTime
            if countdownTime <= 0 {
                phase = .running
                roundTime = 0
            }

        case .running:
            roundTime += deltaTime

            // Update revealed path length based on speed
            revealedLength += difficulty.speed * CGFloat(deltaTime)

            // Show final graphic line at 27 seconds - reveal the complete path earlier
            if roundTime >= 27.0 && segments.count > 0 {
                let totalPathLength = segments.last?.accumulatedLength ?? 0
                if revealedLength < totalPathLength {
                    revealedLength = totalPathLength
                }
            }

            updateRevealedSegments()

            // Check for round end
            if roundTime >= GameConstants.roundTime {
                if player.isEliminated {
                    // Already failed with specific reason
                } else {
                    // Time ran out - player didn't reach finish line in time
                    endGame(won: false, reason: "Time's up! Try to reach the finish line faster!")
                }
            }

            // Check all game rules if player is drawing
            if player.points.count >= 2 {
                checkGameRules()
            }

        default:
            break
        }
    }

    private func updateRevealedSegments() {
        var count = 0
        for segment in segments {
            if segment.accumulatedLength <= revealedLength {
                count += 1
            } else {
                break
            }
        }
        revealedSegmentCount = count
    }

    private func endGame(won: Bool, reason: String) {
        phase = .ended
        stopGameTimer()
        gameCompleted = true
        gameWon = won

        if !won {
            player.isEliminated = true
            player.eliminationReason = reason
        }
    }

    func pauseGame() {
        if phase == .running {
            phase = .paused
            stopGameTimer()
        }
    }

    func resumeGame() {
        if phase == .paused {
            phase = .running
            startGameTimer()
        }
    }

    // MARK: - Game Rules Checking
    func checkGameRules() {
        guard player.points.count >= 2 else { return }
        guard revealedSegmentCount > 0 else { return }

        let lastPlayerPoint = player.points.last!

        // Check if player reached the end line for instant win
        if endLine != .zero {
            let distanceToEndLine = distance(from: lastPlayerPoint, to: endLine)
            if distanceToEndLine < 50 { // Within 50px of end line
                endGame(won: true, reason: "Amazing! You reached the finish line!")
                return
            }
        }

        // 1. Check if player crossed the black line - improved detection
        if player.points.count >= 2 {
            let secondLastPoint = player.points[player.points.count - 2]

            for i in 0..<revealedSegmentCount {
                let segment = segments[i]

                // Check for actual intersection/crossing
                if lineSegmentsIntersect(
                    a: secondLastPoint, b: lastPlayerPoint,
                    c: segment.start, d: segment.end
                ) {
                    endGame(won: false, reason: "Crossed the black line!")
                    return
                }

                // Also check if player is too close (touching the line)
                let distToSegment = distanceFromPoint(lastPlayerPoint, toSegment: segment.start, segment.end)
                if distToSegment < 4 {
                    endGame(won: false, reason: "Crossed the black line!")
                    return
                }
            }
        }

        // 2. Check if player is too far from the black line (proximity rule - core game concept)
        let nearestDistance = findNearestDistanceToBlackLine(from: lastPlayerPoint)
        if nearestDistance > difficulty.maxDistanceFromLine {
            endGame(won: false, reason: "Too far from the black line!")
            return
        }
    }

    // Helper function to calculate distance between two points
    private func distance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }

    // Helper function to find nearest distance from player point to black line
    private func findNearestDistanceToBlackLine(from point: CGPoint) -> CGFloat {
        guard revealedSegmentCount > 0 else { return 0 }

        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude

        // Check distance to all revealed segments
        for i in 0..<revealedSegmentCount {
            let segment = segments[i]
            let distanceToSegment = distanceFromPoint(point, toSegment: segment.start, segment.end)
            minDistance = min(minDistance, distanceToSegment)
        }

        return minDistance
    }

    // MARK: - Path Generation (Large smooth curves only - NO zigzags)
    private func generatePath(in size: CGSize) {
        pathPoints = []
        segments = []

        let margin: CGFloat = 60
        let W = size.width
        let H = max(size.height * 12, 8000) // Ensure minimum 8000px height for 30+ seconds

        // Start at position determined by seeded random
        let randomValue = seededRandom()
        let randomX = margin + CGFloat(randomValue) * (W - 2 * margin)
        var currentPoint = CGPoint(x: randomX, y: margin)

        // Set blue starting point next to the black line
        let offsetDistance: CGFloat = 30
        let sideOffsetRandom = seededRandom()
        let sideOffset = sideOffsetRandom > 0.5 ? offsetDistance : -offsetDistance
        startingPoint = CGPoint(x: currentPoint.x + sideOffset, y: currentPoint.y)

        // Ensure the starting point stays within screen bounds
        if startingPoint.x < margin {
            startingPoint = CGPoint(x: currentPoint.x + offsetDistance, y: currentPoint.y)
        } else if startingPoint.x > W - margin {
            startingPoint = CGPoint(x: currentPoint.x - offsetDistance, y: currentPoint.y)
        }

        pathPoints.append(currentPoint)

        var accumulatedLength: CGFloat = 0

        // Generate simplified path with more vertical movement and fewer turns
        while currentPoint.y < H - margin {
            // Choose section type using seeded random
            let sectionTypeRandom = seededRandom()
            let sectionType = Int(sectionTypeRandom * 5)

            switch sectionType {
            case 0, 1: // Long vertical drops (40% chance)
                let dropDistanceRandom = seededRandom()
                let wobbleAmountRandom = seededRandom()
                let dropDistance = 200 + CGFloat(dropDistanceRandom) * 200
                let wobbleAmount = 8 + CGFloat(wobbleAmountRandom) * 12

                let steps = Int(dropDistance / 30)
                for i in 0..<steps {
                    let wobble = sin(CGFloat(i) * 0.2) * wobbleAmount
                    let nextX = max(margin, min(W - margin, currentPoint.x + wobble))
                    let nextY = currentPoint.y + 30

                    let nextPoint = CGPoint(x: nextX, y: nextY)
                    pathPoints.append(nextPoint)
                    let length = distance(from: currentPoint, to: nextPoint)
                    accumulatedLength += length
                    segments.append(PathSegment(
                        start: currentPoint,
                        end: nextPoint,
                        accumulatedLength: accumulatedLength
                    ))
                    currentPoint = nextPoint

                    if currentPoint.y >= H - margin { break }
                }

            case 2: // Gentle diagonal slope left
                let slopeDistanceRandom = seededRandom()
                let horizontalMoveRandom = seededRandom()
                let slopeDistance = 150 + CGFloat(slopeDistanceRandom) * 100
                let horizontalMove = 80 + CGFloat(horizontalMoveRandom) * 40
                let direction: CGFloat = currentPoint.x > W / 2 ? -1 : 1

                let steps = Int(slopeDistance / 25)
                for i in 0..<steps {
                    let progress = CGFloat(i) / CGFloat(steps)
                    let nextX = max(margin, min(W - margin, currentPoint.x + (horizontalMove * direction * progress)))
                    let nextY = currentPoint.y + 25

                    let nextPoint = CGPoint(x: nextX, y: nextY)
                    pathPoints.append(nextPoint)
                    let length = distance(from: currentPoint, to: nextPoint)
                    accumulatedLength += length
                    segments.append(PathSegment(
                        start: currentPoint,
                        end: nextPoint,
                        accumulatedLength: accumulatedLength
                    ))
                    currentPoint = nextPoint

                    if currentPoint.y >= H - margin { break }
                }

            case 3: // Gentle diagonal slope right
                let slopeDistanceRandom = seededRandom()
                let horizontalMoveRandom = seededRandom()
                let slopeDistance = 150 + CGFloat(slopeDistanceRandom) * 100
                let horizontalMove = 80 + CGFloat(horizontalMoveRandom) * 40
                let direction: CGFloat = currentPoint.x < W / 2 ? 1 : -1

                let steps = Int(slopeDistance / 25)
                for i in 0..<steps {
                    let progress = CGFloat(i) / CGFloat(steps)
                    let nextX = max(margin, min(W - margin, currentPoint.x + (horizontalMove * direction * progress)))
                    let nextY = currentPoint.y + 25

                    let nextPoint = CGPoint(x: nextX, y: nextY)
                    pathPoints.append(nextPoint)
                    let length = distance(from: currentPoint, to: nextPoint)
                    accumulatedLength += length
                    segments.append(PathSegment(
                        start: currentPoint,
                        end: nextPoint,
                        accumulatedLength: accumulatedLength
                    ))
                    currentPoint = nextPoint

                    if currentPoint.y >= H - margin { break }
                }

            default: // Wide S-curve
                let curveWidthRandom = seededRandom()
                let curveHeightRandom = seededRandom()
                let directionRandom = seededRandom()
                let curveWidth = 100 + CGFloat(curveWidthRandom) * 50
                let curveHeight = 200 + CGFloat(curveHeightRandom) * 100
                let direction: CGFloat = directionRandom > 0.5 ? 1 : -1

                let steps = Int(curveHeight / 20)
                for i in 0..<steps {
                    let progress = CGFloat(i) / CGFloat(steps)
                    let curveOffset = sin(progress * CGFloat.pi) * curveWidth * direction
                    let nextX = max(margin, min(W - margin, currentPoint.x + curveOffset))
                    let nextY = currentPoint.y + 20

                    let nextPoint = CGPoint(x: nextX, y: nextY)
                    pathPoints.append(nextPoint)
                    let length = distance(from: currentPoint, to: nextPoint)
                    accumulatedLength += length
                    segments.append(PathSegment(
                        start: currentPoint,
                        end: nextPoint,
                        accumulatedLength: accumulatedLength
                    ))
                    currentPoint = nextPoint

                    if currentPoint.y >= H - margin { break }
                }
            }
        }

        // Set end line position at the end of the path
        if let lastSegment = segments.last {
            endLine = lastSegment.end
        }

        // Initial reveal
        if segments.count > 0 {
            revealedLength = 300
            updateRevealedSegments()
        }
    }
}
