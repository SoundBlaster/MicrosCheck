# Product Requirements Document (PRD)



---

# 00 PRD Table of Contents

# Implementation Plan: iOS Application "Dictaphone" with SwiftUI

> SPECIAL DESIGN IS TAKEN INTO ACCOUNT according to the sent screenshot. Target platform: iOS 18+. Language: Swift 5.10+, UI: SwiftUI, audio: AVFoundation (AVAudioSession/Engine), publication in App Store.

# PRD — Table of Contents (auto)

- [00_PRD_Table_of_Contents](00_PRD_Table_of_Contents.md)
- [01_Area_Goal_Success_Criteria](./01_Area_Goal_Success_Criteria.md)
- [02_Architecture](./02_Architecture.md)
  - [02_01_1_UI](./02_Architecture/02_01_1_UI.md)
  - [02_01_2_ViewModels](./02_Architecture/02_01_2_ViewModels.md)
  - [02_01_3_AudioCore](./02_Architecture/02_01_3_AudioCore.md)
  - [02_01_4_Persistence](./02_Architecture/02_01_4_Persistence.md)
  - [02_01_5_Services](./02_Architecture/02_01_5_Services.md)
  - [02_01_6_Routing](./02_Architecture/02_01_6_Routing.md)
  - [02_01_7_ThreadsAndRealtime](./02_Architecture/02_01_7_ThreadsAndRealtime.md)
  - [02_01_8_AudioSession](./02_Architecture/02_01_8_AudioSession.md)
  - [02_01_9_ArchitectureSummary](./02_Architecture/02_01_9_ArchitectureSummary.md)
  - [02_01_Architecture](./02_Architecture/02_01_Architecture.md)
- [03_Modules_and_Responsibilities](./03_Modules_and_Responsibilities.md)
  - [03_1_RecorderModule](./03_Modules/03_1_RecorderModule.md)
  - [03_2_PlayerModule](./03_Modules/03_2_PlayerModule.md)
  - [03_3_FileManagerModule](./03_Modules/03_3_FileManagerModule.md)
  - [03_4_Bookmarks](./03_Modules/03_4_Bookmarks.md)
  - [03_5_Waveform](./03_Modules/03_5_Waveform.md)
- [04_Data_Models](./04_Data_Models.md)
- [05_Public_Interfaces](./05_Public_Interfaces.md)
- [06_UI_Map](./06_UI_Map.md)
- [07_Detailed_TODO](./07_Detailed_TODO.md)
- [08_Nonfunctional_Requirements](./08_Nonfunctional_Requirements.md)
- [09_Common_User_Actions_Streams](./09_Common_User_Actions_Streams.md)
- [10_Custom_UI_UX_Design](./10_Custom_UI_UX_Design.md)
- [11_Edge_Cases](./11_Edge_Cases.md)
- [12_Test_Plan](./12_Test_Plan.md)
- [13_App_Store_Checklist](./13_App_Store_Checklist.md)
- [14_Extensions](./14_Extensions.md)
- [15_Release_Plan](./15_Release_Plan.md)
- [16_Examples_of_Implementations](./16_Examples_of_Implementations.md)
- [17_Open_Questions](./17_Open_Questions.md)


---

# 01 Area Goal Success Criteria

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


---

# 02 Architecture

# 2. Architecture (High Level)

![[02_01_9_ArchitectureSummary]]

## Layers

- **[UI (SwiftUI)](02_Architecture/02_01_1_UI.md)** — screens and controls, strictly following the design.
- **[ViewModels (ObservableObject)](02_Architecture/02_01_2_ViewModels.md)** — state, event routing, debounce/timers.
- **[AudioCore](02_Architecture/02_01_3_AudioCore.md)** — unified engine for recording (using `AVAudioEngine`) and efficient playback (via `AVAudioPlayer`):
  - **RecordPipeline:** input → format → file writer → metering tap (`AVAudioEngine`).
  - **PlayPipeline:** file → playerNode → timePitch → stereo mixer → output; post-mix meters (or `AVAudioPlayer` for simple playback).
