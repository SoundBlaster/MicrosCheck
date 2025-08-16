# 1. Scope, Goal, Success Criteria

## Goal

Implement an offline dictaphone with professional recording/playback features, a file manager, and support for bookmarks/metadata, matching the provided design.

## Core scenarios

- [ ] Audio recording with L/R level indication, pause, resume, stop, save with metadata.
- [ ] Playback with progress bar, quick rewinds (tap ±10s and hold with scrubbing), A-B loop, DPC (pitch and speed adjustment), overall and channel-wise L/R volume control, UI lock.
- [ ] File management: list, attributes, bookmarks (T-MARK), last position, copy/delete, available space.

## Success criteria (release 1.0 acceptance)

- [ ] Record/pause/stop is stable for ≥60 min without leaks, app remains in the background (Background Audio).
- [ ] L/R meters display average and peak power with update frequency ≥20 Hz and error ≤1 dB.
- [ ] Playback works correctly: rewinds, hold, A-B loop, DPC and volume adjustments without artifacts.
- [ ] File list displays required attributes and operations (copy, delete) without UI blocking.
- [ ] Design matches the mockup (colors, typography, iconography, layout).
- [ ] 0 crashes in stability test (30 min mix of scenarios), background power consumption ≤5%/hour on iPhone 13.

## Limitations and assumptions

- [ ] **Minimum iOS 18** for reliable SwiftUI and AudioEngine operation.
- [ ] **Default recording format:** AAC (m4a), 44.1 kHz, 128–256–320 kbps (configurable). (MP3 recording is not supported system-wide; export to MP3 is possible as a separate stage via an external library—see "Extensions".)
- [ ] File storage in sandbox: `/Documents/Recordings/…`
- [ ] Localizations: EN (v1.0), RU and other popular (later).
