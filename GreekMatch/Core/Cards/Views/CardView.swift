//
//  CardView.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/24/24.
//

import SwiftUI

struct CardView: View {
    @EnvironmentObject var matchManager: MatchManager
    @ObservedObject var viewModel: CardsViewModel
    
    @State private var xOffset: CGFloat = 0
    @State private var degrees: Double = 0
    @State private var currentImageIndex = 0
    @State private var showProfileModal = false
    
    let model: CardModel
    
    var body: some View {
        ZStack(alignment: .bottom){
            ZStack(alignment: .top) {
                if let urls = user.profileImageURLs, !urls.isEmpty, let imageUrl = URL(string: urls[currentImageIndex]) {
                    AsyncImage(url: imageUrl) { phase in
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
                    .frame(width: SizeConstants.cardWidth, height: SizeConstants.cardHeight)
                    .overlay {
                        ImageScrollingOverlay(currentImageIndex: $currentImageIndex, imageCount: imageCount)
                    }
                } else {
                    // Fallback: Gray placeholder
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.gray)
                        .frame(width: SizeConstants.cardWidth, height: SizeConstants.cardHeight)
                        .overlay {
                            ImageScrollingOverlay(currentImageIndex: $currentImageIndex, imageCount: imageCount)
                        }
                }
                
                CardImageIndicatorView(currentImageIndex: currentImageIndex, imageCount: imageCount)
                
                SwipeActionIndicatorView(xOffset: $xOffset)
            }
            
            UserInfoView(showProfileModal: $showProfileModal, user: user)
        }
        .fullScreenCover(isPresented: $showProfileModal) {
            UserProfileView(user: user)
        }
        .onReceive(viewModel.$buttonSwipeAction, perform: { action in
            onReceiveSwipeAction(action)
        })
        .frame(width: SizeConstants.cardWidth, height: SizeConstants.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .offset(x: xOffset)
        .rotationEffect(.degrees(degrees))
        .animation(.snappy, value: xOffset)
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }
}

private extension CardView {
    var user: User {
        return model.user
    }
    
    var imageCount: Int {
        return user.profileImageURLs?.count ?? 0
    }
    
    /// Resets the card to the center position.
    func returnToCenter() {
        xOffset = 0
        degrees = 0
    }
    
    /// Handles swiping the card to the right (like).
    func swipeRight() {
        let action: SwipeAction = .like
        withAnimation {
            xOffset = 500
            degrees = 12
        }
        // After animation completes, remove the card and record swipe
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.swipe(card: model, action: action)
        }
    }
    
    /// Handles swiping the card to the left (reject).
    func swipeLeft() {
        let action: SwipeAction = .reject
        withAnimation {
            xOffset = -500
            degrees = -12
        }
        // After animation completes, remove the card and record swipe
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.swipe(card: model, action: action)
        }
    }
    
    /// Responds to external swipe actions (e.g., button taps).
    /// - Parameter action: The swipe action to perform.
    func onReceiveSwipeAction(_ action: SwipeAction?) {
        guard let action else { return }
        
        if action == .reject {
            swipeLeft()
        } else if action == .like {
            swipeRight()
        }
    }
    
    /// Updates the card's position and rotation based on drag gesture.
    /// - Parameter value: The current drag gesture value.
    func onDragChanged(_ value: DragGesture.Value) {
        xOffset = value.translation.width
        degrees = Double(value.translation.width / 25)
    }
    
    /// Determines the swipe action based on the final drag position.
    /// - Parameter value: The final drag gesture value.
    func onDragEnded(_ value: DragGesture.Value) {
        let width = value.translation.width
        
        if abs(width) <= abs(SizeConstants.screenCutoff) {
            returnToCenter()
            return
        }
        
        if width >= SizeConstants.screenCutoff {
            swipeRight()
        } else {
            swipeLeft()
        }
    }
}
