//
//  WebWordInShapesGameView.swift
//  Sam's Games
//
//  HTML-based Word In Shapes integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebWordInShapesGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss

    @State private var showCompletionAlert = false
    @State private var gameTime: String = ""
    @State private var gameScore: Int = 0

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with back button
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
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))

                // WebView for the game
                WebGameViewRepresentable(
                    seed: dailyPuzzleManager.getSeedForToday(),
                    onGameCompleted: handleGameCompletion
                )
            }
        }
        .navigationBarHidden(true)
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's Word In Shapes puzzle!\n\nScore: \(gameScore)\nTime: \(gameTime)")
        }
    }

    private func handleGameCompletion(score: Int, time: String) {
        // Mark as completed in daily puzzle manager
        dailyPuzzleManager.markCompleted(.wordInShapes)

        // Record completion in statistics
        statisticsManager.recordCompletion(.wordInShapes)

        // Store score and time for alert
        gameScore = score
        gameTime = time

        // Show completion alert
        showCompletionAlert = true
    }
}

// UIViewRepresentable wrapper for WKWebView with JavaScript bridge
struct WebGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let onGameCompleted: (Int, String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(seed: seed, onGameCompleted: onGameCompleted)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Use modern API for JavaScript (iOS 14+)
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        // Add message handler for game completion
        configuration.userContentController.add(context.coordinator, name: "gameCompleted")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true

        // Load the HTML file from bundle
        if let htmlPath = Bundle.main.path(forResource: "game", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)

            // Set navigation delegate to inject seed after page loads
            webView.navigationDelegate = context.coordinator

            // Load the HTML
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("❌ Error: game.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }

    // Coordinator to handle JavaScript messages and navigation
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        let seed: Int
        let onGameCompleted: (Int, String) -> Void

        init(seed: Int, onGameCompleted: @escaping (Int, String) -> Void) {
            self.seed = seed
            self.onGameCompleted = onGameCompleted
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gameCompleted",
               let body = message.body as? [String: Any],
               let score = body["score"] as? Int,
               let time = body["time"] as? String {

                print("✅ Game completed! Score: \(score), Time: \(time)")
                onGameCompleted(score, time)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject the seed after the page loads
            let script = "if (window.setSeed) { window.setSeed(\(seed)); console.log('Seed set to: \(seed)'); }"
            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("❌ Error setting seed: \(error)")
                } else {
                    print("✅ Seed injected: \(self.seed)")
                }
            }
        }
    }
}

#Preview {
    WebWordInShapesGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
