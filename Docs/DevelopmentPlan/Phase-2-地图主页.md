# Phase 2 — 地图主页

## 目标
实现全屏地图展示、定位用户、显示笔记 Pin、点击 Pin 弹出卡片摘要、底部「+」按钮。

---

## 前置依赖
- ✅ Phase 1 完成（数据模型、服务层、占位 MapView）

---

## 步骤

### Step 2.1 — 创建 MapViewModel

**涉及文件**: `ohnowho-app/ViewModels/MapViewModel.swift`

```swift
@Observable
final class MapViewModel {
    var region: MKCoordinateRegion
    var notes: [Note]
    var selectedNote: Note?
    var isShowingNoteCard: Bool
    var searchQuery: String  // Phase 5 使用

    func centerOnUser()
    func refreshNotes()
    func selectNote(_ note: Note)
    func dismissNoteCard()
    func deleteNote(_ note: Note)  // Phase 4 使用
}
```

**关键行为**:
- 初始化时通过 `DataService` 加载所有笔记
- `selectNote` 设置 `selectedNote` 并弹出卡片
- `centerOnUser` 通过 `LocationService` 获取位置

---

### Step 2.2 — 实现全屏地图

**涉及文件**: `ohnowho-app/Views/Map/MapView.swift`

- 集成 MapKit `Map`（iOS 17+ API）
- `MapCameraPosition` 绑定
- 初始区域：优先用户位置，否则默认中国范围
- 地图占据全屏，忽略安全区域
- 设置 `mapControl` 控制缩放、旋转等

**验收**:
- 全屏地图展示
- 可正常缩放、拖动

---

### Step 2.3 — 定位权限与用户位置

**涉及文件**: `ohnowho-app/Views/Map/MapView.swift`, `ohnowho-app/Services/LocationService.swift`

- 首次显示地图时请求定位权限
- `onAppear` 中调用 `LocationService.requestPermission()`
- 授权后自动定位到用户位置
- 添加悬浮「回到当前位置」按钮（右下角，定位图标）
- `showsUserLocation = true`

**验收**:
- 首次启动弹出定位权限框
- 授权后地图定位到用户位置
- 点击「回到当前位置」重新居中

---

### Step 2.4 — 显示笔记 Pin

**涉及文件**: `ohnowho-app/Views/Map/MapView.swift`

- 使用 `Map` 的 `Annotation` 展示笔记位置
- 自定义 Pin 样式：使用砖红色调（`Constants.accent`）
- 每个 Pin 绑定对应的 `Note` 对象
- Pin 标注：显示笔记标题（如有）或"无标题"

---

### Step 2.5 — Pin 点击 → 卡片弹窗

**涉及文件**: `ohnowho-app/Views/Map/MapView.swift`, `ohnowho-app/Views/Note/NoteCardView.swift`

- 点击 Pin → 弹出底部卡片 `NoteCardView`
- 卡片内容：标题、地址、创建时间、正文摘要（前 80 字）
- 卡片底部「查看详情」按钮 → 跳转 Phase 4 详情页（NavigationLink 占位）
- 卡片支持下滑手势关闭

---

### Step 2.6 — 底部「+」按钮

**涉及文件**: `ohnowho-app/Views/Map/MapView.swift`

- 浮动在右下角的圆形「+」按钮
- SF Symbol: `plus.circle.fill`
- 点击后弹出 Phase 3 的新建笔记 Sheet（占位 .sheet 连接）

---

### Step 2.7 — 创建 NoteCardView

**涉及文件**: `ohnowho-app/Views/Note/NoteCardView.swift`

- 参数: `note: Note`, `onDismiss: () -> Void`, `onViewDetail: (Note) -> Void`
- 展示:
  - 标题（若存在）
  - 地址（若存在）+ 创建时间
  - 正文前 80 字 + "..." 摘要
- 底部「查看详情」按钮
- 毛玻璃背景 + 圆角设计

---

## 文件操作清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 📄 新建 | `ohnowho-app/ohnowho-app/ViewModels/MapViewModel.swift` | 地图视图模型 |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/Views/Map/MapView.swift` | 完整实现地图 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Views/Note/NoteCardView.swift` | Pin 卡片 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Views/Common/SearchBar.swift` | 骨架（Phase 5 完整实现） |

## 验收检查清单

- [ ] 打开 App 后显示全屏地图
- [ ] 首次启动请求定位权限
- [ ] 授权后定位到用户位置
- [ ] 地图上有「回到当前位置」按钮
- [ ] 有笔记时显示 Pin
- [ ] 点击 Pin 弹出卡片摘要
- [ ] 卡片显示标题、地址、时间、摘要
- [ ] 卡片可下滑关闭
- [ ] 底部「+」按钮可见
- [ ] 点击「+」弹出新建 Sheet（可占位空 Sheet）
