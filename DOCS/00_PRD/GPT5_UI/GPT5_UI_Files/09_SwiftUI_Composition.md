# 9. SwiftUI Composition

```
RecorderScreen
 ├─ A1WaveformTimelineView
 ├─ A2RecordingInfoPanel
 ├─ A3NavActionsBar
 ├─ A4SearchFilterBar
 ├─ A5TransportBar
 ├─ A6CircularPad
 └─ A7CornerButtons
```

Each view takes immutable props + callbacks.
The `ViewModel` adapts `RecordingEngine` to props and binds outputs.