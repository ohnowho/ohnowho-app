//
//  DataService.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class DataService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - 查询

    /// 获取所有笔记，按创建时间倒序
    func fetchAllNotes() -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 按关键词搜索笔记（标题、正文、地址）
    func fetchNotes(matching query: String) -> [Note] {
        let predicate = #Predicate<Note> { note in
            note.title?.localizedStandardContains(query) == true
            || note.content.localizedStandardContains(query)
            || note.address?.localizedStandardContains(query) == true
        }
        let descriptor = FetchDescriptor<Note>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - 写入

    /// 保存笔记（插入或更新）
    func saveNote(_ note: Note) throws {
        note.updatedAt = Date()
        context.insert(note)
        try context.save()
    }

    /// 删除笔记
    func deleteNote(_ note: Note) throws {
        context.delete(note)
        try context.save()
    }
}
