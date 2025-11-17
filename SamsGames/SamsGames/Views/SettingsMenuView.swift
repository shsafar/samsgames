//
//  SettingsMenuView.swift
//  Sam's Games
//
//  Settings and information menu
//

import SwiftUI

struct SettingsMenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: AppThemeManager
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfUse = false
    @State private var showContactSupport = false
    @State private var showQuitAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image("SamsGamesIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.3), radius: 10)

                        Text("Sam's Games")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Daily Puzzles")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)

                    // Menu Items
                    VStack(spacing: 0) {
                        // Dark Mode Toggle
                        DarkModeToggle(isDarkMode: $themeManager.isDarkMode)

                        Divider()
                            .background(Color.white.opacity(0.2))
                            .padding(.vertical, 10)

                        MenuButton(
                            icon: "shield.lefthalf.filled",
                            title: "Privacy Policy"
                        ) {
                            showPrivacyPolicy = true
                        }

                        MenuButton(
                            icon: "doc.text.fill",
                            title: "Terms of Use"
                        ) {
                            showTermsOfUse = true
                        }

                        MenuButton(
                            icon: "envelope.fill",
                            title: "Support & Contact"
                        ) {
                            showContactSupport = true
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))
                            .padding(.vertical, 10)

                        MenuButton(
                            icon: "xmark.circle.fill",
                            title: "Quit",
                            destructive: true
                        ) {
                            showQuitAlert = true
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Footer
                    Text("©zYouSoft, Inc")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showTermsOfUse) {
                TermsOfUseView()
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
            .alert("Quit App?", isPresented: $showQuitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Quit", role: .destructive) {
                    exit(0)
                }
            } message: {
                Text("Are you sure you want to quit Sam's Games?")
            }
        }
    }
}

struct DarkModeToggle: View {
    @Binding var isDarkMode: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 30)

            Text("Dark Mode")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isDarkMode)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.vertical, 4)
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    var destructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(destructive ? .red : .white)
                    .frame(width: 30)

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(destructive ? .red : .white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsMenuView()
        .environmentObject(AppThemeManager())
}
