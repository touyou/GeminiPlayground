//
//  Item.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var promptText: String
    var promptImages: [Data]
    var responseText: String?
    
    init(timestamp: Date, promptText: String, promptImages: [Data], responseText: String? = nil) {
        self.timestamp = timestamp
        self.promptText = promptText
        self.promptImages = promptImages
        self.responseText = responseText
    }
}
