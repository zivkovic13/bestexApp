//
//  Item.swift
//  bestexApp
//
//  Created by MacBook Pro on 30. 6. 2025..
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
