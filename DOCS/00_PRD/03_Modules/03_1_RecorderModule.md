# RecorderModule

### State Management
Manages the lifecycle of recording sessions with clearly defined states: `idle → recording → paused → stopping → saving → idle`. Ensures correct transitions between states and guards against illegal or unexpected state changes to maintain recording integrity.

### Input Source Selection
Allows users to switch between input sources such as the built-in microphone and headset. Handles relevant configuration options including hardware availability checks, permissions, and fallback scenarios.

### Audio Configuration
Supports configurable audio parameters like sample rate, bitrate, and channel mode (mono/stereo). Enables users to select recording quality settings appropriate for their needs.

### Level Meters
Provides real-time RMS and peak audio level monitoring per channel. Exposes an interface for the UI to display accurate visual feedback of audio input levels.

### Recording Metadata
Maintains detailed metadata for the current recording session, including file name, file size, audio format, recording timestamps, and user-defined tags.

### Pause/Resume Support
Enables seamless pausing and resuming of recordings, preserving state and ensuring no data loss or corruption.

### Error Handling
Detects and reports errors such as hardware access failure, storage limitations, or permission denials to the UI for user notification and recovery actions.

### Extensibility
Designed with extensibility in mind to support future enhancements such as additional input devices (e.g., Bluetooth microphones) and new audio encoding formats.
