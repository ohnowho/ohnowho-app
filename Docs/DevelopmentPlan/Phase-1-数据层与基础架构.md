# Phase 1 — 数据层与基础架构

## 目标
清除 Xcode 模板代码，建立完整的数据模型层、服务层和项目目录结构。

---

## 目录结构

```
ohnowho-app/                      # ← Xcode 项目源目录
├── App/
│   ├── ohnowhoApp.swift            # [改] 重命名 + 重构
│   └── ContentView.swift           # [改] 清空为占位，NavigationStack + MapView
├── Models/
│   ├── Note.swift                  # [新] 笔记数据模型
│   └── MediaAsset.swift            # [新] 媒体资源模型
├── Services/
│   ├── LocationService.swift       # [新] 定位服务（@Observable）
│   ├── DataService.swift           # [新] 数据操作封装（注入式）
│   └── ExportService.swift         # [新] 导入导出服务（骨架）
├── Utils/
│   ├── Constants.swift             # [新] 常量
│   └── Extensions.swift            # [新] 常用扩展
├── Views/
│   └── Map/
│       └── MapView.swift           # [新] 占位地图视图（无 ViewModel 依赖）
└── Resources/                      # [注] 已有，放置 Info.plist、Assets 等
```

> **路径说明**: 所有文件路径均相对于 Xcode 项目源目录 `ohnowho-app/ohnowho-app/`。

---

## 步骤

### Step 1.1 — 清理模板代码

**涉及文件**:
- `Item.swift` — 删除
- `ohnowho_appApp.swift` — 移动到 `App/ohnowhoApp.swift`
- `ContentView.swift` — 改为指向 `MapView` 的容器

- [ ] 删除 `Item.swift`（Xcode 模板自带的数据模型）
- [ ] 创建 `App/` 目录
- [ ] 将 `ohnowho_appApp.swift` **移动并重命名为** `App/ohnowhoApp.swift`
- [ ] 修改 `ContentView.swift`，清空模板列表代码，改为 `NavigationStack + MapView`

**ContentView 改造后**：
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            MapView()
        }
    }
}

#Preview {
    ContentView()
}
```

> **为什么用 NavigationStack**：Phase 2 中 Pin 卡片 → 详情页需要 `NavigationLink`，现在提前包裹，后续不需再调整。

**验收**:
- 不再有任何 `Item` 引用
- 编译不报错

---

### Step 1.2 — 创建数据模型

**涉及文件**: `Models/Note.swift`, `Models/MediaAsset.swift`

#### Note.swift

```swift
import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var title: String?
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var latitude: Double
    var longitude: Double
    var address: String?
    @Relationship(deleteRule: .cascade, inverse: \MediaAsset.note)
    var assets: [MediaAsset]

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
import Foundation
import SwiftData

enum MediaType: String, Codable {
    case image
    case video
}

