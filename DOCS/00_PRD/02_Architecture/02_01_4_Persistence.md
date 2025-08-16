# Persistence

- Implements a file-based persistence layer using FileManager for storing all audio assets and related metadata.
- Each recording is saved as an audio file (e.g., .m4a), with an associated JSON metadata file serialized using Codable for details such as file name, duration, bookmarks, and recording settings.
- All application settings and lightweight user preferences are managed via UserDefaults for efficiency.
- Files and metadata are organized in the sandboxed directory `/Documents/Recordings/…`, ensuring isolation and compatibility with backup policies.
- File operations (rename, copy, delete) are performed atomically to prevent corruption; metadata is kept in sync with audio assets.
- File and metadata naming conventions ensure uniqueness and traceability.
- No database or iCloud/CloudKit database is used at this stage, but the structure allows for potential future extensions.
