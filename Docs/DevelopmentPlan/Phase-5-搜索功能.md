# Phase 5 — 搜索功能

## 目标
实现搜索框，输入关键词后实时过滤地图上显示的 Pin。

---

## 前置依赖
- ✅ Phase 2 完成（地图主页、Pin 显示）

---

## 步骤

### Step 5.1 — 实现 SearchBar

**涉及文件**: `ohnowho-app/Views/Common/SearchBar.swift`

```swift
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "搜索笔记..."
    var onClear: (() -> Void)?
}
```

**UI 设计**:
- 放置在地图顶部
- 毛玻璃半透明背景（`.ultraThinMaterial`）
- 搜索图标（`magnifyingglass`）在左侧
- 有输入时显示「清除」按钮（`xmark.circle.fill`）
- 圆角设计，与地图视觉融合

---

### Step 5.2 — 搜索逻辑

**涉及文件**: `ohnowho-app/ViewModels/MapViewModel.swift`, `ohnowho-app/Services/DataService.swift`

#### MapViewModel 新增
```swift
@Observable
final class MapViewModel {
    var searchQuery: String = ""

    var filteredNotes: [Note] {
        guard !searchQuery.isEmpty else { return notes }
        return notes.filter { note in
            let query = searchQuery.lowercased()
            return (note.title?.lowercased().contains(query) ?? false)
                || note.content.lowercased().contains(query)
                || (note.address?.lowercased().contains(query) ?? false)
        }
    }
}
```

#### DataService 新增
- `fetchNotes(matching query: String) -> [Note]` 方法
- 使用 `Predicate` 进行 SwiftData 查询（可选，也可以内存过滤）

**搜索范围**:
- 笔记标题
- 笔记正文（Markdown 内容）
- 地址文本

---

### Step 5.3 — 搜索 UI 集成

**涉及文件**: `ohnowho-app/Views/Map/MapView.swift`

- SearchBar 放置在地图顶部
- `MapViewModel.searchQuery` 双向绑定
- 地图显示的 Pin 由 `filteredNotes` 驱动
- 无匹配结果时：
  - 清除所有 Pin
  - 显示空状态提示：「未找到匹配的笔记」
- 清除搜索后恢复显示所有 Pin

---

## 文件操作清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| ✏️ 修改 | `ohnowho-app/ohnowho-app/Views/Common/SearchBar.swift` | 完整实现搜索框 |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/ViewModels/MapViewModel.swift` | 增加 searchQuery + filteredNotes |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/Views/Map/MapView.swift` | 集成 SearchBar |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/Services/DataService.swift` | 增加搜索方法（可选） |

## 验收检查清单

- [ ] 地图顶部显示搜索框
- [ ] 搜索框毛玻璃风格，不遮挡地图
- [ ] 输入关键词后实时过滤 Pin
- [ ] 搜索匹配标题
- [ ] 搜索匹配正文内容
- [ ] 搜索匹配地址文本
- [ ] 有「清除」按钮可一键清空搜索
- [ ] 清除搜索后恢复所有 Pin
- [ ] 无搜索结果时显示提示
