//
//  SearchView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/4/25.
//

import SwiftUI
import Firebase

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results = [User]()
    
    private let db = Firestore.firestore()
    
    func searchUsers() async {
        guard !searchText.isEmpty else { return }
        
        do {
            // Example: search by 'fullname'
            let snapshot = try await db.collection("users")
                .whereField("fullname", isGreaterThanOrEqualTo: searchText)
                .whereField("fullname", isLessThan: searchText + "\u{f8ff}")
                .getDocuments()
            
            let users = snapshot.documents.compactMap { try? $0.data(as: User.self) }
            self.results = users
        } catch {
            print("DEBUG: Search error: \(error.localizedDescription)")
        }
    }
}

struct SearchView: View {
    @StateObject var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search name...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Search") {
                    Task {
                        await viewModel.searchUsers()
                    }
                }
                
                List(viewModel.results, id: \.id) { user in
                    VStack(alignment: .leading) {
                        Text(user.fullname)
                            .fontWeight(.semibold)
                        Text(user.email)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}
