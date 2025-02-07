//
//  UserInfoView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/24/24.
//

import SwiftUI

struct UserInfoView: View {
    @Binding var showProfileModal: Bool
    let user: User
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(user.fullname)
                    .font(.title)
                    .fontWeight(.heavy)
                
                Spacer()
                
                Button {
                    showProfileModal.toggle()
                } label : {
                    Image(systemName: "arrow.up.circle")
                        .fontWeight(.bold)
                        .imageScale(.large)
                }
            }
            
            if let bio = user.bio, !bio.isEmpty {
                // Bio exists
                Text(bio)
                    .font(.subheadline)
                    .lineLimit(2)
            } else {
                // Fallback: Empty Bio
                Text("No bio yet.")
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
        )
    }
}
