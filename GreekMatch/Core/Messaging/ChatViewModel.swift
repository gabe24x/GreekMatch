//
//  ChatViewModel.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/4/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var newMessageText = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    let match: MatchData
    
    init(match: MatchData) {
        self.match = match
        listenForMessages()
    }
    
    deinit {
        // Stop Firestore listener when this VM is deallocated
        listener?.remove()
    }
    
    /// Listens for real-time updates to the chat messages.
    private func listenForMessages() {
        guard let matchId = match.id else { return }
        
        // Listen to /matches/<matchId>/messages, sorted by 'timestamp'
        listener = db.collection("matches")
            .document(matchId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("DEBUG: Error listening for messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let newMessages = documents.compactMap { doc -> ChatMessage? in
                    try? doc.data(as: ChatMessage.self)
                }
                
                self.messages = newMessages
            }
    }
    
    /// Sends a new message in the chat.
    func sendMessage() async {
        guard let matchId = match.id else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = ChatMessage(
            senderId: currentUserId,
            text: newMessageText,
            timestamp: Date()
        )
        
        do {
            try db.collection("matches")
                .document(matchId)
                .collection("messages")
                .addDocument(from: message)
            
            // Clear text field
            newMessageText = ""
        } catch {
            print("DEBUG: Error sending message: \(error.localizedDescription)")
        }
    }
}
