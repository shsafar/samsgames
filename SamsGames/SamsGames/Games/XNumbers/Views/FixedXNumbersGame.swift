import SwiftUI

struct FixedXNumbersGame: View {
    @EnvironmentObject var game: XNumbersGameModel
    @StateObject private var progressManager = ProgressManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingCongratulations = false
    @State private var timerFlash = false
    @State private var showStats = false
    @State private var showAwards = false
    @State private var showCoinCelebration = false
    @State private var celebrationCoinImage = "bronzcoin"
    @State private var showSpecialCoinReveal = false
    @State private var specialCoinImage = ""
    @State private var specialCoinMessage = ""

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(red: 0.95, green: 0.95, blue: 0.97)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Header
                HStack {
                    // Timer - Much larger and prominent
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TIME")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        Text(game.formattedTime)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(game.timeColor)
                            .scaleEffect(game.timeElapsed >= 50 && timerFlash && !game.dailyPuzzleMode ? 1.1 : 1.0)
                            .animation(game.dailyPuzzleMode ? nil : .easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: timerFlash)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(game.timeColor.opacity(0.5), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )

                    Spacer()

                    // Stats Button (hidden in daily puzzle mode)
                    if !game.dailyPuzzleMode {
                        Button(action: {
                            showStats = true
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                Text("Stats")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )

                        Spacer()

                        // Awards Button
                        Button(action: {
                            showAwards = true
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "rosette")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                                HStack(spacing: 2) {
                                    Text("\(progressManager.totalTokens)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.orange)
                                    Image("token")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )

                        Spacer()
                    }

                    // Revealed counter and Copyright - Larger
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("Revealed:")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                            Text("\(game.hintsUsed)/\(game.maxHints)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(game.hintsUsed >= 2 ? .orange : .blue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )

                        Text("©zYouSoft, Inc")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, game.dailyPuzzleMode ? 4 : 8)
                .padding(.horizontal, 20)

                // Game Board
                ZStack {
                    GameBoardLayout(game: game)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, game.dailyPuzzleMode ? 8 : 0)

                // Controls
                VStack(spacing: game.dailyPuzzleMode ? 6 : 10) {
                    // Number Bar - Split into 2 rows
                    VStack(spacing: 6) {
                        // Row 1: Numbers 1-5
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { number in
                                Button(action: {
                                    game.placeNumber(number)
                                }) {
                                    Text("\(number)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue.opacity(0.9))
                                        .cornerRadius(8)
                                }
                                .disabled(game.selectedNode == nil)
                            }
                        }

                        // Row 2: Numbers 6-9
                        HStack(spacing: 8) {
                            ForEach(6...9, id: \.self) { number in
                                Button(action: {
                                    game.placeNumber(number)
                                }) {
                                    Text("\(number)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue.opacity(0.9))
                                        .cornerRadius(8)
                                }
                                .disabled(game.selectedNode == nil)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Level Selector Row (hidden in daily puzzle mode)
                    if !game.dailyPuzzleMode {
                    HStack(spacing: 10) {
                        // Level 1 (always unlocked)
                        Button(action: {
                            game.setLevel(1)
                            game.generateNewGame()
                        }) {
                            HStack(spacing: 4) {
                                Text("L1")
                                    .font(.system(size: 16, weight: .bold))
                                if progressManager.level1GamesCompleted >= 5 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                }
                            }
                            .foregroundColor(game.currentLevel == 1 ? .white : .gray)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(game.currentLevel == 1 ? Color.green : Color.gray.opacity(0.2))
                            .cornerRadius(15)
                        }

                        // Level 2 (locked until 5 games in L1)
                        Button(action: {
                            if progressManager.isLevelUnlocked(2) {
                                game.setLevel(2)
                                game.generateNewGame()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("L2")
                                    .font(.system(size: 16, weight: .bold))
                                if !progressManager.isLevelUnlocked(2) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12))
                                } else if progressManager.level2GamesCompleted >= 3 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                }
                            }
                            .foregroundColor(progressManager.isLevelUnlocked(2) ? (game.currentLevel == 2 ? .white : .gray) : .gray)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(progressManager.isLevelUnlocked(2) ? (game.currentLevel == 2 ? Color.green : Color.gray.opacity(0.2)) : Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        }
                        .disabled(!progressManager.isLevelUnlocked(2))

                        // Level 3 (locked until 3 games in L2)
                        Button(action: {
                            if progressManager.isLevelUnlocked(3) {
                                game.setLevel(3)
                                game.generateNewGame()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("L3")
                                    .font(.system(size: 16, weight: .bold))
                                if !progressManager.isLevelUnlocked(3) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12))
                                } else if progressManager.level3GamesCompleted >= 3 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                }
                            }
                            .foregroundColor(progressManager.isLevelUnlocked(3) ? (game.currentLevel == 3 ? .white : .gray) : .gray)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(progressManager.isLevelUnlocked(3) ? (game.currentLevel == 3 ? Color.green : Color.gray.opacity(0.2)) : Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        }
                        .disabled(!progressManager.isLevelUnlocked(3))

                        Spacer()
                    }
                    .padding(.horizontal)
                    }

                    // Rotating Ultimate Coin - Trophy Goal (hidden in daily puzzle mode)
                    if !game.dailyPuzzleMode {
                    HStack {
                        Spacer()
                        RotatingCoin()
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    }

                    // Main Controls Row
                    HStack(spacing: 20) {
                        // New button hidden in daily puzzle mode
                        if !game.dailyPuzzleMode {
                        Button(action: {
                            game.generateNewGame()
                        }) {
                            Label("New", systemImage: "arrow.clockwise")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                        }

                        Button(action: {
                            game.useHint()
                        }) {
                            Label("Reveal (\(game.maxHints - game.hintsUsed))", systemImage: "lightbulb")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(game.hintsUsed >= game.maxHints ? Color.gray : Color.orange)
                                .cornerRadius(20)
                        }
                        .disabled(game.selectedNode == nil || game.hintsUsed >= game.maxHints)

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Label("Exit", systemImage: "xmark.circle")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.red)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.bottom, game.dailyPuzzleMode ? 8 : 16)
            }

            // Coin Celebration Overlay
            if showCoinCelebration {
                CoinCelebrationView(coinImage: celebrationCoinImage, isPresented: $showCoinCelebration)
            }

            // Special Coin Reveal Overlay
            if showSpecialCoinReveal {
                SpecialCoinRevealView(
                    coinImage: specialCoinImage,
                    message: specialCoinMessage,
                    isPresented: $showSpecialCoinReveal
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Start flashing animation when time is low (only in free play mode)
            if !game.dailyPuzzleMode {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    timerFlash = true
                }
            }

            // Set up coin celebration handler
            game.onGameComplete = { level in
                // Determine which coin to show
                switch level {
                case 1:
                    celebrationCoinImage = "bronzcoin"
                case 2:
                    celebrationCoinImage = "silvercoin"
                case 3:
                    celebrationCoinImage = "goldcoin"
                default:
                    celebrationCoinImage = "bronzcoin"
                }
                // Show celebration after a brief delay (let completion alert show first)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCoinCelebration = true
                }
            }

            // Set up special coin reveal handler
            game.onSpecialCoinRevealed = { coinImage, message in
                specialCoinImage = coinImage
                specialCoinMessage = message
                // Show special coin reveal immediately
                showSpecialCoinReveal = true
            }
        }
        .alert(alertTitle, isPresented: alertBinding) {
            // Hide "New Game" button in daily puzzle mode
            if !game.dailyPuzzleMode {
                Button("New Game") {
                    game.generateNewGame()
                }
            }
            if game.showCompletionAlert {
                Button("OK") {
                    game.dismissAlert()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showStats) {
            StatsView()
        }
        .sheet(isPresented: $showAwards) {
            AwardsView()
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { game.showCompletionAlert || game.showTimeoutAlert || game.showTooManyHintsAlert },
            set: { newValue in
                if !newValue {
                    game.dismissAlert()
                }
            }
        )
    }

    private var alertTitle: String {
        if game.showCompletionAlert {
            return "Congratulations!"
        } else if game.showTimeoutAlert {
            return "Time's Up!"
        } else if game.showTooManyHintsAlert {
            return "Game Over!"
        }
        return ""
    }

    private var alertMessage: String {
        if game.showCompletionAlert {
            let timeUsed = game.maxTime - game.timeElapsed
            return "You completed the puzzle with \(timeUsed) seconds remaining and used \(game.hintsUsed) hints!"
        } else if game.showTimeoutAlert {
            return "Maximum 60 seconds exceeded. Try again!"
        } else if game.showTooManyHintsAlert {
            return "You've used too many hints (maximum 3). Try again!"
        }
        return ""
    }
}

struct GameBoardLayout: View {
    @ObservedObject var game: XNumbersGameModel

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let isLandscape = geometry.size.width > geometry.size.height
            // Detect iPad by checking if running on iPad device
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad
            let iPadMultiplier: CGFloat = isIPad ? 1.4 : 1.0
            let scale: CGFloat = (isLandscape
                ? min(geometry.size.width, geometry.size.height) / 850  // Adjusted for bigger nodes
                : min(geometry.size.width, geometry.size.height) / 650) * iPadMultiplier  // Adjusted for bigger nodes

            ZStack {
                // Draw lines to sum squares
                ForEach(game.lines) { line in
                    LinePath(line: line, nodes: game.nodes, center: center, scale: scale)
                }

                // Draw sum squares
                ForEach(game.lines) { line in
                    FixedSumSquareView(line: line, nodes: game.nodes, center: center, scale: scale)
                }

                // Draw nodes
                ForEach(game.nodes) { node in
                    NodeCircle(node: node, game: game, center: center, scale: scale)
                }
            }
        }
    }
}

struct NodeCircle: View {
    let node: GameNode
    @ObservedObject var game: XNumbersGameModel
    let center: CGPoint
    let scale: CGFloat
    var body: some View {
        Button(action: {
            game.selectNode(node)
        }) {
            ZStack {
                // Base sphere with gradient
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                backgroundColor.opacity(0.9),
                                backgroundColor
                            ]),
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: 45 * scale * 0.7
                        )
                    )
                    .frame(width: 45 * scale, height: 45 * scale)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)

