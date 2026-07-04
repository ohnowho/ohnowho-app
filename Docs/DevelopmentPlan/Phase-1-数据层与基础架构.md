# Phase 1 — 数据层与基础架构

## 目标
清除 Xcode 模板代码，建立完整的数据模型层、服务层和项目目录结构。

---

## 目录结构变更

```
ohnowho-app/
├── App/
│   ├── OhNoWhoApp.swift            # [改] 重命名 + 重构
│   └── ContentView.swift           # [改] 清空为占位，连接 MapView
├── Models/
│   ├── Note.swift                  # [新] 笔记数据模型
│   └── MediaAsset.swift            # [新] 媒体资源模型
├── Services/
│   ├── LocationService.swift       # [新] 定位服务
│   ├── DataService.swift           # [新] 数据操作封装
│   └── ExportService.swift         # [新] 导入导出服务（骨架）
├── Utils/
│   ├── Constants.swift             # [新] 常量
│   └── Extensions.swift            # [新] 常用扩展
├── Views/
│   └── Map/
│       └── MapView.swift           # [新] 占位地图视图
├── Docs/                           # 已有
├── ohnowho-app.xcodeproj/          # 已有
├── ohnowho-appTests/               # 已有
└── ohnowho-appUITests/             # 已有
```

## 步骤

### Step 1.1 — 清理模板代码

**涉及文件**: `ohnowho-app/Item.swift`, `ohnowho-app/ContentView.swift`, `ohnowho-app/ohnowho_appApp.swift`

- [ ] 删除 `Item.swift`（模板文件）
- [ ] 清空 `ContentView.swift`，改为指向 `MapView` 的简单容器
- [ ] 重命名 `ohnowho_appApp.swift` → `OhNoWhoApp.swift`

**验收**:
- 不再有任何 `Item` 引用
- 编译不报错

---

### Step 1.2 — 创建数据模型

**涉及文件**: `ohnowho-app/Models/Note.swift`, `ohnowho-app/Models/MediaAsset.swift`

#### Note.swift

```swift
@Model
final class Note {
    var id: UUID
    var title: String?
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var latitude: Double
    var longitude: Double
    var address: String?
    @Relationship(deleteRule: .cascade) var assets: [MediaAsset]

    init(title: String?, content: String, latitude: Double, longitude: Double, address: String?) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.assets = []
    }
}
```

#### MediaAsset.swift

```swift
enum MediaType: String, Codable {
    case image
    case video
}

@Model
final class MediaAsset {
    var id: UUID
    var type: MediaType
    var filename: String
    var mimeType: String
    var createdAt: Date
    var orderIndex: Int
    var note: Note?

    init(type: MediaType, filename: String, mimeType: String, createdAt: Date, orderIndex: Int) {
        self.id = UUID()
        self.type = type
        self.filename = filename
        self.mimeType = mimeType
        self.createdAt = createdAt
        self.orderIndex = orderIndex
    }
}
```

**验收**:
- 模型可在 SwiftData 中正常持久化
- `Note` 删除时级联删除关联的 `MediaAsset`

---

### Step 1.3 — 创建服务层

**涉及文件**: `ohnowho-app/Services/LocationService.swift`, `ohnowho-app/Services/DataService.swift`, `ohnowho-app/Services/ExportService.swift`

#### LocationService.swift
- 封装 `CLLocationManager`
- `@Published` 属性: `authorizationStatus`, `currentLocation`, `currentAddress`
- 方法: `requestPermission()`, `startUpdatingLocation()`, `reverseGeocode()`
- 使用 `async/await` 模式

#### DataService.swift
- 封装 SwiftData 操作
- 方法: `fetchAllNotes()`, `saveNote(_:)`, `deleteNote(_:)`, `fetchNotes(matching:)`
- 使用 `@MainActor` 确保主线程安全

#### ExportService.swift
- 骨架文件，仅定义方法签名
- 方法: `exportToZip() async throws -> URL`, `importFromZip(_:) async throws`

**验收**:
- `LocationService` 可正确获取权限和位置
- `DataService` 的 CRUD 方法可用
- `ExportService` 骨架编译通过

---

### Step 1.4 — 创建工具文件

**涉及文件**: `ohnowho-app/Utils/Constants.swift`, `ohnowho-app/Utils/Extensions.swift`

#### Constants.swift
- 主题色: `static let accent = Color(hex: "#B22222")` 砖红
- SF Symbols: `static let plusIcon = "plus.circle.fill"`, `static let pinIcon = "mappin"`, 等
- 存储路径: `static let mediaDirectory`, `static let exportDirectory`
- 地图默认区域: `static let defaultRegion`

#### Extensions.swift
- `Color(hex:)` 初始化器
- `Date` 格式化扩展（`formatted` 方法）
- `CLLocationCoordinate2D` Equatable 扩展
- `View` Toast 修饰符（骨架）

**验收**:
- 所有常量编译可用
- Color hex 初始化器支持 `#RRGGBB` 格式

---

### Step 1.5 — 更新 App 入口

**涉及文件**: `ohnowho-app/App/OhNoWhoApp.swift`

```swift
@main
struct OhNoWhoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Note.self, MediaAsset.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**验收**:
- App 正常启动
- ModelContainer 注册了 Note 和 MediaAsset

---

### Step 1.6 — 创建占位 MapView

**涉及文件**: `ohnowho-app/Views/Map/MapView.swift`

- 空地图视图（iOS 17+ MapKit API）
- `MapCameraPosition` 绑定
- 包含 `MapViewModel` 的 `@StateObject` 占位（Phase 2 实现）

**验收**:
- 显示一张空白地图
- 编译通过

---

### Step 1.7 — 更新测试

**涉及文件**: `ohnowho-app/ohnowho-appTests/ohnowho_appTests.swift`

- 更新测试文件中的模型引用（Item → Note）
- 添加基本的 DataService CRUD 单元测试

**验收**:
- 单元测试通过

---

## 文件操作清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 🗑️ 删除 | `ohnowho-app/ohnowho-app/Item.swift` | 模板数据模型 |
| 🔄 重命名 | `ohnowho-app/ohnowho-app/ohnowho_appApp.swift` → `ohnowho-app/App/OhNoWhoApp.swift` | 同时修改内容 |
| ✏️ 修改 | `ohnowho-app/ohnowho-app/ContentView.swift` | 清空为占位视图 |
| ✏️ 修改 | `ohnowho-app/ohnowho-appTests/ohnowho_appTests.swift` | 适配新模型 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Models/Note.swift` | 数据模型 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Models/MediaAsset.swift` | 数据模型 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Services/LocationService.swift` | 服务层 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Services/DataService.swift` | 服务层 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Services/ExportService.swift` | 服务层（骨架） |
| 📄 新建 | `ohnowho-app/ohnowho-app/Utils/Constants.swift` | 工具 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Utils/Extensions.swift` | 工具 |
| 📄 新建 | `ohnowho-app/ohnowho-app/Views/Map/MapView.swift` | 占位视图 |

## 验收检查清单

- [ ] App 能正常编译运行，显示一张空地图
- [ ] 不再有任何 `Item` 模板代码引用
- [ ] 目录结构符合架构规划
- [ ] 定位权限请求逻辑已就绪
- [ ] 所有数据模型可在 SwiftData 中正确持久化
- [ ] 单元测试通过
