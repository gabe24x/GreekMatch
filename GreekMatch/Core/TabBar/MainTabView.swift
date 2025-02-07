//
//  MainTabView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/24/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var matchManager: MatchManager

    var body: some View {
        TabView {
            CardStackView()
                .tabItem { Image(systemName : "flame") }
                .tag(0)
            
            InboxView()
                .tabItem { Image(systemName: "bubble") }
                .tag(1)
            
            // Profile Tab
            Group {
                if let currentUser = viewModel.currentUser {
                    CurrentUserProfileView(user: currentUser)
                } else {
                    // Show a placeholder or a loading indicator
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2)
                        Text("Loading Profile...")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                }
            }
            .tabItem { Image(systemName: "person") }
            .tag(2)
        }
        .tint(.primary)
    }
}

// MARK: - Preview

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
            .environmentObject(MatchManager())
    }
}
