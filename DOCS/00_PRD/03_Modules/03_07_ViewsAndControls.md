# 7. Views and Controls (Frontend)

### Overview

This document details the Views and Controls components of the Dictaphone app's frontend UI. These components provide interactive visual elements and user control mechanisms that bind to the backend audio and file management modules.

---

### 1. Transport Controls

- **Record Button:**
  - Large circular button to start recording.
  - Changes to pause during recording to allow pausing.
- **Pause Button:**
  - Enabled during recording to temporarily pause audio capture.
- **Stop Button:**
  - Stops recording or playback.
- **Play Button:**
  - Starts audio playback.
- **Seek Controls:**
  - Support tapping for ±10 seconds seeking.
  - Long press triggers repeated seeking with feedback.
- **A-B Loop Toggle:**
  - Allows enabling/disabling playback looping between A and B points.

---

### 2. Audio Meters and Waveforms

- Displays real-time audio meters showing RMS and peak levels for left and right audio channels.
- Waveform visualization syncs with audio playback or recording progress.
- Supports live updates for meter and waveform animations.
- Customizable styles for colors, scaling, and responsiveness.

---

### 3. Quick Action Buttons and Settings Pickers

- Buttons for common actions include Time-Marks (T-MARK), Favorites, and Options.
- Settings pickers allow users to select audio input sources or toggle appearance modes.
- Buttons support meaningful icons and labels for accessibility.
- UI feedback with animations and state highlighting.

---

### 4. Bookmarks UI

- Interface for adding bookmarks with timestamp and optional annotations.
- Lists bookmarks in an editable and searchable view.
- Supports modal dialogs for editing or deleting bookmarks.
- Enables jumping to bookmarked positions during playback.
- Bookmark data is synchronized with backend bookmark and file metadata modules.

---

### 5. File Listing and Management Actions

- List view of recordings showing file names, durations, and metadata summaries.
- Supports searching, sorting, and filtering of recordings.
- Provides copy, rename, and delete actions with confirmation dialogs.
- Integrates locking overlays to prevent accidental modifications.

---

### 6. Locking Overlays and Info Panels

- UI lock overlays activate during playback or recording to prevent unintended gestures.
- Unlock gesture requires intentional user input with haptic feedback.
- Info/help panels provide contextual assistance and technical details.
- Modal presentations for secondary UI flows and settings.

---

### 7. Accessibility and Design Consistency

- Fully supports VoiceOver screen reader with properly labeled controls.
- Adheres to Dynamic Type size settings for font scaling.
- Color contrast meets accessibility standards.
- Incorporates consistent color palettes, typography, spacing, and iconography.
- Applies skeuomorphic styling with gradients, shadows, and bevels for visual depth.
- Animations enhance responsiveness and user engagement without overwhelming.

---

### Summary

The Views and Controls frontend components translate backend audio, metadata, and state into a rich, interactive user experience. They provide intuitive and accessible mechanisms to operate recording, playback, and file management while adhering to modern design and accessibility guidelines.

---