                // Inner shadow for depth
                Circle()
                    .stroke(Color.black.opacity(0.2), lineWidth: 2)
                    .frame(width: 45 * scale, height: 45 * scale)

                // Glossy highlight
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0)
                            ]),
                            center: .topLeading,
                            startRadius: 1,
                            endRadius: 15 * scale
                        )
                    )
                    .frame(width: 45 * scale, height: 45 * scale)

                // Selection ring
                Circle()
                    .stroke(
                        node.isSelected ? Color.yellow : Color.white.opacity(0.3),
                        lineWidth: node.isSelected ? 3 : 1
                    )
                    .frame(width: 45 * scale, height: 45 * scale)

                // Number text
                Text(node.value != nil ? "\(node.value!)" : "?")
                    .font(.system(size: 20 * scale, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
        }
        .disabled(node.isFixed)
        .position(
            x: center.x + node.position.x * scale,
            y: center.y + node.position.y * scale
        )
    }

    private var backgroundColor: Color {
        // Selected node gets dark yellow
        if game.selectedNode?.id == node.id {
            return Color.yellow.opacity(0.9)
        }

        // Revealed nodes (using Reveal button) get orange background
        if game.revealedNodes.contains(node.id) {
            return Color.orange.opacity(0.9)
        }

        if node.isFixed {
            return Color.blue.opacity(0.9)  // Dark blue for fixed/known numbers
        } else if let value = node.value {
            // Check if all lines containing this node are complete
            let linesContainingNode = game.lines.filter { line in
                line.nodeIds.contains(node.id)
            }
            let allLinesComplete = linesContainingNode.allSatisfy { line in
                line.isComplete(nodes: game.nodes)
            }
            return allLinesComplete ? Color.green.opacity(0.7) : Color.yellow.opacity(0.9)  // Dark yellow for incomplete
        } else {
            return Color.red.opacity(0.9)  // Dark red for unknown nodes with "?"
        }
    }
}

struct LinePath: View {
    let line: GameLine
    let nodes: [GameNode]
    let center: CGPoint
    let scale: CGFloat

    var body: some View {
        Path { path in
            guard let firstNode = nodes.first(where: { $0.id == line.nodeIds.first }),
                  let lastNode = nodes.first(where: { $0.id == line.nodeIds.last }) else { return }

            path.move(to: CGPoint(
                x: center.x + firstNode.position.x * scale,
                y: center.y + firstNode.position.y * scale
            ))

            for nodeId in line.nodeIds.dropFirst() {
                if let node = nodes.first(where: { $0.id == nodeId }) {
                    path.addLine(to: CGPoint(
                        x: center.x + node.position.x * scale,
                        y: center.y + node.position.y * scale
                    ))
                }
            }

            // Extend line to sum box
            path.addLine(to: CGPoint(
                x: center.x + line.sumPosition.x * scale,
                y: center.y + line.sumPosition.y * scale
            ))
        }
        .stroke(Color.blue.opacity(0.8), lineWidth: 4)
    }
}

struct FixedSumSquareView: View {
    let line: GameLine
    let nodes: [GameNode]
    let center: CGPoint
    let scale: CGFloat

    var body: some View {
        let currentSum = line.getCurrentSum(nodes: nodes)
        let isComplete = line.isComplete(nodes: nodes)

        RoundedRectangle(cornerRadius: 6)
            .fill(isComplete ? Color.green : Color.purple)
            .frame(width: 40 * scale, height: 28 * scale)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black.opacity(0.3), lineWidth: 1.5)
            )
            .overlay(
                Text("\(line.targetSum)")
                    .font(.system(size: 14 * scale, weight: .bold))
                    .foregroundColor(.white)
            )
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            .position(
                x: center.x + line.sumPosition.x * scale,
                y: center.y + line.sumPosition.y * scale
            )
    }
}

struct CompactNumberPad: View {
    @ObservedObject var game: XNumbersGameModel

    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        VStack(spacing: 6) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(1...9, id: \.self) { number in
                    Button("\(number)") {
                        game.placeNumber(number)
                    }
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.system(size: 14, weight: .bold))
                }
            }

            Button("Clear") {
                game.clearSelectedNode()
            }
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.8))
            .cornerRadius(12)
        }
        .padding(10)
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
}

// Stats View
struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var statsManager = StatsManager.shared
    @State private var showResetAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 0.95, green: 0.95, blue: 0.97)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Level 1 Stats
                        LevelStatsCard(
                            level: 1,
                            bestTime: statsManager.level1BestTime,
                            gamesPlayed: statsManager.level1GamesPlayed,
                            gamesSolved: statsManager.level1GamesSolved
                        )

                        // Level 2 Stats
                        LevelStatsCard(
                            level: 2,
                            bestTime: statsManager.level2BestTime,
                            gamesPlayed: statsManager.level2GamesPlayed,
                            gamesSolved: statsManager.level2GamesSolved
                        )

                        // Level 3 Stats
                        LevelStatsCard(
                            level: 3,
                            bestTime: statsManager.level3BestTime,
                            gamesPlayed: statsManager.level3GamesPlayed,
                            gamesSolved: statsManager.level3GamesSolved
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showResetAlert = true
                    }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Reset All Statistics?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    statsManager.resetAllStats()
                }
            } message: {
                Text("This will permanently delete all your game statistics. This action cannot be undone.")
            }
        }
    }
}

// Coin Celebration Animation
struct CoinCelebrationView: View {
    let coinImage: String  // "bronzcoin", "silvercoin", "goldcoin"
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss on tap
                    withAnimation {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPresented = false
                    }
                }

            // Spinning coin
            Image(coinImage)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .scaleEffect(scale)
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(opacity)
        }
        .onAppear {
            // Animate coin entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.5
                opacity = 1.0
            }

            // Spin animation
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            // Scale pulse
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                scale = 1.3
            }

            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation {
                    opacity = 0
                    scale = 0.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresented = false
                }
            }
        }
    }
}

