# 数据模型 — OhNoWho

## 技术选型
- 存储引擎：SwiftData（iOS 26+）
- 本地文件：图片/视频存储在 App Sandbox Documents 目录

## Note（笔记）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键，唯一标识 |
| title | String? | 标题（可选） |
| content | String (Markdown) | 笔记正文 |
| createdAt | Date | 创建时间（不可编辑） |
| updatedAt | Date | 最后修改时间 |
| latitude | Double | 纬度 |
| longitude | Double | 经度 |
| address | String? | 反向地理编码地址 |

## MediaAsset（媒体资源）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 主键 |
| noteId | UUID | 所属笔记 ID |
| type | enum { image, video } | 资源类型 |
| filename | String | 本地文件名 |
| mimeType | String | 如 image/jpeg |
| createdAt | Date | 原始创建时间 |
| orderIndex | Int | 排序 |

## 导出格式

```
ohnowho_export_{yyyy-MM-dd}.zip
├── data.json
│   [
│     {
│       "id": "uuid",
│       "title": "标题",
│       "content": "# Markdown",
│       "createdAt": "2025-07-04T10:30:00Z",
│       "updatedAt": "2025-07-04T10:30:00Z",
│       "latitude": 22.3193,
│       "longitude": 114.1694,
│       "address": "地址文本",
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
