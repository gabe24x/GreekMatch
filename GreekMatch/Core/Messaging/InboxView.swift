//
//  InboxView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/4/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct InboxView: View {
    @StateObject var viewModel = InboxViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.matches.isEmpty {
                    Text("No matches yet!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.matches) { match in
                        NavigationLink(destination: ChatView(match: match.matchData, matchedUser: match.user)) {
                            HStack {
                                if let urlString = match.user.profileImageURLs?.first, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        case .failure:
                                            Color.red.opacity(0.3)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 50, height: 50)
                                }
                                
                                Text(match.user.fullname)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Inbox")
            .onAppear {
                Task {
                    await viewModel.fetchMatches()
                }
            }
        }
    }
}

// MARK: - Preview

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
            .environmentObject(AuthViewModel())
            .environmentObject(MatchManager())
    }
}
