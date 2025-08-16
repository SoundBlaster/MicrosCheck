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
