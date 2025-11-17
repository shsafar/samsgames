//
//  WebJushBoxGameView.swift
//  Sam's Games
//
//  JushBox game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebJushBoxGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var showCompletionAlert = false
    @State private var showInstructions = false
    @State private var splashPhase = 0 // 0 = first splash, 1 = second splash, 2 = game
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
            self.level = manager.getJushBoxLevelForDate(archiveDate)
        } else {
            self.seed = manager.getSeedForToday()
            self.level = manager.getTodayJushBoxLevel()
        }
    }

    var body: some View {
        Group {
            if splashPhase == 0 {
                // First splash screen
                splashScreen(imageName: "jushbox3D", text: "Reset your memory...")
            } else if splashPhase == 1 {
                // Second splash screen
                splashScreen(imageName: "jushbox3dplay", text: "Get your index ready...")
            } else {
                // Game view
                gameView
            }
        }
        .onAppear {
            // Check if new day when view appears
            dailyPuzzleManager.checkForNewDay()
            startSplashSequence()
        }
        .navigationBarHidden(true)
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's JushBox puzzle!")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .jushBox)
        }
    }

    // MARK: - Subviews

    private var gameView: some View {
        VStack(spacing: 0) {
            // Top bar with back button - respects safe area
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

            // WebView for the game - lock it in place
            WebJushBoxGameViewRepresentable(
                seed: seed,
                level: level,
                onGameComplete: {
                    handleGameCompletion()
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    private func splashScreen(imageName: String, text: String) -> some View {
        ZStack {
            (colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color.white)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Try to load the image, show placeholder if not found
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                } else {
                    // Placeholder when image not found
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 300, height: 300)

                        Text("Image: \(imageName)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Text(text)
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

    private func startSplashSequence() {
        // Show first splash for 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Reset pulsing for smooth transition to second splash
            isPulsing = false

            withAnimation {
                splashPhase = 1
            }

            // Restart pulsing after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPulsing = true
            }

            // Show second splash for 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    splashPhase = 2
                }
            }
        }
    }

    private func handleGameCompletion() {
        // Only mark as completed if not in archive mode
        if !archiveMode {
            // Mark as completed in daily puzzle manager
            dailyPuzzleManager.markCompleted(.jushBox)

            // Record completion in statistics
            statisticsManager.recordCompletion(.jushBox)
        }

        // Show completion alert after 2 seconds so user can see the solution
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCompletionAlert = true
        }
    }
}

// UIViewRepresentable wrapper for WKWebView
struct WebJushBoxGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let level: Int
    let onGameComplete: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onGameComplete: onGameComplete)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

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
        configuration.userContentController.add(context.coordinator, name: "gameComplete")

        // Enable console logging - capture all arguments
        let consoleScript = WKUserScript(
            source: """
            (function() {
                var originalLog = console.log;
                var originalError = console.error;

                console.log = function() {
                    var args = Array.prototype.slice.call(arguments);
                    var message = args.map(function(arg) {
                        if (typeof arg === 'object') {
                            try { return JSON.stringify(arg); }
                            catch(e) { return String(arg); }
                        }
                        return String(arg);
                    }).join(' ');
                    window.webkit.messageHandlers.logging.postMessage("LOG: " + message);
                };

                console.error = function() {
                    var args = Array.prototype.slice.call(arguments);
                    var message = args.map(function(arg) { return String(arg); }).join(' ');
                    window.webkit.messageHandlers.logging.postMessage("ERROR: " + message);
                };
            })();
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(consoleScript)
        configuration.userContentController.add(context.coordinator, name: "logging")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false

        // Completely disable all scrolling
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        // Disable zooming
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bouncesZoom = false

        // Set navigation delegate
        webView.navigationDelegate = context.coordinator

        // Load local jushbox-game.html using loadFileURL (required for local files)
        if let htmlPath = Bundle.main.path(forResource: "jushbox-game", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)

            // Use loadFileURL with read access to parent directory
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            print("✅ Loading JushBox game from: \(htmlPath)")
        } else {
            print("❌ Error: jushbox-game.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebJushBoxGameViewRepresentable
        var onGameComplete: () -> Void

        init(_ parent: WebJushBoxGameViewRepresentable, onGameComplete: @escaping () -> Void) {
            self.parent = parent
            self.onGameComplete = onGameComplete
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView finished loading")
            print("🔍 Seed: \(parent.seed)")
            print("🔍 Level: \(parent.level)")

            // Set seed and level, then start daily game
            let script = """
            console.log('📡 Swift calling JavaScript...');
            if (window.setSeed && window.startDailyGame) {
                window.setSeed(\(parent.seed));
                console.log('✅ Seed set to: \(parent.seed)');

                // Start game at specific level for daily mode
                window.startDailyGame(\(parent.level));
                console.log('✅ Daily game started at level: \(parent.level)');
                console.log('✅ Daily mode should be:', window.dailyMode);
                console.log('✅ Daily level should be:', window.dailyLevel);
            } else {
                console.error('❌ setSeed or startDailyGame not available');
                console.log('window.setSeed:', typeof window.setSeed);
                console.log('window.startDailyGame:', typeof window.startDailyGame);
            }
            """

            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("❌ Error setting seed and starting game: \(error)")
                } else {
                    print("✅ Seed injected and daily game started")
                    print("📊 Result: \(String(describing: result))")
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed to load: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView provisional navigation failed: \(error.localizedDescription)")
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "logging" {
                print("🌐 JS: \(message.body)")
            } else if message.name == "gameComplete" {
                print("🎉 Game completed!")
                DispatchQueue.main.async {
                    self.onGameComplete()
                }
            }
        }
    }
}

#Preview {
    WebJushBoxGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
