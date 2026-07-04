//
//  Note.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var title: String?
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var latitude: Double
    var longitude: Double
    var address: String?
    @Relationship(deleteRule: .cascade, inverse: \MediaAsset.note)
    var assets: [MediaAsset]

    init(title: String?, content: String, latitude: Double, longitude: Double, address: String?) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.assets = []
    }
}
