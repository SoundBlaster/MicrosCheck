# 9. Interaction and Navigation (Frontend)

### Overview

This document details the interaction patterns and navigation flow within the Dictaphone app's frontend UI. It focuses on how user gestures, routing, and modal presentations are managed to provide a fluid and intuitive user experience.

---

### 1. Enum-Based Routing and Navigation

- The UI uses an enum-based router pattern to manage navigation between primary screens:
  - Record Screen
  - Play Screen
  - File Management Screen
- Routes support optional parameters for passing context data (e.g., selected file, playback position).
- State-driven navigation ensures that screen transitions are reactive to the underlying `AppState` changes.
- Navigation changes include both pushing new views and presenting modal sheets.

---

### 2. Modal Sheets and Secondary UI Flows

- Modal sheets are used to present secondary interfaces such as:
  - Options and Settings dialogs
  - Bookmarks management screens
  - Technical information and help panels
- Modal presentations support dismissal gestures and user actions within the modal propagate state updates back to the main UI state.

---

### 3. UI Lock and Gesture-Based Unlocking

- Implements a UI lock overlay that prevents accidental input during recording or playback sessions.
- Unlocking requires an intentional gesture, typically a 2-second hold or similar sustained input.
- Haptic feedback is integrated to reassure the user of unlocking events.
- Lock state is visually indicated with icons and overlay shading to convey interaction status.

---

### 4. Gesture Support for Seeking

- Allows users to seek playback position efficiently via intuitive gestures.
- Tap gestures on specific buttons enable ±10 seconds seek jumps.
- Holding seek buttons triggers repeated seeking steps at approximately 200ms intervals.
- Audible or haptic feedback may be provided during seeking for user orientation, depending on settings.

---

### 5. Error Messaging, Warnings, and Status Indicators

- Interaction layer manages the display of error messages and warnings arising from backend modules.
- Errors are surfaced in a transient banner or modal that informs the user without disrupting the workflow unnecessarily.
- Status indicators provide real-time feedback on operations such as file save progress, recording state, or connectivity.

---

### 6. Accessibility and Input Adaptations

- Navigation adapts automatically to accessibility settings ensuring consistent experience for VoiceOver and other assistive technologies.
- Gestures and buttons provide alternative input mechanisms where appropriate.
- Focus management and routing are coordinated to maintain logical reading and interaction order.

---

### Summary

The Interaction and Navigation layer orchestrates user inputs, UI transitions, and feedback mechanisms to create a seamless and robust user experience. By employing state-driven routing, careful gesture design, and accessible interaction patterns, it ensures both usability and reliability in controlling recording, playback, and file management features.

---