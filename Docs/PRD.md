# ohnowho — Product Requirements Document (PRD)

## One-Line Positioning
> A map + rich-document note-taking app — your personal location memory assistant.

## Target Users
- Individual users
- People who need to quickly record location-related information
- Travel journaling, shop reviews, parking spot memory, etc.

## Core Value Proposition
- Open the map and see everything you've recorded at each location
- Rich note formats: text (Markdown) + images + videos
- No manual location linking — automatically binds the current location when recording

## MVP Scope (V1.0)
- ✅ Personal tool only, no social / sharing features
- ✅ Native iOS app (Swift + SwiftUI)
- ✅ Target deployment: iOS 26+
- ✅ Local storage first (SwiftData)
- ✅ Import / Export support (JSON + assets as zip)
- ✅ Preserve original timestamps
- ❌ Voice recording (future version)
- ❌ iCloud sync (future version)
- ❌ Geofence reminders (future version)

## Data Ownership
- All data stays on-device, fully under user control
- Export format is open JSON + media files — users can process them anytime

## Visual Style
- Clean, minimal aesthetic, following Apple HIG
- Accent color: Brick Red 🧱
- Light / Dark mode follows system setting
- SF Symbols icon set
