# 3. Architecture Separation: Backend Modules and Frontend UI

This document separates the product requirements and design specification for the Dictaphone app into two complementary parts: "Backend Modules" responsible for core audio, file, and logic layers, and "Frontend UI" focused on views, controls, and user interaction layers. This clear division supports modular development, maintainability, and testability.

---

## Part 1: Backend Modules

The backend consists of foundational components that handle audio processing, file management, user data, and business logic. These modules are platform and UI agnostic and expose interfaces or protocols for integration with the frontend UI.

### 1. RecorderModule

- Manages audio recording lifecycle with state management (`inited`, `prepared`, `recording`, `paused`, `stopped`).
- Controls `AVAudioSession` for recording, input source selection, and permission handling.
- Uses `AVAudioRecorder` for capturing audio with configurable settings.
- Supports pause and resume without corrupting files.
- Provides metering data (RMS and peak levels) for UI visualization.
- Handles recording metadata, active file management, and error states.
- Designed for extensibility to support new devices and formats.

### 2. PlayerModule

- Implements audio playback using `AVAudioPlayer` for basic playback features.
- Manages playback state machine (`stopped`, `playing`, `paused`, `error`).
- Controls audio session settings to support smooth playback.
- Provides hooks for playback progress, seeking, and volume adjustments.
- Integrates with bookmarks and looping features.
- Handles errors gracefully informing the UI layer.

### 3. FileManagerModule

- Centralizes file system operations in the app’s sandboxed directory.
- Handles creation, deletion, renaming, copying, and querying metadata of audio files.
- Extracts detailed audio attributes using AVAsset.
- Provides APIs to list recordings and associated metadata.
- Manages atomic file operations ensuring data integrity during concurrent access.
- Lays groundwork for import/export and metadata synchronization features.

### 4. BookmarksModule (Planned)

- Supports timestamped bookmarks with annotation.
- Persists bookmark data within recording metadata files.
- Enables bookmark export and sharing.

### 5. WaveformModule (Planned)

- Provides live waveform data rendering with real-time audio sampling.
- Performs offline waveform data generation and caching for efficient UI display.
- Supports waveform customization and high-performance rendering.
- Handles errors and recovers from cache corruption.

---

## Part 2: Frontend UI

The frontend UI layer provides interactive views, controls, and user experience flows. It binds to backend modules using observable state, protocols, or direct communication, translating backend data into visual components and user gestures into backend commands.

### 1. Views and Controls

- Implements transport controls (Record, Pause, Stop, Play).
- Displays audio meters (L/R average and peak) and waveforms.
- Provides quick action buttons and settings pickers for input sources.
- Supports bookmarks UI: adding, editing, listing bookmarks with modal dialogs.
- Includes search, file listing, file management actions (copy, delete, rename).
- Integrates locking overlays and info/help panels for accidental input prevention and user guidance.
- Ensures accessible UI based on VoiceOver, contrast, and Dynamic Type system settings.
- Maintains consistent adherence to the design system:
  - Color palette, typography, iconography, spacing rules.
  - Animated states for buttons and waveform updates.
  - Skeuomorphic styling with gradients, shadows, and bevel effects.

### 2. State and View Models

- Uses SwiftUI views bound to observable `AppState` and view models.
- ViewModels orchestrate UI state, route user actions to backend modules, and handle transient UI logic (debouncing, timers).
- Adapts backend data models into UI-friendly representations.
- Responds to backend events (state changes, errors) updating the UI reactively.

### 3. Interaction and Navigation

- Enum-based router drives navigation between record, play, and file management screens.
- Modal sheets present secondary UI flows like options, bookmarks, and technical info.
- UI lock enforces gesture-based unlocking with haptic feedback.
- Gesture support for seeking (tap ±10s, hold for repeated seeking with feedback).
- Handles error messaging, warnings, and status indicators.

---

## Integration Guidelines

- Backend modules expose clean Swift protocols encapsulating core functionality.
- Frontend UI imports these protocols and injects concrete backend instances via environment or dependency injection.
- Communication is primarily unidirectional: 
  - UI sends user requests to backend APIs.
  - Backend publishes state updates or sends delegate callback events.
- Modular separation allows backend unit tests and frontend UI tests in isolation.
- Future extensions can add more services or advanced UI components without disrupting existing layers.

---

## Summary

This division into Backend Modules and Frontend UI ensures a scalable architecture for the Dictaphone app:

| Layer            | Contains                            | Key Characteristics                              |
|------------------|-----------------------------------|-------------------------------------------------|
| **Backend Modules** | Recorder, Player, FileManager, Bookmarks, Waveform | Core audio logic, file and metadata management, business rules. Platform/UI independent. |
| **Frontend UI**    | SwiftUI Views, Controls, ViewModels, Routing | Interactive UI components, animations, accessibility, user workflows. |

This separation will enable efficient parallel development and clear responsibility boundaries aligning with the PRD and implementation plan.