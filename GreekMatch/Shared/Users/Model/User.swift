//
//  User.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import Foundation

struct User: Identifiable, Hashable, Codable {
    let id: String
    let fullname: String
    let email: String
    let grade: String
    let greekAffiliation: String
    var profileImageURLs: [String]?
    var bio: String?
}
