//
//  CardService.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct CardService {
    
    func fetchCardModels() async throws -> [CardModel] {
        let db = Firestore.firestore()
        
        // 1. Get the current user's ID
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return []
        }
        
        // 2. Fetch the current user's document to get their Greek affiliation
        let currentUserDoc = try await db.collection("users")
            .document(currentUserId)
            .getDocument()
        
        // Decode the current user
        guard let currentUser = try? currentUserDoc.data(as: User.self) else {
            // If unable to decode, return empty array
            return []
        }
        
        // 3. Fetch all swipes made by the current user
        let swipesSnapshot = try await db.collection("swipes")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .getDocuments()
        
        let swipedUserIds = swipesSnapshot.documents.compactMap { doc -> String? in
            return doc.data()["toUserId"] as? String
        }
        
        // 4. Fetch all users
        let usersSnapshot = try await db.collection("users").getDocuments()
        let allUsers = usersSnapshot.documents.compactMap { doc -> User? in
            try? doc.data(as: User.self)
        }
        
        // 5. Filter users:
        //    - Exclude current user
        //    - Exclude users with the same Greek affiliation
        //    - Exclude users already swiped on
        let filteredUsers = allUsers.filter { user in
            user.id != currentUserId &&
            user.greekAffiliation != currentUser.greekAffiliation &&
            !swipedUserIds.contains(user.id)
        }
        
        // 6. Convert to CardModel
        let cardModels = filteredUsers.map { CardModel(user: $0) }
        
        return cardModels
    }
}
