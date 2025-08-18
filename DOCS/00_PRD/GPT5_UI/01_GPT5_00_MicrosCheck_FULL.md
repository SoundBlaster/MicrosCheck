# UI Spec Pack → SwiftUI Coding (Execution-Ready)

Below is a self-contained, machine-readable spec for your annotated screens (A1…A7).
For each component you get: concise description, inputs/outputs (data & events), states, interactions, a11y, analytics, acceptance criteria, and test scenarios.
At the end: global architecture, contracts, and a dependency-aware TODO.

⸻

## 0) Scope & Intent

Goal. Turn the SwiftUI template + this spec into real, testable UI components driven by models (no hardcoded demo).
Success criteria.
	•	All A1…A7 features compile & run on iOS 16+.
	•	Visual meters + waveform update ≥ 20 Hz; UI latency (mic → meter) ≤ 100 ms.
	•	AB loop accuracy ≤ ±20 ms; bookmark (T-MARK) precision ≤ ±50 ms.
	•	Background recording energy ≤ 5%/hour (observational).
	•	Accessibility: VoiceOver labels for all controls; contrast ≥ 4.5; Dynamic Type L–XXL.
	•	Snapshot tests for main states; basic instrumentation for FPS and update cadence.

Assumptions.
	•	MVVM with unidirectional data flow; @MainActor UI; audio pipe is mocked for tests.
	•	App uses AVAudioSession/AVAudioRecorder (or your engine) behind a protocol.
	•	Telemetry is optional and stubbed behind a protocol.

⸻

## 1) Global Contracts (for all components)

### 1.1 Data Models (protocols for DI)

```swift 
// Threading: all callbacks deliver on main unless stated.
public protocol RecordingEngine {
    var state: RecordingState { get }
    var meters: MeterLevels { get }                 // fast-updating L/R
    var timeline: TimelineState { get }             // position/duration/playhead
    func startRecording(format: AudioFormat)
    func pauseRecording()
    func resumeRecording()
    func stopRecording() -> URL?
    func addMark()
    func seek(to: TimeInterval)
    func setABLoop(start: TimeInterval?, end: TimeInterval?)
    func setDPC(rate: Float) // 0.5…2.0
}

public struct RecordingState: Equatable {
    public enum Mode { case idle, recording, paused, playing }
    public var mode: Mode
    public var fileName: String?
    public var fileSizeBytes: Int64
    public var format: AudioFormat // e.g., mp3 320kbps
    public var startedAt: Date?
}

public struct MeterLevels: Equatable {
    public var leftDB: Float // -60…0
    public var rightDB: Float
}

public struct TimelineState: Equatable {
    public var current: TimeInterval     // seconds
    public var duration: TimeInterval
}

public struct AudioFormat: Equatable {
    public var container: String // "MP3"
    public var bitrateKbps: Int
}
```

### 1.2 Events & Messaging

	•	UI → Engine: user intents (record, pause, play, stop, seek, mark, set A/B, set DPC).
	•	Engine → UI: RecordingState, MeterLevels, TimelineState publishers (Combine) or async streams, ≥20 Hz for meters/waveform.

### 1.3 Common Visual/UX Rules

	•	Haptics: light on button taps; success on T-MARK; warning on AB invalid.
	•	Disabled states show 40% opacity; pressed state scales 0.96.
	•	Error banner (top, 3s) for engine errors.
	•	Lock mode disables controls except unlock gesture (long-press 1s).

⸻

## 2) Component Specs

Notation: Inputs (data props), Outputs (callbacks/closures), States (internal), AC (acceptance criteria).

### A1 Top Waveform & Timeline

#### A1a Live Waveform Visualization

	•	Inputs: TimelineState, streaming Float arrays (RMS/peak) or image slices; isRecording: Bool.
	•	Outputs: none.
	•	States: scroll‐free fixed viewport with moving playhead; 60 FPS preferred; decimation for long durations.
	•	Interactions: pinch to zoom disabled (v1); horizontal drag to seek off (handled by scrubber below if added later).
	•	A11y: decorative; VoiceOver label “Waveform”.
	•	AC:
	•	Updates ≥ 20 Hz while recording; playhead drift ≤ 1 frame @60 FPS (≈16 ms).
	•	No dropped frames for 30-min session on mid-range device.
	•	Tests: snapshot (dark/light), performance test measuring update cadence, long-duration memory profile (no unbounded arrays).

