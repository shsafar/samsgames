//
//  WebArrowRaceGameView.swift
//  Sam's Games
//
//  Arrow Race game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebArrowRaceGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var showCompletionAlert = false
    @State private var showInstructions = false
    @State private var showSplash = true
    @State private var isPulsing = false

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil
    var archiveSeed: Int? = nil

    // Calculate seed and level
    private let seed: Int
    private let level: Int

    init(archiveMode: Bool = false, archiveDate: Date? = nil, archiveSeed: Int? = nil) {
        self.archiveMode = archiveMode
        self.archiveDate = archiveDate
        self.archiveSeed = archiveSeed

        let manager = DailyPuzzleManager()
        if let archiveSeed = archiveSeed, let archiveDate = archiveDate {
            self.seed = archiveSeed
            self.level = manager.getArrowRaceLevelForDate(archiveDate)
        } else {
            self.seed = manager.getSeedForToday()
            self.level = manager.getTodayArrowRaceLevel()
        }
    }

    var body: some View {
        Group {
            if showSplash {
                splashScreen
            } else {
                gameView
            }
        }
        .onAppear {
            dailyPuzzleManager.checkForNewDay()
            startSplashTimer()
        }
        .navigationBarHidden(true)
        .alert("Game Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's Arrow Race puzzle!")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .arrowRace)
        }
    }

    // MARK: - Subviews

    private var splashScreen: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97),
                    Color(red: 0.85, green: 0.85, blue: 0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // Try to load the custom icon, show SF Symbol if not found
                if let customIcon = GameType.arrowRace.customIcon,
                   let uiImage = UIImage(named: customIcon) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 280, maxHeight: 280)
                        .padding(.horizontal, 20)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                } else {
                    // Fallback to SF Symbol
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 120))
                        .foregroundColor(.orange)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                Text("Arrow Race")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.orange)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            isPulsing = true
        }
    }

    private var gameView: some View {
        VStack(spacing: 0) {
            // Top bar with back button
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.blue)
                }

                Spacer()

                Button(action: { showInstructions = true }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(Color(UIColor.systemBackground))

            // WebView for the game
            WebArrowRaceGameViewRepresentable(
                seed: seed,
                level: level,
                onGameCompleted: archiveMode ? { _ in } : handleGameCompletion
            )
            .id("\(seed)-\(level)") // Force recreation when seed or level changes
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: - Helper Functions

    private func startSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                showSplash = false
            }
        }
    }

    private func handleGameCompletion(won: Bool) {
        if won && !archiveMode {
            dailyPuzzleManager.markCompleted(.arrowRace)
            statisticsManager.recordGamePlayed(for: .arrowRace, won: true)
            showCompletionAlert = true
        } else if !won {
            statisticsManager.recordGamePlayed(for: .arrowRace, won: false)
        }
    }
}

// MARK: - WebView Representable

struct WebArrowRaceGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let level: Int
    let onGameCompleted: (Bool) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true

        // Add message handler for game completion
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "gameComplete")
        configuration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.onGameCompleted = onGameCompleted

        guard let htmlPath = Bundle.main.path(forResource: "arrowrace", ofType: "html", inDirectory: "Games/ArrowRace") else {
            print("❌ Arrow Race HTML not found")
            return
        }

        do {
            let htmlString = try String(contentsOfFile: htmlPath, encoding: .utf8)
            let baseURL = URL(fileURLWithPath: htmlPath).deletingLastPathComponent()
            webView.loadHTMLString(htmlString, baseURL: baseURL)

            // Wait for page to load, then set seed and level
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                webView.evaluateJavaScript("window.setSeed(\(seed));") { _, error in
                    if let error = error {
                        print("❌ Error setting seed: \(error)")
                    } else {
                        print("✅ Arrow Race seed set: \(seed)")
                    }
                }

                webView.evaluateJavaScript("window.setLevel(\(level));") { _, error in
                    if let error = error {
                        print("❌ Error setting level: \(error)")
                    } else {
                        print("✅ Arrow Race level set: \(level)")
                    }
                }
            }
        } catch {
            print("❌ Error loading Arrow Race HTML: \(error)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onGameCompleted: onGameCompleted)
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        var onGameCompleted: (Bool) -> Void

        init(onGameCompleted: @escaping (Bool) -> Void) {
            self.onGameCompleted = onGameCompleted
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gameComplete", let body = message.body as? [String: Any] {
                let won = body["won"] as? Bool ?? false
                print("✅ Arrow Race game completed: \(won ? "Won" : "Lost")")
                onGameCompleted(won)
            }
        }
    }
}

// MARK: - Preview

struct WebArrowRaceGameView_Previews: PreviewProvider {
    static var previews: some View {
        WebArrowRaceGameView()
            .environmentObject(DailyPuzzleManager())
            .environmentObject(StatisticsManager())
    }
}
