import Foundation

enum Suit: String, CaseIterable {
    case spades
    case clubs
    case diamonds
    case hearts

    var symbol: String {
        switch self {
        case .spades: return "♠"
        case .clubs: return "♣"
        case .diamonds: return "♦"
        case .hearts: return "♥"
        }
    }
}

enum Rank: Int, CaseIterable {
    case ace = 14
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13

    var displayName: String {
        switch self {
        case .ace: return "ace"
        case .two: return "two"
        case .three: return "three"
        case .four: return "four"
        case .five: return "five"
        case .six: return "six"
        case .seven: return "seven"
        case .eight: return "eight"
        case .nine: return "nine"
        case .ten: return "ten"
        case .jack: return "jack"
        case .queen: return "queen"
        case .king: return "king"
        }
    }

    var shortText: String {
        switch self {
        case .ace: return "A"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        }
    }
}

struct Card {
    let suit: Suit
    let rank: Rank

    var value: Int {
        rank.rawValue
    }

    var imageName: String {
        let number = assetNumber()
        return "\(number)-\(rank.displayName) of \(suit.rawValue)"
    }

    var shortName: String {
        "\(rank.shortText)\(suit.symbol)"
    }

    private func assetNumber() -> String {
        let suitOffset: Int

        switch suit {
        case .spades:
            suitOffset = 0
        case .clubs:
            suitOffset = 1
        case .diamonds:
            suitOffset = 2
        case .hearts:
            suitOffset = 3
        }

        let rankIndex: Int

        switch rank {
        case .ace: rankIndex = 0
        case .two: rankIndex = 1
        case .three: rankIndex = 2
        case .four: rankIndex = 3
        case .five: rankIndex = 4
        case .six: rankIndex = 5
        case .seven: rankIndex = 6
        case .eight: rankIndex = 7
        case .nine: rankIndex = 8
        case .ten: rankIndex = 9
        case .jack: rankIndex = 10
        case .queen: rankIndex = 11
        case .king: rankIndex = 12
        }

        let finalNumber = (rankIndex * 4) + suitOffset + 1
        return String(format: "%03d", finalNumber)
    }
}
