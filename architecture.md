# 🧱 Personal Vault – Technical & Architecture Document

## 1. Overview
Personal Vault is a mobile-first, multi-device personal information manager built with Flutter.  
It securely stores multiple types of personal data — passwords, documents, contacts, events, and custom records — and syncs them safely across devices using Google Drive integration.

## 2. Functional Overview

| Feature           | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| Multi-type Vault  | Supports multiple item types — passwords, documents, contacts, events, and user-defined custom items. |
| Folder Organization | Each item can be grouped under folders like Work, Personal, Health, etc.  |
| Tags & Search     | Items can have multiple tags; smart search supports filters by folder, type, tags, or keywords. |
| Document Preview  | In-app preview for PDFs, images (JPG/PNG), and text files.                  |
| Thumbnails        | Auto-generated for PDF/image files for faster browsing.                    |
| Encryption        | Uses Argon2 for key derivation and VaultCrypto for AES-256 encryption of both data and thumbnails. |
| Offline Storage   | Uses encrypted SQLite (via sqflite) for local storage.                      |
| Incremental Sync  | Integrates with Google Drive API for safe multi-device synchronization.    |
| Background Auto-Sync | Supports event-based and periodic sync operations in background mode.  |

## 3. Technical Architecture

### 3.1 Layered Architecture
```
┌────────────────────────────┐
│        UI Layer (Flutter)  │
│  • Flutter Material Widgets│
│  • MVVM / Provider Pattern │
│  • Responsive Layouts      │
└────────────┬───────────────┘
             │
┌────────────▼───────────────┐
│     Application Layer      │
│  • VaultController         │
│  • SearchController        │
│  • Folder/Tag Managers     │
│  • Google Drive SyncMgr    │
└────────────┬───────────────┘
             │
┌────────────▼───────────────┐
│      Data Layer            │
│  • Local DB (sqflite)      │
│  • Drive API Integration   │
│  • VaultCrypto (AES + Argon2) │
│  • Repository Interfaces   │
└────────────┬───────────────┘
             │
┌────────────▼───────────────┐
│   Platform Services Layer  │
│  • Google Sign-In          │
│  • FilePicker / ImagePicker│
│  • PDF Viewer / Thumbnailer│
└────────────────────────────┘
```

## 4. Data Flow
1. **User Action:** Add or edit vault item (password/doc/contact/etc.)  
2. **VaultController:** Validates data, encrypts with VaultCrypto.  
3. **Repository:** Persists encrypted data to local SQLite.  
4. **SyncManager:** Queues sync tasks (upload/download) with Drive.  
5. **Google Drive API:** Syncs encrypted blobs (no plaintext ever leaves device).  
6. **UI Refresh:** Observer pattern triggers UI update on changes.  

## 5. Security Design

| Component       | Mechanism                                                      |
|-----------------|---------------------------------------------------------------|
| Key Derivation  | Argon2id using master password + salt                         |
| Encryption      | AES-256-GCM                                                   |
| Local Storage   | Encrypted SQLite (per-record encryption)                     |
| Cloud Sync      | Encrypted blobs only, zero-knowledge model                   |
| Auth            | Google Sign-In (OAuth 2.0) for Drive access                  |

## 6. Database Schema (Simplified)

| Table       | Columns                                           |
|------------|--------------------------------------------------|
| items      | id, type, folder_id, title, data_encrypted, thumbnail_encrypted, tags |
| folders    | id, name, parent_id                              |
| tags       | id, name                                         |
| item_tags  | item_id, tag_id                                  |
| sync_state | item_id, version, last_sync_time                 |

## 7. UI Pages

| Page           | Purpose                                    |
|----------------|--------------------------------------------|
| LoginPage      | Google Sign-In, unlock vault               |
| DashboardPage  | Folder view, quick access, search          |
| VaultItemPage  | Add/edit item (password/doc/contact/event) |
| PreviewPage    | PDF/Image/Text viewer                       |
| SettingsPage   | Encryption, sync, theme, account settings  |

## 8. Packages & Dependencies

| Purpose              | Package                                   |
|---------------------|-------------------------------------------|
| State Management     | provider / riverpod                       |
| Local DB             | sqflite                                   |
| Encryption           | cryptography, argon2, flutter_secure_storage |
| PDF/Image View       | pdfx, photo_view                           |
| Google Drive Sync    | googleapis, google_sign_in                 |
| File Picker          | file_picker                               |
| Background Tasks     | workmanager                               |
| UI Components        | flutter_staggered_grid_view, animations  |

## 9. Deployment Targets

| Platform  | Status                                        |
|-----------|-----------------------------------------------|
| Android   | ✅ Fully supported                            |
| iOS       | ✅ Fully supported                            |
| Web       | ⚙️ Preview mode (encryption limited by WebCrypto API) |
| Desktop   | 🚧 Planned for SaaS extension                 |

