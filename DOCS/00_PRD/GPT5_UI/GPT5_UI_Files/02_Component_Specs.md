# 2. Component Specs

Notation:
- **Inputs** – data properties supplied by ViewModel.
- **Outputs** – UI events and control callbacks.
- **States** – internal component states not exposed externally.
- **AC** – acceptance criteria defining success.
- **A11y** – accessibility guidelines and implementations.
- **Tests** – required test cases and validation strategies.

## A1 Top Waveform & Timeline

### A1a Live Waveform Visualization

Inputs:
- TimelineState (current position, duration)
- Streamed RMS or peak float arrays or image slices at ≥ 20 Hz update rate.
- isRecording flag indicating active capture state.

Outputs:
- None; purely visual.

States:
- Fixed-width viewport that scrolls visually by updating playhead position.
- Target frame rate 60 FPS preferred; decimate waveform data if duration exceeds threshold.
- Playhead drift from audio stream must not exceed 16 ms (1 frame at 60 FPS).

Interactions:
- Pinch-to-zoom disabled in v1 frontend implementation.
- Horizontal dragging for seek is disabled; this will be handled by a separate scrubber control.

A11y:
- Marked decorative with .accessibilityHidden(true).
- VoiceOver provides a descriptive label "Audio waveform display" to support screen reader context.

AC:
- Visual waveform updates at minimum 20 Hz during recording and playback.
- Playhead position aligns with TimelineState current within ≤ 16 ms tolerance.
- No dropped frames over continuous 30-minute test session on mid-range iOS devices.

Tests:
- Snapshot tests in both dark and light modes across Dynamic Type sizes.
- Performance tests verifying update cadence rate under load.
- Memory profiling tests validating no unbounded accumulation of waveform data.

### A1b Vertical Decibel Level Ruler

Inputs:
- Decibel range min/max (typically -60 to 0 dB).
- Tick step increments (default 10 dB).

AC:
- Label ticks must remain readable across Dynamic Type L–XL font sizes.
- Ruler's vertical alignment matches precisely with the audio meter bars for consistent UX.
- Contrast ratio meets accessibility minimum 4.5:1 color contrast.

### A1c Time Ruler H-M-S

Inputs:
- TimelineState providing current time and duration.
- Grid step duration (default 5 seconds for major tick marks).

AC:
- Major grid tick aligns precisely with time 0 of TimelineState.
- Current time label displayed adjacent to playhead position within ±50 milliseconds accuracy.
- Tick labels update dynamically as TimelineState progresses, ensuring alignment.

⸻

## A2 Recording Information Panel

### A2a1 Current Recording Duration

Inputs:
- TimelineState.current timestamp.
- Current RecordingState.mode to know if paused or recording.

AC:
- Duration displays in format HHh MMm SSs, e.g., \"1h07m26s\".
- Updates precisely once per second when recording.
- When paused, the duration display freezes and stops incrementing.
- Accessibility announces changes at the one-second boundary clearly.

### A2a2 Elapsed Size Indicator

Inputs:
- RecordingState.fileSizeBytes for current size.
- Optional bitrate value for calculating approximate size increments.

AC:
- Displays file size in megabytes with suffix \"MB\".
- Updates at a cadence of no more than once every 2 seconds to avoid UI overhead.
- Numeric value rounds to one decimal place (e.g., 3.4 MB).
- Approximations verified within 5% of actual file size on disk.

### A2a3 Audio Format Badge

Inputs:
- AudioFormat structure with container format and bitrate.

AC:
- Displays string formatted as \"MP3 • 320Kbps\" or equivalent.
- Updates dynamically if format changes mid-session (unlikely but handled).

### A2b1 File Name

Inputs:
- RecordingState.fileName string.

AC:
- File name truncates the middle section when too long to fit.
- Long-press gesture copies the full file name to clipboard and shows an ephemeral toast confirmation.
- VoiceOver announces file name fully on focus and on copy confirmation.
- Copy gesture debounced to prevent rapid repeated copies.

### A2b2 File Size Indicator

Inputs:
- File size displayed outside recording sessions, matching final size.

