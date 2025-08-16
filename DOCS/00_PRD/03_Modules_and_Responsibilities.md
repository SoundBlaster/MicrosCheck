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

### UI Overview and Layout Structure (Based on Design Screenshot)

1. Main Screen

1.1. Top Waveform and Timeline

- Displays live waveform visualization with a moving playhead indicating current position.
- Vertical ruler showing decibel level (+ and -).
- Time ruler showing hours, minutes, and seconds.

1.2. Recording Information Panel

1.2.1. Left Block of Panel shows as vertical stack

- current recording status: `[• REC]`.
- elapsed time: 1h07m26s
- audio format: MP3 & bitrate in Kbps

1.2.2. Right Block of Panel layout as vertical stack

Contains

 - File name
 - File size
 - Audio Meter Display (see 1.2.2.1)

1.2.2.1 Audio Meter Display layout as Vertical Stack

Contains

- L - left channel level meter indicates Left channel loudness values with dB readings at the trailing edge
- scale from -60 to 0 db
- R - right channel level meter indicates Right channel loudness values with dB readings at the trailing edge

1.3. Navigation and Action Buttons layout as horizontal stack

Contains buttons for navigation and marking:

- `< Back`
- `Home`
- `Time-Mark (T-MARK)`
- `Options`

1.4. Search and Filter Controls Panel layout as horizontal stack

- Search text field
- Associated buttons:
 - appearance modes
 - favorites
 - waveform views

1.5. Transport Controls layout as horizontal stack

- Large circular stop button
- Block of actual recording status layout as vertical stack
 - Label `[RECORDING]`
 - Red blinking indicator
- Large circular record/pause button

1.6 Central Circular Playback Control

Rounded complex real-look buttons as iPod wheel

- Central circular playback control with directional buttons for rewind:
 - play/pause in center of the wheel
 - fast forward on the right segment
 - rewind on the left segment
 - `[A-B ˇ]` loop indicators show active loop segments on the bottom segment
 - `[DPC ˆ]` toggle for dynamic playback control speed and pitch on the top segment

1.7. UI Lock and Info Icons

- Lock button at the bottom left to prevent accidental touches.
- Info button on the right for help or metadata.

1.8. Dark Theme with Modern Styling

- Dark background with high contrast blue highlights for recording time and red for active recording indicator.
- Buttons with subtle shadows and rounded corners provide skeuomorphic depth.

- **Top Waveform and Timeline:** Displays live waveform visualization with a moving playhead indicating current position, alongside a time ruler showing hours, minutes, and seconds.
- **Recording Information Panel:** Shows current recording status (e.g., REC), elapsed time, audio format (MP3, bitrate), and file name with size.
- **Audio Meter Display:** Dual channel level meters indicate left (L) and right (R) channel loudness values with dB readings.
- **Navigation and Action Buttons:** Back, Home, Time-Mark (T-MARK), and Options allow quick navigation and marking.
- **Search and Filter Controls:** Search input with associated buttons for appearance modes, favorites, and waveform views.
- **Transport Controls:** Large circular stop and record/pause buttons flank a central circular playback control with directional buttons for rewind, play/pause, fast forward, and A-B loop toggle.
- **Playback Rate and Loop Controls:** DPC toggle for dynamic playback control speed and pitch; A-B loop indicators show active loop segments.
- **UI Lock and Info Icons:** Lock icon at the bottom left to prevent accidental touches; info icon on the right for help or metadata.
- **Dark Theme with Modern Styling:** UI uses dark background with high contrast blue highlights for recording time and red for active recording indicator; buttons with subtle shadows and rounded corners provide skeuomorphic depth.

This modular layout offers comprehensive audio recording and playback management in one screen, supporting both touch and gesture-based interactions consistent with iOS design standards.

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
