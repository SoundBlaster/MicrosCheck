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

- [x] Input: Audio file
- [x] Process: Setup AVAudioEngine playback chain (playerNode, timePitch, mixer).
- [x] Output: Audio playback with effects.
- [x] Priority: High
- [x] Dependencies: R1
- [x] Acceptance Criteria: Playback supports all formats, positions accurate

# P2 Track Playback Progress and Position

- [x] Input: Timer
- [x] Process: Poll player time periodically for UI.
- [x] Output: Updated UI playback position.
- [x] Priority: High
- [x] Dependencies: P1
- [x] Acceptance Criteria: Playback position does not drift more than 0.5s/hour

# P3 Implement Seek Tap Behavior (±10 seconds)

- [x] Input: UI gesture
- [x] Process: Implement jump nudge seek ±10 seconds.
- [x] Output: Playback position updated.
- [x] Priority: High
- [x] Dependencies: P1
- [x] Acceptance Criteria: Seek step is accurate, no sounds clipped or corrupted

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

- [x] Input: RMS/Peak data
- [x] Process: Render live waveform via Canvas or Metal.
- [x] Output: Smooth waveform graph updating ≥ 30 FPS.
- [x] Priority: High
- [x] Dependencies: R4
- [x] Acceptance Criteria: Smooth updates, no jank in live waveform rendering

> Refer to waveform generation and caching details in [03_05_WaveformModule.md](./03_Modules/03_5_Waveform.md) and UI rendering guidance under [09_SwiftUI_Composition.md](./GPT5_UI/GPT5_UI_Files/09_SwiftUI_Composition.md).

# UI3 Implement Offline Waveform Generation and Caching

- [x] Input: Audio files
- [x] Process: Pre-calc waveform previews, cache results.
- [x] Output: Cached waveform previews for efficient scroll.
- [x] Priority: Medium
- [x] Dependencies: P1, FM1
- [x] Acceptance Criteria: Fast list scroll performance, cache size under 5% of disk

# FM1 Setup Catalog Structure in Filesystem

- [x] Input: None
- [x] Process: Create and manage `/Documents/Recordings` directory.
- [x] Output: Directory structure verified.
- [x] Priority: High
- [x] Dependencies: None
- [x] Acceptance Criteria: Proper permissions and backup policy adherence

# FM2 Retrieve File List with Attributes

- [x] Input: Disk contents
- [x] Process: Use FileManager and AVAsset to fetch metadata.
- [x] Output: Array of FileMeta objects.
- [x] Priority: High
- [x] Dependencies: FM1
- [x] Acceptance Criteria: All required attributes present and accurate

# FM3 Implement Copy, Delete, Rename File Operations

- [x] Input: File IDs
- [x] Process: Perform file operations asynchronously.
- [x] Output: Updated file states, new IDs on copy/rename.
- [x] Priority: Medium
- [x] Dependencies: FM2
- [x] Acceptance Criteria: UI remains responsive during operations

# FM4 Query Free Disk Space

- [x] Input: None
- [x] Process: Use URLResourceValues for free space.
- [x] Output: Free disk space in bytes.
- [x] Priority: Low
- [x] Dependencies: FM1
- [x] Acceptance Criteria: Value reflects actual disk state

# BM1 Implement Bookmarks (T-MARK)

- [x] Input: Current playback/record time
- [x] Process: Append bookmark to metadata JSON file.
- [x] Output: Updated bookmarks array.
- [x] Priority: Medium
- [x] Dependencies: P2, FM2
- [x] Acceptance Criteria: Bookmarks visible and selectable in UI

# ST1 Manage Recording Settings Persistence

- [x] Input: UI inputs
- [x] Process: Save and load recording settings with UserDefaults and JSON.
- [x] Output: Persistent RecordingSettings.
- [x] Priority: Medium
- [x] Dependencies: R2
- [x] Acceptance Criteria: Settings applied correctly and persist across sessions

# SEC1 Implement UI Lock Overlay with Gestures and Haptics

- [x] Input: User gesture
- [x] Process: Display lock overlay, block input, unlock with long-press (2s).
- [x] Output: Locked UI state.
- [x] Priority: Medium
- [x] Dependencies: UI1
- [x] Acceptance Criteria: Controls disabled except unlock; unlock via 2s hold; haptic feedback

