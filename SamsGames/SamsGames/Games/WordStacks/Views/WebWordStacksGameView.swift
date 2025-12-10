//
//  WebWordStacksGameView.swift
//  Sam's Games
//
//  WordStacks game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebWordStacksGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss

    @State private var showCompletionAlert = false
    @State private var gameScore: Int = 0
    @State private var showInstructions = false
    @State private var showSplash = true
    @State private var splashScale: CGFloat = 0.5
    @State private var splashOpacity: Double = 0.0
    @State private var showExitWarning = false

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil
    var archiveSeed: Int? = nil

    // Computed seed
    private var seed: Int {
        if let archiveSeed = archiveSeed {
            return archiveSeed
        }
        return dailyPuzzleManager.getSeedForToday()
    }

    // Check if already completed (for both regular and archive mode)
    private var isAlreadyCompleted: Bool {
        if archiveMode {
            // In archive mode, check if this specific date was completed
            if let date = archiveDate {
                return statisticsManager.isCompleted(for: .wordStacks, on: date)
            }
            return false
        }
        // Regular mode - check if today is completed
        return dailyPuzzleManager.isCompletedToday(.wordStacks)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with back button and help button
                HStack {
                    Button(action: { showExitWarning = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.orange)
                    }

                    Spacer()

                    Button(action: { showInstructions = true }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))

                // Show either completed screen or game
                if isAlreadyCompleted {
                    WordStacksCompletedView()
                } else {
                    // WebView for the game
                    WebWordStacksGameViewRepresentable(
                        seed: seed,
                        onGameCompleted: handleGameCompletion
                    )
                    .id(seed)
                }
            }

            // Splash screen overlay (only if not already completed)
            if showSplash && !isAlreadyCompleted {
                ZStack {
                    // Orange-green gradient background
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.7, blue: 0.3),
                            Color(red: 0.2, green: 0.7, blue: 0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack {
                        // Try to load custom icon
                        if let customIcon = GameType.wordStacks.customIcon,
                           let uiImage = UIImage(named: customIcon) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .scaleEffect(splashScale)
                                .opacity(splashOpacity)
                        } else {
                            // Fallback to SF Symbol
                            Image(systemName: "square.stack.3d.up.fill")
                                .font(.system(size: 120))
                                .foregroundColor(.white)
                                .scaleEffect(splashScale)
                                .opacity(splashOpacity)
                        }

                        Text("WordStacks")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's WordStacks puzzle!\n\nWords Solved: \(gameScore)")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .wordStacks)
        }
        .alert("Exit Game?", isPresented: $showExitWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure? You may lose your progress if you exit.")
        }
        .onAppear {
            dailyPuzzleManager.checkForNewDay()

            if !isAlreadyCompleted {
                withAnimation(.easeOut(duration: 0.6)) {
                    splashScale = 1.0
                    splashOpacity = 1.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        showSplash = false
                    }
                }
            }
        }
    }

    private func handleGameCompletion(score: Int) {
        if archiveMode {
            // Archive mode - record completion for the specific archive date
            if let date = archiveDate {
                statisticsManager.recordCompletion(.wordStacks, date: date)
            }
        } else {
            // Regular mode - mark today as completed
            dailyPuzzleManager.markCompleted(.wordStacks)
            statisticsManager.recordCompletion(.wordStacks)
        }

        gameScore = score
        showCompletionAlert = true
    }
}

// MARK: - Already Completed View
struct WordStacksCompletedView: View {
    @State private var timeUntilNext = ""

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.7, blue: 0.3),
                    Color(red: 0.2, green: 0.7, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Icon
                if let customIcon = GameType.wordStacks.customIcon,
                   let uiImage = UIImage(named: customIcon) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                } else {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }

                VStack(spacing: 12) {
                    Text("Puzzle Completed!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("Great job! You've finished today's WordStacks puzzle.")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                VStack(spacing: 8) {
                    Text("Next puzzle in:")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))

                    Text(timeUntilNext)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.2))
                )

                Text("Try past puzzles in the Archive!")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()
            }
        }
        .onReceive(timer) { _ in
            updateCountdown()
        }
        .onAppear {
            updateCountdown()
        }
    }

    private func updateCountdown() {
        let now = Date()
        let calendar = Calendar.current

        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
              let startOfTomorrow = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            timeUntilNext = "Soon!"
            return
        }

        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: startOfTomorrow)

        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0

        timeUntilNext = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - UIViewRepresentable
struct WebWordStacksGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let onGameCompleted: (Int) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(seed: seed, onGameCompleted: onGameCompleted)
    }

    func makeUIView(context: Context) -> WKWebView {
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        dataStore.removeData(ofTypes: dataTypes, modifiedSince: Date(timeIntervalSince1970: 0)) { }

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = dataStore
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        configuration.userContentController.add(context.coordinator, name: "gameCompleted")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true

        if let htmlPath = Bundle.main.path(forResource: "wordstacks", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.navigationDelegate = context.coordinator
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("❌ Error: wordstacks.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var seed: Int
        let onGameCompleted: (Int) -> Void

        init(seed: Int, onGameCompleted: @escaping (Int) -> Void) {
            self.seed = seed
            self.onGameCompleted = onGameCompleted
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gameCompleted",
               let body = message.body as? [String: Any],
               let score = body["score"] as? Int {

                print("✅ WordStacks completed! Score: \(score)")
                onGameCompleted(score)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let script = """
            if (window.setSeed && window.enableDailyMode && window.startGame) {
                window.setSeed(\(seed));
                window.enableDailyMode();
                window.startGame();
            }
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

#Preview {
    WebWordStacksGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
