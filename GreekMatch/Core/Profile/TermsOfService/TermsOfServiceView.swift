//
//  TermsOfServiceView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/5/25.
//

import SwiftUI

/// A scrollable Terms of Service view with a dismiss button.
struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(longTOSContent)
                    .padding()
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
            }
            .navigationTitle("Terms of Service")
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
    
    /// The full Terms of Service text with proper formatting.
    private let longTOSContent = """
    **Terms of Service**

    **Last Updated:** January 4, 2025

    Welcome to **GreekMatch**!

    These Terms of Service ("**Terms**") govern your access to and use of the **GreekMatch** mobile application (the "**App**") provided by **GreekMatchDev** ("**we**," "**us**," or "**our**"). By downloading, installing, or using the App, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use the App.

    ### 1. Use of the App

    - **Eligibility:** You must be at least **18 years old** to use the App. By using the App, you represent and warrant that you meet this age requirement.
    - **Account Creation:** To use certain features of the App, you may need to create an account. You agree to provide accurate and complete information and to keep your account information updated.
    - **Responsibilities:** You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.

    ### 2. User Conduct

    - **Prohibited Activities:** You agree not to:
      - Use the App for any unlawful purpose or in violation of any local, state, national, or international law.
      - Engage in harassment, hate speech, or any form of abusive behavior.
      - Post or transmit any content that is defamatory, obscene, or infringes on the rights of others.
      - Attempt to gain unauthorized access to the App or its related systems.

    ### 3. Content

    - **User-Generated Content:** You retain ownership of the content you post on the App. By posting content, you grant us a **non-exclusive, royalty-free, transferable, sublicensable** license to use, reproduce, modify, and display your content within the App.
    - **No Guarantee:** We do not guarantee the accuracy, reliability, or completeness of any user-generated content.

    ### 4. Privacy

    Your use of the App is also governed by our **Privacy Policy**. Please review our Privacy Policy to understand our practices regarding your personal data.

    ### 5. Termination

    We reserve the right to suspend or terminate your access to the App, without prior notice, for any reason, including violation of these Terms.

    ### 6. Disclaimers

    - **No Warranty:** The App is provided "as is" without any warranties, express or implied.
    - **Limitation of Liability:** In no event shall we be liable for any indirect, incidental, special, consequential, or punitive damages arising out of your use of the App.

    ### 7. Governing Law

    These Terms shall be governed by and construed in accordance with the laws of the **State of Florida**, without regard to its conflict of law principles.

    ### 8. Changes to Terms

    We may modify these Terms from time to time. We will notify you of any changes by updating the "Last Updated" date at the top of these Terms. Continued use of the App after any changes constitutes acceptance of the new Terms.

    ### 9. Contact Us

    If you have any questions about these Terms, please contact us at:

    - **Email:** greekmatch@gmail.com
    """
}

// MARK: - Preview

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
    }
}