#### A1b Vertical Decibel Level Ruler

	•	Inputs: min/max dB (-60…0), tick step (10 dB).
	•	AC: tick labels readable at L–XL Dynamic Type; ruler aligns with meter bars.

#### A1c Time Ruler H-M-S

	•	Inputs: TimelineState, grid step (5s default).
	•	AC: tick at 0 aligns with start; current time label matches playhead ±50 ms.

⸻

### A2 Recording Information Panel

#### A2a1 Current Recording Duration

	•	Inputs: TimelineState.current, engine mode.
	•	AC: format Hh M m S s (e.g., 1h07m26s); updates every second; paused stops incrementing.

#### A2a2 Elapsed Size Indicator
	
	•	Inputs: RecordingState.fileSizeBytes; bitrate (optional).
	•	AC: updates ≤ 2 s cadence; suffix MB; rounding to 0.1 MB.

#### A2a3 Audio Format Badge
	
	•	Inputs: AudioFormat.
	•	AC: string “MP3 • 320Kbps”.

#### A2b1 File Name
	
	•	Inputs: RecordingState.fileName.
	•	AC: truncates middle; copy on long-press (toast).

#### A2b2 File Size Indicator
	
	•	Inputs: same as A2a2 when not recording (final size).
	•	AC: matches actual file on disk ±1%.

#### A2b3 L/R Audio Meters
	
	•	Inputs: MeterLevels.
	•	AC:
	•	Update ≥ 20 Hz; peak hold decay 1.5 dB/s; clip indicator at ≥-1 dB for ≥ 100 ms.
	•	Left/right labeled for VoiceOver.

#### Tests

- UI snapshot
- meter animation cadence test (synthetic sine at -12 dB)
- copying file name long-press

⸻

### A3 Navigation & Action Buttons

#### A3a BACK

	•	Outputs: onBack().
	•	AC: disabled when modal not dismissible.

#### A3b HOME

	•	Outputs: onHome().
	•	AC: asks to stop/confirm if recording active.

#### A3c T-MARK

	•	Outputs: engine.addMark().
	•	AC: places mark at current time with precision ≤ ±50 ms; haptic success; toast “Mark added”.

#### A3d OPTION

	•	Outputs: onOptions() (opens settings sheet).
	•	AC: sheet covers 60% height; preserves recording.

#### Tests

- mark placement accuracy with simulated clock skew
- confirm dialog when recording.

⸻

### A4 Search & Filter Controls Panel

#### A4a Search Field
	•	Inputs: bound text, debounce 300 ms.
	•	Outputs: onSearch(query).
	•	AC: return key = search; clear button resets list.

#### A4b Brightness / Theme Toggle (stub)
	•	Outputs: onToggleTheme().
	•	AC: persists in user defaults; respects system setting by default.

#### A4c Favorites Filter
	•	Outputs: onToggleFavorites().
	•	AC: icon filled on active; announces via VoiceOver “Favorites on/off”.

#### A4d Waveform Density (stub)
	•	Outputs: onWaveformDensity(step).
	•	AC: 3 presets; redraw ≤ 50 ms.

#### Tests

- search debounce unit test
- toggle persistence.

⸻

### A5 Transport Controls

#### A5a STOP (large square)
	•	Outputs: engine.stopRecording() (or stop playback).
	•	AC: when recording, commit file; when playing, return to start.

#### A5b REC/PAUSE (large circle)
	•	Outputs: toggles record/pause/resume.
	•	AC:
	•	Pressing from idle → starts recording within ≤ 200 ms; mic permission flow handled once.
	•	From recording → pauses within 100 ms; from paused → resumes ≤ 100 ms.
	•	Visual states: idle (hollow), recording (solid red), paused (two bars).

