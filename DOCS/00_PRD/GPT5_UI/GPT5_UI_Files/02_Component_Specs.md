# 2. Component Specs

Notation:
- **Inputs** – data props
- **Outputs** – callbacks/closures
- **States** – internal
- **AC** – acceptance criteria
- **A11y** – Voice Over, accessibility
- **Tests** – Test Cases and Plans

## A1 Top Waveform & Timeline

### A1a Live Waveform Visualization

Inputs:
- TimelineState
- streaming Float arrays (RMS/peak) or image slices
- isRecording: Bool

Outputs:
- none.

States:
- scroll‐free fixed viewport with moving playhead
- 60 FPS preferred
- decimation for long durations

Interactions:
- pinch to zoom disabled (v1)
- horizontal drag to seek off (handled by scrubber below if added later)

A11y:
- decorative
- VoiceOver label “Waveform”

AC:
- Updates ≥ 20 Hz while recording; playhead drift ≤ 1 frame @60 FPS (≈16 ms).
- No dropped frames for 30-min session on mid-range device.

Tests:
- snapshot (dark/light)
- performance test measuring update cadence
- long-duration memory profile (no unbounded arrays)

### A1b Vertical Decibel Level Ruler

Inputs:
- min/max dB (-60…0)
- tick step (10 dB)

AC:
- tick labels readable at L–XL Dynamic Type
- ruler aligns with meter bars

### A1c Time Ruler H-M-S

Inputs:
- TimelineState
- grid step (5s default)

AC:
- tick at 0 aligns with start
- current time label matches playhead ±50 ms

⸻

## A2 Recording Information Panel

### A2a1 Current Recording Duration

Inputs:
- TimelineState.current
- engine mode

AC:
- format Hh M m S s (e.g., 1h07m26s)
- updates every second
- paused stops incrementing

### A2a2 Elapsed Size Indicator

Inputs:
- RecordingState.fileSizeBytes
- bitrate (optional)

AC:
- updates ≤ 2 s cadence
- suffix MB
- rounding to 0.1 MB

### A2a3 Audio Format Badge

Inputs:
- AudioFormat

AC:
- string “MP3 • 320Kbps”

### A2b1 File Name

Inputs:
- RecordingState.fileName

AC:
- truncates middle
- copy on long-press (toast)

### A2b2 File Size Indicator

Inputs:
- same as A2a2 when not recording (final size)

AC:
- matches actual file on disk ±1%

### A2b3 L/R Audio Meters

Inputs:
- MeterLevels

AC:
- Update ≥ 20 Hz
- peak hold decay 1.5 dB/s
- clip indicator at ≥-1 dB for ≥ 100 ms

A11y:
- Left/right labeled for VoiceOver

Tests:
- UI snapshot
- meter animation cadence test (synthetic sine at -12 dB)
- copying file name long-press

⸻

## A3 Navigation & Action Buttons

### A3a BACK

Outputs:
- onBack()

AC:
- disabled when modal not dismissible

### A3b HOME

Outputs:
- onHome()

AC:
- asks to stop/confirm if recording active

### A3c T-MARK

Outputs:
- engine.addMark()

AC:
- places mark at current time with precision ≤ ±50 ms
- haptic success
- toast “Mark added”

### A3d OPTION

Outputs:
- onOptions() – opens settings sheet

AC:
- sheet covers 60% height
- preserves recording

Tests:
- mark placement accuracy with simulated clock skew
- confirm dialog when recording.

⸻

## A4 Search & Filter Controls Panel

### A4a Search Field

Inputs:
- bound text
- debounce 300 ms

Outputs:
- onSearch(query)

AC:
- return key = search
- clear button resets list

### A4b Brightness / Theme Toggle (stub)

Outputs:
- onToggleTheme()

AC:
- persists in user defaults
- respects system setting by default.

### A4c Favorites Filter

Outputs:
- onToggleFavorites()

AC:
- icon filled on active
- announces via VoiceOver “Favorites on/off”

### A4d Waveform Density (stub)

Outputs:
- onWaveformDensity(step)

AC:
- 3 presets
- redraw ≤ 50 ms

Tests:
- search debounce unit test
- toggle persistence.

⸻

## A5 Transport Controls

### A5a STOP (large square)

Outputs:
- engine.stopRecording() (or stop playback)

AC:
- when recording
- commit file
- when playing, return to start

### A5b REC/PAUSE (large circle)

Outputs
- toggles record/pause/resume

AC:
- Pressing from idle → starts recording within ≤ 200 ms
- mic permission flow handled once
- From recording → pauses within 100 ms
- from paused → resumes ≤ 100 ms

States: visuals
- idle (hollow)
- recording (solid red)
- paused (two bars)

### A5c RECORDING indicator (text + LED)

Inputs:
- RecordingState.mode

AC:
- blinks 0.8 s period when recording
- steady when paused

Tests:
- state transitions
- permission denial path
- stop saves file (mocked)

⸻

## A6 Central Circular Playback Control

### A6a Center Play/Pause Button

Outputs
- play/pause current file via engine

AC:
- icon reflects state
- play latency ≤ 150 ms

### A6b Left Segment «⏮ / -5s»

Outputs:
- seek back fixed step (default 5 s)

AC:
- if A-B active & before A → snap to A

### A6c Right Segment «⏭ / +5s»

Outputs:
- seek forward 5 s

AC:
- if A-B active & beyond B → snap to B

### A6d Bottom Segment A-B

Outputs:
- first tap sets A at current
- second tap sets B
- third tap clears A-B

AC:
- A before B enforced
- if B < A → swap with warning haptic
- Loop playback stays inside [A,B] with boundary tolerance ≤ ±20 ms
- no pops/clicks

### A6e Top Segment DPC (speed)

Inputs:
- rate: Float

Outputs:
- engine.setDPC(rate)

AC:
- stepping 1.0→1.25→1.5→1.75→2.0→0.75→0.5→1.0 (cyclic)
- label updates
- pitch correction on (engine)

Tests:
- AB logic table tests
- loop stability under scrub
- DPC cycling persistence.

⸻

## A7 UI Lock & Info Icons

### A7a Lock (bottom-left)

Outputs:
- toggles `isLocked`

AC:
- Long-press 1s to unlock (to avoid accidental) when locked
- all interactive controls ignore taps except lock
- Visual overlay “Locked” 800ms on engage

### A7b Info (bottom-right)

Outputs:
- onInfo() — show help sheet

AC:
- accessible label “Info”

Tests:
- lock prevents all hot areas
- unlock long-press gesture recognizer unit test.
