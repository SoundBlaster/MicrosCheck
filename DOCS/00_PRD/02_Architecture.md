# 2. Architecture (High Level)

![[02_01_9_ArchitectureSummary]]

## Layers

- **[UI (SwiftUI)](02_Architecture/02_01_1_UI.md)** — screens and controls, strictly following the design.
- **[ViewModels (ObservableObject)](02_Architecture/02_01_2_ViewModels.md)** — state, event routing, debounce/timers.
- **[AudioCore](02_Architecture/02_01_3_AudioCore.md)** — unified engine on `AVAudioEngine`:
  - **RecordPipeline:** input → format → file writer → metering tap.
  - **PlayPipeline:** file → playerNode → timePitch → stereo mixer → output; post-mix meters.
- **[Persistence](02_Architecture/02_01_4_Persistence.md)** — `FileManager` + associated JSON metadata (`Codable`) + `UserDefaults` for settings.
- **[Services](02_Architecture/02_01_5_Services.md)** — Permissions, Background, Haptics, AppStateLock, WaveformCache.
- **[Routing](02_Architecture/02_01_6_Routing.md)** — simple enum-router/Sheet (within a single Record/Play screen + modals).

## Threads and realtime

- Audio processing on the audio thread; UI label updates — via `DispatchSourceTimer`/`CADisplayLink` (≤50 Hz).
- All file operations — on a background queue, with progress tracking.

> See detailed description in [Threads & Realtime](02_Architecture/02_01_7_ThreadsAndRealtime.md).

## Audio Session

- `AVAudioSessionCategoryPlayAndRecord`, mode `.spokenAudio`/`.default`, options: `.allowBluetooth`, `.defaultToSpeaker`, `.mixWithOthers` (configurable).
- Handles interruptions (incoming call), source/route changes, Remote Control (additional stage).

> See detailed description in [Audio Session](02_Architecture/02_01_8_AudioSession.md).
