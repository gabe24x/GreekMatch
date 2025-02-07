//
//  CardsViewModel.swift
//  GreekMatch
//
//  Created by Gabe De Brito on 12/25/24.
//

import Foundation

@MainActor
class CardsViewModel: ObservableObject {
    @Published var cardModels = [CardModel]()
    @Published var buttonSwipeAction: SwipeAction?
    
    private let service: CardService
    
    /// Closure to handle swipe actions, injected by the parent view.
    var swipeHandler: ((CardModel, SwipeAction) -> Void)?
    
    init(service: CardService) {
        self.service = service
        Task { await fetchCardModels() }
    }
    
    /// Fetches swipe cards using the CardService.
    func fetchCardModels() async {
        do {
            self.cardModels = try await service.fetchCardModels()
        } catch {
            print("DEBUG: Failed to fetch cards with error: \(error)")
        }
    }
    
    /// Removes a card from the current list.
    /// - Parameter card: The card to be removed.
    func removeCard(_ card: CardModel) {
        guard let index = cardModels.firstIndex(where: { $0.id == card.id }) else { return }
        cardModels.remove(at: index)
    }
    
    /// Handles a swipe action by removing the card and invoking the swipe handler.
    /// - Parameters:
    ///   - card: The card being swiped.
    ///   - action: The swipe action (.like or .reject).
    func swipe(card: CardModel, action: SwipeAction) {
        removeCard(card)
        swipeHandler?(card, action)
    }
}
