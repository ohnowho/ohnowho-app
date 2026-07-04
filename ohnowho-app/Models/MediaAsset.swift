//
//  MediaAsset.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import Foundation
import SwiftData

enum MediaType: String, Codable {
    case image
    case video
}

@Model
final class MediaAsset {
    @Attribute(.unique) var id: UUID
    var type: MediaType
    var filename: String
    var mimeType: String
    var createdAt: Date
    var orderIndex: Int
    var note: Note?

    init(type: MediaType, filename: String, mimeType: String, createdAt: Date, orderIndex: Int) {
        self.id = UUID()
        self.type = type
        self.filename = filename
        self.mimeType = mimeType
        self.createdAt = createdAt
        self.orderIndex = orderIndex
    }
}
