# 1. Global Contracts for all Components

## 1.1 Data Models Protocols for DI

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

## 1.2 Events & Messaging

 - UI → Engine: user intents (record, pause, play, stop, seek, mark, set A/B, set DPC).
 - Engine → UI: RecordingState, MeterLevels, TimelineState publishers (Combine) or async streams, ≥20 Hz for meters/waveform.

## 1.3 Common Visual/UX Rules

 - Haptics: light on button taps; success on T-MARK; warning on AB invalid.
 - Disabled states show 40% opacity; pressed state scales 0.96.
 - Error banner (top, 3s) for engine errors.
 - Lock mode disables controls except unlock gesture (long-press 1s).