AC:
- Matches file size on disk to within ±1% accuracy.
- Information updates after file is fully committed by the engine.

### A2b3 L/R Audio Meters

Inputs:
- MeterLevels structure containing left and right channel dB levels.

AC:
- Audio meters update at minimum 20 Hz frequency to reflect real-time levels.
- Peak hold decay rate implemented at 1.5 dB per second.
- Clip indicator triggers visibly when signal exceeds -1 dB for 100 ms or longer.
- Clip indicator animation fades out over 0.3 seconds.
- Clip status resets after silence period.

A11y:
- Meters labeled "Left channel level" and "Right channel level" for VoiceOver.
- VoiceOver announces channel peak and clip status changes at least once per second.

Tests:
- UI snapshot tests for various level inputs.
- Meter animation cadence validation using synthetic sine wave at -12 dB.
- Verify copy-to-clipboard action on file name long press triggers toast and accessibility announcement.

⸻

## A3 Navigation & Action Buttons

### A3a BACK

Outputs:
- onBack()

AC:
- The back button is disabled if the current modal or screen cannot be dismissed.
- Button state updates reactively with presentation context.

### A3b HOME
Outputs:
- onHome()

AC:
- Triggers confirmation dialog if recording is in progress to prevent data loss.
- Confirmation dialogs comply with accessibility and focus management guidelines.

### A3c T-MARK

Outputs:
- engine.addMark()

AC:
- Adds a timestamped mark at the video/audio playback or recording current time.
- Precision of mark placement guaranteed within ±50 milliseconds.
- Emits haptic success feedback on mark placement.
- Displays toast message \"Mark added\" for 2 seconds.
- Handles debounce logic to prevent multiple marks within 150 milliseconds.

### A3d OPTION

Outputs:
- onOptions() – opens settings or configuration sheet.

AC:
- Settings sheet covers approximately 60% of the vertical screen height on presentation.
- When opened during recording, recording process is preserved without interruption.
- Settings changes are persisted and applied asynchronously.

Tests:
- Unit test mark precision with simulated clock skew.
- E2E tests confirm dialogs appear on active recording.
- Visual and accessibility tests for option sheet layout.

⸻

## A4 Search & Filter Controls Panel

### A4a Search Field

Inputs:
- Bound `String` text state passed from parent component.
- Internal debounce period set to 300 milliseconds to limit processing rate.

Outputs:
- onSearch(query: String) callback fired on user submission or debounce expiry.

AC:
- Pressing enter/return triggers search immediately.
- Clear button resets the search field and fires empty query event.
- Search field is accessible with proper VoiceOver label and hints.
- Debounce reduces excessive queries while maintaining responsiveness.

### A4b Brightness / Theme Toggle (stub)

Outputs:
- onToggleTheme() callback to request theme mode change.

AC:
- Toggle is persisted in user defaults or external settings store.
- System default theme respected if user has not explicitly overridden.
- UI updates immediately to reflect new theme.

### A4c Favorites Filter

Outputs:
- onToggleFavorites() callback toggles favorites filter state.

AC:
- Icon displays filled style when active and outlined when inactive.
- VoiceOver announces current favorites filter state as \"Favorites on\" or \"Favorites off\".
- Toggle action triggers filter refresh asynchronously.

### A4d Waveform Density (stub)

Outputs:
- onWaveformDensity(step: Int) callback to adjust waveform rendering density.

AC:
- Supports three preset density values for user selection.
- UI redraw latency does not exceed 50 milliseconds on preset change.
- Persistence of selection implemented for session or longer.

Tests:
- Unit tests for debounce logic on search input.
- Persistence and behavior tests for theme toggle.
- Accessibility validations for filter toggle controls.

⸻

## A5 Transport Controls

### A5a STOP (large square button)

Outputs:
- Calls engine.stopRecording() or stops playback.

AC:
- When pressed during recording, recording stops and the file is committed.
- When pressed during playback, playback is stopped, and the timeline resets to the start.
- Disabled state reflects current engine status (e.g., disabled idle or paused).

