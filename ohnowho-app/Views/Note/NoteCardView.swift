//
//  NoteCardView.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import SwiftUI

struct NoteCardView: View {
    let note: Note
    var onDismiss: () -> Void
    var onViewDetail: (Note) -> Void

    private let summaryMaxLength = 80

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - 拖动指示条
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(.secondary.opacity(0.5))
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
            }

            // MARK: - 标题
            if let title = note.title, !title.isEmpty {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }

            // MARK: - 地址 + 时间
            HStack(spacing: 4) {
                if let address = note.address, !address.isEmpty {
                    Label(address, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text("·")
                        .foregroundStyle(.secondary)
                }
                Text(note.createdAt.formatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: - 内容摘要
            if !note.content.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.8))
                    .lineLimit(3)
            }

            // MARK: - 查看详情
            Button {
                onViewDetail(note)
            } label: {
                HStack {
                    Text("查看详情")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .foregroundStyle(Constants.accent)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 80 {
                        onDismiss()
                    }
                }
        )
    }

    private var summary: String {
        let trimmed = note.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > summaryMaxLength {
            return String(trimmed.prefix(summaryMaxLength)) + "..."
        }
        return trimmed
    }
}

#Preview {
    VStack {
        Spacer()
        NoteCardView(
            note: Note(
                title: "南山咖啡店",
                content: "这家咖啡店的拿铁非常棒，环境也很舒适，适合周末来办公。推荐他们的手冲咖啡和提拉米苏。",
                latitude: 22.5,
                longitude: 113.9,
                address: "广东省深圳市南山区"
            ),
            onDismiss: {},
            onViewDetail: { _ in }
        )
    }
    .background(Color.gray.opacity(0.1))
}
