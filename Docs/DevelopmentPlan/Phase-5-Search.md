# Phase 5 — Search

## Goal
Implement a search bar that filters pins on the map in real-time as the user types keywords.

---

## Prerequisites
- ✅ Phase 2 complete (map home, pin display)

---

## Steps

### Step 5.1 — Implement SearchBar

**File**: `Views/Common/SearchBar.swift`

```swift
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search notes..."
    var onClear: (() -> Void)?
}
```

**UI Design**:
- Positioned at the top of the map
- Frosted glass background (`.ultraThinMaterial`)
- Search icon (`magnifyingglass`) on the left
- "Clear" button (`xmark.circle.fill`) appears when input is present
- Rounded corners, blends with the map

---

### Step 5.2 — Search Logic

**Files**: `ViewModels/MapViewModel.swift`, `Services/DataService.swift`

#### MapViewModel Additions
```swift
@Observable
final class MapViewModel {
    var searchQuery: String = ""

    var filteredNotes: [Note] {
        guard !searchQuery.isEmpty else { return notes }
        return notes.filter { note in
            let query = searchQuery.lowercased()
            return (note.title?.lowercased().contains(query) ?? false)
                || note.content.lowercased().contains(query)
                || (note.address?.lowercased().contains(query) ?? false)
        }
    }
}
```

#### DataService Additions
- `fetchNotes(matching query: String) -> [Note]` method
- Uses `Predicate` for SwiftData query (optional; in-memory filtering also works)

**Search Scope**:
- Note title
- Note body (Markdown content)
- Address text

---

### Step 5.3 — Search UI Integration

**File**: `Views/Map/MapView.swift`

- SearchBar placed at the top of the map
- Two-way binding with `MapViewModel.searchQuery`
- Map pins driven by `filteredNotes`
- When no matches:
  - Clear all pins
  - Show empty state: "No matching notes found"
- Clearing search restores all pins

---

## File Operations Summary

| Operation | File Path | Description |
|-----------|-----------|-------------|
| ✏️ Modify | `Views/Common/SearchBar.swift` | Full search bar implementation |
| ✏️ Modify | `ViewModels/MapViewModel.swift` | Add searchQuery + filteredNotes |
| ✏️ Modify | `Views/Map/MapView.swift` | Integrate SearchBar |
| ✏️ Modify | `Services/DataService.swift` | Add search method (optional) |

## Acceptance Checklist

- [ ] Search bar displayed at the top of the map
- [ ] Frosted glass style, does not obscure the map
- [ ] Typing keywords filters pins in real-time
- [ ] Search matches titles
- [ ] Search matches body content
- [ ] Search matches address text
- [ ] "Clear" button clears search in one tap
- [ ] Clearing search restores all pins
- [ ] Empty state shown when no results