@Model
final class MediaAsset {
    @Attribute(.unique) var id: UUID
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

**关键设计说明**:
- `Note.id` 设置了 `.unique`，防止导入时产生重复记录
- `@Relationship(inverse:)` 显式指定了双向关系的反向路径，确保级联删除正常工作
- `MediaAsset.filename` 存储的是相对路径文件名（如 `uuid.jpg`），完整的沙盒路径由 `Constants.mediaDirectory` 拼接

**验收**:
- 模型可在 SwiftData 中正常持久化
- `Note` 删除时自动级联删除关联的 `MediaAsset`
- UUID 唯一约束生效

---

### Step 1.3 — 创建服务层

**涉及文件**: `Services/LocationService.swift`, `Services/DataService.swift`, `Services/ExportService.swift`

#### LocationService.swift

使用 iOS 17+ 的 `@Observable` macro（而非旧的 `ObservableObject + @Published`）。

```swift
import CoreLocation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocation?
    var currentAddress: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    /// 请求"使用期间"定位权限
    func requestPermission() { ... }

    /// 开始更新位置
    func startUpdatingLocation() { ... }

    /// 停止更新位置（省电）
    func stopUpdatingLocation() { ... }

    /// 反向地理编码（async/await）
    func reverseGeocode(_ location: CLLocation) async -> String? { ... }

    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { ... }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { ... }
}
```

**关键行为**:
- 始终检查 `requestWhenInUseAuthorization`
- 不需要定位时调用 `stopUpdatingLocation()` 节省电量
- `reverseGeocode` 使用 `CLGeocoder.reverseGeocodeLocation(_:)` 的 async 版本

#### DataService.swift

采用**构造器注入**方式获取 `ModelContext`。

```swift
import SwiftData

@MainActor
final class DataService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// 获取所有笔记，按创建时间倒序
    func fetchAllNotes() -> [Note] { ... }

    /// 保存（插入或更新）
    func saveNote(_ note: Note) throws { ... }

    /// 删除笔记
    func deleteNote(_ note: Note) throws { ... }

    /// 按关键词搜索笔记
    func fetchNotes(matching query: String) -> [Note] { ... }
}
```

**注入方式说明**:
在 `ohnowhoApp.swift` 中创建 DataService 并传递给 ContentView：
```swift
let dataService = DataService(context: sharedModelContainer.mainContext)
ContentView().environment(dataService)
```

#### ExportService.swift

骨架文件，仅定义方法签名，Phase 6 完整实现。

```swift
import Foundation

/// 数据导入导出服务
/// Phase 1 仅定义接口，Phase 6 完整实现
final class ExportService {

    /// 导出所有数据为 zip 包
    /// - Returns: 导出的 zip 文件 URL
    func exportToZip() async throws -> URL {
        fatalError("尚未实现 - Phase 6")
    }

    /// 从 zip 包导入数据
    /// - Parameter url: zip 文件 URL
    func importFromZip(_ url: URL) async throws {
        fatalError("尚未实现 - Phase 6")
    }
}
```

**验收**:
- `LocationService` 可正确请求权限和获取位置
- `DataService` 的 CRUD 方法编译通过
- `ExportService` 骨架编译通过

---

### Step 1.4 — 创建工具文件

**涉及文件**: `Utils/Constants.swift`, `Utils/Extensions.swift`

#### Constants.swift

```swift
import SwiftUI

enum Constants {
    // MARK: - 主题色
    static let accent = Color(hex: "#B22222")

    // MARK: - SF Symbols
    static let plusIcon = "plus.circle.fill"
    static let pinIcon = "mappin"
    static let searchIcon = "magnifyingglass"
    static let clearIcon = "xmark.circle.fill"
    static let locationIcon = "location"
    static let locationFillIcon = "location.fill"
    static let gearIcon = "gearshape"

    // MARK: - 存储路径
    static let mediaDirectory = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("media")
    static let exportDirectory = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("exports")

    // MARK: - 地图
    static let defaultLatitude = 35.0
    static let defaultLongitude = 105.0
    static let defaultZoom: CLLocationDegrees = 5_000_000
}
```

#### Extensions.swift

```swift
import SwiftUI
import MapKit

// MARK: - Color Hex 初始化
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - Date 格式化
extension Date {
    var formatted: String {
        self.formatted(date: .long, time: .shortened)
    }
}

// MARK: - CLLocationCoordinate2D Equatable
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
```

**验收**:
- 所有常量编译可用
- `Color(hex:)` 支持 `#RRGGBB` 格式
- `Date.formatted` 返回可读的时间字符串

---

### Step 1.5 — 更新 App 入口

**涉及文件**: `App/ohnowhoApp.swift`

```swift
import SwiftUI
import SwiftData

@main
struct ohnowhoApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Note.self, MediaAsset.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            fatalError("无法创建 ModelContainer")
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(DataService(context: sharedModelContainer.mainContext))
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**关键变化**:
- 注册 `Note.self` 和 `MediaAsset.self`，不再有 `Item.self`
- 通过 `Environment` 将 `DataService` 注入到视图层级

**验收**:
- App 正常启动
- ModelContainer 注册了 Note 和 MediaAsset
- DataService 可通过 `@Environment` 在视图中访问

---

### Step 1.6 — 创建占位 MapView

**涉及文件**: `Views/Map/MapView.swift`

```swift
import SwiftUI
import MapKit

struct MapView: View {
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(initialPosition: position)
            .ignoresSafeArea()
    }
}

#Preview {
    MapView()
}
```

> **说明**: Phase 1 中的 MapView 是纯占位，无 ViewModel 依赖。Phase 2 会在此基础上增加 `MapViewModel`、定位、Pin 等逻辑。

**验收**:
- 显示一张空白地图
- 编译通过

---

### Step 1.7 — 配置 Info.plist

位置访问需要在 `Resources/Info.plist` 中添加描述键。

**涉及文件**: `Info.plist`（位于 `ohnowho-app/ohnowho-app/` 目录）

- [ ] 在 Info.plist 中添加：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ohnowho 需要访问您的位置，以便在笔记中记录当前位置</string>
```