// Special Coin Reveal Animation
struct SpecialCoinRevealView: View {
    let coinImage: String  // Asset name of special coin
    let message: String    // Message to display
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var messageOpacity: Double = 0

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss on tap
                    withAnimation {
                        opacity = 0
                        messageOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPresented = false
                    }
                }

            VStack(spacing: 20) {
                // Spinning coin
                Image(coinImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(scale)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(opacity)

                // Message text
                Text(message)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(messageOpacity)
            }
        }
        .onAppear {
            // Animate coin entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.3
                opacity = 1.0
            }

            // Spin animation
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            // Scale pulse
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                scale = 1.5
            }

            // Message fade in
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                messageOpacity = 1.0
            }

            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation {
                    opacity = 0
                    messageOpacity = 0
                    scale = 0.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresented = false
                }
            }
        }
    }
}

// Awards View - Show progression, coins, tokens
struct AwardsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var progressManager = ProgressManager.shared
    @State private var showResetAlert = false
    @State private var showUnlockAlert = false
    @State private var unlockLevel = 0

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white,
                        Color(red: 0.95, green: 0.95, blue: 0.97)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Total Tokens Available Display
                        HStack {
                            Image("token")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Tokens Available")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.purple)
                                Text("\(progressManager.totalTokens)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.orange, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )

                        // Level 1 Progress
                        LevelProgressCard(
                            level: 1,
                            gamesCompleted: progressManager.level1GamesCompleted,
                            gamesRequired: 5,
                            coinCount: progressManager.bronzeCoins,
                            coinName: "Bronze",
                            coinValue: 5,
                            coinIcon: "🥉",
                            isUnlocked: true,
                            onUnlock: nil
                        )

                        // Level 2 Progress
                        LevelProgressCard(
                            level: 2,
                            gamesCompleted: progressManager.level2GamesCompleted,
                            gamesRequired: 3,
                            coinCount: progressManager.silverCoins,
                            coinName: "Silver",
                            coinValue: 10,
                            coinIcon: "🥈",
                            isUnlocked: progressManager.isLevelUnlocked(2),
                            onUnlock: progressManager.isLevelUnlocked(2) ? nil : {
                                unlockLevel = 2
                                showUnlockAlert = true
                            }
                        )

                        // Level 3 Progress
                        LevelProgressCard(
                            level: 3,
                            gamesCompleted: progressManager.level3GamesCompleted,
                            gamesRequired: 3,
                            coinCount: progressManager.goldCoins,
                            coinName: "Gold",
                            coinValue: 25,
                            coinIcon: "🥇",
                            isUnlocked: progressManager.isLevelUnlocked(3),
                            onUnlock: progressManager.isLevelUnlocked(3) ? nil : {
                                unlockLevel = 3
                                showUnlockAlert = true
                            }
                        )

                        // Ultimate Coins (repeatable purchase)
                        UltimateCoinCard(
                            ultimateCoins: progressManager.ultimateCoins,
                            totalTokens: progressManager.totalTokens,
                            onPurchase: {
                                if progressManager.purchaseUltimateCoin() {
                                    // Success animation could go here
                                }
                            }
                        )

                        // Start All Over Button
                        Button(action: {
                            showResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                Text("Start All Over")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Awards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Unlock Level \(unlockLevel)?", isPresented: $showUnlockAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Unlock (\(unlockLevel == 2 ? 25 : 50)🪙)", role: .destructive) {
                    let cost = unlockLevel == 2 ? 25 : 50
                    _ = progressManager.unlockLevel(unlockLevel, cost: cost)
                }
            } message: {
                Text("Spend \(unlockLevel == 2 ? 25 : 50) tokens to unlock Level \(unlockLevel) early?")
            }
            .alert("Reset All Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset Everything", role: .destructive) {
                    progressManager.resetAllProgress()
                }
            } message: {
                Text("This will permanently delete ALL your progression, coins, and tokens. This cannot be undone.")
            }
        }
    }
}

