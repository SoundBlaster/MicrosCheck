# 8. State and View Models (Frontend)

### Overview

This document describes the state management and view model layer of the Dictaphone app's frontend UI. It focuses on how the application maintains and orchestrates UI state, adapts backend data models, and routes user interactions to backend services for a reactive user experience.

---

### 1. AppState and Observable State

- The app uses an `AppState` object representing the entire UI state, including recording, playback, file listing, bookmarks, and settings.
- `AppState` is observable, allowing SwiftUI views to bind to and reactively update when state changes occur.
- State properties track session status, error messages, playback position, recording states, UI lock status, and transient UI flags (e.g., loading indicators).

---

### 2. View Models

- View models encapsulate UI logic and state transformations necessary for views to render appropriately.
- They subscribe to backend module state changes and map raw backend data models into UI-friendly formats.
- Provide debouncing or throttling for inputs or UI updates when necessary (e.g., search input, metering updates).
- Handle transient UI logic such as timers, animation triggers, and error display durations.
- Expose commands and actions for the views to invoke, forwarding these to the backend API implementations.

---

### 3. Routing and Navigation State

- The navigation stack and routes between screens (Record, Play, File Management) are represented in the state.
- Uses enum-based routing with optional parameters to navigate and present modal sheets for options, bookmarks, and info.
- Route changes update `AppState` causing views to transition reactively and modally as appropriate.

---

### 4. Event Handling and Backend Integration

- Backend modules publish state updates and events asynchronously through delegates or Combine publishers.
- View models subscribe to these streams and update `AppState` accordingly.
- Errors or warnings from backend modules result in transient UI error states with user feedback.
- User gestures and commands from views funnel through view models to call backend functions, enforcing input validation or preconditions.

---

### 5. State Synchronization and Persistence

- The `AppState` persists key UI state between app launches, including last played positions, bookmark visibility, and user preferences.
- Synchronization mechanisms keep frontend UI in sync with backend file and audio session state changes.
- Supports restoring playback and recording sessions seamlessly after interruptions or app restarts.

---

### Summary

The State and View Models layer is crucial for providing a responsive, stable, and user-friendly frontend experience. By centralizing UI state management and mediating backend interactions, this layer enables clear separation of concerns, easier testing, and smooth updates aligned with reactive SwiftUI paradigms.

---