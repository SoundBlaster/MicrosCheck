# FileManagerModule

### Directory Management
Manages the `Recordings/` directory, handling creation, listing, and organization of recording files. Calculates and reports disk usage and available space.

### Metadata Handling
Associates each audio file with a corresponding `*.json` metadata file containing last playback position, bookmarks, tags, user notes, and detailed audio information.

### File Operations
Supports core file operations including copy, delete, rename, and attribute queries on both audio files and their metadata files.

### Audio Attribute Extraction
Leverages `AVAsset` to extract detailed audio attributes such as duration, format, number of channels, and sample rate for use in the UI and metadata.

### Import/Export
Facilitates importing audio and metadata from external sources and exporting files and associated metadata for backup or sharing.

### Error Handling
Detects and manages file-related errors such as storage limitations, permission issues, file corruption, or missing files to maintain stability.
