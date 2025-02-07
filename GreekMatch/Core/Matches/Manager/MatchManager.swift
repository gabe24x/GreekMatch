//
//  MatchManager.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/2/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

@MainActor
class MatchManager: ObservableObject {
    @Published var matchedUser: User?
    @Published var matchedMatch: MatchData?
    
    private let db = Firestore.firestore()

    /// Records a swipe action and checks for a match if it's a 'like'.
    /// - Parameters:
    ///   - user: The user being swiped on.
    ///   - action: The swipe action (.like or .reject).
    func recordSwipe(toUser user: User, action: SwipeAction) {
        Task {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            // 1. Record the swipe in Firestore
            let swipeRef = db.collection("swipes").document("\(currentUserId)_swiped_\(user.id)")
            
            let swipeData: [String: Any] = [
                "fromUserId": currentUserId,
                "toUserId": user.id,
                "action": action == .like ? "like" : "reject",
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            do {
                try await swipeRef.setData(swipeData)
                print("DEBUG: Recorded swipe \(action) for user \(user.id)")
                
                if action == .like {
                    await checkForMatch(withUser: user)
                }
            } catch {
                print("DEBUG: Failed to record swipe: \(error.localizedDescription)")
            }
        }
    }
    
    /// Checks for a reciprocal 'like' to establish a match.
    /// - Parameter user: The user who was liked.
    private func checkForMatch(withUser user: User) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // 2. Check if the other user has also liked the current user
        let reciprocalRef = db.collection("swipes").document("\(user.id)_swiped_\(currentUserId)")
        
        do {
            let doc = try await reciprocalRef.getDocument()
            if let action = doc.data()?["action"] as? String, action == "like" {
                // It's a match!
                matchedUser = user
                
                // 3. Create a "match" document
                let matchData: [String: Any] = [
                    "users": [currentUserId, user.id],
                    "timestamp": FieldValue.serverTimestamp()
                ]
                let matchRef = db.collection("matches").document()
                try await matchRef.setData(matchData)
                
                // 4. Fetch the created match document
                let matchDoc = try await db.collection("matches").document(matchRef.documentID).getDocument()
                if let match = try? matchDoc.data(as: MatchData.self) {
                    matchedMatch = match
                }
            }
        } catch {
            print("DEBUG: Error checking reciprocal like: \(error.localizedDescription)")
        }
    }
}
