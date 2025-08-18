# Master TODO List for iOS Dictaphone Application Implementation

This document provides a comprehensive, structured, and priority-based task list with clear inputs, processes, outputs, dependencies, and acceptance criteria for the full implementation of the Dictaphone iOS app using SwiftUI and related audio technologies.

For component-level UI specifications, please refer to the corresponding detailed specs in the [GPT5 UI Files](./GPT5_UI/GPT5_UI_Files).

---

The following is a detailed, plain-text list of implementation tasks categorized and ordered by priority and dependencies, with their respective inputs, processes, outputs, and acceptance criteria.


# R1 Configure AudioSession for Play and Record

- [x] Input: None
- [x] Process: Setup AVAudioSession, handle interruptions and route changes.
- [x] Output: Active and stable audio session.
- [x] Priority: High
- [x] Dependencies: None
- [x] Acceptance Criteria: Recording and playback are uninterrupted; correct handling of interruptions like phone calls

# R2 Implement Recording Pipeline with AVAudioEngine

- [x] Input: RecordingSettings
- [x] Process: Configure input node, conversion, and AVAudioFile writing.
- [x] Output: AAC .m4a audio file produced.
- [x] Priority: High

- [x] Dependencies: R1
- [x] Acceptance Criteria: Files are playable, duration accuracy within ±50ms/hour

# R3 Support Pause and Resume in Recording

- [x] Input: Recording state
- [x] Process: Stop buffer without closing file; manage state transition.
- [x] Output: Updated audio file remains intact.
- [x] Priority: High
- [x] Dependencies: R2
- [x] Acceptance Criteria: No audio clicks on pause/resume; total timer reflects cumulative recording time

# R4 Implement Real-time L/R Audio Meters (RMS/Peak)

- [x] Input: Audio buffers
- [x] Process: Apply DSP tap for metering audio levels.
- [x] Output: Left/right channel RMS and peak levels.
- [x] Priority: High

- [x] Dependencies: R2
- [x] Acceptance Criteria: Real-time meter updates ≥ 20 Hz, no UI lags, CPU usage <10%

# R5 Implement Recording Source Route Picker

- [x] Input: Audio input routes
- [x] Process: Use AVAudioSession to provide route selection.
- [x] Output: Selected active input source.
- [x] Priority: Medium
- [x] Dependencies: R1
- [x] Acceptance Criteria: Switching input routes works without crashes; UI reflects active source

# R6 Update Recording Metadata (Name, Size, Format)

- [x] Input: File name, path
- [x] Process: Update JSON metadata file with current info.
- [x] Output: Updated metadata JSON file.
- [x] Priority: Medium
- [x] Dependencies: R2
- [x] Acceptance Criteria: Metadata stays synchronized with recording state and file attributes

# P1 Build Audio Playback Pipeline

- [ ] Input: Audio file
- [ ] Process: Setup AVAudioEngine playback chain (playerNode, timePitch, mixer).
- [ ] Output: Audio playback with effects.
- [ ] Priority: High
- [ ] Dependencies: R1
- [ ] Acceptance Criteria: Playback supports all formats, positions accurate

# P2 Track Playback Progress and Position

- [ ] Input: Timer
- [ ] Process: Poll player time periodically for UI.
- [ ] Output: Updated UI playback position.
- [ ] Priority: High
- [ ] Dependencies: P1
- [ ] Acceptance Criteria: Playback position does not drift more than 0.5s/hour

# P3 Implement Seek Tap Behavior (±10 seconds)

- [ ] Input: UI gesture
- [ ] Process: Implement jump nudge seek ±10 seconds.
- [ ] Output: Playback position updated.
- [ ] Priority: High
- [ ] Dependencies: P1
- [ ] Acceptance Criteria: Seek step is accurate, no sounds clipped or corrupted

# P4 Implement Hold Seek with Continuous Nudge (200 ms)

- [x] Input: UI gesture
- [x] Process: Repeat seeking with audio feedback every 200 ms.
- [x] Output: Fast seek navigation.
- [x] Priority: Medium
- [x] Dependencies: P1, P3
- [x] Acceptance Criteria: Feedback clear; lag from input to response < 100 ms

# P5 Implement Dynamic Playback Control (DPC) Rate/Pitch

- [x] Input: Playback speed/pitch controls
- [x] Process: Configure AVAudioUnitTimePitch for rate/pitch.
- [x] Output: Playback altered in real time.
- [x] Priority: High
- [x] Estimate: 1 day
- [x] Dependencies: P1
- [x] Acceptance Criteria: Rate/pitch adjustable on the fly; no audio artifacts

# P6 Implement Master and Channel Volume Control

- [x] Input: Volume levels
- [x] Process: Adjust mixer gains for master and L/R channels.
- [x] Output: Changed audio volume levels.
- [x] Priority: Medium

- [x] Dependencies: P1
- [x] Acceptance Criteria: Linear volume response; no clipping or distortion

# P7 Implement A-B Loop Playback

- [x] Input: Loop points A & B
- [x] Process: Loop playback between points with seamless looping.
- [x] Output: Continuous audio loop.
- [x] Priority: Medium
- [x] Dependencies: P1, P2
- [x] Acceptance Criteria: Loop boundaries accurate within ±20 ms; no audio pops/clicks

# UI1 Build SwiftUI Screens Layout According to Design

