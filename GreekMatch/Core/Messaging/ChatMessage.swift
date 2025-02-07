//
//  ChatMessage.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/4/25.
//

import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let senderId: String
    let text: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case text
        case timestamp
    }
}
