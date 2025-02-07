//
//  UserMatchView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/2/25.
//

import SwiftUI

struct UserMatchView: View {
    @Binding var show: Bool
    @EnvironmentObject var matchManager: MatchManager
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // State variables to handle navigation
    @State private var navigateToChat = false
    @State private var chatMatch: MatchData? = nil
    @State private var chatUser: User? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // Semi-transparent background
                Rectangle()
                    .fill(Color.black.opacity(0.7))
                    .ignoresSafeArea()
                
                VStack(spacing: 120) {
                    // Title Section
                    VStack {
                        Text("It's a Match!")
                            .font(.custom("Snell Roundhand", size: 60))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                        
                        if let matchedUser = matchManager.matchedUser {
                            Text("You and \(matchedUser.fullname) have liked each other.")
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Profile Images Section
                    HStack(spacing: 16) {
                        // Current User's Image
                        if let currentUser = authViewModel.currentUser,
                           let currentUserURLs = currentUser.profileImageURLs,
                           !currentUserURLs.isEmpty,
                           let currentUserURL = URL(string: currentUserURLs[0]) {
                            AsyncImage(url: currentUserURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    // Fallback if the URL fails
                                    Color.red.opacity(0.3)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .shadow(radius: 4)
                            )
                        } else {
                            // Fallback if the current user has no image
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 150, height: 150)
                        }

                        // Matched User's Image
                        if let matchedUser = matchManager.matchedUser,
                           let matchedURLs = matchedUser.profileImageURLs,
                           !matchedURLs.isEmpty,
                           let matchedURL = URL(string: matchedURLs[0]) {
                            AsyncImage(url: matchedURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    // Fallback if the URL fails
                                    Color.red.opacity(0.3)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .shadow(radius: 4)
                            )
                        } else {
                            // Fallback if the matched user has no image
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 150, height: 150)
                        }
                    }
                    
                    // Action Buttons Section
                    VStack(spacing: 16) {
                        // Send Message Button
                        Button(action: {
                            if let match = matchManager.matchedMatch,
                               let user = matchManager.matchedUser {
                                chatMatch = match
                                chatUser = user
                                navigateToChat = true
                                show = false // Dismiss the match view
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Send Message")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .frame(height: 44)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(22)
                        }
                        
                        // Keep Swiping Button
                        Button(action: {
                            show = false // Dismiss the match view
                        }) {
                            HStack {
                                Spacer()
                                Text("Keep Swiping")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .frame(height: 44)
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            // Define the navigation destination for ChatView
            .navigationDestination(isPresented: $navigateToChat) {
                if let match = chatMatch, let user = chatUser {
                    ChatView(match: match, matchedUser: user)
                } else {
                    Text("Match data not available.")
                        .foregroundColor(.red)
                        .font(.headline)
                }
            }
        }
    }

    // MARK: - Preview

    struct UserMatchView_Previews: PreviewProvider {
        static var previews: some View {
            // Sample user for preview
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
            
            UserMatchView(show: .constant(true))
                .environmentObject(MatchManager())
                .environmentObject(AuthViewModel())
                .onAppear {
                    // Setup sample data
                    let matchManager = MatchManager()
                    matchManager.matchedUser = sampleUser
                    matchManager.matchedMatch = sampleMatch
                }
        }
    }
}