#### A5c RECORDING indicator (text + LED)
	•	Inputs: RecordingState.mode.
	•	AC: blinks 0.8 s period when recording; steady when paused.

#### Tests

- state transitions
- permission denial path
- stop saves file (mocked).

⸻

### A6 Central Circular Playback Control

#### A6a Center Play/Pause Button
	•	Outputs: play/pause current file via engine.
	•	AC: icon reflects state; play latency ≤ 150 ms.

#### A6b Left Segment «⏮ / -5s»
	•	Outputs: seek back fixed step (default 5 s).
	•	AC: if A-B active & before A → snap to A.

#### A6c Right Segment «⏭ / +5s»
	•	Outputs: seek forward 5 s.
	•	AC: if A-B active & beyond B → snap to B.

#### A6d Bottom Segment A-B
	•	Outputs: first tap sets A at current; second tap sets B; third tap clears A-B.
	•	AC:
	•	A before B enforced; if B < A → swap with warning haptic.
	•	Loop playback stays inside [A,B] with boundary tolerance ≤ ±20 ms; no pops/clicks.

#### A6e Top Segment DPC (speed)

Inputs:

- rate: Float;

Outputs:

- engine.setDPC(rate).

AC:

- stepping 1.0→1.25→1.5→1.75→2.0→0.75→0.5→1.0 (cyclic)
- label updates
- pitch correction on (engine)

Tests:

- AB logic table tests
- loop stability under scrub
- DPC cycling persistence.

⸻

### A7 UI Lock & Info Icons

#### A7a Lock (bottom-left)

Outputs:

- toggles `isLocked`

AC:

- Long-press 1s to unlock (to avoid accidental) when locked
- all interactive controls ignore taps except lock
- Visual overlay “Locked” 800ms on engage

#### A7b Info (bottom-right)

Outputs:

- onInfo() — show help sheet

AC:

- accessible label “Info”

Tests:

- lock prevents all hot areas 
- unlock long-press gesture recognizer unit test.

⸻

## 3) Cross-Cutting: Error & Edge Cases

•	Mic permission denied → disable REC with tooltip; pressing shows system prompt once, then app sheet.
•	Disk full → stop recording with error banner; partial file preserved if format allows.
•	Route change (headphones unplug) → continue recording; if playing, pause with banner.
•	Background: continuing recording; pausing playback; lock UI persists.

⸻

## 4) Accessibility (global)

•	Labels/hints for every button; traits (.button, .selected).
•	Dynamic Type up to XXL without truncating critical labels; marquee for long file names.
•	Hit targets ≥ 44×44 pt; circular pad segments each ≥ 48° arc and ≥ 56 pt height.
•	Color: meets 4.5:1 contrast; red/green not the only carriers (use shapes/state).

⸻

## 5) Analytics (optional, stubbed)

Events:

- rec_start
- rec_pause
- rec_resume
- rec_stop
- mark_add
- ab_set
- ab_clear
- seek
- dpc_change
- lock_toggle.

Payloads:

- timestamp
- position
- rate
- file id.

⸻

## 6) Acceptance Test Matrix (Core)

ID	Scenario	Steps	Expected
T01	Start recording	Idle → tap REC	State=recording ≤200ms; timer runs; meters animate
T02	Pause/resume	Recording → tap REC → tap REC	Modes: paused ≤100ms → recording ≤100ms
T03	Stop saves file	Recording → tap STOP	State=idle; file URL non-nil; size increases then finalizes
T04	T-MARK accuracy	While recording, press T-MARK	Mark time within ±50ms of current; haptic success
T05	AB loop	Play file; tap A; after ~3s tap B	Playback loops inside [A,B]; boundary ≤ ±20ms
T06	DPC cycle	Tap DPC repeatedly	Rates follow cycle; playback continues without artifacts
T07	Lock UI	Enable lock	All controls inert except lock; long-press 1s unlocks
T08	Meters cadence	Record 30 min	Update ≥20Hz; no UI freezes; peak hold behavior valid
T09	Route change	Playing → unplug headphones	Playback pauses; banner shown; recording unaffected
T10	Permission denied	No mic permission → tap REC	System prompt first time; then inline sheet; REC disabled


