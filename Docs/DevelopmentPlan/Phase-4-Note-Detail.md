# Phase 4 — Note Detail

## Goal
Implement full note detail display, including Markdown rendering, media viewing, editing, deletion, and location moving.

---

## Prerequisites
- ✅ Phase 1 complete (data models, services)
- ✅ Phase 3 complete (NoteViewModel, edit view)

---

## Steps

### Step 4.1 — Implement NoteDetailView

**File**: `Views/Note/NoteDetailView.swift`

```swift
struct NoteDetailView: View {
    let note: Note
    @State private var showEditSheet = false
    @State private var showDeleteToast = false
    @State private var showLocationPicker = false
    @Environment(\.dismiss) var dismiss
}
```

**Layout**:
```
┌─ ScrollView ──────────────────────┐
│ [Title - largeTitle]              │
│ 📍 Address  · 🕐 Creation Time    │
│ ──── Divider ────                 │
│ [Markdown Rendered Body]          │
│                                   │
│ [Media Grid]                     │
│ ┌─────┐ ┌─────┐ ┌─────┐        │
│ │ 📷  │ │ 📷  │ │ 📹  │        │
│ └─────┘ └─────┘ └─────┘        │
│                                   │
└────────────────────────────────────┘
Bottom toolbar: [Edit] [Delete] [Move Location]
```

---

### Step 4.2 — Markdown Rendering

- Use MarkdownUI library to render note body
- Supports: headings `#`, lists `-`, bold `**`, italic `*`, code blocks `` ` ``
- Rendered inside a `ScrollView` for long content

---

### Step 4.3 — Media Viewer

**File**: `Views/Common/MediaViewer.swift` (full implementation)

#### Image Viewing
- Tap image → fullscreen display
- Supports pinch-to-zoom and drag
- "Close" button to return

#### Video Playback
- Tap video → `AVPlayer` fullscreen playback
- Shows playback controls
- Auto-play/pause

#### Navigation
- Swipe left/right to switch between media items
- Page indicator at bottom

---

### Step 4.4 — Edit Note

- Tap "Edit" → opens `NoteEditView` with current `Note`
- After edit, `NoteViewModel` saves and refreshes
- Detail view content updates immediately

---

### Step 4.5 — Delete Note (with Undo)

**Interaction Flow**:
1. Tap "Delete"
2. No confirmation dialog — directly delete
3. Bottom Toast appears: "Note deleted" + "Undo" button
4. Toast visible for 5 seconds
5. Tap "Undo" → restore the note
6. Timeout → permanent deletion

**Implementation Notes**:
- On delete, mark the note as deleted and store in a temporary variable
- On undo, restore from the temporary variable
- Use `withAnimation` for Toast entrance/exit
- Toast can be a custom View modifier

---

### Step 4.6 — Move Location

- Tap "Move Location" → opens `LocationPickerView` (created in Phase 3)
- Drag pin to new location
- Confirm updates `Note.latitude` / `Note.longitude` / `Note.address`
- On map return, pin position syncs

---

## File Operations Summary

| Operation | File Path | Description |
|-----------|-----------|-------------|
| 📄 Create | `Views/Note/NoteDetailView.swift` | Note detail page |
| ✏️ Modify | `Views/Common/MediaViewer.swift` | Full media viewer implementation |
| ✏️ Modify | `Utils/Extensions.swift` | Add Toast view modifier |

## Acceptance Checklist

- [ ] Can enter detail page from map pin card
- [ ] Title, address, and creation time display correctly
- [ ] Markdown body renders correctly
- [ ] Images are tappable for fullscreen view (zoom, drag)
- [ ] Videos are tappable for fullscreen playback
- [ ] Can edit notes, content updates in real time
- [ ] Can delete notes with undo Toast
- [ ] Undo within 5 seconds restores the note
- [ ] Timeout results in permanent deletion
- [ ] Can move note location
- [ ] Location update syncs with map pin
