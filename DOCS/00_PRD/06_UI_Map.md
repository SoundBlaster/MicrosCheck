# 6. UI Map by Screenshot and Identifiers

## Top Waveform Timeline
> Displays audio waveform with time markings and playhead, providing a visual overview of the recording timeline and navigation.

- **Top Waveform Timeline** (`WaveformTimelineView`)
- Time markings (e.g., 00:45, 01:00, …)
- Red pin playhead

## Info Card (Recording State)
> Shows current recording details, elapsed time, format, and audio levels for user awareness during recording sessions.

- **Info Card (in recording)** (`RecordingInfoCard`)
- Blue REC badge + explicit red 'RECORDING' LED-style indicator
- Elapsed timer (format: 1h07m26s)
- File name, size (e.g., 72.9 mb)
- File format & bitrate (e.g., MP3 • 320Kbps)
- L/R meters with dB readout, labeled (e.g., L: -7dB, R: -21dB)
- Current peak values

## Toolbar Row
> Provides core navigation and quick access actions for file management and options.

- `< Back | Home | T‑MARK | Option >` buttons
  - `T‑MARK`: Quick bookmark of current time
  - `Option`: Opens options sheet (source selection, format/bitrate, export, rename, delete)

## Quick Action Buttons
> Contains icon-based shortcuts above the search field for theme, favorites, and view sorting.

- Three Icon Buttons (above Search Field)
  - **Sun Icon**: Likely toggles dark/light mode or brightness
  - **Star Icon**: Possibly favorites/bookmarks list
  - **Grid/Dots Icon**: Sort/view/menu options

## Search Field
> Allows users to search for files or tags within their recordings library.

- Search by files/tags

## Transport Controls
> Main controls for stopping, pausing, or recording audio, emphasizing immediate access to crucial functions.

- `STOP` button (large, visually highlights when active)
- `REC/PAUSE` button (large, visually highlights when active)

## Recording State Indicator
> Visually signals when recording is in progress, reinforcing the current app mode.

- Small red LED-style indicator labeled 'RECORDING' above D-Pad

## D-Pad (TransportPad)
> Enables playback control, navigation, and advanced features like DPC and A-B repeat, via a multi-directional pad.

- **D‑Pad** (`TransportPad`)
- Center: Play/Pause (large play icon button)
- Up: DPC (panel with Rate/Pitch)
- Left/Right: Double-arrow icons for step ±10s (tap) / hold for repeated steps (seek/skip)
- Bottom: A‑B (set/reset)

## Lock Button
> Secures the interface by enabling overlay lock to prevent accidental input.

- Lock icon; enables overlay lock (bottom left)

## Info Button
> Provides access to technical info and help resources for the user.

- Info icon; opens tech info/help (bottom right)
