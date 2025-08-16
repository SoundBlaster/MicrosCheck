# 2. Architecture (High Level)

## Layers

- **UI (SwiftUI)** — screens and controls, strictly following the design.
- **ViewModels (ObservableObject)** — state, event routing, debounce/timers.
- **AudioCore** — unified engine on `AVAudioEngine`:
  - **RecordPipeline:** input → format → file writer → metering tap.
  - **PlayPipeline:** file → playerNode → timePitch → stereo mixer → output; post-mix meters.
- **Persistence** — `FileManager` + associated JSON metadata (`Codable`) + `UserDefaults` for settings.
- **Services** — Permissions, Background, Haptics, AppStateLock, WaveformCache.
- **Routing** — simple enum-router/Sheet (within a single Record/Play screen + modals).
  
## Threads and realtime

- Audio processing on the audio thread; UI label updates — via `DispatchSourceTimer`/`CADisplayLink` (≤50 Hz).
- All file operations — on a background queue, with progress tracking.

## Audio Session

- `AVAudioSessionCategoryPlayAndRecord`, mode `.spokenAudio`/`.default`, options: `.allowBluetooth`, `.defaultToSpeaker`, `.mixWithOthers` (configurable).
- Handles interruptions (incoming call), source/route changes, Remote Control (additional stage).
