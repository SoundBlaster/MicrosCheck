# 0) Scope & Intent

**Goal.** Turn the SwiftUI template + this spec into **real, testable UI components** driven by models (no hardcoded demo).  
**Success criteria.**

- All A1…A7 features compile & run on iOS 16+.
- Visual meters + waveform update ≥ 20 Hz; UI latency (mic → meter) ≤ 100 ms.
- AB loop accuracy ≤ ±20 ms; bookmark (T-MARK) precision ≤ ±50 ms.
- Background recording energy ≤ 5%/hour (observational).
- Accessibility: VoiceOver labels for all controls; contrast ≥ 4.5; Dynamic Type L–XXL.
- Snapshot tests for main states; basic instrumentation for FPS and update cadence.

**Assumptions.**

- MVVM with unidirectional data flow; `@MainActor` UI; audio pipe is mocked for tests.
- App uses `AVAudioSession`/`AVAudioRecorder` (or your engine) behind a protocol.
- Telemetry is optional and stubbed behind a protocol.