> UI Lock and Info icon specs can be found in [02_Component_Specs.md - Section A7](./GPT5_UI/GPT5_UI_Files/02_Component_Specs.md#A7-UI-Lock-Info-Icons).

# QA1 Unit Test AudioCore Components

- [x] Input: Unit test cases
- [x] Process: Write XCTest cases covering core functionality.
- [x] Output: Passed unit test suite.
- [x] Priority: High
- [x] Dependencies: Core modules
- [x] Acceptance Criteria: All key code paths covered

# QA2 Basic UI Tests

- [x] Input: UI test cases
- [x] Process: Implement XCUITest for essential UI flows.
- [x] Output: Passed UI test suite.
- [x] Priority: Medium
- [x] Dependencies: UI1
- [x] Acceptance Criteria: Minimum regression coverage

> Unit and UI test plans are outlined in [07_Unit_UI_Test_List.md](./GPT5_UI/GPT5_UI_Files/07_Unit_UI_Test_List.md) and acceptance matrix in [06_Acceptance_Test_Matrix.md](./GPT5_UI/GPT5_UI_Files/06_Acceptance_Test_Matrix.md).

# QA3 Perform Stress and Endurance Tests

- [ ] Input: App, device, mock data
- [ ] Process: Automated and manual testing under load.
- [ ] Output: Stress report with performance and stability data.
- [ ] Priority: High
- [ ] Dependencies: QA1, QA2
- [ ] Acceptance Criteria: Verified stability, error handling, no crashes or data loss under stress conditions

# UI Consistency & Design Polish TODOs (per PRD and Design Comparison)

> These tasks address all visual, accessibility, and interaction discrepancies between the current UI implementation and the original design mockup, as well as compliance with requirements set in 00_Scope_and_Intent.md.

## UI Visual & Functional Consistency

- [ ] **A1. Picker Styling: Input Source (Not Selected)**
    - Input: Current Picker implementation, design spec
    - Process: Replace or restyle the Picker to use a large, centered, underlined blue label when no input is selected; match mockup visual for selected state.
    - Output: Picker matches design (blue, underlined, prominent)
    - Priority: High
    - Effort: 2h
    - Dependencies: UI1
    - Acceptance: Picker is visually and functionally identical to design

- [ ] **A2. Quick Action/Filter Panel Polishing**
    - Input: Current SearchFilterPanel
    - Process: Audit and update icons, backgrounds, and spacing. Ensure pill-shaped backgrounds, bold blue icons/text, and precise spacing per spec.
    - Output: Filter panel matches design visually and functionally
    - Priority: High
    - Effort: 2h
    - Dependencies: UI1
    - Acceptance: Panel visuals and interactions match design; all actions work

- [ ] **A3. Navigation Buttons Row (Home, Back, T-MARK, Options)**
    - Input: Navigation button row code
    - Process: Ensure all buttons use pill backgrounds, blue icons/text, correct order, and size per design. Adjust spacing and font as needed.
    - Output: Navigation row matches design
    - Priority: High
    - Effort: 2h
    - Dependencies: UI1
    - Acceptance: Button appearance, order, and interactions match design

- [ ] **A4. Info Card & Meter Styling**
    - Input: Info card HStack
    - Process: Fine-tune font weights/colors, ensure meter bars show both average and peak, improve ruler/dB label alignment. Visual polish for contrast and spacing.
    - Output: Card visually matches mockup
    - Priority: High
    - Effort: 2h
    - Dependencies: R4, UI1
    - Acceptance: Info card is pixel-perfect vs. mockup

- [ ] **A5. Lock and Info Button Styling**
    - Input: Lock/info button row
    - Process: Adjust icon size/color, spacing, and background to match pill shape and blue highlight in design. Add accessibility/voiceover labels if missing.
    - Output: Row matches design visually and for accessibility
    - Priority: Medium
    - Effort: 1h
    - Dependencies: UI1
    - Acceptance: Lock/info row is visually and functionally identical

- [ ] **A6. Main Controls Polishing**
    - Input: Stop/Record controls
    - Process: Tune icon sizes, boldness, color contrast, and layout. Blinking red indicator should match mockup size/animation. Ensure correct disabling/enabling logic.
    - Output: Main controls match design and spec
    - Priority: High
    - Effort: 1.5h
    - Dependencies: UI1, R3
    - Acceptance: Control visuals and behaviors are per design

- [ ] **A7. File List Section Styling**
    - Input: FileListView and empty state
    - Process: Ensure section title uses bold font; empty state shows appropriate icon and text styling; refresh icon present and blue as per design.
    - Output: File list matches design in all states
    - Priority: Medium
    - Effort: 1h
    - Dependencies: FM2
    - Acceptance: File list visuals match mockup

## Accessibility & Compliance

- [ ] **AA1. Accessibility Audit and Fixes**
    - Input: All UI components
    - Process: Audit VoiceOver labels, ensure minimum contrast ratio 4.5, support Dynamic Type up to XXL, test with accessibility tools.
    - Output: Fully accessible UI, compliant with PRD
    - Priority: High
    - Effort: 2h
    - Dependencies: All UI tasks
    - Acceptance: All controls are labeled; contrast and scaling pass tests

## Test Coverage & Verification

- [ ] **T1. Automated Snapshot Test Coverage**
    - Input: All main UI states (Ready, Recording, Playing, Empty List, File Selected)
    - Process: Implement/expand snapshot tests for each state (light/dark mode, accessibility sizes)
    - Output: Snapshot test suite covers all visual states
    - Priority: High
    - Effort: 2h
    - Dependencies: UI1, QA2
    - Acceptance: Tests pass, all visuals match design

---

> All tasks must follow the metadata and quality rules outlined in 00_Scope_and_Intent.md. This section should be kept updated as progress is made and new gaps are discovered.
