//
//  SplashScreenView.swift
//  Sam's Games
//
//  Splash screen shown on app launch
//

import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Gradient background matching app icon colors
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.55, blue: 0.4),  // Coral/orange
                    Color(red: 0.95, green: 0.45, blue: 0.35)  // Darker coral
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // App Icon
                Image("SamsGamesIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .cornerRadius(40)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(scale)
                    .opacity(opacity)

                // App Name
                Text("Sam's Games")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(opacity)

                Text("Daily Puzzles")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Animate in
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }

            // Dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isPresented: .constant(true))
}
