//
//  PrivacyPolicyView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 20/04/2025.
//


import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Group {
                    SectionHeader("1. Local-Only Data Storage")
                    SectionText("All data entered into Heracles is stored only on your device. We do not collect, transmit, or store your data on external servers or cloud services.")

                    SectionHeader("2. No Account Required")
                    SectionText("You do not need to create an account or provide personal information to use Heracles.")

                    SectionHeader("3. Health and Workout Data")
                    SectionText("Workout-related data is stored locally and only used within the app. We do not access Apple Health unless you explicitly enable access.")

                    SectionHeader("4. No Third-Party Access")
                    SectionText("We do not use third-party analytics, ads, or trackers. Your data stays with you.")
                }

                Group {
                    SectionHeader("5. User Control")
                    SectionText("You can delete your data at any time by uninstalling the app.")

                    SectionHeader("6. Children’s Privacy")
                    SectionText("Heracles is not intended for children under 13. We do not knowingly collect data from children.")

                    SectionHeader("7. Changes to This Policy")
                    SectionText("We may update this policy from time to time. Changes will be reflected in the app or on our site.")

                    SectionHeader("8. Contact Us")
                    SectionText("Email: heracles@uped.dev")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }

    private func SectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
    }

    private func SectionText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.primary)
    }
}
