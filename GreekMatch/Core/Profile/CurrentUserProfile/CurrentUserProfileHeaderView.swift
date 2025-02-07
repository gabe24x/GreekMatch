//
//  CurrentUserProfileHeaderView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import SwiftUI

struct CurrentUserProfileHeaderView: View {
    let user: User
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                if let urls = user.profileImageURLs, !urls.isEmpty {
                    Image(urls[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .background {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 128, height: 128)
                                .shadow(radius: 10)
                        }
                } else {
                    // Fallback: Gray circular placeholder
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 120, height: 120)
                        .background {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 128, height: 128)
                                .shadow(radius: 10)
                        }
                }
                
                Image(systemName: "pencil")
                    .imageScale(.small)
                    .foregroundStyle(.gray)
                    .background {
                        Circle()
                            .fill(.white)
                            .frame(width: 32, height: 32)
                    }
                    .offset(x: -8, y: 10)
            }
            
            Text("\(user.fullname)")
                .font(.title2)
                .fontWeight(.light)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
    }
}
