# 2. PlayerModule (Backend)

### Overview
The PlayerModule provides backend audio playback services and maintains playback state. It wraps core audio APIs to control playback and expose relevant state and events to the frontend UI.

### Responsibilities

- **Playback Control:** Offers play, pause, stop functionality via `AVAudioPlayer`.
- **State Management:** Tracks playback states: `inited`, `playing`, `paused`, `stopped`, and error states.
- **Audio Session Management:** Configures and activates `AVAudioSession` with playback category and options tailored for smooth playback.
- **Playback Features:** Supports seeking, playback speed and pitch adjustment (DPC), volume control, and A-B loop support.
- **Bookmark Integration:** Interfaces with bookmarks to allow quick jumps to saved positions and resuming playback.
- **Error Management:** Handles playback errors gracefully, propagating error states and messages to the UI layer.

### Seeking Functionality

- Tap gestures allow seeking ±10 seconds.
- Holding seek buttons triggers repeated seeking steps every 200ms.
- Optionally provides audible feedback during seeking for better user orientation.

### Playback Speed and Pitch Control (DPC)

- Utilizes `AVAudioUnitTimePitch` for on-the-fly adjustment of:
  - Playback rate (0.5x to 2.0x speed).
  - Pitch shifts (±1200 cents).

### Volume and Balance

- Offers master volume control ranging from 0% to 200%.
- Independently adjusts left and right channel gain in decibels (-60 dB to +12 dB).
- Volume adjustments implemented via audio mixer nodes to maintain audio fidelity.

### A-B Looping

- Allows users to define A and B points within the audio timeline.
- Supports continuous looping between A and B points.
- Provides functions to set, reset, and clear loop points.
- Ensures smooth transitions without audio clicks or artifacts.

### UI Lock

- Implements an optional overlay UI lock preventing accidental input during playback.
- Requires intentional user gestures (e.g., 2-second hold) to unlock.
- Integrated haptic feedback enhances user interaction confidence.

### APIs and Protocols

- Defines an `AudioPlayer` protocol capturing core playback and control methods.
- Implements `AudioPlayerImpl` encapsulating AVAudioPlayer and AVAudioEngine components along with state management and event delegation.
- Uses delegate classes to react to playback completion or decode errors, updating internal state accordingly.

### Integration Notes

- The PlayerModule is purely a backend service with no UI dependencies.
- Exposes reactive state and control methods for the frontend UI to bind and invoke.
- Interfaces cleanly with the bookmark module and file management systems.
- Designed for extensibility to incorporate future playback enhancements such as effects processing or alternative playback engines.

---

# Summary

The PlayerModule backend forms the core of audio playback functionality for the Dictaphone app. It abstracts AVFoundation framework details and provides a robust, feature-rich interface for playback control, state reporting, and error handling.

Frontend UI components consume this module to display playback controls, seek bars, and other status indicators while routing user input back to the player service. This clean separation ensures maintainability, testability, and extensibility for a high-quality user experience.