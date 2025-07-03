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
        
        // Decode id: accept either String or Int and convert Int to String
        if let idString = try? container.decode(String.self, forKey: .id) {
            id = idString
        } else if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            throw DecodingError.keyNotFound(CodingKeys.id, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "ID key not found"))
        }
        
        name = try container.decode(String.self, forKey: .name)
        yearBorn = try container.decode(Int.self, forKey: .yearBorn)
        city = try container.decode(String.self, forKey: .city)
        wins = try container.decode(Int.self, forKey: .wins)
        imageUrls = try container.decodeIfPresent([String].self, forKey: .imageUrls) ?? []
        currentRound = try container.decodeIfPresent(Int.self, forKey: .currentRound) ?? 0

        // Decode isFavorite allowing Int 0/1 to Bool conversion
        if container.contains(.isFavorite) {
            if let boolVal = try? container.decode(Bool.self, forKey: .isFavorite) {
                isFavorite = boolVal
            } else if let intVal = try? container.decode(Int.self, forKey: .isFavorite) {
                isFavorite = intVal != 0
            } else {
                isFavorite = false
            }
        } else {
            isFavorite = false
        }
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