### A5b REC/PAUSE (large circular toggle button)

Outputs:
- Toggles between record, pause, and resume states.

AC:
- Pressing REC from idle state initiates recording start within 200 milliseconds.
- Handles microphone permission flow by prompting once per session.
- Pressing REC while recording pauses within 100 milliseconds.
- Pressing REC while paused resumes recording within 100 milliseconds.

Visual States:
- Idle: hollow circular border.
- Recording: filled solid red circle.
- Paused: icon showing two vertical pause bars.

### A5c RECORDING Indicator (text + LED dot)

Inputs:
- RecordingState.mode.

AC:
- LED blinks rhythmically with 0.8-second period during recording.
- LED shows steady illumination when recording is paused.
- Text label updates to reflect current recording state ("Recording", "Paused", or hidden).
- Accessibility notifications announce recording mode change.

Tests:
- Verify state machine transitions between idle, recording, and paused states.
- Test microphone permission denial paths with appropriate UI feedback.
- Confirm that pressing Stop commits file correctly in mock mode.

⸻

## A6 Central Circular Playback Control

### A6a Center Play/Pause Button

Outputs:
- Triggers play/pause on current playback file using engine interface.

AC:
- Play/pause icon updates immediately to reflect playing or paused state.
- Latency between tap and play start does not exceed 150 milliseconds.
- Button disables interaction briefly during state transitions to prevent rapid toggling.

### A6b Left Segment «⏮ / -5s»

Outputs:
- Seeks playback backward by a fixed 5-second step or configurable value.

AC:
- When A-B looping is active and current playback is before point A, seek snaps to A mark.
- Single tap trigger per user event ensured via debouncing.

### A6c Right Segment «⏭ / +5s»

Outputs:
- Seeks playback forward by fixed 5 seconds or configured step.

AC:
- When A-B loop active and position is beyond point B, seek snaps forward to point B.
- Debounce protects against multiple rapid invocations.

### A6d Bottom Segment A-B Looping Controls

Outputs:
- First tap sets loop start point A at current playback position.
- Second tap sets loop end point B.
- Third tap clears the A-B loop.

AC:
- Enforce A < B ordering; if B set before A, automatically swap with haptic warning.
- Playback loops strictly inside [A, B] region with boundary tolerance ≤ ±20 milliseconds.
- Looping is seamless without audible pops or clicks at boundaries.
- User feedback via haptics and UI highlights.

### A6e Top Segment DPC (Dynamic Playback Control) Speed Selector

Inputs:
- Current playback rate as Float.

Outputs:
- Calls engine.setDPC(rate) with chosen playback speed.

AC:
- Playback speeds cycle through sequence: 1.0 → 1.25 → 1.5 → 1.75 → 2.0 → 0.75 → 0.5 → 1.0.
- Label updates promptly to reflect current speed.
- Engine applies pitch correction to maintain audio fidelity.
- User can rely on persistent playback speed across sessions.

Tests:
- Validate all states in A-B loop state management table.
- Stress test loop stability under scrubbing and rapid seeking.
- Verify DPC speed cycling persistence and correctness.

⸻

## A7 UI Lock & Info Icons

### A7a Lock (bottom-left button)

Outputs:
- Toggles boolean `isLocked` state in UI.

AC:
- Lock engaged state disables interaction on all controls except the lock button to prevent accidental input.
- Unlock requires a long-press gesture of minimum 1 second to confirm user intent and avoid accidental unlock.
- Visual overlay with text \"Locked\" appears for 800 milliseconds upon lock engagement.
- Lock state persists across app state changes during the session.
- VoiceOver announces lock state changes clearly for accessibility.

### A7b Info (bottom-right button)

Outputs:
- onInfo() callback to display contextual help sheet or modal.

AC:
- Button is fully accessible with label \"Info\".
- Info sheet complies with accessibility, theming, and size standards.
- Ensures focus management on modal presentation and dismissal.

Tests:
- Validate that lock disables all other tap areas effectively.
- Unit test the unlock long-press gesture duration and recognition.
- Accessibility checks for Info button label and modal.