- **[Persistence](02_Architecture/02_01_4_Persistence.md)** — `FileManager` + associated JSON metadata (`Codable`) + `UserDefaults` for settings.
- **[Services](02_Architecture/02_01_5_Services.md)** — Permissions, Background, Haptics, AppStateLock, WaveformCache.
- **[Routing](02_Architecture/02_01_6_Routing.md)** — simple enum-router/Sheet (within a single Record/Play screen + modals).

## Threads and realtime

- Audio processing on the audio thread; UI label updates — via `DispatchSourceTimer`/`CADisplayLink` (≤50 Hz).
- All file operations — on a background queue, with progress tracking.

> See detailed description in [Threads & Realtime](02_Architecture/02_01_7_ThreadsAndRealtime.md).

## Audio Session

- Audio session category is set dynamically: uses `AVAudioSession.Category.playAndRecord` for recording and `AVAudioSession.Category.playback` for playback, with mode `.spokenAudio`/`.default` and options: `.allowBluetooth`, `.defaultToSpeaker`, `.mixWithOthers` (configurable).
- Handles interruptions (incoming call), source/route changes, Remote Control (additional stage).

> See detailed description in [Audio Session](02_Architecture/02_01_8_AudioSession.md).


---

# 03 Modules and Responsibilities

# 3. Modules and Responsibilities

## Table of Contents

1. [RecorderModule](03_1_RecorderModule.md)
2. [PlayerModule](03_2_PlayerModule.md)
3. [FileManagerModule](03_3_FileManagerModule.md)
4. [Bookmarks (T‑MARK)](03_4_Bookmarks.md)
5. [Waveform](03_5_Waveform.md)


---

# 04 Data Models

# 4. Codable Data Models

```swift
enum AudioFormat: String, Codable { case aac /*default*/, pcm, alac /*…*/ }

struct RecordingSettings: Codable {
    var sampleRate: Double // 44100 | 48000
    var bitrateKbps: Int   // 128..320 (for AAC)
    var channels: Int      // 1|2
    var format: AudioFormat
}

struct AudioFileID: Hashable, Codable { let path: String }

struct Bookmark: Codable, Identifiable {
    let id: UUID
    var time: TimeInterval
    var title: String?
    var note: String?
    var createdAt: Date
}

struct AudioAttributes: Codable {
    var duration: TimeInterval
    var bitrateKbps: Int?
    var sampleRate: Double
    var channels: Int
    var format: AudioFormat
    var fileSizeBytes: Int64
}

struct FileMeta: Codable {
    var id: AudioFileID
    var displayName: String
    var createdAt: Date
    var lastPlayedPosition: TimeInterval?
    var bookmarks: [Bookmark]
    var audio: AudioAttributes
    var userTags: [String]
    var custom: [String:String]?
}

struct PlaybackState: Codable {
    var position: TimeInterval
    var rate: Float      // 0.5..2.0
    var pitchCents: Float // -1200..+1200
    var volumeMaster: Float // 0..2
    var volumeL: Float      // in dB
    var volumeR: Float
    var aPoint: TimeInterval?
    var bPoint: TimeInterval?
}
```


---

# 05 Public Interfaces

# 5. Public Interfaces for separation of responsibility

```swift
protocol RecorderService {
    var isRecording: Bool { get }
    var elapsed: TimeInterval { get } // total recording time (including pauses)
    var meters: (lAvg: Float, lPeak: Float, rAvg: Float, rPeak: Float) { get }
    var currentMeta: FileMeta? { get }

    func configure(_ settings: RecordingSettings) throws
    func selectInput(_ route: RecorderInputRoute) throws // built-in / headset / bluetooth
    func start() throws
    func pause() throws
    func resume() throws
    func stopAndSave(name: String?) async throws -> FileMeta
}

protocol PlayerService {
    var isPlaying: Bool { get }
    var position: TimeInterval { get }
    var duration: TimeInterval { get }
    var meters: (lAvg: Float, lPeak: Float, rAvg: Float, rPeak: Float) { get }

    func load(_ file: AudioFileID) async throws
    func play() throws
    func pause() throws
    func stop() throws
    func seek(to: TimeInterval, smooth: Bool)
    func nudge(by seconds: TimeInterval) // ±10s
    func holdSeek(start direction: SeekDirection) // repeated steps with interval
    func holdSeekStop()

    // DPC & volume
    func setRate(_ v: Float)
    func setPitchCents(_ v: Float)
    func setMasterVolume(_ v: Float)
    func setChannelGains(lDb: Float, rDb: Float)

    // A-B
    func setAPoint(_ t: TimeInterval?)
    func setBPoint(_ t: TimeInterval?)
    func clearAB()
}

protocol FilesService {
    func list() async throws -> [FileMeta]
    func attributes(for id: AudioFileID) async throws -> FileMeta
    func copy(_ id: AudioFileID, to newName: String) async throws -> AudioFileID
    func delete(_ id: AudioFileID) async throws
    func freeDiskSpaceBytes() throws -> Int64
    func rename(_ id: AudioFileID, to newName: String) async throws -> AudioFileID
    func updateMeta(_ meta: FileMeta) async throws
}
```


