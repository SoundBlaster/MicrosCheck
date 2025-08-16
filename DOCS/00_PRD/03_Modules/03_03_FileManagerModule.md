```
# 3. FileManagerModule (Backend)

### Overview
The FileManagerModule is a backend service dedicated to managing audio files and associated metadata within the app’s sandboxed file system.

### Responsibilities

- **Directory Management:** Creates and maintains the `/Documents/Recordings/` directory used to store audio files and metadata safely.
- **File Operations:** Supports atomic file operations including creating, copying, renaming, and deleting audio files and their metadata counterparts.
- **Metadata Handling:** Associates each audio file with a JSON metadata file containing playback position, bookmarks, user tags, notes, and detailed audio attributes.
- **Audio Attribute Extraction:** Uses AVFoundation’s `AVAsset` to extract audio properties such as duration, sample rate, format, and channel count for use in UI and metadata.
- **Import/Export:** Prepares infrastructure for importing audio assets from external sources and exporting files plus metadata for backup or sharing.
- **Error Handling:** Detects and recovers from file system errors, permission denials, file corruption, or missing files, ensuring app stability.

### APIs and Protocols

- Defines the `FileReader` protocol exposing file system operations like checking existence, deletion, file size retrieval, and obtaining standard paths.
- Defines the `File` protocol abstracting file details through URL encapsulation.
- Provides concrete implementations `FileReaderImpl` and `FileImpl` for on-disk file management.

### Integration Notes

- Exposes backend APIs consumed by UI components for file listing, metadata display, and file management actions.
- Maintains strict separation of backend file management responsibilities from UI rendering or interaction logic.
- Collaborates closely with Recorder and Player modules to synchronize file state and metadata consistency.
- Supports atomic operations for safe concurrent file access or modifications, preventing data loss or corruption.
- Designed with future extensibility for added synchronization or cloud storage integration.

---

# Summary

The FileManagerModule backend serves as the core persistent storage manager for recordings and their metadata. By encapsulating all file system complexities and metadata responsibilities, it provides a stable and maintainable foundation that the frontend UI and audio modules build upon while maintaining clear separation of concerns.
