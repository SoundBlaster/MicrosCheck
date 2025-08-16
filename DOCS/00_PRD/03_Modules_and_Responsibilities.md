# 3. Modules and Responsibilities

## Overview

This section describes the primary modules implemented in the application, reflecting the actual source code structure and responsibilities. Each module encapsulates a distinct area of functionality related to audio recording and playback, file management, bookmarks, and waveform display.

---

## 1. RecorderModule

### Responsibilities

- **State Management:** Controls the lifecycle of recording sessions with a state machine enforcing valid transitions among states: `inited`, `prepared`, `recording`, `paused`, and `stopped`.
- **Audio Session Configuration:** Prepares and manages the `AVAudioSession` for recording, ensuring permissions and hardware availability.
- **Input Source Selection:** Enumerates available microphone inputs, supports selecting preferred input (e.g., built-in mic).
- **Recording Control:** Starts, pauses, and stops recording using `AVAudioRecorder`, with metering enabled for real-time audio level monitoring.
- **Error Handling:** Detects errors such as session misconfiguration, permission denial, and hardware unavailability, propagating errors for UI feedback.
- **Metadata Handling:** Tracks the current recording file URL and file cleanup prior to starting new recordings.
- **Extensibility:** Supports future enhancements including additional input devices, configurable settings, and improved recording quality.

### Key Types

- `RecorderState`: Defines discrete states of the recorder.
- `RecorderError`: Enumerates possible error cases.
- `RecorderImpl`: Concrete implementation of the `Recorder` protocol.
- `RecorderDelegate`: Handles AVAudioRecorder delegate callbacks.

---

## 2. PlayerModule

### Responsibilities

- **Playback Control:** Provides standard playback actions: play, pause, stop, using `AVAudioPlayer`.
- **State Tracking:** Maintains playback states `inited`, `playing`, `paused`, `stopped`, and `error` (with error details).
- **Audio Session Management:** Prepares and activates the `AVAudioSession` for playback scenarios.
- **Error Handling:** Handles playback errors and delegate callbacks gracefully.
- **File Abstraction:** Operates on abstract `File` type, decoupling file handling from playback logic.

### Key Types

- `AudioPlayer`: Protocol defining basic playback API.
- `AudioPlayerImpl`: Concrete player implementation wrapping `AVAudioPlayer` with state management.
- `AudioPlayerAVDelegate`: Delegate for AVAudioPlayer events.

---

## 3. FileManagerModule

### Responsibilities

- **File System Access:** Manages reading, existence checks, deletion, size retrieval, and path management for audio files in the sandboxed documents directory.
- **File Wrappers:** Abstracts file URLs into `File` protocol implementations.
- **Recording File Management:** Provides consistent access to the recording file location and handles cleanup prior to recording.
- **Supports Extensions:** Facilitates future metadata and file operations as per project scope.

### Key Types

- `FileReader`: Protocol defining file-related operations.
- `FileReaderImpl`: Concrete implementation managing files on disk.
- `File`: Protocol representing a file abstraction.
- `FileImpl`: Concrete implementation wrapping a URL.

---

## 4. BookmarksModule

*(Not yet fully implemented in source)*

### Planned Responsibilities

- **Bookmark Management:** Support quick timestamp bookmarking during playback and recording.
- **Annotation:** Allow detailed names or notes associated with bookmarks.
- **Persistence:** Save bookmarks alongside audio metadata files.
- **UI Integration:** Present bookmarks in lists, allow editing and navigation.
- **Export:** Facilitate sharing and backup of bookmarks.

---

## 5. WaveformModule

*(Not yet fully implemented in source)*

### Planned Responsibilities

- **Live Waveform Rendering:** Display real-time audio level waveform using Canvas or Metal.
- **Offline Waveform Caching:** Pre-generate waveform previews stored for efficient retrieval.
- **Customization:** Support style variations, zoom, color schemes.
- **Performance:** Optimize to maintain smooth UI responsiveness during waveform rendering.
- **Error Handling:** Manage failures in waveform generation or display gracefully.

---

## Additional Notes

- The architecture leverages Swift concurrency (`@MainActor`), protocols for clear separation, and dependency injection for testing and extensibility.
- UI modules interface with these core modules via observable state and bindings (as per the `AppState` class model).
- The modules adhere closely to AVFoundation standards for audio handling, ensuring robustness and compatibility.
