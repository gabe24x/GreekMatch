//
//  ChatView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/4/25.
//

import SwiftUI
import FirebaseAuth

struct ChatView: View {
    let match: MatchData
    let matchedUser: User
    
    @StateObject private var viewModel: ChatViewModel
    
    init(match: MatchData, matchedUser: User) {
        self.match = match
        self.matchedUser = matchedUser
        _viewModel = StateObject(wrappedValue: ChatViewModel(match: match))
    }
    
    var body: some View {
        VStack {
            // Header with matched user info
            HStack {
                if let urlString = matchedUser.profileImageURLs?.first, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            // Show fallback if the URL fails
                            Color.red.opacity(0.3)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                }
                
                Text(matchedUser.fullname)
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            Divider()
            
            // Messages list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message, isCurrentUser: message.senderId == Auth.auth().currentUser?.uid)
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Text Field + Send Button
            HStack {
                TextField("Message...", text: $viewModel.newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    Task {
                        await viewModel.sendMessage()
                    }
                }
                .disabled(viewModel.newMessageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(matchedUser.fullname)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMatch = MatchData(
            id: "match123",
            users: ["currentUserId", "matchedUserId"],
            timestamp: Date()
        )
        
        let sampleUser = User(
            id: "matchedUserId",
            fullname: "Jane Smith",
            email: "jane@example.com",
            grade: "Senior",
            greekAffiliation: "Zeta Tau Alpha",
            profileImageURLs: ["https://example.com/jane.jpg"],
            bio: "Hello! I'm Jane."
        )
        
        ChatView(match: sampleMatch, matchedUser: sampleUser)
            .environmentObject(AuthViewModel())
    }
}
