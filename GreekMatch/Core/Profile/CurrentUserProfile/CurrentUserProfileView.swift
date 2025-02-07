//
//  CurrentUserProfileView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import SwiftUI

struct CurrentUserProfileView: View {
    @State private var showEditProfile = false
    @State private var showTermsOfService = false
    @State private var showDeleteConfirmation = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    let user: User
    
    var body: some View {
        NavigationStack {
            List {
                // Header View
                CurrentUserProfileHeaderView(user: user)
                    .onTapGesture { showEditProfile.toggle() }
                
                // Account Information
                Section("Account Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(user.fullname)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(user.email)
                    }
                    
                    HStack {
                        Text("Year")
                        Spacer()
                        Text(user.grade)  // Assuming 'grade' now represents 'Year'
                    }
                    
                    HStack {
                        Text("Greek Affiliation")
                        Spacer()
                        Text(user.greekAffiliation)
                    }
                }
                
                // Legal Section
                Section("Legal") {
                    // Make Terms of Service clickable
                    Button(action: {
                        showTermsOfService.toggle()
                    }) {
                        Text("Terms of Service")
                            .foregroundColor(.blue)
                    }
                }
                
                // Logout/Delete Section
                Section {
                    Button("Logout") {
                        viewModel.signOut()
                    }
                    .foregroundStyle(.red)
                    
                    Button("Delete Account") {
                        showDeleteConfirmation = true
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            
            // Edit Profile Screen
            .fullScreenCover(isPresented: $showEditProfile) {
                EditProfileView(user: user)
            }
            
            // Terms of Service Sheet
            .sheet(isPresented: $showTermsOfService) {
                TermsOfServiceView()
            }
            
            // Delete Confirmation Alert
            .alert("Confirm Account Deletion", isPresented: $showDeleteConfirmation, actions: {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            // Optionally, navigate to login screen or perform other actions
                        } catch {
                            // Handle deletion error if necessary
                            print("DEBUG: Failed to delete account: \(error.localizedDescription)")
                        }
                    }
                }
            }, message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            })
        }
    }
}

// MARK: - Preview

struct CurrentUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample user for preview
        let sampleUser = User(
            id: "user123",
            fullname: "John Doe",
            email: "john@example.com",
            grade: "Junior",
            greekAffiliation: "Theta Chi",
            profileImageURLs: ["https://example.com/image1.jpg"],
            bio: "Hello! I'm John."
        )
        
        CurrentUserProfileView(user: sampleUser)
            .environmentObject(AuthViewModel())
    }
}
