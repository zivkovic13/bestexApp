import Foundation
import SwiftData

@Model
class Girl: Identifiable, Codable {
    @Attribute var id: String
    @Attribute var name: String
    @Attribute var yearBorn: Int
    @Attribute var city: String
    @Attribute var wins: Int
    @Attribute var imageUrls: [String] = []
    @Attribute var currentRound: Int = 0          // New: tracks current round
    @Attribute var isFavorite: Bool = false       // New: favorite flag

    init(
        id: String = UUID().uuidString,
        name: String,
        yearBorn: Int,
        city: String,
        wins: Int = 0,
        imageUrls: [String] = [],
        currentRound: Int = 0,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.yearBorn = yearBorn
        self.city = city
        self.wins = wins
        self.imageUrls = imageUrls
        self.currentRound = currentRound
        self.isFavorite = isFavorite
    }

    enum CodingKeys: CodingKey {
        case id, name, yearBorn, city, wins, imageUrls, currentRound, isFavorite
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        yearBorn = try container.decode(Int.self, forKey: .yearBorn)
        city = try container.decode(String.self, forKey: .city)
        wins = try container.decode(Int.self, forKey: .wins)
        imageUrls = try container.decode([String].self, forKey: .imageUrls)
        currentRound = try container.decodeIfPresent(Int.self, forKey: .currentRound) ?? 0
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(yearBorn, forKey: .yearBorn)
        try container.encode(city, forKey: .city)
        try container.encode(wins, forKey: .wins)
        try container.encode(imageUrls, forKey: .imageUrls)
        try container.encode(currentRound, forKey: .currentRound)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}
