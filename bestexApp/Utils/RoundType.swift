import SwiftUI

enum RoundType: String, CaseIterable {
    case qualifying = "KVALIFIKACIJE"
    case round128 = "RUNDA 128"
    case round64 = "RUNDA 64"
    case round32 = "RUNDA 32"
    case round16 = "RUNDA 16"
    case quarterFinal = "CETVRTFINALE"
    case semiFinal = "POLUFINALE"
    case final = "FINALE"

    var roundNumber: Int {
        switch self {
        case .qualifying: return 0
        case .round128: return 1
        case .round64: return 2
        case .round32: return 3
        case .round16: return 4
        case .quarterFinal: return 5
        case .semiFinal: return 6
        case .final: return 7
        }
    }

    var nextRound: RoundType? {
        let all = RoundType.allCases
        guard let currentIndex = all.firstIndex(of: self), currentIndex < all.count - 1 else {
            return nil
        }
        return all[currentIndex + 1]
    }

    var color: Color {
        switch self {
        case .qualifying: return .purple
        case .round128: return .purple
        case .round64: return .purple
        case .round32: return .purple
        case .round16: return .purple
        case .quarterFinal: return .green
        case .semiFinal: return .blue
        case .final: return .red
        }
    }
}
