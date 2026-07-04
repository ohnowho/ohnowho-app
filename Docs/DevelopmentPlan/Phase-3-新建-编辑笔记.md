# Phase 3 — 新建 / 编辑笔记

## 目标
实现完整的笔记创建和编辑功能，包括 Markdown 编辑、媒体添加、位置绑定、手动调整位置。

---

## 前置依赖
- ✅ Phase 1 完成（数据模型、服务层）

---

## 步骤

### Step 3.1 — 创建 NoteViewModel

**涉及文件**: `ohnowho-app/ViewModels/NoteViewModel.swift`

```swift
@Observable
final class NoteViewModel {
    // 编辑状态
    var title: String
    var content: String
    var mediaAssets: [MediaAsset]
    var location: CLLocationCoordinate2D
    var address: String
    var isSaving: Bool

    // 编辑模式
    private var editingNote: Note?
    var isEditing: Bool { editingNote != nil }

    // 方法
    func loadNote(_ note: Note)             // 编辑模式：加载已有笔记
    func saveNote()                         // 保存（新建/更新）
    func addMedia(from picker: PHPickerResult)
    func removeMedia(at index: Int)
    func updateLocation(_ coord: CLLocationCoordinate2D)
    func reverseGeocodeCurrentLocation()
}
```

**关键行为**:
- `isEditing` 为 `true` 时保存更新已有笔记，否则新建
- 验证：至少需要内容或媒体才可保存
- 保存时复制媒体文件到 App Sandbox

---

### Step 3.2 — 实现 NoteEditView

**涉及文件**: `ohnowho-app/Views/Note/NoteEditView.swift`

| 组件 | 说明 |
|------|------|
| 呈现方式 | 底部 Sheet（`.presentationDetents([.medium, .large])`） |
| 标题区 | 可选的标题输入框，placeholder "添加标题（可选）" |
| 正文区 | Markdown 编辑区域，支持编辑/预览切换 |
| 媒体区 | 水平滚动缩略图行，支持添加/删除 |
| 位置区 | 显示地址文本，"调整位置"按钮 |
| 操作栏 | 「取消」和「保存」按钮 |

---

### Step 3.3 — Markdown 编辑器

**依赖**: MarkdownUI 第三方库

- 集成 MarkdownUI 作为渲染预览
- 编辑模式：纯文本 `TextEditor` + 自制工具栏
- 预览模式：MarkdownUI 渲染
- 工具栏按钮：
  - `B` (Bold): `**text**`
  - `I` (Italic): `*text*`
  - `H` (Heading): `# text`
  - `•` (List): `- item`
  - `[]` (Code): `` `code` ``
  - `👁️` 切换编辑/预览

---

### Step 3.4 — 媒体选择

**涉及文件**: `ohnowho-app/ViewModels/NoteViewModel.swift`

- 使用 `PHPickerViewController` 选择图片/视频（iOS 14+）
- 使用 `UIImagePickerController` 即时拍照
- 选中后：
  1. 将原文件复制到 `Documents/media/` 目录
  2. 生成 `MediaAsset` 对象
  3. 添加到 `mediaAssets` 数组
- 支持删除已添加的媒体

---

### Step 3.5 — 位置绑定

**涉及文件**: `ohnowho-app/ViewModels/NoteViewModel.swift`, `ohnowho-app/Views/Common/LocationPickerView.swift`

- 打开 Sheet 时自动获取当前位置（`LocationService`）
- 显示地址文本（若反向编码成功）
- 「调整位置」按钮 → 弹出 `LocationPickerView`
- 位置为必填项，不可保存无位置笔记

---

### Step 3.6 — 编辑模式

- `NoteEditView` 接受可选 `Note` 参数
- 有 `Note` → 编辑模式：预填所有字段
- 无 `Note` → 新建模式：清空字段，获取位置
- 保存编辑时更新 `updatedAt` 时间戳
- 保存后通知 `MapViewModel` 刷新笔记列表

---

### Step 3.7 — 创建 LocationPickerView

**涉及文件**: `ohnowho-app/Views/Common/LocationPickerView.swift`

- 迷你地图视图
- 可拖动的 Pin（中心固定 Pin，拖动地图移动位置）
- 反向编码显示地址
- 「确认位置」按钮返回结果

```swift
struct LocationPickerView: View {
    @Binding var coordinate: CLLocationCoordinate2D
    @Binding var address: String
    @Environment(\.dismiss) var dismiss
}
```

---

## 文件操作清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 📄 新建 | `ohnowho-app/ohnowho-app/ViewModels/NoteViewModel.swift` | 笔记视图模型 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Views/Note/NoteEditView.swift` | 新建/编辑视图 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Views/Common/LocationPickerView.swift` | 位置选择器 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Views/Common/MediaViewer.swift` | 骨架 |

## 验收检查清单

- [ ] 点击「+」按钮弹出新建笔记 Sheet
- [ ] 可输入标题
- [ ] 可输入 Markdown 正文
- [ ] 工具栏支持 Bold / Italic / Heading / List / Code
- [ ] 可切换编辑/预览模式
- [ ] 可从相册选择图片/视频
- [ ] 可拍照添加
- [ ] 媒体缩略图在编辑器中预览
- [ ] 新建时自动绑定当前位置
- [ ] 可手动调整位置（拖动 Pin）
- [ ] 地址文本正确显示
- [ ] 保存后地图上出现新 Pin
- [ ] 可编辑已有笔记，保存后更新内容
- [ ] 内容或媒体为空时禁止保存
- [ ] 无位置时禁止保存
