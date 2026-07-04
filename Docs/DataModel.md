# Data Model — ohnowho

## Technology Choices
- Storage engine: SwiftData (iOS 26+)
- Local files: images/videos stored in App Sandbox Documents directory

## Note

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key, unique identifier |
| title | String? | Title (optional) |
| content | String (Markdown) | Note body |
| createdAt | Date | Creation time (read-only) |
| updatedAt | Date | Last modification time |
| latitude | Double | Latitude |
| longitude | Double | Longitude |
| address | String? | Reverse-geocoded address |

## MediaAsset

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| type | enum { image, video } | Media type |
| filename | String | Local file name |
| mimeType | String | e.g. image/jpeg |
| createdAt | Date | Original creation time |
| orderIndex | Int | Display order |

## Export Format

```
ohnowho_export_{yyyy-MM-dd}.zip
├── data.json
│   [
│     {
│       "id": "uuid",
│       "title": "Title",
│       "content": "# Markdown",
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
│           "createdAt": "...",
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
