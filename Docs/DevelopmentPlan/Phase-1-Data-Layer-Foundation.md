# Phase 1 — Data Layer & Foundation

## Goal
Clean up Xcode template code, establish the complete data model layer, service layer, and project directory structure.

---

## Directory Structure

```
ohnowho-app/                      # ← Xcode project source directory
├── App/
│   ├── ohnowhoApp.swift            # [Mod] Renamed + restructured
│   └── ContentView.swift           # [Mod] Cleared placeholder, NavigationStack + MapView
├── Models/
│   ├── Note.swift                  # [New] Note data model
│   └── MediaAsset.swift            # [New] Media asset model
├── Services/
│   ├── LocationService.swift       # [New] Location service (@Observable)
│   ├── DataService.swift           # [New] Data operations (constructor injection)
│   └── ExportService.swift         # [New] Import/Export service (skeleton)
├── Utils/
│   ├── Constants.swift             # [New] Constants
│   └── Extensions.swift            # [New] Common extensions
├── Views/
│   └── Map/
│       └── MapView.swift           # [New] Placeholder map (no ViewModel dependency)
└── Resources/                      # [Note] Existing, contains Info.plist, Assets etc.
```

> **Path note**: All file paths are relative to the Xcode project source directory `ohnowho-app/ohnowho-app/`.

---

## Steps

### Step 1.1 — Clean Up Template Code

**Files involved**:
- `Item.swift` — delete
- `ohnowho_appApp.swift` — move to `App/ohnowhoApp.swift`
- `ContentView.swift` — convert to MapView container

- [ ] Delete `Item.swift` (Xcode template data model)
- [ ] Create `App/` directory
- [ ] **Move and rename** `ohnowho_appApp.swift` → `App/ohnowhoApp.swift`
- [ ] Rewrite `ContentView.swift`, replace template list code with `NavigationStack + MapView`

**ContentView after refactor**:
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

> **Why NavigationStack?**: Phase 2's pin card → detail page needs `NavigationLink`. Wrapping now avoids future restructuring.

**Acceptance**:
- No remaining `Item` references
- Compiles without errors

---

### Step 1.2 — Create Data Models

**Files involved**: `Models/Note.swift`, `Models/MediaAsset.swift`

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

**Key Design Notes**:
- `Note.id` uses `.unique` to prevent duplicate records during import
- `@Relationship(inverse:)` explicitly specifies the bidirectional relationship to ensure cascade delete works
- `MediaAsset.filename` stores a relative path (e.g. `uuid.jpg`); the full sandbox path is constructed via `Constants.mediaDirectory`

**Acceptance**:
- Models persist correctly in SwiftData
- Deleting a `Note` cascades to delete its `MediaAsset` entries
- UUID uniqueness constraint is enforced

---

### Step 1.3 — Create Service Layer

**Files involved**: `Services/LocationService.swift`, `Services/DataService.swift`, `Services/ExportService.swift`

#### LocationService.swift

Uses iOS 17+'s `@Observable` macro (instead of the older `ObservableObject + @Published`).

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

    /// Request when-in-use location permission
    func requestPermission() { ... }

    /// Start updating location
    func startUpdatingLocation() { ... }

    /// Stop updating location (save power)
    func stopUpdatingLocation() { ... }

    /// Reverse geocode (async/await)
    func reverseGeocode(_ location: CLLocation) async -> String? { ... }

    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { ... }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { ... }
}
```

**Key Behaviors**:
- Always uses `requestWhenInUseAuthorization`
- Call `stopUpdatingLocation()` when location is no longer needed to save battery
- `reverseGeocode` uses `CLGeocoder.reverseGeocodeLocation(_:)` async version

#### DataService.swift

Uses **constructor injection** to receive `ModelContext`.

```swift
import SwiftData