⸻

## 7) Unit/UI Test List (by component)

•	A1 Waveform: decimator unit test; timeline alignment; memory growth < 2 MB over 30 min (mock stream).
•	A2 Meters: level→bar mapping; clip indicator timing.
•	A3 T-MARK: debounce (≥150 ms) prevents double marks.
•	A5 States: state machine transitions (idle↔recording↔paused) property tests.
•	A6 AB: state table (A=nil/B=nil, A set, B set, invalid order) + fast seek edges.
•	A7 Lock: gesture minimum duration; exclusion zones.

UI (XCTest + ViewInspector/Snapshot): dark/light, localization en/ru, Dynamic Type L/XXL.

⸻

## 8) Missing/Supporting Pieces (add now)

•	Settings Sheet (from OPTION):
•	Recording format presets; pre-roll toggle; DPC cycle list; theme (system/light/dark).
•	Error Banner/Toast component (reusable).
•	Permission Explainer Sheet (post-denial).
•	Theming tokens (spacing, radius, typography).
•	Haptics service, Analytics service protocols.
•	Preview Providers with deterministic mocks & fixtures (golden levels/wave chunks).
•	Localization infrastructure.

⸻

## 9) SwiftUI Composition (suggested)

RecorderScreen
 ├─ A1WaveformTimelineView
 ├─ A2RecordingInfoPanel
 ├─ A3NavActionsBar
 ├─ A4SearchFilterBar
 ├─ A5TransportBar
 ├─ A6CircularPad
 └─ A7CornerButtons

Each view takes immutable props + callbacks; the ViewModel adapts RecordingEngine to props and binds outputs.

⸻

## 10) Developer TODO (Dependency-Aware)

ID	Task	Input/Output	Priority	Effort
P0	Define protocols & models (Sec.1)	Swift files + mocks	High	0.5d
P1	RecordingViewModel (state reducer)	Engine→Props mapping; actions→engine	High	1d
P2	A2 meters component	MeterLevels→bars; clip	High	0.5d
P3	A1 waveform renderer	stream→layer; timeline overlay	High	1.5d
P4	A5 transport	stop/rec/pause UI	High	0.5d
P5	A6 circular pad	play/seek/AB/DPC	High	1d
P6	A3 nav actions	back/home/mark/options	Medium	0.5d
P7	A7 lock/info	lock gate + help sheet	Medium	0.5d
P8	A4 search/filter	search field + toggles	Medium	0.5d
P9	Error/Toast component	reusable banner	Medium	0.5d
P10	Settings sheet	minimal options	Medium	0.5d
P11	Accessibility pass	labels, traits, Dynamic Type	High	0.5d
P12	Snapshot tests	key states per view	High	0.75d
P13	Performance tests	meter cadence, AB tolerance	High	0.75d
P14	Localization en/ru	strings + tests	Low	0.5d

Dependencies:
	•	P1 depends on P0.
	•	P3 depends on P0, P1 (timeline).
	•	P5 depends on P1 (actions & timeline).
	•	Test tasks (P12–P13) depend on corresponding views.

⸻

## 11) Acceptance Checklist (turn-in to LLM agent)

	•	Implement protocols + mocks (Sec.1).
	•	Compose RecorderScreen with all A1…A7 views.
	•	Wire ViewModel intents to RecordingEngine.
	•	Meet update/latency targets; log measured metrics.
	•	Ship tests from Sections 6–7; CI run green.
	•	A11y verified with VoiceOver on device.
	•	Dark/Light snapshots match.

⸻

## 12) Hand-off Notes for the Coding Agent

	•	Use SwiftUI + Combine, minimum iOS 16.
	•	Keep heavy rendering (A1) in a CALayer/Metal-backed view if needed, but expose a SwiftUI wrapper.
	•	No blocking work on the main thread; schedule engine callbacks on main.
	•	Provide Preview mocks for: idle, recording (-12 dB), paused, playing, long file (≥ 1h), AB active.
	•	Every public view has a Props struct + Callbacks struct to make it LLM-friendly.