//
//  SizeConstants.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import SwiftUI

struct SizeConstants {
    static var screenCutoff: CGFloat {
        (UIScreen.main.bounds.width / 2) * 1.2
    }
    
    static var cardWidth : CGFloat {
        UIScreen.main.bounds.width - 20
    }
    
    static var cardHeight : CGFloat {
        UIScreen.main.bounds.height / 1.45
    }
}
