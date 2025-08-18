# 1) Global Contracts (for all components)

## 1.1 Data Models (protocols for DI)
```swift
// Threading: all callbacks deliver on main unless stated.
public protocol RecordingEngine {
    var state: RecordingState { get }
    var meters: MeterLevels { get }
    var timeline: TimelineState { get }
    func startRecording(format: AudioFormat)
    func pauseRecording()
    func resumeRecording()
    func stopRecording() -> URL?
    func addMark()
    func seek(to: TimeInterval)
    func setABLoop(start: TimeInterval?, end: TimeInterval?)
    func setDPC(rate: Float)
}
...
```

## 1.2 Events & Messaging
- UI → Engine: user intents (record, pause, play, stop, seek, mark, set A/B, set DPC).
- Engine → UI: `RecordingState`, `MeterLevels`, `TimelineState` publishers (Combine) or async streams, **≥20 Hz** for meters/waveform.

## 1.3 Common Visual/UX Rules
- Haptics, disabled states, error banner, lock mode, etc.
