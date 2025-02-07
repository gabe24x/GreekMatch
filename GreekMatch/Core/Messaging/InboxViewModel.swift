//
//  InboxViewModel.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/4/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct MatchWithUser: Identifiable {
    let id: String
    let user: User
    let matchData: MatchData
}

@MainActor
class InboxViewModel: ObservableObject {
    @Published var matches = [MatchWithUser]()
    private let db = Firestore.firestore()
    
    /// Fetches all matches involving the current user and retrieves the corresponding matched users' details.
    func fetchMatches() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        do {
            // 1. Fetch all match documents where current user is a participant
            let snapshot = try await db.collection("matches")
                .whereField("users", arrayContains: currentUserId)
                .getDocuments()
            
            var matchWithUsers = [MatchWithUser]()
            
            // 2. Iterate through each match to find the matched user
            for doc in snapshot.documents {
                if let match = try? doc.data(as: MatchData.self) {
                    // Identify the other user in the match
                    let otherUserId = match.users.first(where: { $0 != currentUserId })
                    if let otherUserId = otherUserId {
                        // Fetch the other user's details
                        let userDoc = try await db.collection("users").document(otherUserId).getDocument()
                        if let otherUser = try? userDoc.data(as: User.self) {
                            let matchWithUser = MatchWithUser(id: match.id ?? doc.documentID, user: otherUser, matchData: match)
                            matchWithUsers.append(matchWithUser)
                        }
                    }
                }
            }
            
            self.matches = matchWithUsers
        } catch {
            print("DEBUG: Failed to fetch matches: \(error.localizedDescription)")
        }
    }
}
