//
//  RegistrationView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/3/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    
    // Instead of a TextField for "Grade", we create a Picker for "Year"
    @State private var selectedYear = "Freshman"
    
    // The Greek Affiliation Code the user types in
    @State private var affiliationCode = ""
    
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // For showing errors
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    // We can create a list of available years
    private let allYears = ["Freshman", "Sophomore", "Junior", "Senior"]
    
    var body: some View {
        VStack {
            Image(.greekLogo)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .shadow(radius: 3)
                .padding(.vertical, 32)
            
            // Form fields
            VStack(spacing: 24) {
                // Email
                InputView(
                    text: $email,
                    title: "Email Address",
                    placeholder: "name@example.com"
                )
                .autocapitalization(.none)
                
                // Fullname
                InputView(
                    text: $fullname,
                    title: "Full Name",
                    placeholder: "Enter your name"
                )
                
                // Year (Picker)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Year")  // instead of Grade
                        .foregroundColor(Color(.darkGray))
                        .fontWeight(.semibold)
                        .font(.footnote)
                    
                    Picker("Select Year", selection: $selectedYear) {
                        ForEach(allYears, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Divider()
                }
                
                // Greek Affiliation Signup Code
                InputView(
                    text: $affiliationCode,
                    title: "Greek Affiliation Code",
                    placeholder: "Enter your code"
                )
                
                // Password
                InputView(
                    text: $password,
                    title: "Password",
                    placeholder: "Enter your password",
                    isSecureField: true
                )
                
                // Confirm Password (with checkmark)
                ZStack(alignment: .trailing) {
                    InputView(
                        text: $confirmPassword,
                        title: "Confirm Password",
                        placeholder: "Confirm your password",
                        isSecureField: true
                    )
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Sign Up button
            Button {
                Task {
                    await handleSignUp()
                }
            } label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            // Already have an account
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign in")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Sign Up Error"),
                message: Text(errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Authentication
extension RegistrationView {
    @MainActor
    private func handleSignUp() async {
        // 1) Validate the affiliation code
        guard let affiliationName = GreekAffiliationCodes.valid[affiliationCode] else {
            errorMessage = "Invalid Greek Affiliation Code."
            showErrorAlert = true
            return
        }
        
        do {
            // 2) Attempt to create user
            try await viewModel.createUser(
                withEmail: email,
                password: password,
                fullname: fullname,
                grade: selectedYear, // passing the chosen year
                affiliation: affiliationName // pass the matched affiliation
            )
        } catch {
            // 3) If it fails, show the error message
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

// MARK: - AuthenticationFormProtocol
extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
        && !affiliationCode.isEmpty  // Must have code to proceed
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}