> **为什么是 WhenInUse**：根据 PRD，App 仅在"使用期间"需要定位，不需要后台定位权限。

**验收**:
- App 启动时不会因定位权限未配置而闪退
- 定位权限弹窗显示正确的描述文字

---

### Step 1.8 — 安装 SPM 依赖

**涉及文件**: Xcode 项目配置

- [ ] 通过 Xcode → File → Add Package Dependencies... 添加以下依赖：

| 包 | URL | 用途 | 阶段 |
|----|-----|------|------|
| **MarkdownUI** | `https://github.com/gonzalezreal/swift-markdown-ui` | Markdown 渲染/编辑 | Phase 3/4 |
| **ZipFoundation** | `https://github.com/weichsel/ZIPFoundation` | zip 打包解包 | Phase 6 |

> **为什么在 Phase 1 安装**: 避免后续开发中途中断去处理依赖配置。
> **注意**: 两个包目前只是添加依赖，实际 import 和使用分别在 Phase 3 和 Phase 6。

**验收**:
- SPM 依赖解析成功，编译通过
- 项目中可看到 `swift-markdown-ui` 和 `ZIPFoundation` 的引用

---

### Step 1.9 — 更新单元测试

**涉及文件**: `ohnowho-appTests/ohnowho_appTests.swift`

- [ ] 删除引用 `Item` 的测试代码
- [ ] 添加 `DataService` 的 CRUD 测试：

```swift
import Testing
import SwiftData
@testable import ohnowho_app

struct DataServiceTests {
    @Test func testCreateAndFetchNote() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
        let service = DataService(context: container.mainContext)

        let note = Note(title: "测试", content: "内容", latitude: 22.3, longitude: 114.1, address: "香港")
        try service.saveNote(note)
        let notes = service.fetchAllNotes()
        #expect(notes.count == 1)
        #expect(notes.first?.title == "测试")
    }

    @Test func testDeleteNote() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
        let service = DataService(context: container.mainContext)

        let note = Note(title: nil, content: "将被删除", latitude: 0, longitude: 0, address: nil)
        try service.saveNote(note)
        try service.deleteNote(note)
        let notes = service.fetchAllNotes()
        #expect(notes.isEmpty)
    }
}
```

**验收**:
- 单元测试通过
- 覆盖 DataService 的 CRUD 基本操作

---

## 文件操作清单

所有路径均相对于 Xcode 项目源目录 `ohnowho-app/ohnowho-app/`。

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 🗑️ 删除 | `Item.swift` | 模板数据模型 |
| 🔄 移动+改 | `ohnowho_appApp.swift` → `App/ohnowhoApp.swift` | 同时修改内容 |
| ✏️ 修改 | `ContentView.swift` | 清空为 NavigationStack + MapView |
| ✏️ 修改 | `Info.plist` | 添加 `NSLocationWhenInUseUsageDescription` |
| ✏️ 修改 | `../ohnowho-appTests/ohnowho_appTests.swift` | 适配新模型 + 添加 CRUD 测试 |
| ✏️ 修改 | Xcode 项目配置 | 添加 MarkdownUI 和 ZipFoundation SPM 依赖 |
| 📄 新建 | `App/` | 存放 App 入口文件 |
| 📄 新建 | `Models/Note.swift` | 数据模型 |
| 📄 新建 | `Models/MediaAsset.swift` | 数据模型 |
| 📄 新建 | `Services/LocationService.swift` | 定位服务 |
| 📄 新建 | `Services/DataService.swift` | 数据操作封装 |
| 📄 新建 | `Services/ExportService.swift` | 导入导出服务（骨架） |
| 📄 新建 | `Utils/Constants.swift` | 常量 |
| 📄 新建 | `Utils/Extensions.swift` | 扩展方法 |
| 📄 新建 | `Views/Map/MapView.swift` | 占位地图视图 |

---

## 验收检查清单

- [ ] App 能正常编译运行，显示一张空地图
- [ ] 不再有任何 `Item` 模板代码引用
- [ ] 目录结构符合架构规划（`App/`、`Models/`、`Services/`、`Utils/`、`Views/`）
- [ ] `Note` 和 `MediaAsset` 已注册到 ModelContainer
- [ ] SwiftData 双向关系正确，级联删除生效
- [ ] Info.plist 已配置定位权限描述
- [ ] MarkdownUI 和 ZipFoundation SPM 依赖已安装
- [ ] `LocationService` 权限请求逻辑已就绪
- [ ] `DataService` 注入式初始化可用
- [ ] 单元测试通过
