//
//  WebDoubleBubbleGameView.swift
//  Sam's Games
//
//  Double Bubble game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebDoubleBubbleGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss

    @State private var showCompletionAlert = false
    @State private var gameScore: Int = 0
    @State private var showInstructions = false

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil
    var archiveSeed: Int? = nil

    // Computed seed - properly initialized BEFORE WebView creation
    private var seed: Int {
        if let archiveSeed = archiveSeed {
            return archiveSeed
        }
        return dailyPuzzleManager.getSeedForToday()
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with back button and help button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.purple)
                    }

                    Spacer()

                    Button(action: { showInstructions = true }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))

                // WebView for the game
                WebDoubleBubbleGameViewRepresentable(
                    seed: seed,
                    onGameCompleted: archiveMode ? { _ in } : handleGameCompletion
                )
                .id(seed) // Force recreation when seed changes (new day)
            }
        }
        .navigationBarHidden(true)
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's Double Bubble puzzle!\\n\\nScore: \\(gameScore)")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .doubleBubble)
        }
        .onAppear {
            // Check if new day when view appears
            dailyPuzzleManager.checkForNewDay()
        }
    }

    private func handleGameCompletion(score: Int) {
        // Mark as completed in daily puzzle manager
        dailyPuzzleManager.markCompleted(.doubleBubble)

        // Record completion in statistics
        statisticsManager.recordCompletion(.doubleBubble)

        // Store score for alert
        gameScore = score

        // Show completion alert
        showCompletionAlert = true
    }
}

// UIViewRepresentable wrapper for WKWebView with JavaScript bridge
struct WebDoubleBubbleGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let onGameCompleted: (Int) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(seed: seed, onGameCompleted: onGameCompleted)
    }

    func makeUIView(context: Context) -> WKWebView {
        // Clear ALL WebView data first to ensure fresh game
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        dataStore.removeData(ofTypes: dataTypes, modifiedSince: Date(timeIntervalSince1970: 0)) { }

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = dataStore

        // Use modern API for JavaScript (iOS 14+)
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        // Inject script to set waitingForSeed flag BEFORE page loads
        let waitingScript = WKUserScript(
            source: "window.waitingForSeed = true;",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(waitingScript)

        // Add message handler for game completion
        configuration.userContentController.add(context.coordinator, name: "gameCompleted")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true

        // Load the HTML file from bundle
        if let htmlPath = Bundle.main.path(forResource: "doublebubble", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)

            // Set navigation delegate to inject seed after page loads
            webView.navigationDelegate = context.coordinator

            // Load the HTML
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("❌ Error: doublebubble.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed - .id(seed) handles recreation on seed change
    }

    // Coordinator to handle JavaScript messages and navigation
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

                print("✅ Game completed! Score: \\(score)")
                onGameCompleted(score)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject the seed after the page loads, then start the game
            let script = """
            if (window.setSeed && window.startDailyGame) {
                // AGGRESSIVE RESET
                localStorage.clear();
                sessionStorage.clear();

                // Set the correct daily seed
                window.setSeed(\\(seed));

                // Start daily game
                window.startDailyGame();
            }
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

#Preview {
    WebDoubleBubbleGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
