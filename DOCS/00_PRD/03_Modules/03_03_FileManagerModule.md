``` 
# 3. FileManagerModule (Backend)

### Overview

The FileManagerModule is a backend service responsible for managing all file system interactions related to audio recordings and their metadata. It ensures safe and efficient storage, retrieval, and manipulation of audio files within the app’s sandboxed documents directory.

### Responsibilities

- **Directory Management:** Creates, organizes, and manages the `/Documents/Recordings/` directory structure used to store audio files and metadata safely.
- **File Operations:** Supports atomic file operations including creating, copying, renaming, deleting audio files and their metadata counterparts to maintain data integrity.
- **Metadata Handling:** Associates each audio file with a corresponding JSON metadata file containing playback position, bookmarks, user tags, notes, and detailed audio attributes.
- **Audio Attribute Extraction:** Utilizes AVFoundation’s `AVAsset` to extract audio properties such as duration, sample rate, format, and channel count, making this information available for UI display and metadata purposes.
- **Import/Export:** Prepares infrastructure for importing audio assets from external sources and exporting files plus metadata for backup or sharing.
- **Error Handling:** Detects, reports, and manages file system errors including permission issues, storage limitations, file corruption, or missing files, ensuring app stability.

### APIs and Protocols

- Implements the `FileReader` protocol providing file system operations such as:
  - Checking file existence.
  - Safe file deletion.
  - Retrieving file size and standard path access.
- Implements the `File` protocol, abstracting file details through URL encapsulation.
- Provides concrete implementations such as `FileReaderImpl` and `FileImpl` for on-disk file management within the app sandbox.

### Integration Notes

- This module exposes backend APIs that the frontend UI and higher-level modules utilize for displaying file lists, metadata display, and handling file management actions.
- Maintains strict separation of backend file management responsibilities from UI rendering or interaction logic.
- Collaborates closely with Recorder and Player modules to synchronize file state and metadata consistency.
- Supports atomic operations for safe concurrent file access or modifications to prevent data loss or corruption.
- Designed with future extensibility for added synchronization or cloud storage integration.

---

# Summary

The FileManagerModule backend serves as the core persistent storage manager for recordings and their metadata. By encapsulating all file system complexities and metadata responsibilities, it provides a stable and maintainable foundation that the frontend UI and audio modules build upon while maintaining clear separation of concerns.
