//
//  EditProfileView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/26/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    // We receive the current user from outside
    let user: User
    
    // Local states for editing
    @State private var bio: String
    @State private var greekAffiliation: String
    @State private var year: String
    
    // NEW: We'll store the user's profile images in a local array so we can edit/add/delete them
    @State private var profileImageURLs: [String]
    
    // Custom init to prefill from user
    init(user: User) {
        self.user = user
        _bio = State(initialValue: user.bio ?? "")
        _greekAffiliation = State(initialValue: user.greekAffiliation)
        _year = State(initialValue: user.grade)
        _profileImageURLs = State(initialValue: user.profileImageURLs ?? [])
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Updated grid passing a Binding
                ProfileImageGridView(profileImageURLs: $profileImageURLs)
                    .padding()
                
                VStack(spacing: 24) {
                    
                    // ABOUT ME (Bio)
                    VStack(alignment: .leading) {
                        Text("ABOUT ME")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        TextField("Add your bio", text: $bio, axis: .vertical)
                            .padding()
                            .frame(height: 64, alignment: .top)
                            .background(Color(.secondarySystemBackground))
                            .font(.subheadline)
                    }
                    
                    // Greek Affiliation & Year
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Greek Affiliation")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        TextField("Update Greek Affiliation", text: $greekAffiliation)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .font(.subheadline)
                        
                        Text("Year")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        TextField("Update Year", text: $year)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .font(.subheadline)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        Task {
                            await updateProfile()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Firestore Update
extension EditProfileView {
    @MainActor
    private func updateProfile() async {
        let db = Firestore.firestore()
        
        // Build dictionary with updated fields
        let data: [String: Any] = [
            "bio": bio,
            "greekAffiliation": greekAffiliation,
            "year": year,
            "profileImageURLs": profileImageURLs
        ]
        
        do {
            try await db.collection("users")
                .document(user.id)
                .updateData(data)
            
            print("DEBUG: Successfully updated profile in Firestore.")
        } catch {
            print("DEBUG: Failed to update profile with error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = User(
            id: "user123",
            fullname: "John Doe",
            email: "john@example.com",
            grade: "Junior",
            greekAffiliation: "Theta Chi",
            profileImageURLs: ["https://example.com/image1.jpg"],
            bio: "Hello! I'm John."
        )
        
        EditProfileView(user: sampleUser)
    }
}
