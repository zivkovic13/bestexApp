//
//  Girl.swift
//  bestexApp
//
//  Created by MacBook Pro on 30. 6. 2025..
//


import Foundation
import SwiftData

@Model
class Girl {
    var name: String
    var yearBorn: Int
    var city: String
    var images: [String]

    init(name: String, yearBorn: Int, city: String, images: [String] = []) {
        self.name = name
        self.yearBorn = yearBorn
        self.city = city
        self.images = images
    }
}
