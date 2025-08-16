# 3. Architecture Separation: Backend Modules and Frontend UI

This document separates the product requirements and design specification for the Dictaphone app into two complementary parts: "Backend Modules" responsible for core audio, file, and logic layers, and "Frontend UI" focused on views, controls, and user interaction layers. This clear division supports modular development, maintainability, and testability.

## Part 1: Backend Modules

See detailed backend module specifications:

- [[03_Modules/03_01_RecorderModule.md]]
- [[03_Modules/03_02_PlayerModule.md]]
- [[03_Modules/03_03_FileManagerModule.md]]
- [[03_Modules/03_04_BookmarksModule.md]]
- [[03_Modules/03_05_WaveformModule.md]]

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
