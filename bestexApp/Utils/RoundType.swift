import SwiftUI

enum RoundType: String, CaseIterable {
    case qualifying = "KVALIFIKACIONA RUNDA"
    case preliminary = "PRELIMINARNA RUNDA"
    case round64 = "RUNDA 64"
    case round32 = "RUNDA 32"
    case round16 = "RUNDA 16"
    case round8 = "OSMINA FINALA"
    case quarterFinal = "CETVRTFINALE"
    case semiFinal = "POLUFINALE"
    case final = "FINALE"

    var roundNumber: Int {
        switch self {
        case .qualifying: return 0
        case .preliminary: return 1
        case .round64: return 2
        case .round32: return 3
        case .round16: return 4
        case .round8: return 5
        case .quarterFinal: return 6
        case .semiFinal: return 7
        case .final: return 8
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
        case .preliminary: return .gray
        case .round64: return .blue
        case .round32: return .green
        case .round16: return .orange
        case .round8: return .purple
        case .quarterFinal: return .pink
        case .semiFinal: return .red
        case .final: return .yellow
        }
    }
}
