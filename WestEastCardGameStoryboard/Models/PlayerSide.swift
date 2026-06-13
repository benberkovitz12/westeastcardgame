import Foundation

enum PlayerSide: String {
    case west = "West Side"
    case east = "East Side"

    var opposite: PlayerSide {
        switch self {
        case .west: return .east
        case .east: return .west
        }
    }
}
