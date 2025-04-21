//
//  TermsOfServiceView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 20/04/2025.
//


import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Group {
                    SectionHeader("1. Acceptance of Terms")
                    SectionText("By using Heracles, you agree to these Terms. If you do not agree, please do not use the app.")

                    SectionHeader("2. Local Use Only")
                    SectionText("Heracles is a local-only app. No internet connection is required, and no data is transmitted outside your device.")

                    SectionHeader("3. User Responsibility")
                    SectionText("You are responsible for the accuracy of your data, the safety of your device, and your compliance with local laws.")

                    SectionHeader("4. Health Disclaimer")
                    SectionText("Heracles is for informational purposes only. Always consult a healthcare provider before starting new workout routines.")
                }

                Group {
                    SectionHeader("5. Intellectual Property")
                    SectionText("All content and design elements in Heracles are the property of the developer unless stated otherwise. Unauthorized use is prohibited.")

                    SectionHeader("6. No Warranties")
                    SectionText("The app is provided 'as is' with no warranties or guarantees.")

                    SectionHeader("7. Limitation of Liability")
                    SectionText("We are not liable for any injuries, losses, or misuse arising from the use of Heracles.")

                    SectionHeader("8. Termination")
                    SectionText("We may discontinue or update the app without notice. You may stop using it at any time.")

                    SectionHeader("9. Changes to Terms")
                    SectionText("Updates to these Terms may occur. Continued use indicates your acceptance of any changes.")

                    SectionHeader("10. Contact")
                    SectionText("Email: heracles@uped.dev")
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
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
