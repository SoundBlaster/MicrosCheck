# 6. UI Overview and Layout Structure (Frontend)

### Overview

This document describes the overall structure and key UI components of the Dictaphone app's main frontend screen, based on the current design screenshot. It outlines the layout divisions and functional UI elements to aid developers and designers in understanding and implementing the frontend module.

---

### 1. Main Screen Layout

#### 1.1. Top Waveform and Timeline

- Live waveform visualization displaying audio amplitude with a moving playhead to indicate the current playback or recording position.
- Vertical decibel level ruler (+ and -) aligned with waveform amplitude.
- Time ruler showing hours, minutes, and seconds for navigation and reference.

#### 1.2. Recording Information Panel

- **1.2.1. Left Block (Vertical Stack):**
  - Current recording status indicator (`[• REC]` with blinking red dot).
  - Elapsed time display in hours, minutes, and seconds (e.g., 1h07m26s).
  - Audio format and bitrate information (e.g., MP3, 192 Kbps).

- **1.2.2. Right Block (Vertical Stack):**
  - File name of the active recording.
  - File size indicator.
  - Audio Meter Display (see 1.2.2.1).

- **1.2.2.1. Audio Meter Display (Vertical Stack):**
  - Left channel level meter with decibel scale from -60 to 0 dB.
  - Right channel level meter mirroring left with same decibel scale.
  - Each channel meter shows current loudness and trailing dB readings.

#### 1.3. Navigation and Action Buttons (Horizontal Stack)

- Button to navigate back (`< Back`).
- Home button.
- Time-Mark (T-MARK) button for placing bookmarks or markers.
- Options/settings button.

#### 1.4. Search and Filter Controls Panel (Horizontal Stack)

- Search text input field.
- Buttons for:
  - Switching appearance modes (themes).
  - Accessing favorites.
  - Toggling waveform view styles.

#### 1.5. Transport Controls (Horizontal Stack)

- Large circular stop button.
- Vertical stack showing recording status:
  - Label `[RECORDING]`.
  - Blinking red recording indicator.
- Large circular record/pause button to start and pause recording.

#### 1.6. Central Circular Playback Control

- Rounded “real-look” iPod-style wheel control with directional segments:
  - Center play/pause button.
  - Left segment rewind button.
  - Right segment fast forward button.
  - Bottom segment A-B loop toggle indicator (`[A-B ˇ]`).
  - Top segment DPC toggle for dynamic playback control speed and pitch (`[DPC ˆ]`).

#### 1.7. UI Lock and Info Icons

- Lock button on the bottom left corner to prevent accidental touches during playback or recording.
- Info button on the bottom right corner for accessing help or metadata information.

---

### 2. Visual Styling and Theming

- Dark theme background providing high contrast for visibility in low light conditions.
- Blue highlights emphasize elapsed/recording time.
- Red color highlights active recording indicators and alerts.
- Buttons styled with subtle shadows, rounded corners, and skeuomorphic depth effects to visually separate functional elements.

---

### Summary

This structured layout offers a comprehensive and intuitive interface for managing audio recording and playback. It balances detailed audio visualizations with easily accessible transport and navigation controls. The design respects iOS platform conventions for touch interactions and modern visual aesthetics, facilitating effective user engagement and control.

---