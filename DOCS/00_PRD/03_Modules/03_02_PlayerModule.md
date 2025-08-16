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
# Summary

The PlayerModule backend forms the core of audio playback functionality for the Dictaphone app. It abstracts AVFoundation framework details and provides a robust, feature-rich interface for playback control, state reporting, and error handling.

Frontend UI components consume this module to display playback controls, seek bars, and other status indicators while routing user input back to the player service. This clean separation ensures maintainability, testability, and extensibility for a high-quality user experience.
