//
//  AuthViewModel.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/3/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    private let db = Firestore.firestore()
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    /// Signs in a user with email and password.
    /// - Parameters:
    ///   - email: User's email address.
    ///   - password: User's password.
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("DEBUG: Signed in user with UID: \(result.user.uid)")
            await fetchUser()
        } catch {
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
            throw error // Rethrow for UI to handle alert if needed
        }
    }
    
    /// Creates a new user account and stores user data in Firestore.
    /// - Parameters:
    ///   - email: User's email address.
    ///   - password: User's password.
    ///   - fullname: User's full name.
    ///   - grade: User's year (e.g., Freshman).
    ///   - affiliation: User's Greek affiliation name.
    func createUser(withEmail email: String, password: String, fullname: String, grade: String, affiliation: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            print("DEBUG: Created user with UID: \(result.user.uid)")
            
            // Build user object
            let user = User(
                id: result.user.uid,
                fullname: fullname,
                email: email,
                grade: grade,
                greekAffiliation: affiliation,
                profileImageURLs: [],
                bio: nil
            )
            
            // Encode and store user in Firestore
            try db.collection("users").document(user.id).setData(from: user, merge: true)
            print("DEBUG: User data stored in Firestore")
            
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Signs out the current user.
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            print("DEBUG: User signed out successfully")
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    /// Deletes the current user's account and all associated data.
    func deleteAccount() async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserId = currentUser.uid
        
        do {
            // 1. Delete user document from Firestore
            try await db.collection("users").document(currentUserId).delete()
            print("DEBUG: User document deleted from Firestore")
            
            // 2. Delete swipes made by the user
            let swipesFromSnapshot = try await db.collection("swipes")
                .whereField("fromUserId", isEqualTo: currentUserId)
                .getDocuments()
            for doc in swipesFromSnapshot.documents {
                try await doc.reference.delete()
            }
            print("DEBUG: Deleted swipes from user")
            
            // 3. Delete swipes received by the user
            let swipesToSnapshot = try await db.collection("swipes")
                .whereField("toUserId", isEqualTo: currentUserId)
                .getDocuments()
            for doc in swipesToSnapshot.documents {
                try await doc.reference.delete()
            }
            print("DEBUG: Deleted swipes to user")
            
            // 4. Delete matches involving the user
            let matchesSnapshot = try await db.collection("matches")
                .whereField("users", arrayContains: currentUserId)
                .getDocuments()
            for matchDoc in matchesSnapshot.documents {
                let matchId = matchDoc.documentID
                // Delete messages in the match
                let messagesSnapshot = try await db.collection("matches").document(matchId).collection("messages").getDocuments()
                for msgDoc in messagesSnapshot.documents {
                    try await msgDoc.reference.delete()
                }
                // Delete the match document
                try await matchDoc.reference.delete()
            }
            print("DEBUG: Deleted matches involving user")
            
            // 5. Delete user from Auth
            try await currentUser.delete()
            self.userSession = nil
            self.currentUser = nil
            print("DEBUG: User account deleted from Auth")
            
        } catch {
            print("DEBUG: deleteAccount() - error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Fetches the current user's data from Firestore.
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No current user session")
            return
        }
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            if let user = try? snapshot.data(as: User.self) {
                self.currentUser = user
                print("DEBUG: Fetched current user: \(user.fullname)")
            } else {
                print("DEBUG: Failed to decode user from Firestore")
            }
        } catch {
            print("DEBUG: Failed to fetch user with error: \(error.localizedDescription)")
        }
    }
}
