//
//  ohnowho_appTests.swift
//  ohnowho-appTests
//
//  Created by konan on 7/4/26.
//

import Testing
import SwiftData
@testable import ohnowho_app

@MainActor
struct DataServiceTests {

    @Test func testCreateAndFetchNote() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try await ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
        let service = DataService(context: container.mainContext)

        let note = Note(title: "测试", content: "内容", latitude: 22.3, longitude: 114.1, address: "香港")
        try service.saveNote(note)
        let notes = service.fetchAllNotes()
        #expect(notes.count == 1)
        #expect(notes.first?.title == "测试")
        #expect(notes.first?.content == "内容")
        #expect(notes.first?.address == "香港")
    }

    @Test func testDeleteNote() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try await ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
        let service = DataService(context: container.mainContext)

        let note = Note(title: nil, content: "将被删除", latitude: 0, longitude: 0, address: nil)
        try service.saveNote(note)
        try service.deleteNote(note)
        let notes = service.fetchAllNotes()
        #expect(notes.isEmpty)
    }

    @Test func testSaveNoteUpdatesTimestamp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try await ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
        let service = DataService(context: container.mainContext)

        let note = Note(title: "时间测试", content: "正文", latitude: 10, longitude: 20, address: nil)
        let originalCreatedAt = note.createdAt
        let originalUpdatedAt = note.updatedAt

        try await Task.sleep(for: .milliseconds(10))
        try service.saveNote(note)

        #expect(note.createdAt == originalCreatedAt)      // 创建时间不变
        #expect(note.updatedAt > originalUpdatedAt)        // 更新时间刷新
    }

    @Test func testSearchNotes() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try await ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
        let service = DataService(context: container.mainContext)

        let note1 = Note(title: "咖啡店", content: "在深圳南山", latitude: 22.5, longitude: 113.9, address: "广东省深圳市")
        let note2 = Note(title: "书店", content: "在北京三里屯", latitude: 39.9, longitude: 116.4, address: "北京市朝阳区")
        try service.saveNote(note1)
        try service.saveNote(note2)

        let result = service.fetchNotes(matching: "深圳")
        #expect(result.count == 1)
        #expect(result.first?.title == "咖啡店")
    }
}
