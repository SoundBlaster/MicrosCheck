## File Storage Policy

- **Local Only:** All audio files and associated metadata are stored strictly on-device in the app's sandbox; there is no synchronization or backup to iCloud, CloudKit, or any remote storage service in the current release.
- **No App-level Encryption:** Persistent audio files and metadata are not encrypted at rest or in transit by the app (device-level iOS security applies; the app does not implement its own encryption layer).
- **Storage Location:** All files are saved in the sandboxed directory `/Documents/Recordings/…`.
- **Permanent Deletion:** File deletion is immediate and irreversible—there is no "Trash" or retention period.
- **Alignment:** This policy aligns with the Security & Privacy and Non-Functional Requirements (see section 8).
- **Exception (Roadmap):** iCloud/remote storage integration is planned only as a potential future (post-1.0) extension. See "Extensions."

# Persistence

- Implements a file-based persistence layer using FileManager for storing all audio assets and related metadata.
- Each recording is saved as an audio file (e.g., .m4a), with an associated JSON metadata file serialized using Codable for details such as file name, duration, bookmarks, and recording settings.
- All application settings and lightweight user preferences are managed via UserDefaults for efficiency.
- Files and metadata are organized in the sandboxed directory `/Documents/Recordings/…`, ensuring isolation and compatibility with backup policies.
- File operations (rename, copy, delete) are performed atomically to prevent corruption; metadata is kept in sync with audio assets.
- File and metadata naming conventions ensure uniqueness and traceability.
- No database or iCloud/CloudKit database is used at this stage, but the structure allows for potential future extensions.
