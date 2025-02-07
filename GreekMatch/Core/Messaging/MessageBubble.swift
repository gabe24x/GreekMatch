//
//  MessageBubble.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 1/4/25.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            Text(message.text)
                .padding()
                .foregroundColor(.white)
                .background(isCurrentUser ? Color.blue : Color.gray)
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}

// MARK: - Preview

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageBubble(message: ChatMessage(id: "msg1", senderId: "user1", text: "Hello!", timestamp: Date()), isCurrentUser: true)
                .previewLayout(.sizeThatFits)
                .padding()
            
            MessageBubble(message: ChatMessage(id: "msg2", senderId: "user2", text: "Hi there!", timestamp: Date()), isCurrentUser: false)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
