import Foundation

final class GameEngine {
    private var deck: [Card] = []

    init() {
        resetDeck()
    }

    func resetDeck() {
        deck = []

        for rank in Rank.allCases {
            for suit in Suit.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }

        deck.shuffle()
    }

    func dealTwoCards() -> (player: Card, computer: Card)? {
        if deck.count < 2 {
            resetDeck()
        }

        guard let playerCard = deck.popLast(),
              let computerCard = deck.popLast() else {
            return nil
        }

        return (playerCard, computerCard)
    }
}