@MainActor
final class DataService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Fetch all notes, ordered by creation time descending
    func fetchAllNotes() -> [Note] { ... }

    /// Save (insert or update)
    func saveNote(_ note: Note) throws { ... }

    /// Delete a note
    func deleteNote(_ note: Note) throws { ... }

    /// Search notes by keyword
    func fetchNotes(matching query: String) -> [Note] { ... }
}
```

**Injection approach**:
In `ohnowhoApp.swift`, create DataService and pass it to ContentView:
```swift
let dataService = DataService(context: sharedModelContainer.mainContext)
ContentView().environment(dataService)
```

#### ExportService.swift

Skeleton file — defines method signatures only; full implementation in Phase 6.

```swift
import Foundation

/// Data import/export service
/// Phase 1 only defines the interface; Phase 6 provides full implementation
final class ExportService {

    /// Export all data as a zip package
    /// - Returns: The exported zip file URL
    func exportToZip() async throws -> URL {
        fatalError("Not yet implemented - Phase 6")
    }

    /// Import data from a zip package
    /// - Parameter url: The zip file URL
    func importFromZip(_ url: URL) async throws {
        fatalError("Not yet implemented - Phase 6")
    }
}
```

**Acceptance**:
- `LocationService` correctly requests permission and gets location
- `DataService` CRUD methods compile
- `ExportService` skeleton compiles

---

### Step 1.4 — Create Utility Files

**Files involved**: `Utils/Constants.swift`, `Utils/Extensions.swift`

#### Constants.swift

```swift
import SwiftUI

enum Constants {
    // MARK: - Theme Colors
    static let accent = Color(hex: "#B22222")

    // MARK: - SF Symbols
    static let plusIcon = "plus.circle.fill"
    static let pinIcon = "mappin"
    static let searchIcon = "magnifyingglass"
    static let clearIcon = "xmark.circle.fill"
    static let locationIcon = "location"
    static let locationFillIcon = "location.fill"
    static let gearIcon = "gearshape"

    // MARK: - Storage Paths
    static let mediaDirectory = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("media")
    static let exportDirectory = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("exports")

    // MARK: - Map Defaults
    static let defaultLatitude: CLLocationDegrees = 35.0
    static let defaultLongitude: CLLocationDegrees = 105.0
    static let defaultZoom: CLLocationDistance = 5_000_000
}
```

#### Extensions.swift

```swift
import SwiftUI
import MapKit

// MARK: - Color Hex Initializer

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

// MARK: - Date Formatting

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

**Acceptance**:
- All constants compile and are usable
- `Color(hex:)` supports `#RRGGBB` format
- `Date.formatted` returns a readable time string

---

### Step 1.5 — Update App Entry

**Files involved**: `App/ohnowhoApp.swift`

```swift
import SwiftUI
import SwiftData

@main
struct ohnowhoApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Note.self, MediaAsset.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            fatalError("Failed to create ModelContainer")
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

**Key Changes**:
- Registers `Note.self` and `MediaAsset.self`; `Item.self` removed
- Injects `DataService` into the view hierarchy via `.environment()`

**Acceptance**:
- App launches correctly
- ModelContainer registers Note and MediaAsset
- DataService is accessible via `@Environment` in views

---

### Step 1.6 — Create Placeholder MapView

**Files involved**: `Views/Map/MapView.swift`

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

> **Note**: The Phase 1 MapView is a pure placeholder with no ViewModel dependency. Phase 2 will add `MapViewModel`, location services, pins, etc.

**Acceptance**:
- Shows an empty map
- Compiles

---

### Step 1.7 — Configure Info.plist

Location access requires adding a usage description key to `Info.plist`.

**Files involved**: `Info.plist` (located in `ohnowho-app/ohnowho-app/`)

- [ ] Add the following to Info.plist:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ohnowho needs access to your location to record it in your notes</string>
```

> **Why WhenInUse**: Per the PRD, the app only needs location access while in use, not in the background.

**Acceptance**:
- App does not crash on launch due to missing location permission config
- Location permission dialog shows the correct description text

---

### Step 1.8 — Install SPM Dependencies

**Files involved**: Xcode project configuration

