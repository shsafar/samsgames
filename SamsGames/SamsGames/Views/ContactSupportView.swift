//
//  ContactSupportView.swift
//  Sam's Games
//
//  Support and Contact information
//

import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)

                        Text("Support & Contact")
                            .font(.system(size: 28, weight: .bold))

                        Text("We're here to help!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    // Contact Methods
                    VStack(spacing: 20) {
                        ContactCard(
                            icon: "envelope.fill",
                            title: "Email Support",
                            subtitle: "Get help via email",
                            value: "support@zyousoft.com",
                            color: .blue
                        )

                        ContactCard(
                            icon: "globe",
                            title: "Website",
                            subtitle: "Visit our website",
                            value: "www.zyousoft.com",
                            color: .green
                        )

                        ContactCard(
                            icon: "questionmark.circle.fill",
                            title: "FAQ",
                            subtitle: "Frequently asked questions",
                            value: "Coming soon",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)

                    // App Info
                    VStack(spacing: 12) {
                        Divider()
                            .padding(.vertical, 10)

                        InfoRow(label: "App Version", value: "1.0.0")
                        InfoRow(label: "Developer", value: "zYouSoft, Inc")
                        InfoRow(label: "Platform", value: "iOS")
                    }
                    .padding(.horizontal)

                    // Feedback Section
                    VStack(spacing: 12) {
                        Text("Having issues or suggestions?")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("Please email us at support@zyousoft.com with details about your experience. We appreciate your feedback!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 10)

                    Spacer(minLength: 30)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ContactCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ContactSupportView()
}
