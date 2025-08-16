# 1. RecorderModule (Backend)

### Overview
The RecorderModule manages the entire audio recording process as a backend service. It exposes core functionality related to starting, pausing, resuming, and stopping audio capture, and maintains the recording state lifecycle.

### Responsibilities

- **State Management:** Controls recording session states through a state machine with states: `inited`, `prepared`, `recording`, `paused`, `stopped`.
- **Audio Session Configuration:** Sets up and manages `AVAudioSession` for audio recording with appropriate permissions handling.
- **Input Source Management:** Enumerates available audio input devices (e.g., built-in mic, headset) and allows selection.
- **Recording Control:** Starts, pauses, resumes, and stops recording, ensuring no corruption or data loss.
- **Metering:** Provides real-time RMS and peak level data per channel for UI visualization.
- **Metadata Management:** Tracks recording file URL, manages file cleanup before recording, and saves metadata.
- **Error Handling:** Detects hardware, permission, or session errors and surfaces them for user feedback.
- **Extensibility:** Designed to support additional input devices, customizable audio settings, and future encoding formats.

### APIs and Protocols

- Exposes a `Recorder` protocol defining state properties and command methods (`prepare()`, `record()`, `pause()`, `stop()`).
- Provides concrete implementation `RecorderImpl` managing AVFoundation integration and state control.
- Uses delegate objects like `RecorderDelegate` to handle low-level AVAudioRecorder events asynchronously.

### Integration Notes

The RecorderModule does not include any UI rendering or interaction logic; it simply exposes observable state and methods for the frontend UI to bind and respond to. This separation enables unit testing and clear responsibility boundaries.

---

# 2. PlayerModule (Backend)

### Overview
The PlayerModule provides backend audio playback services and maintains playback state.

### Responsibilities

- **Playback Control:** Offers play, pause, stop functionality via `AVAudioPlayer`.
- **State Management:** Tracks playback states: `inited`, `playing`, `paused`, `stopped`, and error states.
- **Audio Session Management:** Configures and activates `AVAudioSession` with playback category and options.
- **Playback Features:** Supports seeking, playback speed and pitch adjustment, volume controls, and A-B looping.
- **Bookmark Integration:** Interfaces with bookmark data to jump to saved positions.
- **Error Management:** Reports playback errors and handles completion events.

### APIs and Protocols

- Defines `AudioPlayer` protocol with core playback functions.
- Implements `AudioPlayerImpl` wrapping AVAudioPlayer with state machine and delegate handling.

### Integration Notes

Designed as a backend component without UI dependencies. Provides data and events for the UI layer to visualize playback progress and respond to user input.

---

# 3. FileManagerModule (Backend)

### Overview
Manages file system operations for recordings and related metadata in the app sandbox.

### Responsibilities

- **Directory Management:** Creates and manages `/Documents/Recordings/` directory structure.
- **File Operations:** Supports copying, renaming, deleting audio and metadata files atomically.
- **Metadata Handling:** Associates audio files with JSON metadata including playback position and bookmarks.
- **Attribute Extraction:** Uses AVAsset to extract audio attributes (duration, format, channels).
- **Import/Export:** Prepares for importing/exporting audio files and their metadata.
- **Error Handling:** Detects and handles file system or permission errors gracefully.

### APIs and Protocols

- Defines `FileReader` and `File` protocols for file abstraction.
- Provides concrete implementations such as `FileReaderImpl` and `FileImpl`.

### Integration Notes

Exposes backend APIs for file-related tasks consumed by the UI and higher-level modules.

---

# 4. BookmarksModule (Backend, Planned)

### Overview
Manages timestamp bookmarks within recordings, including persistence, editing, and export.

### Responsibilities

- **Quick Marking:** Supports instant bookmark at current playback/record position.
- **Detailed Annotations:** Allows users to add titles and notes to bookmarks.
- **Listing and Navigation:** Provides bookmark lists and navigation APIs.
- **Persistence:** Saves bookmarks in associated metadata files for recordings.
- **Sharing:** Facilitates exporting and sharing bookmark data.

### Integration Notes

This module will be implemented as a backend component exposing protocols for UI control.

---

# 5. WaveformModule (Backend, Planned)

### Overview
Supports waveform rendering capabilities as a backend service.

### Responsibilities

- **Live Rendering:** Samples audio data in real time for UI display.
- **Offline Waveform Generation:** Precomputes waveform previews for quick display.
- **Caching:** Stores waveform data for performance optimization.
- **Customization:** Supports display styles, zooming, color theming.
- **Performance:** Optimizes for minimal CPU load and smooth UI experience.
- **Error Handling:** Recovers gracefully from waveform generation or cache errors.

### Integration Notes

This module will provide waveform data to the frontend UI for rendering visual waveforms.

---

# Summary

The backend modules form the foundation of core audio processing, playback, file management, user data, and waveform data. They expose clean interfaces for integration with the frontend UI, facilitating robust, maintainable, and testable architecture.

The frontend UI layer is expected to bind to these backend modules, reacting to changes and sending user-driven commands while maintaining no direct audio or file operation logic.
