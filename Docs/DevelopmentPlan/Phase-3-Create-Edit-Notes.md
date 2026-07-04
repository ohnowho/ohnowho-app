# Phase 3 — Create / Edit Notes

## Goal
Implement complete note creation and editing functionality, including Markdown editing, media attachment, location binding, and manual location adjustment.

---

## Prerequisites
- ✅ Phase 1 complete (data models, services)

---

## Steps

### Step 3.1 — Create NoteViewModel

**File**: `ViewModels/NoteViewModel.swift`

```swift
@Observable
final class NoteViewModel {
    // Editing state
    var title: String
    var content: String
    var mediaAssets: [MediaAsset]
    var location: CLLocationCoordinate2D
    var address: String
    var isSaving: Bool

    // Edit mode
    private var editingNote: Note?
    var isEditing: Bool { editingNote != nil }

    // Methods
    func loadNote(_ note: Note)             // Edit mode: load existing note
    func saveNote()                         // Save (new/update)
    func addMedia(from picker: PHPickerResult)
    func removeMedia(at index: Int)
    func updateLocation(_ coord: CLLocationCoordinate2D)
    func reverseGeocodeCurrentLocation()
}
```

**Key Behaviors**:
- When `isEditing` is `true`, saving updates an existing note; otherwise creates a new one
- Validation: requires at least content or media to save
- Copies media files to App Sandbox on save

---

### Step 3.2 — Implement NoteEditView

**File**: `Views/Note/NoteEditView.swift`

| Component | Description |
|-----------|-------------|
| Presentation | Bottom Sheet (`.presentationDetents([.medium, .large])`) |
| Title Area | Optional title field, placeholder "Add title (optional)" |
| Body Area | Markdown editing area with edit/preview toggle |
| Media Area | Horizontally scrolling thumbnail strip, add/delete support |
| Location Area | Display address text, "Adjust Location" button |
| Action Bar | "Cancel" and "Save" buttons |

---

### Step 3.3 — Markdown Editor

**Dependency**: MarkdownUI (third-party library)

- Integrate MarkdownUI for rendering preview
- Edit mode: plain `TextEditor` + custom toolbar
- Preview mode: MarkdownUI rendering
- Toolbar buttons:
  - `B` (Bold): `**text**`
  - `I` (Italic): `*text*`
  - `H` (Heading): `# text`
  - `•` (List): `- item`
  - `[]` (Code): `` `code` ``
  - `👁️` Toggle edit/preview

---

### Step 3.4 — Media Picker

**File**: `ViewModels/NoteViewModel.swift`

- Use `PHPickerViewController` for photo/video selection (iOS 14+)
- Use `UIImagePickerController` for instant camera capture
- On selection:
  1. Copy original file to `Documents/media/` directory
  2. Create `MediaAsset` object
  3. Add to `mediaAssets` array
- Support removing already-added media

---

### Step 3.5 — Location Binding

**Files**: `ViewModels/NoteViewModel.swift`, `Views/Common/LocationPickerView.swift`

- Auto-fetch current location when Sheet opens (`LocationService`)
- Display address text (if reverse geocoding succeeded)
- "Adjust Location" button → opens `LocationPickerView`
- Location is required; saving without location is not allowed

---

### Step 3.6 — Edit Mode

- `NoteEditView` accepts an optional `Note` parameter
- With `Note` → edit mode: pre-fill all fields
- Without `Note` → create mode: clear fields, fetch location
- On edit save: update `updatedAt` timestamp
- After save: notify `MapViewModel` to refresh the notes list

---

### Step 3.7 — Create LocationPickerView

**File**: `Views/Common/LocationPickerView.swift`

- Mini map view
- Draggable pin (fixed center pin, drag map to move location)
- Reverse geocode to display address
- "Confirm Location" button to return result

```swift
struct LocationPickerView: View {
    @Binding var coordinate: CLLocationCoordinate2D
    @Binding var address: String
    @Environment(\.dismiss) var dismiss
}
```

---

## File Operations Summary

| Operation | File Path | Description |
|-----------|-----------|-------------|
| 📄 Create | `ViewModels/NoteViewModel.swift` | Note view model |
| 📄 Create | `Views/Note/NoteEditView.swift` | Create/Edit note view |
| 📄 Create | `Views/Common/LocationPickerView.swift` | Location picker |
| 📄 Create | `Views/Common/MediaViewer.swift` | Skeleton |

## Acceptance Checklist

- [ ] Tapping "+" opens the new note Sheet
- [ ] Can input a title
- [ ] Can input Markdown body text
- [ ] Toolbar supports Bold / Italic / Heading / List / Code
- [ ] Can toggle between edit and preview modes
- [ ] Can select images/video from photo library
- [ ] Can take a photo with the camera
- [ ] Media thumbnails preview in the editor
- [ ] Auto-binds current location on create
- [ ] Can manually adjust location (drag pin)
- [ ] Address text displays correctly
- [ ] New pin appears on map after saving
- [ ] Can edit existing notes, content updates after save
- [ ] Saving is blocked when content and media are both empty
- [ ] Saving is blocked when no location is set
