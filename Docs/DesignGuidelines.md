# Design Guidelines — ohnowho

## Overall Style
- Clean, minimal aesthetic, following Apple HIG
- Generous whitespace, text-first design
- Light / Dark mode support (follows system setting)
- SF Symbols icon set

## Colors
| Use | Value |
|-----|-------|
| Accent Color | `#B22222` Brick Red 🧱 |
| Accent (Light Mode Emphasis) | `#8B1A1A` Dark Brick Red |
| Pin Selection | `#CD5C5C` Light Brick Red |
| Search Bar Background | `.ultraThinMaterial` frosted glass |
| Background | System Background |
| Text | Label Color |
| Map Pin | System default red pin |

## Typography
- SF Pro (system default font)

## App Icon
- Symbol-style icon (❓ ❗ 📍 direction TBD)

## Map
- MapKit standard map style
- Note pins: system default red pin

## Interaction Details
- Delete note: no confirmation dialog, directly delete with undo Toast
- Search: search-as-you-type, real-time map filtering