---

# 06 UI Map

# 6. UI Map by Screenshot and Identifiers

## Top Waveform Timeline

ID: {#top-waveform-timeline}
> Displays audio waveform with time markings and playhead, providing a visual overview of the recording timeline and navigation.

- **Top Waveform Timeline** (`WaveformTimelineView`)
- Time markings (e.g., 00:45, 01:00, …)
- Red pin playhead

## Info Card (Recording State)

ID: {#info-card}
> Shows current recording details, elapsed time, format, and audio levels for user awareness during recording sessions.

- **Info Card (in recording)** (`RecordingInfoCard`)
- Blue REC badge + explicit red 'RECORDING' LED-style indicator
- Elapsed timer (format: 1h07m26s)
- File name, size (e.g., 72.9 mb)
- File format & bitrate (e.g., MP3 • 320Kbps)
- L/R meters with dB readout, labeled (e.g., L: -7dB, R: -21dB)
- Current peak values

## Toolbar Row

ID: {#toolbar-row}
> Provides core navigation and quick access actions for file management and options.

- Option: Opens options sheet (source selection, format/bitrate, export, rename, delete)
- Export is performed via the standard iOS Share Sheet.
- Default export format is AAC (.m4a).
- MP3 export is not available in version 1.0 (planned as roadmap feature).
- Exported payload includes filename, duration, and creation date as metadata (where supported by destination apps).

## Quick Action Buttons

ID: {#quick-action-buttons}
> Contains icon-based shortcuts above the search field for theme, favorites, and view sorting.

- Three Icon Buttons (above Search Field)
  - **Sun Icon**: Likely toggles dark/light mode or brightness
  - **Star Icon**: Possibly favorites/bookmarks list
  - **Grid/Dots Icon**: Sort/view/menu options

## Search Field

ID: {#search-field}
> Allows users to search for files or tags within their recordings library.

- Search by files/tags

## Transport Controls

ID: {#transport-controls}
> Main controls for stopping, pausing, or recording audio, emphasizing immediate access to crucial functions.

- `STOP` button (large, visually highlights when active)
- `REC/PAUSE` button (large, visually highlights when active)

## Recording State Indicator

ID: {#recording-indicator}
> Visually signals when recording is in progress, reinforcing the current app mode.

- Small red LED-style indicator labeled 'RECORDING' above D-Pad

## D-Pad (TransportPad)

ID: {#dpad}
> Enables playback control, navigation, and advanced features like DPC and A-B repeat, via a multi-directional pad.

- **D‑Pad** (`TransportPad`)
- Center: Play/Pause (large play icon button)
- Up: DPC (panel with Rate/Pitch)
- Left/Right: Double-arrow icons for step ±10s (tap) / hold for repeated steps (seek/skip)
- Bottom: A‑B (set/reset)

## Lock Button

ID: {#lock-button}
> Secures the interface by enabling overlay lock to prevent accidental input.

- Lock icon; enables overlay lock (bottom left)

## Info Button

ID: {#info-button}
> Provides access to technical info and help resources for the user.

- Info icon; opens tech info/help (bottom right)


---

# 07 Detailed TODO

# 7. Detailed TODO - stages, atomic tasks with metadata

| ID   | Task                                     | Input                  | Process                                 | Output                | Prior. | Estimate | Dependencies | Acceptance Criteria                                                   |
| ---- | ---------------------------------------- | ---------------------- | --------------------------------------- | --------------------- | ------ | -------- | ------------- | -------------------------------------------------------------------- |
| R1   | Configure AudioSession (PlayAndRecord)   | none                   | Config, interruption/route notifications| active session        | High   | 4h       | —             | Recording/playback not interrupted, correct pause on call            |
| R2   | Recording pipeline on AVAudioEngine      | RecordingSettings      | inputNode→converter→AVAudioFile         | .m4a file             | High   | 2d       | R1            | File playable, duration accurate (±50ms/hour)                        |
| R3   | Pause/resume recording                   | state                  | stop buffer without closing file        | updated file          | High   | 6h       | R2            | No clicks, timer counts total time                                   |
| R4   | Meters L/R (RMS/Peak, 20–30 Hz)          | audio buffers          | tap+DSP                                 | values for UI         | High   | 1d       | R2            | Real-time, no lags, CPU < 10%                                        |
| R5   | Recording source (route picker)          | routes                 | select via AVAudioSession               | active source         | Med    | 6h       | R1            | Switch without crash, indication                                     |
| R6   | Current recording metadata               | name/path              | update JSON                             | meta file             | Med    | 4h       | R2            | Name, size, format, time update                                      |
| P1   | Playback pipeline                       | file                   | playerNode+timePitch+mixer              | sound                 | High   | 2d       | R1            | Plays all supported files, position accurate                         |
| P2   | Progress/position                        | timer                  | poll playerTime                         | UI update             | High   | 6h       | P1            | No drift (>0.5s/hour)                                                |
| P3   | Seek tap ±10s                            | gesture                | nudge                                  | new position          | High   | 4h       | P1            | Steps accurate, no sound clipping                                    |
| P4   | Seek with hold                           | gesture                | repeat nudge/200ms + "with sound"       | fast navigation       | Med    | 8h       | P1,P3         | Clear feedback, lag <100ms                                           |
| P5   | DPC Rate/Pitch                           | values                 | config AVAudioUnitTimePitch             | modified sound        | High   | 1d       | P1            | No artifacts, switch on‑the‑fly                                      |
| P6   | Master and L/R Volume                    | values                 | mixer gains/panner                      | changed level         | Med    | 1d       | P1            | Linear response, no clipping                                         |
| P7   | A‑B Loop                                 | A/B                    | loop in render/timer                    | looping               | Med    | 1d       | P1,P2         | No clicks at loop transition                                         |
| UI1  | Screen according to layout               | design                 | SwiftUI components                      | pixel-perfect         | High   | 3d       | P2,R4         | Match spacing, colors, sizes                                        |
| UI2  | Waveform Live                            | RMS/Peak               | Canvas/Metal                            | graph                 | High   | 2d       | R4            | Frequency ≥30 FPS, smooth                                            |
| UI3  | Waveform Offline                         | file                   | pre-calc + cache                        | preview               | Med    | 2d       | P1,FS1        | Fast list scroll, cache <5% disk                                     |
| FM1  | Catalog structure                        | none                   | /Documents/Recordings                   | directory             | High   | 2h       | —             | Permissions, backup policy ok                                        |
| FM2  | File list                                | disk                   | FileManager+AVAsset                     | [FileMeta]            | High   | 1d       | FM1           | All attributes filled                                                |
| FM3  | Copy/Delete/Rename                       | id                     | background operations                    | new id                | Med    | 1d       | FM2           | UI does not block                                                    |
| FM4  | Free space                               | —                      | URLResourceValues                       | bytes                 | Low    | 2h       | FM1           | Value correct                                                        |
| BM1  | Bookmarks T‑MARK                         | pos                    | append → meta.json                      | bookmarks[]           | Med    | 1d       | P2,FM2        | Visible and selectable in UI                                         |
| ST1  | Recording settings                       | UI                     | UserDefaults+JSON                       | RecordingSettings     | Med    | 1d       | R2            | Applied to new recording                                             |
| SEC1 | UI Lock                                  | gesture                | overlay + haptics                       | anti‑misclick         | Med    | 6h       | UI1           | Unlock by holding 2s                                                 |
| QA1  | AudioCore unit tests                     | —                      | XCTest                                  | report                | High   | 1d       | core          | Key paths covered                                                    |
| QA2  | Basic UI tests                           | —                      | XCUITest                                | report                | Med    | 1d       | UI1           | Minimum regression                                                   |
| QA3  | Stress/endurance tests (long recording, battery, low storage, large library) | app, device, mock data | Automated/manual long-duration, high-volume, and resource-constrained scenarios | QA stress report | High | 2d | QA1, QA2 | Verified stability, data integrity, error handling, and UI responsiveness under all stress conditions |


---

# 08 Nonfunctional Requirements

# 8. Non-Functional Requirements (NFR)

## Performance

 - Latency: End-to-end delay between microphone input and visual meter update / playback feedback shall not exceed 150 ms.
 - AB-loop stability: Loop boundaries shall not deviate more than ±20 ms; no audible clicks/pops at loop points.
 - Bookmark accuracy: Bookmarks shall resolve within ±50 ms of the intended audio position.
 - Responsiveness: UI thread shall process input events within ≤200 ms even under heavy load (e.g., scrolling a list of 5k items).
 - Stress: App shall sustain 8+ hour continuous recording/playback sessions without crash, memory leak, or data loss.
 - Battery drain: In-app battery consumption shall be measured under continuous recording and playback, and shall not exceed 15% per hour on a standard battery benchmark device.

## Capacity

 - Maximum recording length: Continuous recording of at least 24 hours without crash, data loss, or memory leaks.
 - File list scalability: Support smooth UI performance and search with libraries of up to 5,000 recordings, including batch operations (delete, export).

## Resource Utilization

 - Memory: ≤ 150 MB RAM during typical operation (excluding audio file size).
 - CPU: ≤ 25% average load during recording and playback on mid-range iOS devices.
 - File integrity: No data loss or corruption allowed even if storage becomes full during recording. App must gracefully stop recording, display a clear error, and preserve existing data.
 - Energy efficiency:
 - Foreground: App shall complete 8 hours of continuous recording on a single battery charge on supported devices.
 - Background: Battery consumption ≤ 5%/hour during background recording.

## Reliability

 - Interruptions: Recording shall automatically resume after system interruptions (e.g., phone call, route change).
 - Data integrity: No audio data loss or corruption during unexpected app termination or power loss.

## Security & Privacy

 - Local storage only: Audio files shall be stored exclusively on device storage (no remote upload by default).
 - Permission handling: Use NSMicrophoneUsageDescription in Info.plist with explicit user consent.
 - Encryption: Temporary buffers and cached metadata shall not be written to unencrypted storage.

### Storage & Deletion Policy

- All audio files and associated metadata are stored strictly on-device in the app's sandbox; there is no synchronization or backup to iCloud, CloudKit, or any remote/cloud service in the current release.
- Persistent audio files and metadata are not encrypted at rest or in transit by the app (device-level iOS security applies; the app does not implement its own encryption layer).
- File deletion is permanent and immediate; there is no "Trash" or retention period.
- Any form of iCloud/remote/cloud storage is not supported in the current version. See roadmap/extensions for possible future changes.

## Accessibility

 - VoiceOver: All primary controls shall be labeled and operable via VoiceOver.
 - Contrast ratio: UI elements must achieve at least 4.5:1 contrast ratio.
 - Dynamic Type: App shall respect system text scaling settings.

## Diagnostics & Logging

 - Logging: Use os_log with proper privacy levels (.public / .private).
 - Debug flags: Enable additional diagnostic logging in debug builds only.
 - Crash reporting: Record non-PII diagnostics on fatal errors for QA verification.


---

# 09 Common User Actions Streams

# 9. Common User Action Streams (Core)

## 1. Recording

- Tap `REC` → pipeline starts → "REC" badge, timer runs, meters active.
- Tap `PAUSE` → state changes to `paused`, timer stops; tap again — `resume`.
- Tap `STOP` → file closes, metadata saved → switch to player mode for this file.

## 2. Playback

- Tap `Play` → progress moves, rewind buttons active.
- Tap `<<` or `>>` → ±10s.
- Hold `<<`/`>>` → step every 200ms with audio preview.
- Up on `DPC` → panel: Rate/Pitch sliders.
- Down on `A‑B` → A, then B, then "reset".
- Volume: master slider and L/R (from "Option").
- `T‑MARK` → bookmark at current position.

## 3. Files

- Search → filter by name/tags.
- Swipe or "Option" menu: copy, rename, delete, details.


---

# 10 Custom UI UX Design

# 10. UX Details Considering SPECIAL DESIGN

- Skeuomorphism, resemblance to a real device
- Palette — dark, with contrasting accents; round buttons, large “STOP/REC”.
- L/R meters: double bars (average power and peak), labels in dB (for example `-7 dB / -21 dB`).
- Top time ruler with marks and a red cursor.
- Lock at the bottom left — toggles overlay (semi-transparent layer with the hint “Hold to unlock for 2s”).
- Icon `i` — modal “About the App” + gesture guide.
- Haptic feedback: start/stop recording, setting A/B, placing T-MARK.


---

# 11 Edge Cases

# 11. Edge Cases and Failures

## AudioCore & Audio Session
- **No free space:** Gracefully stop recording, warn the user, auto-save partial file if possible.
- **Audio session interruption (e.g., call):** Pause recording/playback, attempt to resume when possible. Notify user if full recovery is not possible.
- **Loss of input route (e.g., unplug headset):** Auto-switch to built-in microphone, notify user.
- **Corrupted audio file or metadata:** Move affected files to `Recordings/_Corrupted/`, attempt recovery from metadata backup.
- **Zero signal (silence):** Optional auto-pause feature (planned for future).

## Persistence
- **File system errors (rename, delete, copy):** Show error message, retry or roll back to last known good state.
- **Metadata/audio file mismatch:** Detect and quarantine for user review. Provide restore or delete options.
- **Simultaneous file access (race condition):** Use atomic file operations and locking for safety.

## Services
- **Denied permissions (microphone, files, background audio):** Inform the user, provide link to Settings to enable, and disable affected features.
- **Background execution terminated (system kill):** Save state frequently, warn user of possible data loss.
- **Haptic feedback unavailable or failed:** Fall back to visual cues only; do not block critical flows.
- **Waveform cache corruption:** Regenerate waveform data on next access, mark old cache as invalid.

## UI
- **UI lock fails to engage or disengage:** Prevent actions until resolved, require user confirmation.
- **Unresponsive controls:** Watchdog timers and fallback UI path (e.g., hard stop button).
- **Accessibility feature conflict:** Provide alternate navigation/control path, warn user.

## General
- **Unexpected app termination (crash, force quit):** Auto-save state and recover on next launch.
- **Unsupported audio file format:** Inform user, block import/playback, suggest supported formats.

- Review and expand this list as new scenarios arise during development and testing.


---

# 12 Test Plan

# 12. Test Plan

## 1. Unit Tests

**Purpose:** To verify the correctness of individual components in isolation.

**Contents:**

- Meters: Test RMS (Root Mean Square) and Peak audio levels.
- Recording Accuracy: Ensure the length of recordings is as expected.
- DPC Without Clicks: Validate "DPC" (possibly "Direct Playback Control" or similar) operates noiselessly.
- A-B Boundaries: Confirm A-B repeat/marking boundaries function as intended.

## 2. Instrumental Tests

**Purpose:** To measure system-level metrics and performance.

**Contents:**

- CPU/Energy: Measure CPU usage and energy consumption during operation.
- Background Recording: Record in the background for 60 minutes to ensure stability and accuracy.

## 3. UI Tests

**Purpose:** To ensure user interface flows work as expected.

**Contents:**

- REC → PAUSE → RESUME → STOP: Test main recording flow scenarios.
- Rewinds: Verify rewind functionality.
- Bookmarks: Ensure adding and navigating bookmarks works.
- File Deletion: Confirm users can delete recordings as intended.

## 4. Regression Tests

**Purpose:** To confirm that core features continue to work after changes.

**Contents:**

- 20 Scripts: Run scripted tests covering all core features.
- Smoke Tests: Perform basic checks on app launch and essential operations.


---

# 13 App Store Checklist

# 13. App Store Checklist

- `NSMicrophoneUsageDescription`, `UIBackgroundModes = audio`.
- Icons/screenshots, Privacy Policy (offline).
- Handling remote crashes (if connected, for example, Firebase Crashlytics — optional).
- Testing on older/newer devices, VoiceOver, dynamic type.


---

# 14 Extensions

# 14. Extensions (after 1.0)

## Baseline File Export (1.0)

- **Share Sheet Export:** In version 1.0, users can export audio files via the standard iOS Share Sheet, enabling sharing to other apps (Mail, Messages, Files, Drive, etc.).
- **Export Format:** The default and only export format for 1.0 is AAC (.m4a). MP3 export is not available in 1.0 but is planned for a future update (see below).
- **Metadata Included:** The exported payload provides the original filename, file duration, and creation date as part of the file's metadata where supported by the destination (e.g., Files app will display these).
- **How to Export:** Users select 'Export' from the Option sheet in the UI, which invokes the system Share Sheet for the chosen file.

- Export to MP3: Planned for a future update to provide more format options. (Note: MP3 export is not available in version 1.0; only AAC/.m4a is supported initially.)
- iCloud Drive Integration: Later versions will allow direct saving and retrieving from iCloud Drive.
- Metadata Enhancement: Future updates will expand metadata tagging capabilities beyond the baseline.


---

# 15 Release Plan

# 15. Release Plan (estimate)

- **Sprint 1 (1.5–2 weeks):** R1–R4, FM1–FM2, UI1 (main screen without DPC/A‑B), basic player P1–P3.
- **Sprint 2 (1.5 weeks):** P4–P7, UI2, BM1, ST1, SEC1.
- **Sprint 3 (1 week):** UI3, FM3–FM4, QA1–QA2, polishing, App Store checklist.

Total: ~4–5 weeks for 1.0 by a team of 1 iOS developer.

- A dedicated period for Stress/QA (covering long recordings, battery drain, disk space exhaustion, and large library scenarios) is included in the release deliverables, and its completion is a requirement for final release. This aligns with the QA and stress requirements detailed earlier in the PRD and NFR.


---

# 16 Examples of Implementations

# 16. Short Implementation Examples (Reference Snippets)

## RMS/Peak meters from audio tap

```swift
func computeMeters(from buffer: AVAudioPCMBuffer) -> (rms: Float, peak: Float) {
    let ch = buffer.floatChannelData![0]
    let n = Int(buffer.frameLength)
    var sum: Float = 0, peak: Float = -Float.greatestFiniteMagnitude
    vDSP_measqv(ch, 1, &sum, vDSP_Length(n)) // root mean square
    vDSP_maxv(ch, 1, &peak, vDSP_Length(n))
    let rms = 10 * log10f(sum) // dBFS
    let pk  = 20 * log10f(abs(peak))
    return (rms, pk)
}
```

## A-B loop (on position timer)

```swift
if let a = aPoint, let b = bPoint, position >= b {
    seek(to: a, smooth: true)
}
```

## Holding "fast" seek/repeat

```swift
holdTimer = DispatchSource.makeTimerSource()
holdTimer?.schedule(deadline: .now(), repeating: .milliseconds(200))
holdTimer?.setEventHandler { [weak self] in self?.nudge(by: direction == .forward ? 2.0 : -2.0) }
holdTimer?.resume()
```


---

# 17 Open Questions

# 17. Open Questions for approval

1. Default ranges for DPC?
    - Rate 0.75–1.5
    - Pitch ±600c or ±1200c?
2. Standard recording quality presets: Low/Medium/High - and their exact parameters.
3. Is MPRemoteCommandCenter (headset control) needed in version 1.0?
4. "Option" mechanics, which items are definitely in 1.0:
    - source
    - format
    - renaming
    - export
5. Waveform display scheme during recording: continuous tape or fixed buffer of the last minute?
