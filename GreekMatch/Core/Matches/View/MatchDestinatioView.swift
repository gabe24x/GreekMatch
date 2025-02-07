//
//  MatchDestinationView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/2/25.
//

import SwiftUI

struct MatchDestinationView: View {
    let match: MatchData?
    let matchedUser: User?
    
    var body: some View {
        Group {
            if let match = match, let user = matchedUser {
                ChatView(match: match, matchedUser: user)
            } else {
                Text("Match data not available.")
                    .foregroundColor(.red)
                    .font(.headline)
            }
        }
    }
}

struct MatchDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with valid match and user
            let sampleUser = User(
                id: "user123",
                fullname: "John Doe",
                email: "john@example.com",
                grade: "Junior",
                greekAffiliation: "Theta Chi",
                profileImageURLs: ["https://example.com/image1.jpg"],
                bio: "Hello! I'm John."
            )
            
            let sampleMatch = MatchData(
                id: "match123",
                users: ["currentUserId", "user123"],
                timestamp: Date()
            )
            
            MatchDestinationView(match: sampleMatch, matchedUser: sampleUser)
            
            // Preview without match data
            MatchDestinationView(match: nil, matchedUser: nil)
        }
    }
}
