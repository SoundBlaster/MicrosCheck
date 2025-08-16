# Persistence

- **Local Only:** All audio files and associated metadata are stored strictly on-device in the app's sandbox; there is no synchronization or backup to iCloud, CloudKit, or any remote storage service in the current release.
- **No App-level Encryption:** Persistent audio files and metadata are not encrypted at rest or in transit by the app (device-level iOS security applies; the app does not implement its own encryption layer).
- **Storage Location:** All files are saved in the sandboxed directory `/Documents/Recordings/…`.
- **Permanent Deletion:** File deletion is immediate and irreversible—there is no "Trash" or retention period.
- **Alignment:** This policy aligns with the Security & Privacy and Non-Functional Requirements (see section 8).
- **Exception (Roadmap):** iCloud/remote storage integration is planned only as a potential future (post-1.0) extension. See "Extensions."

## File Export Policy (Baseline 1.0)

- Audio file export is provided via the standard iOS Share Sheet, allowing users to share recordings with other apps (Mail, Messages, Files, Drive, etc.).
- The default and only supported export format in version 1.0 is AAC (.m4a). MP3 export is not available in the initial release but is planned for a future update.
- When exporting, the payload includes the original filename, file duration, and creation date as metadata (where supported by destination apps and storage).
- Export is accessed through the Option sheet in the UI when a recording is selected.

- For full export scenarios, see also the UI Map and Extensions documentation.

## Persistence

- Implements a file-based persistence layer using FileManager for storing all audio assets and related metadata.
- Each recording is saved as an audio file (e.g., .m4a), with an associated JSON metadata file serialized using Codable for details such as file name, duration, bookmarks, and recording settings.
- All application settings and lightweight user preferences are managed via UserDefaults for efficiency.
- Files and metadata are organized in the sandboxed directory `/Documents/Recordings/…`, ensuring isolation and compatibility with backup policies.
- File operations (rename, copy, delete) are performed atomically to prevent corruption; metadata is kept in sync with audio assets.
- File and metadata naming conventions ensure uniqueness and traceability.
- No database or iCloud/CloudKit database is used at this stage, but the structure allows for potential future extensions.
