//
//  MatchData.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/4/25.
//

import FirebaseFirestore
import Foundation

struct MatchData: Identifiable, Codable {
    @DocumentID var id: String?
    let users: [String]
    let timestamp: Date?
}
