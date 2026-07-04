# Phase 2 — Map Home

## Goal
Implement fullscreen map display, user location, note pins, pin tap → card popup, and bottom "+" button.

---

## Prerequisites
- ✅ Phase 1 complete (data models, services, placeholder MapView)

---

## Steps

### Step 2.1 — Create MapViewModel

**File**: `ViewModels/MapViewModel.swift`

```swift
@Observable
final class MapViewModel {
    var region: MKCoordinateRegion
    var notes: [Note]
    var selectedNote: Note?
    var isShowingNoteCard: Bool
    var searchQuery: String  // Used in Phase 5

    func centerOnUser()
    func refreshNotes()
    func selectNote(_ note: Note)
    func dismissNoteCard()
    func deleteNote(_ note: Note)  // Used in Phase 4
}
```

**Key Behaviors**:
- Loads all notes via `DataService` on initialization
- `selectNote` sets `selectedNote` and shows the card
- `centerOnUser` gets location via `LocationService`

---

### Step 2.2 — Fullscreen Map

**File**: `Views/Map/MapView.swift`

- Integrate MapKit `Map` (iOS 17+ API)
- `MapCameraPosition` binding
- Initial region: prioritize user location, otherwise default to China
- Map occupies fullscreen, ignores safe area
- Standard map controls (zoom, rotate, etc.)

**Acceptance**:
- Fullscreen map displayed
- Zoom and pan work correctly

---

### Step 2.3 — Location Permission & User Location

**Files**: `Views/Map/MapView.swift`, `Services/LocationService.swift`

- Request location permission on first map display
- Call `LocationService.requestPermission()` in `onAppear`
- Auto-center on user location after authorization
- Add floating "Back to Location" button (bottom-right, location icon)
- Show user's blue dot on map

**Acceptance**:
- Location permission dialog appears on first launch
- Map centers on user location after authorization
- "Back to Location" button re-centers the map

---

### Step 2.4 — Display Note Pins

**File**: `Views/Map/MapView.swift`

- Use `Marker` on `Map` to show note locations
- Custom pin tint: brick red (`Constants.accent`)
- Each pin is bound to its corresponding `Note`
- Pin label shows note title (or "Note" if no title)

---

### Step 2.5 — Pin Tap → Card Popup

**Files**: `Views/Map/MapView.swift`, `Views/Note/NoteCardView.swift`

- Tap a pin → bottom card `NoteCardView` appears
- Card shows: title, address, creation time, content summary (first 80 chars)
- "View Details" button → navigates to Phase 4 detail page (NavigationLink placeholder)
- Card supports swipe-down to dismiss

---

### Step 2.6 — Bottom "+" Button

**File**: `Views/Map/MapView.swift`

- Floating circular "+" button at bottom-right
- SF Symbol: `plus.circle.fill`
- Tap opens Phase 3's new note Sheet (placeholder .sheet connection)

---

### Step 2.7 — Create NoteCardView

**File**: `Views/Note/NoteCardView.swift`

- Parameters: `note: Note`, `onDismiss: () -> Void`, `onViewDetail: (Note) -> Void`
- Displays:
  - Title (if exists)
  - Address (if exists) + creation time
  - First 80 chars of content + "..." summary
- "View Details" button at bottom
- Frosted glass background + rounded corners

---

## File Operations Summary

| Operation | File Path | Description |
|-----------|-----------|-------------|
| 📄 Create | `ViewModels/MapViewModel.swift` | Map view model |
| ✏️ Modify | `Views/Map/MapView.swift` | Full map implementation |
| 📄 Create | `Views/Note/NoteCardView.swift` | Pin card popup |
| 📄 Create | `Views/Common/SearchBar.swift` | Skeleton for Phase 5 |

## Acceptance Checklist

- [ ] Fullscreen map shows on app launch
- [ ] First launch requests location permission
- [ ] Map centers on user location after authorization
- [ ] "Back to Location" button visible on map
- [ ] Pins display when notes exist
- [ ] Tap pin shows card summary
- [ ] Card shows title, address, time, and summary
- [ ] Card can be swiped down to dismiss
- [ ] Bottom "+" button is visible
- [ ] Tapping "+" opens a new note Sheet (placeholder is acceptable)