struct LevelProgressCard: View {
    let level: Int
    let gamesCompleted: Int
    let gamesRequired: Int
    let coinCount: Int
    let coinName: String
    let coinValue: Int
    let coinIcon: String
    let isUnlocked: Bool
    let onUnlock: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Level \(level)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.blue)
                Spacer()
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                } else if gamesCompleted >= gamesRequired {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Divider()

            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(gamesCompleted)/\(gamesRequired) games")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(gamesCompleted) / CGFloat(gamesRequired), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }

            // Coins
            HStack {
                Image(coinName == "Bronze" ? "bronzcoin" : (coinName == "Silver" ? "silvercoin" : "goldcoin"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text("\(coinName) Coins:")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                HStack(spacing: 2) {
                    Text("\(coinCount) (\(coinCount * coinValue) Tokens)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
            }

            // Unlock Button (if not unlocked)
            if let unlock = onUnlock {
                Button(action: unlock) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.open.fill")
                        Text("Unlock for \(level == 2 ? 25 : 50)")
                            .font(.system(size: 16, weight: .semibold))
                        Image("token")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct UltimateCoinCard: View {
    let ultimateCoins: Int  // Changed from hasUltimateCoin: Bool
    let totalTokens: Int
    let onPurchase: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack(spacing: 8) {
                Image("ultimatecoin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("Ultimate Coins")  // Pluralized
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.purple)
            }

            // Show count of owned ultimate coins
            Text("Owned: \(ultimateCoins)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(ultimateCoins > 0 ? .green : .gray)

            Text("The Ultimate Reward")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            // Button always visible - repeatable purchase
            Button(action: onPurchase) {
                HStack(spacing: 4) {
                    Text("Purchase Ultimate Reward for 100 Tokens")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(totalTokens >= 100 ? Color.purple : Color.gray)
                .cornerRadius(12)
            }
            .disabled(totalTokens < 100)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct LevelStatsCard: View {
    let level: Int
    let bestTime: Int
    let gamesPlayed: Int
    let gamesSolved: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Level \(level)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.blue)

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best Time")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(bestTime > 0 ? "\(bestTime)s" : "--")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.green)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Games Played")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text("\(gamesPlayed)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.blue)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Games Solved")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text("\(gamesSolved)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.purple)
                }

                Spacer()

                if gamesPlayed > 0 {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Success Rate")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Text("\(Int(Double(gamesSolved) / Double(gamesPlayed) * 100))%")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// Stats Manager
class StatsManager: ObservableObject {
    static let shared = StatsManager()

    @Published var level1BestTime: Int = 0
    @Published var level1GamesPlayed: Int = 0
    @Published var level1GamesSolved: Int = 0

    @Published var level2BestTime: Int = 0
    @Published var level2GamesPlayed: Int = 0
    @Published var level2GamesSolved: Int = 0

    @Published var level3BestTime: Int = 0
    @Published var level3GamesPlayed: Int = 0
    @Published var level3GamesSolved: Int = 0

    private init() {
        loadStats()
    }

    func loadStats() {
        level1BestTime = UserDefaults.standard.integer(forKey: "level1BestTime")
        level1GamesPlayed = UserDefaults.standard.integer(forKey: "level1GamesPlayed")
        level1GamesSolved = UserDefaults.standard.integer(forKey: "level1GamesSolved")

        level2BestTime = UserDefaults.standard.integer(forKey: "level2BestTime")
        level2GamesPlayed = UserDefaults.standard.integer(forKey: "level2GamesPlayed")
        level2GamesSolved = UserDefaults.standard.integer(forKey: "level2GamesSolved")

        level3BestTime = UserDefaults.standard.integer(forKey: "level3BestTime")
        level3GamesPlayed = UserDefaults.standard.integer(forKey: "level3GamesPlayed")
        level3GamesSolved = UserDefaults.standard.integer(forKey: "level3GamesSolved")
    }

    func recordGameComplete(level: Int, timeElapsed: Int) {
        switch level {
        case 1:
            level1GamesPlayed += 1
            level1GamesSolved += 1
            if level1BestTime == 0 || timeElapsed < level1BestTime {
                level1BestTime = timeElapsed
            }
            UserDefaults.standard.set(level1BestTime, forKey: "level1BestTime")
            UserDefaults.standard.set(level1GamesPlayed, forKey: "level1GamesPlayed")
            UserDefaults.standard.set(level1GamesSolved, forKey: "level1GamesSolved")

        case 2:
            level2GamesPlayed += 1
            level2GamesSolved += 1
            if level2BestTime == 0 || timeElapsed < level2BestTime {
                level2BestTime = timeElapsed
            }
            UserDefaults.standard.set(level2BestTime, forKey: "level2BestTime")
            UserDefaults.standard.set(level2GamesPlayed, forKey: "level2GamesPlayed")
            UserDefaults.standard.set(level2GamesSolved, forKey: "level2GamesSolved")

        case 3:
            level3GamesPlayed += 1
            level3GamesSolved += 1
            if level3BestTime == 0 || timeElapsed < level3BestTime {
                level3BestTime = timeElapsed
            }
            UserDefaults.standard.set(level3BestTime, forKey: "level3BestTime")
            UserDefaults.standard.set(level3GamesPlayed, forKey: "level3GamesPlayed")
            UserDefaults.standard.set(level3GamesSolved, forKey: "level3GamesSolved")

        default:
            break
        }
    }

    func recordGameStarted(level: Int) {
        switch level {
        case 1:
            level1GamesPlayed += 1
            UserDefaults.standard.set(level1GamesPlayed, forKey: "level1GamesPlayed")
        case 2:
            level2GamesPlayed += 1
            UserDefaults.standard.set(level2GamesPlayed, forKey: "level2GamesPlayed")
        case 3:
            level3GamesPlayed += 1
            UserDefaults.standard.set(level3GamesPlayed, forKey: "level3GamesPlayed")
        default:
            break
        }
    }

    func resetAllStats() {
        // Reset all stats to 0
        level1BestTime = 0
        level1GamesPlayed = 0
        level1GamesSolved = 0

        level2BestTime = 0
        level2GamesPlayed = 0
        level2GamesSolved = 0

        level3BestTime = 0
        level3GamesPlayed = 0
        level3GamesSolved = 0

        // Clear UserDefaults
        UserDefaults.standard.set(0, forKey: "level1BestTime")
        UserDefaults.standard.set(0, forKey: "level1GamesPlayed")
        UserDefaults.standard.set(0, forKey: "level1GamesSolved")

        UserDefaults.standard.set(0, forKey: "level2BestTime")
        UserDefaults.standard.set(0, forKey: "level2GamesPlayed")
        UserDefaults.standard.set(0, forKey: "level2GamesSolved")

        UserDefaults.standard.set(0, forKey: "level3BestTime")
        UserDefaults.standard.set(0, forKey: "level3GamesPlayed")
        UserDefaults.standard.set(0, forKey: "level3GamesSolved")
    }
}

// Progress Manager - Handles coins, tokens, and level progression
class ProgressManager: ObservableObject {
    static let shared = ProgressManager()

    // Progression tracking
    @Published var level1GamesCompleted: Int = 0
    @Published var level2GamesCompleted: Int = 0
    @Published var level3GamesCompleted: Int = 0

    // Coins collected
    @Published var bronzeCoins: Int = 0
    @Published var silverCoins: Int = 0
    @Published var goldCoins: Int = 0

    // Total tokens - computed from coin counts
    var totalTokens: Int {
        return (bronzeCoins * 5) + (silverCoins * 10) + (goldCoins * 25)
    }

    // Ultimate reward - changed to counter for multiple purchases
    @Published var ultimateCoins: Int = 0

    // Unlocked levels (1 is always unlocked)
    @Published var unlockedLevels: Set<Int> = [1]

    private init() {
        loadProgress()
    }

    func loadProgress() {
        level1GamesCompleted = UserDefaults.standard.integer(forKey: "level1GamesCompleted")
        level2GamesCompleted = UserDefaults.standard.integer(forKey: "level2GamesCompleted")
        level3GamesCompleted = UserDefaults.standard.integer(forKey: "level3GamesCompleted")

        bronzeCoins = UserDefaults.standard.integer(forKey: "bronzeCoins")
        silverCoins = UserDefaults.standard.integer(forKey: "silverCoins")
        goldCoins = UserDefaults.standard.integer(forKey: "goldCoins")

        // totalTokens is now computed automatically from coin counts
        ultimateCoins = UserDefaults.standard.integer(forKey: "ultimateCoins")

        // Load unlocked levels
        if let levels = UserDefaults.standard.array(forKey: "unlockedLevels") as? [Int] {
            unlockedLevels = Set(levels)
        } else {
            unlockedLevels = [1] // Level 1 always unlocked by default
        }

        // Re-validate unlocked levels based on current progress (safety check after reset)
        // Only unlock levels if progress justifies it
        var validLevels: Set<Int> = [1] // L1 always unlocked
        if level1GamesCompleted >= 5 {
            validLevels.insert(2)
        }
        if level2GamesCompleted >= 3 {
            validLevels.insert(3)
        }
        unlockedLevels = unlockedLevels.intersection(validLevels).union([1]) // Ensure L1 always unlocked
    }

    func recordGameComplete(level: Int) {
        switch level {
        case 1:
            if level1GamesCompleted < 5 {
                level1GamesCompleted += 1
                bronzeCoins += 1

                // Unlock Level 2 when 5 games completed
                if level1GamesCompleted >= 5 {
                    unlockedLevels.insert(2)
                }
            } else {
                // Still give coins even after unlock
                bronzeCoins += 1
            }

            UserDefaults.standard.set(level1GamesCompleted, forKey: "level1GamesCompleted")
            UserDefaults.standard.set(bronzeCoins, forKey: "bronzeCoins")

        case 2:
            if level2GamesCompleted < 3 {
                level2GamesCompleted += 1
                silverCoins += 1

                // Unlock Level 3 when 3 games completed
                if level2GamesCompleted >= 3 {
                    unlockedLevels.insert(3)
                }
            } else {
                // Still give coins even after unlock
                silverCoins += 1
            }

            UserDefaults.standard.set(level2GamesCompleted, forKey: "level2GamesCompleted")
            UserDefaults.standard.set(silverCoins, forKey: "silverCoins")

        case 3:
            level3GamesCompleted += 1
            goldCoins += 1

            UserDefaults.standard.set(level3GamesCompleted, forKey: "level3GamesCompleted")
            UserDefaults.standard.set(goldCoins, forKey: "goldCoins")

        default:
            break
        }

        // Save unlocked levels (totalTokens is now computed automatically)
        UserDefaults.standard.set(Array(unlockedLevels), forKey: "unlockedLevels")
    }

    func deductTokens(_ amount: Int) {
        // Deduct tokens by removing coins (gold first, then silver, then bronze)
        var remaining = amount

        // Remove gold coins (25 tokens each)
        let goldToRemove = min(goldCoins, remaining / 25)
        goldCoins -= goldToRemove
        remaining -= goldToRemove * 25

        // Remove silver coins (10 tokens each)
        let silverToRemove = min(silverCoins, remaining / 10)
        silverCoins -= silverToRemove
        remaining -= silverToRemove * 10

        // Remove bronze coins (5 tokens each)
        let bronzeToRemove = min(bronzeCoins, remaining / 5)
        bronzeCoins -= bronzeToRemove

        // Save updated coin counts
        UserDefaults.standard.set(bronzeCoins, forKey: "bronzeCoins")
        UserDefaults.standard.set(silverCoins, forKey: "silverCoins")
        UserDefaults.standard.set(goldCoins, forKey: "goldCoins")
    }

    func unlockLevel(_ level: Int, cost: Int) -> Bool {
        guard totalTokens >= cost else { return false }

        deductTokens(cost)
        unlockedLevels.insert(level)

        UserDefaults.standard.set(Array(unlockedLevels), forKey: "unlockedLevels")

        return true
    }

    func purchaseUltimateCoin() -> Bool {
        guard totalTokens >= 100 else { return false }

        deductTokens(100)
        ultimateCoins += 1

        UserDefaults.standard.set(ultimateCoins, forKey: "ultimateCoins")

        return true
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        return unlockedLevels.contains(level)
    }

    func addBonusProgress(level: Int, amount: Int) {
        // Add or subtract progress from special nodes (move up/down coins)
        switch level {
        case 1:
            let newProgress = max(0, level1GamesCompleted + amount)
            level1GamesCompleted = min(5, newProgress)  // Cap at 5
            UserDefaults.standard.set(level1GamesCompleted, forKey: "level1GamesCompleted")

            // Check if should unlock Level 2
            if level1GamesCompleted >= 5 {
                unlockedLevels.insert(2)
                UserDefaults.standard.set(Array(unlockedLevels), forKey: "unlockedLevels")
            }

        case 2:
            let newProgress = max(0, level2GamesCompleted + amount)
            level2GamesCompleted = min(3, newProgress)  // Cap at 3
            UserDefaults.standard.set(level2GamesCompleted, forKey: "level2GamesCompleted")

            // Check if should unlock Level 3
            if level2GamesCompleted >= 3 {
                unlockedLevels.insert(3)
                UserDefaults.standard.set(Array(unlockedLevels), forKey: "unlockedLevels")
            }

        case 3:
            let newProgress = max(0, level3GamesCompleted + amount)
            level3GamesCompleted = min(3, newProgress)  // Cap at 3
            UserDefaults.standard.set(level3GamesCompleted, forKey: "level3GamesCompleted")

        default:
            break
        }
    }

    func resetGameProgress() {
        // Reset ONLY game progress counts (keep coins and tokens)
        level1GamesCompleted = 0
        level2GamesCompleted = 0
        level3GamesCompleted = 0

        // Lock L2 and L3 again (player must replay from L1)
        unlockedLevels = [1]  // Only Level 1 unlocked

        // Save to UserDefaults
        UserDefaults.standard.set(0, forKey: "level1GamesCompleted")
        UserDefaults.standard.set(0, forKey: "level2GamesCompleted")
        UserDefaults.standard.set(0, forKey: "level3GamesCompleted")
        UserDefaults.standard.set(Array(unlockedLevels), forKey: "unlockedLevels")
    }

    func resetAllProgress() {
        // Reset everything
        level1GamesCompleted = 0
        level2GamesCompleted = 0
        level3GamesCompleted = 0

        bronzeCoins = 0
        silverCoins = 0
        goldCoins = 0

        ultimateCoins = 0
        unlockedLevels = [1]  // Only Level 1 unlocked

        // Clear UserDefaults
        UserDefaults.standard.set(0, forKey: "level1GamesCompleted")
        UserDefaults.standard.set(0, forKey: "level2GamesCompleted")
        UserDefaults.standard.set(0, forKey: "level3GamesCompleted")

        UserDefaults.standard.set(0, forKey: "bronzeCoins")
        UserDefaults.standard.set(0, forKey: "silverCoins")
        UserDefaults.standard.set(0, forKey: "goldCoins")

        UserDefaults.standard.set(0, forKey: "ultimateCoins")
        UserDefaults.standard.set([1], forKey: "unlockedLevels")

        // Reset current game level to 1 (fix for "Start All Over" bug)
        UserDefaults.standard.set(1, forKey: "currentGameLevel")

        // Post notification to reset the active game to L1
        NotificationCenter.default.post(name: NSNotification.Name("ResetGameToLevel1"), object: nil)
    }
}

// Special Node Types for Hidden Coins
enum SpecialNodeType {
    case glassy      // Instant win
    case moveUp      // +1 game progress
    case moveDown    // -1 game progress
}

// Game Model
struct GameNode: Identifiable {
    let id: Int
    let position: CGPoint
    var value: Int?
    var correctValue: Int
    var isFixed: Bool
    var isSelected: Bool = false
    var isSpecial: Bool = false
    var specialType: SpecialNodeType? = nil
}

struct GameLine: Identifiable {
    let id: Int
    let nodeIds: [Int]
    let targetSum: Int
    let sumPosition: CGPoint

    func getCurrentSum(nodes: [GameNode]) -> Int {
        nodeIds.compactMap { id in
            nodes.first(where: { $0.id == id })?.value
        }.reduce(0, +)
    }

    func isComplete(nodes: [GameNode]) -> Bool {
        let allFilled = nodeIds.allSatisfy { id in
            nodes.first(where: { $0.id == id })?.value != nil
        }
        return allFilled && getCurrentSum(nodes: nodes) == targetSum
    }
}

class XNumbersGameModel: ObservableObject {
    @Published var nodes: [GameNode] = []
    @Published var lines: [GameLine] = []
    @Published var selectedNode: GameNode?
    @Published var timeElapsed = 0
    @Published var isGameComplete = false
    @Published var showCompletionAlert = false
    @Published var hintsUsed = 0
    @Published var showTimeoutAlert = false
    @Published var showTooManyHintsAlert = false
    @Published var gameOver = false
    @Published var currentLevel: Int = 1 // Level 1 or Level 2
    @Published var revealedNodes: Set<Int> = [] // Track nodes revealed using Reveal button
    @Published var timerStarted = false // Track if timer has started (starts on first move)

    let maxTime = 60 // 60 seconds limit
    let maxHints = 3 // Maximum 3 hints

    private var timer: Timer?
    var onGameComplete: ((Int) -> Void)?  // Closure to call when game completes, passes current level
    var onSpecialCoinRevealed: ((String, String) -> Void)?  // Closure for special coin reveal (image, message)

    // Daily puzzle mode properties
    var dailyPuzzleMode: Bool = false
    var gameSeed: UInt64?
    var onDailyPuzzleComplete: (() -> Void)?  // Callback for daily puzzle completion

    init(seed: UInt64? = nil, dailyPuzzleMode: Bool = false, dailyLevel: Int? = nil) {
        self.dailyPuzzleMode = dailyPuzzleMode
        self.gameSeed = seed

        // In daily puzzle mode, use provided level; otherwise load from UserDefaults
        if dailyPuzzleMode, let level = dailyLevel {
            currentLevel = level
        } else if UserDefaults.standard.object(forKey: "currentGameLevel") != nil {
            currentLevel = UserDefaults.standard.integer(forKey: "currentGameLevel")
        } else {
            // If no saved level, determine the appropriate starting level
            let l1Complete = ProgressManager.shared.level1GamesCompleted >= 5
            let l2Complete = ProgressManager.shared.level2GamesCompleted >= 3

            if l1Complete && l2Complete {
                // Both L1 and L2 complete, start at L3
                currentLevel = 3
            } else if l1Complete {
                // L1 complete, start at L2
                currentLevel = 2
            } else {
                // Default to L1
                currentLevel = 1
            }
            UserDefaults.standard.set(currentLevel, forKey: "currentGameLevel")
        }

        // Only auto-generate if not in daily puzzle mode
        if !dailyPuzzleMode {
            generateNewGame()
        }

        // Listen for reset notification from "Start All Over" button
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ResetGameToLevel1"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.currentLevel = 1
            self?.generateNewGame()
        }
    }

    func setLevel(_ level: Int) {
        currentLevel = level
        UserDefaults.standard.set(currentLevel, forKey: "currentGameLevel")
    }

    func generateNewGame() {
        // Generate random numbers 1-9 for all positions
        let allValues = generateRandomValues()

        if currentLevel == 1 {
            // Level 1: Original 13 nodes
            // Create nodes with some hidden
            nodes = [
                // Top
                GameNode(id: 0, position: CGPoint(x: 0, y: -120), value: nil, correctValue: allValues[0], isFixed: false),

                // Row 2
                GameNode(id: 1, position: CGPoint(x: -60, y: -60), value: nil, correctValue: allValues[1], isFixed: false),
                GameNode(id: 2, position: CGPoint(x: 0, y: -60), value: nil, correctValue: allValues[2], isFixed: false),
                GameNode(id: 3, position: CGPoint(x: 60, y: -60), value: nil, correctValue: allValues[3], isFixed: false),

                // Row 3 (middle)
                GameNode(id: 4, position: CGPoint(x: -120, y: 0), value: nil, correctValue: allValues[4], isFixed: false),
                GameNode(id: 5, position: CGPoint(x: -60, y: 0), value: nil, correctValue: allValues[5], isFixed: false),
                GameNode(id: 6, position: CGPoint(x: 0, y: 0), value: nil, correctValue: allValues[6], isFixed: false),
                GameNode(id: 7, position: CGPoint(x: 60, y: 0), value: nil, correctValue: allValues[7], isFixed: false),
                GameNode(id: 8, position: CGPoint(x: 120, y: 0), value: nil, correctValue: allValues[8], isFixed: false),

                // Row 4
                GameNode(id: 9, position: CGPoint(x: -60, y: 60), value: nil, correctValue: allValues[9], isFixed: false),
                GameNode(id: 10, position: CGPoint(x: 0, y: 60), value: nil, correctValue: allValues[10], isFixed: false),
                GameNode(id: 11, position: CGPoint(x: 60, y: 60), value: nil, correctValue: allValues[11], isFixed: false),

                // Bottom
                GameNode(id: 12, position: CGPoint(x: 0, y: 120), value: nil, correctValue: allValues[12], isFixed: false)
            ]

            // Randomly hide 3-5 nodes
            let nodesToHide: Int
            var availableIndices = Array(0..<13)

            if let seed = gameSeed {
                var rng = SeededRandomGenerator(seed: seed)
                nodesToHide = Int.random(in: 3...5, using: &rng)
                availableIndices.shuffle(using: &rng)
            } else {
                nodesToHide = Int.random(in: 3...5)
                availableIndices.shuffle()
            }

            // Show values for nodes that are not hidden
            for i in nodesToHide..<13 {
                let index = availableIndices[i]
                nodes[index].value = nodes[index].correctValue
                nodes[index].isFixed = true
            }
        } else if currentLevel == 2 {
            // Level 2: Add 2 corner nodes (15 total)
            nodes = [
                // NEW: Top-left corner (aligned with diagonal)
                GameNode(id: 0, position: CGPoint(x: -120, y: -120), value: nil, correctValue: allValues[0], isFixed: false),

                // Top
                GameNode(id: 1, position: CGPoint(x: 0, y: -120), value: nil, correctValue: allValues[1], isFixed: false),

                // NEW: Top-right corner (aligned with diagonal)
                GameNode(id: 2, position: CGPoint(x: 120, y: -120), value: nil, correctValue: allValues[2], isFixed: false),

                // Row 2
                GameNode(id: 3, position: CGPoint(x: -60, y: -60), value: nil, correctValue: allValues[3], isFixed: false),
                GameNode(id: 4, position: CGPoint(x: 0, y: -60), value: nil, correctValue: allValues[4], isFixed: false),
                GameNode(id: 5, position: CGPoint(x: 60, y: -60), value: nil, correctValue: allValues[5], isFixed: false),

                // Row 3 (middle)
                GameNode(id: 6, position: CGPoint(x: -120, y: 0), value: nil, correctValue: allValues[6], isFixed: false),
                GameNode(id: 7, position: CGPoint(x: -60, y: 0), value: nil, correctValue: allValues[7], isFixed: false),
                GameNode(id: 8, position: CGPoint(x: 0, y: 0), value: nil, correctValue: allValues[8], isFixed: false),
                GameNode(id: 9, position: CGPoint(x: 60, y: 0), value: nil, correctValue: allValues[9], isFixed: false),
                GameNode(id: 10, position: CGPoint(x: 120, y: 0), value: nil, correctValue: allValues[10], isFixed: false),

                // Row 4
                GameNode(id: 11, position: CGPoint(x: -60, y: 60), value: nil, correctValue: allValues[11], isFixed: false),
                GameNode(id: 12, position: CGPoint(x: 0, y: 60), value: nil, correctValue: allValues[12], isFixed: false),
                GameNode(id: 13, position: CGPoint(x: 60, y: 60), value: nil, correctValue: allValues[13], isFixed: false),

                // Bottom
                GameNode(id: 14, position: CGPoint(x: 0, y: 120), value: nil, correctValue: allValues[14], isFixed: false)
            ]

            // Randomly hide 4-6 nodes for Level 2
            let nodesToHide: Int
            var availableIndices = Array(0..<15)

            if let seed = gameSeed {
                var rng = SeededRandomGenerator(seed: seed)
                nodesToHide = Int.random(in: 4...6, using: &rng)
                availableIndices.shuffle(using: &rng)
            } else {
                nodesToHide = Int.random(in: 4...6)
                availableIndices.shuffle()
            }

            // Show values for nodes that are not hidden
            for i in nodesToHide..<15 {
                let index = availableIndices[i]
                nodes[index].value = nodes[index].correctValue
                nodes[index].isFixed = true
            }
        } else {
            // Level 3: Add 3 nodes at top (18 total)
            nodes = [
                // NEW: Top of left diagonal
                GameNode(id: 0, position: CGPoint(x: -180, y: -180), value: nil, correctValue: allValues[0], isFixed: false),

                // NEW: Top of vertical center line
                GameNode(id: 1, position: CGPoint(x: 0, y: -180), value: nil, correctValue: allValues[1], isFixed: false),

                // NEW: Top of right diagonal
                GameNode(id: 2, position: CGPoint(x: 180, y: -180), value: nil, correctValue: allValues[2], isFixed: false),

                // Top-left corner (from Level 2)
                GameNode(id: 3, position: CGPoint(x: -120, y: -120), value: nil, correctValue: allValues[3], isFixed: false),

                // Top center (from Level 2)
                GameNode(id: 4, position: CGPoint(x: 0, y: -120), value: nil, correctValue: allValues[4], isFixed: false),

                // Top-right corner (from Level 2)
                GameNode(id: 5, position: CGPoint(x: 120, y: -120), value: nil, correctValue: allValues[5], isFixed: false),

                // Row 2
                GameNode(id: 6, position: CGPoint(x: -60, y: -60), value: nil, correctValue: allValues[6], isFixed: false),
                GameNode(id: 7, position: CGPoint(x: 0, y: -60), value: nil, correctValue: allValues[7], isFixed: false),
                GameNode(id: 8, position: CGPoint(x: 60, y: -60), value: nil, correctValue: allValues[8], isFixed: false),

                // Row 3 (middle)
                GameNode(id: 9, position: CGPoint(x: -120, y: 0), value: nil, correctValue: allValues[9], isFixed: false),
                GameNode(id: 10, position: CGPoint(x: -60, y: 0), value: nil, correctValue: allValues[10], isFixed: false),
                GameNode(id: 11, position: CGPoint(x: 0, y: 0), value: nil, correctValue: allValues[11], isFixed: false),
                GameNode(id: 12, position: CGPoint(x: 60, y: 0), value: nil, correctValue: allValues[12], isFixed: false),
                GameNode(id: 13, position: CGPoint(x: 120, y: 0), value: nil, correctValue: allValues[13], isFixed: false),

                // Row 4
                GameNode(id: 14, position: CGPoint(x: -60, y: 60), value: nil, correctValue: allValues[14], isFixed: false),
                GameNode(id: 15, position: CGPoint(x: 0, y: 60), value: nil, correctValue: allValues[15], isFixed: false),
                GameNode(id: 16, position: CGPoint(x: 60, y: 60), value: nil, correctValue: allValues[16], isFixed: false),

                // Bottom
                GameNode(id: 17, position: CGPoint(x: 0, y: 120), value: nil, correctValue: allValues[17], isFixed: false)
            ]

            // Randomly hide 5-7 nodes for Level 3
            let nodesToHide: Int
            var availableIndices = Array(0..<18)

            if let seed = gameSeed {
                var rng = SeededRandomGenerator(seed: seed)
                nodesToHide = Int.random(in: 5...7, using: &rng)
                availableIndices.shuffle(using: &rng)
            } else {
                nodesToHide = Int.random(in: 5...7)
                availableIndices.shuffle()
            }

            // Show values for nodes that are not hidden
            for i in nodesToHide..<18 {
                let index = availableIndices[i]
                nodes[index].value = nodes[index].correctValue
                nodes[index].isFixed = true
            }
        }

        // Add special nodes (30% chance)
        addSpecialNodes()

        // Calculate correct sums based on generated values
        setupLines()

        // Reset game state (timer will start on first move)
        isGameComplete = false
        showCompletionAlert = false
        timeElapsed = 0
        selectedNode = nil
        hintsUsed = 0
        showTimeoutAlert = false
        showTooManyHintsAlert = false
        gameOver = false
        revealedNodes.removeAll() // Clear revealed nodes for new game
        timerStarted = false // Timer will start when user makes first move
    }

    private func generateRandomValues() -> [Int] {
        // Generate random values between 1-9 based on level
        let count = currentLevel == 1 ? 13 : (currentLevel == 2 ? 15 : 18)

        // Use seeded random if available (for daily puzzles)
        if let seed = gameSeed {
            var rng = SeededRandomGenerator(seed: seed)
            return (0..<count).map { _ in Int.random(in: 1...9, using: &rng) }
        } else {
            return (0..<count).map { _ in Int.random(in: 1...9) }
        }
    }

    private func setupLines() {
        if currentLevel == 1 {
            // Level 1: Original lines
            lines = [
                // Horizontal middle line (left to right)
                GameLine(id: 0, nodeIds: [4, 5, 6, 7, 8],
                        targetSum: nodes[4].correctValue + nodes[5].correctValue + nodes[6].correctValue + nodes[7].correctValue + nodes[8].correctValue,
                        sumPosition: CGPoint(x: -160, y: 0)),

                GameLine(id: 1, nodeIds: [4, 5, 6, 7, 8],
                        targetSum: nodes[4].correctValue + nodes[5].correctValue + nodes[6].correctValue + nodes[7].correctValue + nodes[8].correctValue,
                        sumPosition: CGPoint(x: 160, y: 0)),

                // Vertical middle line (top to bottom)
                GameLine(id: 2, nodeIds: [0, 2, 6, 10, 12],
                        targetSum: nodes[0].correctValue + nodes[2].correctValue + nodes[6].correctValue + nodes[10].correctValue + nodes[12].correctValue,
                        sumPosition: CGPoint(x: 0, y: 160)),

                // Top-right to bottom-left diagonal
                GameLine(id: 3, nodeIds: [3, 6, 9],
                        targetSum: nodes[3].correctValue + nodes[6].correctValue + nodes[9].correctValue,
                        sumPosition: CGPoint(x: -100, y: 100)),

                // Top-left to bottom-right diagonal
                GameLine(id: 4, nodeIds: [1, 6, 11],
                        targetSum: nodes[1].correctValue + nodes[6].correctValue + nodes[11].correctValue,
                        sumPosition: CGPoint(x: 100, y: 100))
            ]
        } else if currentLevel == 2 {
            // Level 2: Lines with new corner nodes
            lines = [
                // Horizontal middle line (left to right)
                GameLine(id: 0, nodeIds: [6, 7, 8, 9, 10],
                        targetSum: nodes[6].correctValue + nodes[7].correctValue + nodes[8].correctValue + nodes[9].correctValue + nodes[10].correctValue,
                        sumPosition: CGPoint(x: -160, y: 0)),

                GameLine(id: 1, nodeIds: [6, 7, 8, 9, 10],
                        targetSum: nodes[6].correctValue + nodes[7].correctValue + nodes[8].correctValue + nodes[9].correctValue + nodes[10].correctValue,
                        sumPosition: CGPoint(x: 160, y: 0)),

                // Vertical middle line (top to bottom)
                GameLine(id: 2, nodeIds: [1, 4, 8, 12, 14],
                        targetSum: nodes[1].correctValue + nodes[4].correctValue + nodes[8].correctValue + nodes[12].correctValue + nodes[14].correctValue,
                        sumPosition: CGPoint(x: 0, y: 160)),

                // Top-left corner diagonal (NEW) - sum displays on RIGHT
                GameLine(id: 3, nodeIds: [0, 3, 8, 13],
                        targetSum: nodes[0].correctValue + nodes[3].correctValue + nodes[8].correctValue + nodes[13].correctValue,
                        sumPosition: CGPoint(x: 100, y: 100)),

                // Top-right corner diagonal (NEW) - sum displays on LEFT
                GameLine(id: 4, nodeIds: [2, 5, 8, 11],
                        targetSum: nodes[2].correctValue + nodes[5].correctValue + nodes[8].correctValue + nodes[11].correctValue,
                        sumPosition: CGPoint(x: -100, y: 100))
            ]
        } else {
            // Level 3: Lines with 3 additional top nodes
            lines = [
                // Horizontal middle line (left to right)
                GameLine(id: 0, nodeIds: [9, 10, 11, 12, 13],
                        targetSum: nodes[9].correctValue + nodes[10].correctValue + nodes[11].correctValue + nodes[12].correctValue + nodes[13].correctValue,
                        sumPosition: CGPoint(x: -160, y: 0)),

                GameLine(id: 1, nodeIds: [9, 10, 11, 12, 13],
                        targetSum: nodes[9].correctValue + nodes[10].correctValue + nodes[11].correctValue + nodes[12].correctValue + nodes[13].correctValue,
                        sumPosition: CGPoint(x: 160, y: 0)),

                // Vertical middle line (top to bottom) - extended to new top node
                GameLine(id: 2, nodeIds: [1, 4, 7, 11, 15, 17],
                        targetSum: nodes[1].correctValue + nodes[4].correctValue + nodes[7].correctValue + nodes[11].correctValue + nodes[15].correctValue + nodes[17].correctValue,
                        sumPosition: CGPoint(x: 0, y: 160)),

                // Left diagonal (top to bottom) - extended to new top node
                GameLine(id: 3, nodeIds: [0, 3, 6, 11, 16],
                        targetSum: nodes[0].correctValue + nodes[3].correctValue + nodes[6].correctValue + nodes[11].correctValue + nodes[16].correctValue,
                        sumPosition: CGPoint(x: 100, y: 100)),

                // Right diagonal (top to bottom) - extended to new top node
                GameLine(id: 4, nodeIds: [2, 5, 8, 11, 14],
                        targetSum: nodes[2].correctValue + nodes[5].correctValue + nodes[8].correctValue + nodes[11].correctValue + nodes[14].correctValue,
                        sumPosition: CGPoint(x: -100, y: 100))
            ]
        }
    }

    private func addSpecialNodes() {
        // No special coins in Level 1 - only L2 and L3
        guard currentLevel >= 2 else { return }

        // 30% chance to add special nodes
        guard Int.random(in: 1...100) <= 30 else { return }

        // Get indices of hidden nodes (not fixed, no value)
        let hiddenNodeIndices = nodes.indices.filter { !nodes[$0].isFixed && nodes[$0].value == nil }
        guard !hiddenNodeIndices.isEmpty else { return }

        // Determine how many special nodes to add based on level
        var specialNodesToAdd = 0
        var glassyCount = 0

        // Use seeded random if available
        if let seed = gameSeed {
            var rng = SeededRandomGenerator(seed: seed &+ 1000) // Offset seed for special nodes
            switch currentLevel {
            case 1:
                specialNodesToAdd = Int.random(in: 1...2, using: &rng)
            case 2:
                specialNodesToAdd = Int.random(in: 1...3, using: &rng)
                glassyCount = min(Int.random(in: 0...2, using: &rng), specialNodesToAdd)
            case 3:
                specialNodesToAdd = Int.random(in: 1...2, using: &rng)
                glassyCount = min(Int.random(in: 0...1, using: &rng), specialNodesToAdd)
            default:
                break
            }
            // Randomly select nodes to make special (seeded)
            let selectedIndices = hiddenNodeIndices.shuffled(using: &rng).prefix(min(specialNodesToAdd, hiddenNodeIndices.count))
        } else {
            switch currentLevel {
            case 1:
                specialNodesToAdd = Int.random(in: 1...2)
            case 2:
                specialNodesToAdd = Int.random(in: 1...3)
                glassyCount = min(Int.random(in: 0...2), specialNodesToAdd)
            case 3:
                specialNodesToAdd = Int.random(in: 1...2)
                glassyCount = min(Int.random(in: 0...1), specialNodesToAdd)
            default:
                break
            }
        }

        // Randomly select nodes to make special
        let selectedIndices: any Collection<Int>
        if let seed = gameSeed {
            var rng = SeededRandomGenerator(seed: seed &+ 1000)
            selectedIndices = hiddenNodeIndices.shuffled(using: &rng).prefix(min(specialNodesToAdd, hiddenNodeIndices.count))
        } else {
            selectedIndices = hiddenNodeIndices.shuffled().prefix(min(specialNodesToAdd, hiddenNodeIndices.count))
        }

        // Assign special types
        var glassyAssigned = 0
        for index in selectedIndices {
            if glassyAssigned < glassyCount {
                // Assign glassy
                nodes[index].isSpecial = true
                nodes[index].specialType = .glassy
                glassyAssigned += 1
            } else {
                // Randomly assign move up or move down
                nodes[index].isSpecial = true
                nodes[index].specialType = Bool.random() ? .moveUp : .moveDown
            }
        }
    }

    func selectNode(_ node: GameNode) {
        guard !node.isFixed else { return }

        for i in nodes.indices {
            nodes[i].isSelected = false
        }

        if let index = nodes.firstIndex(where: { $0.id == node.id }) {
            // Check if this is a special node - reveal immediately!
            if nodes[index].isSpecial, let specialType = nodes[index].specialType {
                // Don't select the node, just trigger the special effect
                handleSpecialNodeEffect(specialType)

                // For glassy coin, game will complete automatically (checkGameComplete handles it)
                checkGameComplete()

                // For move up/down coins, auto-generate new game to prevent exploit
                if specialType == .moveUp || specialType == .moveDown {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.generateNewGame()
                    }
                }
                return
            }

            // Regular node - select it for number entry
            nodes[index].isSelected = true
            selectedNode = nodes[index]

            // Start timer on first move
            if !timerStarted {
                timerStarted = true
                startTimer()
            }
        }
    }

    func placeNumber(_ number: Int) {
        guard let selected = selectedNode,
              let index = nodes.firstIndex(where: { $0.id == selected.id }) else { return }

        // Start timer on first move (if not already started)
        if !timerStarted {
            timerStarted = true
            startTimer()
        }

        nodes[index].value = number
        nodes[index].isSelected = false
        selectedNode = nil

        checkGameComplete()
    }

    private func handleSpecialNodeEffect(_ type: SpecialNodeType) {
        // Determine coin image and message based on type
        let coinImage: String
        let message: String

        switch type {
        case .glassy:
            coinImage = "goldcoin"  // Using gold coin for now - add glassy coin asset later
            message = "Golden Infinity Coin- Instant Win!"
            // Instant win - complete all nodes with correct values
            for i in nodes.indices {
                if !nodes[i].isFixed {
                    nodes[i].value = nodes[i].correctValue
                }
            }
            // Game will be checked as complete in checkGameComplete()

        case .moveUp:
            coinImage = "moveup coin"  // Asset name with space as shown in folder
            message = "Good Luck Function-Move Up 1 Game"
            // Add +1 to current level progress AND award coins
            ProgressManager.shared.addBonusProgress(level: currentLevel, amount: 1)
            // Award the level's coin (bronze/silver/gold) for the bonus progress
            switch currentLevel {
            case 1:
                ProgressManager.shared.bronzeCoins += 1
                UserDefaults.standard.set(ProgressManager.shared.bronzeCoins, forKey: "bronzeCoins")
            case 2:
                ProgressManager.shared.silverCoins += 1
                UserDefaults.standard.set(ProgressManager.shared.silverCoins, forKey: "silverCoins")
            case 3:
                ProgressManager.shared.goldCoins += 1
                UserDefaults.standard.set(ProgressManager.shared.goldCoins, forKey: "goldCoins")
            default:
                break
            }

        case .moveDown:
            coinImage = "move lose down coin"  // Asset name with spaces as shown in folder
            message = "Square Root, Bad Luck!\nMove down a game"
            // Subtract -1 from current level progress (don't go below 0) AND remove coins
            ProgressManager.shared.addBonusProgress(level: currentLevel, amount: -1)
            // Remove the level's coin (bronze/silver/gold) for the penalty
            switch currentLevel {
            case 1:
                ProgressManager.shared.bronzeCoins = max(0, ProgressManager.shared.bronzeCoins - 1)
                UserDefaults.standard.set(ProgressManager.shared.bronzeCoins, forKey: "bronzeCoins")
            case 2:
                ProgressManager.shared.silverCoins = max(0, ProgressManager.shared.silverCoins - 1)
                UserDefaults.standard.set(ProgressManager.shared.silverCoins, forKey: "silverCoins")
            case 3:
                ProgressManager.shared.goldCoins = max(0, ProgressManager.shared.goldCoins - 1)
                UserDefaults.standard.set(ProgressManager.shared.goldCoins, forKey: "goldCoins")
            default:
                break
            }
        }

        // Trigger the special coin reveal popup
        onSpecialCoinRevealed?(coinImage, message)
    }

    func clearSelectedNode() {
        guard let selected = selectedNode,
              let index = nodes.firstIndex(where: { $0.id == selected.id }) else { return }

        nodes[index].value = nil
        nodes[index].isSelected = false
        selectedNode = nil
    }

    func useHint() {
        guard let selected = selectedNode,
              let index = nodes.firstIndex(where: { $0.id == selected.id }),
              !gameOver else { return }

        // Check if too many hints
        if hintsUsed >= maxHints {
            showTooManyHintsAlert = true
            gameOver = true
            stopTimer()
            return
        }

        hintsUsed += 1
        nodes[index].value = nodes[index].correctValue
        nodes[index].isSelected = false

        // Mark this node as revealed (for orange background)
        revealedNodes.insert(nodes[index].id)

        selectedNode = nil

        checkGameComplete()
    }

    private func checkGameComplete() {
        // Check if all lines add up correctly to their target sums
        let allLinesCorrect = lines.allSatisfy { line in
            line.isComplete(nodes: nodes)
        }

        if allLinesCorrect {
            isGameComplete = true
            showCompletionAlert = true
            stopTimer()

            // Daily puzzle mode: trigger completion callback and skip auto-generation
            if dailyPuzzleMode {
                onDailyPuzzleComplete?()
                return
            }

            // Record stats
            StatsManager.shared.recordGameComplete(level: currentLevel, timeElapsed: timeElapsed)

            // Award coins and tokens for progression
            ProgressManager.shared.recordGameComplete(level: currentLevel)

            // Trigger coin celebration (before changing level)
            let completedLevel = currentLevel
            onGameComplete?(completedLevel)

            // Auto-advance to next level if current level is complete
            if completedLevel == 1 && ProgressManager.shared.level1GamesCompleted >= 5 {
                // L1 complete, move to L2 and generate new game
                if ProgressManager.shared.isLevelUnlocked(2) {
                    setLevel(2)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.generateNewGame()
                    }
                }
            } else if completedLevel == 2 && ProgressManager.shared.level2GamesCompleted >= 3 {
                // L2 complete, move to L3 and generate new game
                if ProgressManager.shared.isLevelUnlocked(3) {
                    setLevel(3)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.generateNewGame()
                    }
                }
            } else if completedLevel == 3 && ProgressManager.shared.level3GamesCompleted >= 3 {
                // L3 complete (3/3) - Reset game progress and start cycle over
                ProgressManager.shared.resetGameProgress()
                // Go back to L1 and generate new game
                setLevel(1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.generateNewGame()
                }
            } else {
                // Still progressing within current level - auto-generate new game
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.generateNewGame()
                }
            }
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if !self.isGameComplete && !self.gameOver {
                    self.timeElapsed += 1

                    // Check for timeout
                    if self.timeElapsed >= self.maxTime {
                        self.showTimeoutAlert = true
                        self.gameOver = true
                        self.stopTimer()
                    }
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    var formattedTime: String {
        let remainingTime = max(0, maxTime - timeElapsed)
        return String(format: "%02d:%02d", remainingTime / 60, remainingTime % 60)
    }

    var timeColor: Color {
        let remainingTime = maxTime - timeElapsed
        if remainingTime <= 10 {
            return .red
        } else if remainingTime <= 20 {
            return .orange
        } else {
            return .black
        }
    }

    func dismissAlert() {
        // Reset alert states
        showCompletionAlert = false
        showTimeoutAlert = false
        showTooManyHintsAlert = false
        // Keep isGameComplete true if the game was actually completed
    }
}

// MARK: - Rotating Coin Component
struct RotatingCoin: View {
    @State private var rotation: Double = 0

    var body: some View {
        Image("ultimatecoin")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}
