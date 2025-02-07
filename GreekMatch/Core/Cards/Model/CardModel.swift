//
//  CardModel.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import Foundation

struct CardModel {
    let user: User
}

extension CardModel: Identifiable, Hashable {
    var id: String { return user.id }
}
