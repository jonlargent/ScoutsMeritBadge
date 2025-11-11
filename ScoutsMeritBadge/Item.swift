//
//  Item.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
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