- [ ] Add the following packages via Xcode → File → Add Package Dependencies...:

| Package | URL | Purpose | Phase |
|---------|-----|---------|-------|
| **MarkdownUI** | `https://github.com/gonzalezreal/swift-markdown-ui` | Markdown rendering/editing | Phase 3/4 |
| **ZipFoundation** | `https://github.com/weichsel/ZIPFoundation` | Zip packing/unpacking | Phase 6 |

> **Why install in Phase 1**: Avoids interrupting later development phases for dependency configuration.
> **Note**: These packages are only added as dependencies now; actual `import` and usage happen in Phase 3 and Phase 6.

**Acceptance**:
- SPM dependency resolution succeeds, build passes
- Project references `swift-markdown-ui` and `ZIPFoundation`

---

### Step 1.9 — Update Unit Tests

**Files involved**: `ohnowho-appTests/ohnowho_appTests.swift`

- [ ] Remove test code referencing `Item`
- [ ] Add `DataService` CRUD tests:

```swift
import Testing
import SwiftData
@testable import ohnowho_app

struct DataServiceTests {
    @Test func testCreateAndFetchNote() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
        let service = DataService(context: container.mainContext)

        let note = Note(title: "Test", content: "Content", latitude: 22.3, longitude: 114.1, address: "Hong Kong")
        try service.saveNote(note)
        let notes = service.fetchAllNotes()
        #expect(notes.count == 1)
        #expect(notes.first?.title == "Test")
    }

    @Test func testDeleteNote() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, MediaAsset.self, configurations: config)
        let service = DataService(context: container.mainContext)

        let note = Note(title: nil, content: "Will be deleted", latitude: 0, longitude: 0, address: nil)
        try service.saveNote(note)
        try service.deleteNote(note)
        let notes = service.fetchAllNotes()
        #expect(notes.isEmpty)
    }
}
```

**Acceptance**:
- All unit tests pass
- Coverage of DataService basic CRUD operations

---

## File Operations Summary

All paths relative to Xcode project source directory `ohnowho-app/ohnowho-app/`.

| Operation | File Path | Description |
|-----------|-----------|-------------|
| 🗑️ Delete | `Item.swift` | Template data model |
| 🔄 Move+Rename | `ohnowho_appApp.swift` → `App/ohnowhoApp.swift` | Restructure |
| ✏️ Modify | `ContentView.swift` | Replace with NavigationStack + MapView |
| ✏️ Modify | `Info.plist` | Add `NSLocationWhenInUseUsageDescription` |
| ✏️ Modify | `../ohnowho-appTests/ohnowho_appTests.swift` | Adapt for new models + add CRUD tests |
| ✏️ Modify | Xcode project config | Add MarkdownUI and ZipFoundation SPM deps |
| 📄 Create | `App/` directory | Store app entry file |
| 📄 Create | `Models/Note.swift` | Data model |
| 📄 Create | `Models/MediaAsset.swift` | Data model |
| 📄 Create | `Services/LocationService.swift` | Location service |
| 📄 Create | `Services/DataService.swift` | Data operations |
| 📄 Create | `Services/ExportService.swift` | Import/Export skeleton |
| 📄 Create | `Utils/Constants.swift` | Constants |
| 📄 Create | `Utils/Extensions.swift` | Extensions |
| 📄 Create | `Views/Map/MapView.swift` | Placeholder map |

---

## Acceptance Checklist

- [ ] App builds and runs, shows an empty map
- [ ] No remaining `Item` template code references
- [ ] Directory structure matches architecture plan (`App/`, `Models/`, `Services/`, `Utils/`, `Views/`)
- [ ] `Note` and `MediaAsset` registered in ModelContainer
- [ ] SwiftData bidirectional relationship correct, cascade delete works
- [ ] Info.plist configured with location permission description
- [ ] MarkdownUI and ZipFoundation SPM dependencies installed
- [ ] `LocationService` permission request logic ready
- [ ] `DataService` constructor injection usable
- [ ] Unit tests pass
