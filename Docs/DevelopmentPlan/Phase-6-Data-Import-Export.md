# Phase 6 — Data Import / Export

## Goal
Implement full data export as a zip package and import from a zip package, ensuring user data is portable.

---

## Prerequisites
- ✅ Phase 1 complete (data models, ExportService skeleton)
- ✅ Phase 3 complete (notes/media data structures finalized)
- ✅ Phase 4 complete (data validated through actual use)

---

## Export Format Specification

Per `Docs/DataModel.md`, the export package structure is:

```
ohnowho_export_2025-07-04.zip
├── data.json
│   [
│     {
│       "id": "uuid",
│       "title": "Title",
│       "content": "# Markdown body",
│       "createdAt": "2025-07-04T10:30:00Z",
│       "updatedAt": "2025-07-04T10:30:00Z",
│       "latitude": 22.3193,
│       "longitude": 114.1694,
│       "address": "Address text",
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

## Steps

### Step 6.1 — Implement Export Service

**File**: `Services/ExportService.swift`

```swift
final class ExportService {
    /// Full export
    func exportToZip() async throws -> URL

    /// Import from zip
    func importFromZip(_ url: URL) async throws
}
```

#### Export Flow
1. Fetch all `Note` objects (with `MediaAsset`) from SwiftData
2. Build `data.json` (JSONEncoder + ISO8601DateFormatter)
3. Create a temporary directory
4. Write `data.json` to the temp directory root
5. Iterate over media files, copy to `assets/images/` and `assets/videos/` by type
6. Package using `FileManager.zipItem(at: to:)` or ZipFoundation
7. Return the generated zip file URL

#### Import Flow
1. User selects a zip file
2. Unzip to a temporary directory
3. Read and parse `data.json`
4. De-duplicate by `id`: skip existing entries, insert new ones
5. Copy media files to App Sandbox `Documents/media/`
6. Batch-write to SwiftData
7. Clean up temporary files

---

### Step 6.2 — Export UI

**Files**: `Views/Map/MapView.swift`, `Views/Settings/SettingsView.swift`

- Add "Export Data" entry in the map nav bar or menu
- Show ProgressView "Exporting..." on tap
- After export completes, automatically present `UIActivityViewController` (ShareSheet)

```swift
// Export trigger
Button("Export Data") {
    Task {
        isExporting = true
        let url = try await exportService.exportToZip()
        isExporting = false
        showShareSheet(url)
    }
}
```

---

### Step 6.3 — Import UI

**File**: `Views/Settings/SettingsView.swift`

- "Import Data" button
- Uses `UIDocumentPickerViewController` to select a zip file
- Shows ProgressView during import
- On completion, shows result: "Successfully imported N notes"
- On failure, shows error message

```swift
// Import trigger
Button("Import Data") {
    showDocumentPicker = true
}
.fileImporter(isPresented: $showDocumentPicker, allowedContentTypes: [.zip]) { result in
    // Handle import
}
```

---

### Step 6.4 — Create Settings Page

**File**: `Views/Settings/SettingsView.swift`

- Export Data (with timestamp in filename)
- Import Data
- App Info: version number, build number
- App icon + name

**How to access**:
- Settings icon button in the map nav bar (`gearshape`)
- Or a menu at the bottom-right of the map

---

### Step 6.5 — Update Tests

**File**: `ohnowho-appTests/ohnowho_appTests.swift`

- Export JSON serialization test
- Import JSON deserialization test
- Media file management test

---

## File Operations Summary

| Operation | File Path | Description |
|-----------|-----------|-------------|
| ✏️ Modify | `Services/ExportService.swift` | Full export/import implementation |
| 📄 Create | `Views/Settings/SettingsView.swift` | Settings page |
| ✏️ Modify | `Views/Map/MapView.swift` | Add settings entry point |
| ✏️ Modify | `ohnowho-appTests/ohnowho_appTests.swift` | Add import/export tests |

## Acceptance Checklist

- [ ] All notes + media can be exported as zip
- [ ] `data.json` in the zip conforms to the specified format
- [ ] Media files are correctly placed under `assets/` directory
- [ ] Exported zip can be shared via ShareSheet
- [ ] Data can be imported from a zip package
- [ ] Import de-duplicates by id, skipping existing notes
- [ ] Media files are correctly restored after import
- [ ] Map refreshes with new pins after import
- [ ] Error message displayed on import failure
- [ ] Progress indicator shown during import/export
