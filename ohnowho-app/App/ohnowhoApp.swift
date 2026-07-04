//
//  ohnowhoApp.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import SwiftUI
import SwiftData

@main
struct ohnowhoApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Note.self, MediaAsset.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            fatalError("无法创建 ModelContainer")
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(DataService(context: sharedModelContainer.mainContext))
        }
        .modelContainer(sharedModelContainer)
    }
}
