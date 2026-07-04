//
//  SearchBar.swift
//  ohnowho-app
//
//  Created by konan on 7/4/26.
//

import SwiftUI

/// 搜索框组件
/// Phase 2 骨架，Phase 5 完整实现
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "搜索笔记..."
    var onClear: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button {
                    text = ""
                    onClear?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

#Preview {
    SearchBar(text: .constant(""))
        .padding(.top, 50)
}
