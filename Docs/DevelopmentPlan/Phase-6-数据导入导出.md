# Phase 6 — 数据导入导出

## 目标
实现全量数据导出为 zip 包和从 zip 包导入恢复，确保用户数据可迁移。

---

## 前置依赖
- ✅ Phase 1 完成（数据模型、ExportService 骨架）
- ✅ Phase 3 完成（笔记/媒体数据结构完整）
- ✅ Phase 4 完成（数据经过实际使用验证）

---

## 导出格式规范

参考 `Docs/DataModel.md`，导出包结构如下：

```
ohnowho_export_2025-07-04.zip
├── data.json
│   [
│     {
│       "id": "uuid",
│       "title": "标题",
│       "content": "# Markdown 正文",
│       "createdAt": "2025-07-04T10:30:00Z",
│       "updatedAt": "2025-07-04T10:30:00Z",
│       "latitude": 22.3193,
│       "longitude": 114.1694,
│       "address": "地址文本",
│       "assets": [
│         {
│           "id": "uuid",
│           "type": "image",
│           "filename": "assets/images/uuid.jpg",
│           "mimeType": "image/jpeg",
│           "createdAt": "2025-07-04T10:30:00Z",
│           "orderIndex": 0
│         }
│       ]
│     }
│   ]
└── assets/
    ├── images/
    │   └── {uuid}.jpg
    └── videos/
        └── {uuid}.mp4
```

---

## 步骤

### Step 6.1 — 导出服务实现

**涉及文件**: `ohnowho-app/Services/ExportService.swift`

```swift
final class ExportService {
    /// 全量导出
    func exportToZip() async throws -> URL

    /// 从 zip 导入
    func importFromZip(_ url: URL) async throws
}
```

#### 导出流程
1. 从 SwiftData 获取所有 `Note`（含 `MediaAsset`）
2. 构建 `data.json`（JSONEncoder + ISO8601DateFormatter）
3. 创建临时目录
4. 将 `data.json` 写入临时目录根
5. 遍历媒体文件，按类型复制到 `assets/images/` 和 `assets/videos/`
6. 使用 `FileManager.zipItem(at: to:)` 或 ZipFoundation 打包
7. 返回生成的 zip 文件 URL

#### 导入流程
1. 用户选择 zip 文件
2. 解压到临时目录
3. 读取并解析 `data.json`
4. 按 `id` 去重：已存在的跳过，新数据插入
5. 将媒体文件复制到 App Sandbox `Documents/media/`
6. 批量写入 SwiftData
7. 清理临时文件

---

### Step 6.2 — 导出 UI

**涉及文件**: `ohnowho-app/Views/Map/MapView.swift`, `ohnowho-app/Views/Settings/SettingsView.swift`

- 在地图导航栏或菜单中添加「导出数据」入口
- 点击后显示 ProgressView「正在导出...」
- 导出完成后自动弹出 `UIActivityViewController`（ShareSheet）分享 zip

```swift
// 导出触发
Button("导出数据") {
    Task {
        isExporting = true
        let url = try await exportService.exportToZip()
        isExporting = false
        showShareSheet(url)
    }
}
```

---

### Step 6.3 — 导入 UI

**涉及文件**: `ohnowho-app/Views/Settings/SettingsView.swift`

- 「导入数据」按钮
- 使用 `UIDocumentPickerViewController` 选择 zip 文件
- 导入中显示 ProgressView
- 完成后显示结果：成功导入 N 条笔记
- 失败时显示错误信息

```swift
// 导入触发
Button("导入数据") {
    showDocumentPicker = true
}
.fileImporter(isPresented: $showDocumentPicker, allowedContentTypes: [.zip]) { result in
    // 处理导入
}
```

---

### Step 6.4 — 创建设置页面

**涉及文件**: `ohnowho-app/Views/Settings/SettingsView.swift`

- 导出数据（带时间戳文件名）
- 导入数据
- 应用信息: 版本号、构建号
- App 图标 + 名称

**如何进入**:
- 地图导航栏右侧设置图标按钮（`gearshape`）
- 或地图右下角菜单

---

### Step 6.5 — 更新测试

**涉及文件**: `ohnowho-app/ohnowho-appTests/ohnowho_appTests.swift`

- 导出 JSON 序列化测试
- 导入 JSON 反序列化测试
- 媒体文件管理测试

---

## 文件操作清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| ✏️ 修改 | `ohnowho-app/ohnowho-app/Services/ExportService.swift` | 完整实现导出/导入 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Views/Settings/SettingsView.swift` | 设置页面 |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/Views/Map/MapView.swift` | 添加设置项入口 |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/ohnowho-appTests/ohnowho_appTests.swift` | 增加导入导出测试 |

## 验收检查清单

- [ ] 可导出所有笔记 + 媒体为 zip
- [ ] zip 包中 data.json 格式符合规范
- [ ] 媒体文件正确存放在 assets/ 目录下
- [ ] 导出后可通过 ShareSheet 分享
- [ ] 可从 zip 包导入数据
- [ ] 导入时按 id 去重，已存在的笔记跳过
- [ ] 导入后媒体文件正确恢复
- [ ] 导入完成后地图刷新显示新 Pin
- [ ] 导入失败时显示错误信息
- [ ] 导入/导出过程中显示进度
