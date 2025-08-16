# 3. FileManagerModule (Backend)

### Overview

The FileManagerModule is a backend service responsible for managing all file system interactions related to audio recordings and their metadata. It ensures safe and efficient storage, retrieval, and manipulation of audio files within the app’s sandboxed documents directory.

### Responsibilities

- **Directory Management:** Creates, organizes, and manages the `/Documents/Recordings/` directory structure used to store audio files and metadata.
- **File Operations:** Supports copying, renaming, deleting, and querying attributes of audio and metadata files, all performed atomically to maintain data integrity.
- **Metadata Handling:** Associates each audio file with a corresponding JSON metadata file that includes last playback positions, bookmarks, tags, user notes, and audio-related information.
- **Audio Attribute Extraction:** Utilizes `AVAsset` to extract detailed audio file attributes such as duration, format, number of channels, and sample rate, making this information available for UI display and metadata purposes.
- **Import/Export:** Prepares for future extension to support importing audio files and metadata from external sources, and exporting for backup or sharing.
- **Error Handling:** Detects, reports, and manages file system errors including permission issues, storage limitations, file corruption, or missing files, ensuring app stability.

### APIs and Protocols

- Implements the `FileReader` protocol providing methods for:
  - Checking file existence.
  - Deleting files safely.
  - Retrieving file size and paths.
- Implements the `File` protocol to represent an abstract file with a URL.
- Concrete implementations include `FileReaderImpl` and `FileImpl` that handle actual file system operations within the app sandbox.

### Integration Notes

- This module exposes backend APIs that the frontend UI and higher-level modules utilize for displaying file lists, file attributes, and proceeding with file management actions.
- Maintains strict separation from UI concerns, focusing solely on reliable file system management.
- Works in conjunction with the Recorder and Player modules to coordinate access and updates to recording files and their metadata.

---

# Summary

The FileManagerModule forms the backbone of audio file persistence and management within the Dictaphone app. By encapsulating all filesystem details and metadata handling in a dedicated backend module, it facilitates a robust, consistent, and maintainable architecture where UI and audio logic layers interact cleanly with persistent data storage.