- [x] Input: Design specs
- [x] Process: Compose SwiftUI components for each UI section.
- [x] Output: Pixel-perfect UI matching design.
- [x] Priority: High
- [x] Dependencies: P2, R4
- [x] Acceptance Criteria: UI matches design colors, sizes, and spacing exactly

> See detailed UI component specs in [02_Component_Specs.md](./GPT5_UI/GPT5_UI_Files/02_Component_Specs.md) for A1…A7 component breakdown.

# UI2 Implement Live Waveform Display

- [ ] Input: RMS/Peak data
- [ ] Process: Render live waveform via Canvas or Metal.
- [ ] Output: Smooth waveform graph updating ≥ 30 FPS.
- [ ] Priority: High
- [ ] Dependencies: R4
- [ ] Acceptance Criteria: Smooth updates, no jank in live waveform rendering

> Refer to waveform generation and caching details in [03_05_WaveformModule.md](./03_Modules/03_5_Waveform.md) and UI rendering guidance under [09_SwiftUI_Composition.md](./GPT5_UI/GPT5_UI_Files/09_SwiftUI_Composition.md).

# UI3 Implement Offline Waveform Generation and Caching

- [ ] Input: Audio files
- [ ] Process: Pre-calc waveform previews, cache results.
- [ ] Output: Cached waveform previews for efficient scroll.
- [ ] Priority: Medium
- [ ] Dependencies: P1, FM1
- [ ] Acceptance Criteria: Fast list scroll performance, cache size under 5% of disk

# FM1 Setup Catalog Structure in Filesystem

- [ ] Input: None
- [ ] Process: Create and manage `/Documents/Recordings` directory.
- [ ] Output: Directory structure verified.
- [ ] Priority: High
- [ ] Estimate: 2 hours
- [ ] Dependencies: None
- [ ] Acceptance Criteria: Proper permissions and backup policy adherence

# FM2 Retrieve File List with Attributes

- [ ] Input: Disk contents
- [ ] Process: Use FileManager and AVAsset to fetch metadata.
- [ ] Output: Array of FileMeta objects.
- [ ] Priority: High
- [ ] Dependencies: FM1
- [ ] Acceptance Criteria: All required attributes present and accurate

# FM3 Implement Copy, Delete, Rename File Operations

- [x] Input: File IDs
- [x] Process: Perform file operations asynchronously.
- [x] Output: Updated file states, new IDs on copy/rename.
- [x] Priority: Medium
- [x] Dependencies: FM2
- [x] Acceptance Criteria: UI remains responsive during operations

# FM4 Query Free Disk Space

- [ ] Input: None
- [ ] Process: Use URLResourceValues for free space.
- [ ] Output: Free disk space in bytes.
- [ ] Priority: Low
- [ ] Dependencies: FM1
- [ ] Acceptance Criteria: Value reflects actual disk state

# BM1 Implement Bookmarks (T-MARK)

- [ ] Input: Current playback/record time
- [ ] Process: Append bookmark to metadata JSON file.
- [ ] Output: Updated bookmarks array.
- [ ] Priority: Medium
- [ ] Dependencies: P2, FM2
- [ ] Acceptance Criteria: Bookmarks visible and selectable in UI

# ST1 Manage Recording Settings Persistence

- [ ] Input: UI inputs
- [ ] Process: Save and load recording settings with UserDefaults and JSON.
- [ ] Output: Persistent RecordingSettings.
- [ ] Priority: Medium
- [ ] Dependencies: R2
- [ ] Acceptance Criteria: Settings applied correctly and persist across sessions

# SEC1 Implement UI Lock Overlay with Gestures and Haptics

- [x] Input: User gesture
- [x] Process: Display lock overlay, block input, unlock with long-press (2s).
- [x] Output: Locked UI state.
- [x] Priority: Medium
- [x] Dependencies: UI1
- [x] Acceptance Criteria: Controls disabled except unlock; unlock via 2s hold; haptic feedback

> UI Lock and Info icon specs can be found in [02_Component_Specs.md - Section A7](./GPT5_UI/GPT5_UI_Files/02_Component_Specs.md#A7-UI-Lock-Info-Icons).

# QA1 Unit Test AudioCore Components

- [ ] Input: Unit test cases
- [ ] Process: Write XCTest cases covering core functionality.
- [ ] Output: Passed unit test suite.
- [ ] Priority: High
- [ ] Dependencies: Core modules
- [ ] Acceptance Criteria: All key code paths covered

# QA2 Basic UI Tests

- [ ] Input: UI test cases
- [ ] Process: Implement XCUITest for essential UI flows.
- [ ] Output: Passed UI test suite.
- [ ] Priority: Medium
- [ ] Dependencies: UI1
- [ ] Acceptance Criteria: Minimum regression coverage

> Unit and UI test plans are outlined in [07_Unit_UI_Test_List.md](./GPT5_UI/GPT5_UI_Files/07_Unit_UI_Test_List.md) and acceptance matrix in [06_Acceptance_Test_Matrix.md](./GPT5_UI/GPT5_UI_Files/06_Acceptance_Test_Matrix.md).

# QA3 Perform Stress and Endurance Tests

- [ ] Input: App, device, mock data
- [ ] Process: Automated and manual testing under load.
- [ ] Output: Stress report with performance and stability data.
- [ ] Priority: High
- [ ] Dependencies: QA1, QA2
- [ ] Acceptance Criteria: Verified stability, error handling, no crashes or data loss under stress conditions
