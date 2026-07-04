# Phase 4 — 笔记详情页

## 目标
实现完整的笔记详情展示，包括 Markdown 渲染、媒体查看、编辑/删除/移动位置操作。

---

## 前置依赖
- ✅ Phase 1 完成（数据模型、服务层）
- ✅ Phase 3 完成（NoteViewModel、编辑视图）

---

## 步骤

### Step 4.1 — 实现 NoteDetailView

**涉及文件**: `ohnowho-app/Views/Note/NoteDetailView.swift`

```swift
struct NoteDetailView: View {
    let note: Note
    @State private var showEditSheet = false
    @State private var showDeleteToast = false
    @State private var showLocationPicker = false
    @Environment(\.dismiss) var dismiss
}
```

**布局**:
```
┌─ ScrollView ──────────────────────┐
│ [标题 - largeTitle]               │
│ 📍 地址  · 🕐 创建时间            │
│ ──── Divider ────                 │
│ [Markdown 渲染正文]               │
│                                    │
│ [媒体网格]                        │
│ ┌─────┐ ┌─────┐ ┌─────┐         │
│ │ 📷  │ │ 📷  │ │ 📹  │         │
│ └─────┘ └─────┘ └─────┘         │
│                                    │
└────────────────────────────────────┘
底部工具栏: [编辑] [删除] [移动位置]
```

---

### Step 4.2 — Markdown 渲染

- 使用 MarkdownUI 库渲染笔记正文
- 支持：标题 `#`、列表 `-`、粗体 `**`、斜体 `*`、代码块 `` ` ``
- 渲染在 `ScrollView` 中，支持长内容滚动

---

### Step 4.3 — 媒体查看器

**涉及文件**: `ohnowho-app/Views/Common/MediaViewer.swift`（完整实现）

#### 图片查看
- 点击图片 → 全屏显示
- 支持双指缩放、拖动
- 「关闭」按钮返回

#### 视频播放
- 点击视频 → `AVPlayer` 全屏播放
- 显示播放控件
- 自动播放/暂停

#### 切换
- 支持左右滑动切换多个媒体
- 底部页码指示器

---

### Step 4.4 — 编辑笔记

- 点击「编辑」→ 弹出 `NoteEditView`，传入当前 `Note`
- 编辑完成后 `NoteViewModel` 保存并刷新
- 详情页内容实时更新

---

### Step 4.5 — 删除笔记（带撤销）

**交互流程**:
1. 点击「删除」
2. 不弹确认对话框，直接执行删除
3. 底部弹出 Toast：「笔记已删除」+「撤销」按钮
4. Toast 显示 5 秒
5. 点击「撤销」→ 恢复笔记数据
6. 超时 → 数据永久删除

**实现要点**:
- 删除时先标记删除状态，存入临时变量
- 撤销时从临时变量恢复
- 使用 `withAnimation` 做 Toast 出现/消失动画
- Toast 可自定义 View 修饰符

---

### Step 4.6 — 移动位置

- 点击「移动位置」→ 弹出 `LocationPickerView`（Phase 3 创建）
- 拖动 Pin 到新位置
- 确认后更新 `Note.latitude` / `Note.longitude` / `Note.address`
- 返回地图后 Pin 位置同步更新

---

## 文件操作清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 📄 新建 | `ohnowho-app/ohnowho-app/Views/Note/NoteDetailView.swift` | 笔记详情页 |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/Views/Common/MediaViewer.swift` | 完整实现媒体查看器 |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/Utils/Extensions.swift` | 增加 Toast 修饰符 |

## 验收检查清单

- [ ] 从地图 Pin 卡片可进入详情页
- [ ] 标题、地址、创建时间正确显示
- [ ] Markdown 正文正常渲染
- [ ] 图片可点击全屏查看（缩放、拖动）
- [ ] 视频可点击全屏播放
- [ ] 可编辑笔记，内容保存后实时更新
- [ ] 可删除笔记，删除时弹出撤销 Toast
- [ ] 5 秒内点击撤销可恢复
- [ ] 超时后删除不可恢复
- [ ] 可移动笔记位置
- [ ] 位置更新后地图 Pin 同步
