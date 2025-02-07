//
//  CardStackView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import SwiftUI

struct CardStackView: View {
    @EnvironmentObject var matchManager: MatchManager
    @State private var showMatchView = false
    @StateObject var viewModel = CardsViewModel(service: CardService())
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    
                    if viewModel.cardModels.isEmpty {
                        // If there are no cards, show a message
                        Text("No more people available to swipe on.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        // Otherwise, show the swipeable cards
                        ZStack {
                            ForEach(viewModel.cardModels) { card in
                                CardView(viewModel: viewModel, model: card)
                            }
                        }
                        
                        // Swipe action buttons
                        if !viewModel.cardModels.isEmpty {
                            SwipeActionButtonsView(viewModel: viewModel)
                        }
                    }
                }
                .blur(radius: showMatchView ? 20 : 0)
                
                // Match pop-up
                if showMatchView {
                    UserMatchView(show: $showMatchView)
                }
            }
            .animation(.easeInOut, value: showMatchView)
            .onReceive(matchManager.$matchedUser) { user in
                showMatchView = user != nil
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ZStack {
                        Image(.greekLogo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150)
                            .shadow(radius: 3)
                    }
                }
            }
        }
    }
}

#Preview {
    CardStackView()
        .environmentObject(MatchManager())
}
