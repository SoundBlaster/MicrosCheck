## 2) Архитектура (высокий уровень)

**Слои:**
- **UI (SwiftUI)** — экраны и контролы, строго по макету.
- **ViewModels (ObservableObject)** — состояние, маршрутизация событий, дебаунс/таймеры.
- **AudioCore** — единый движок на `AVAudioEngine`:
  - **RecordPipeline:** input → format → file writer → metering tap.
  - **PlayPipeline:** file → playerNode → timePitch → stereo mixer → output; метры post‑mix.
- **Persistence** — `FileManager` + сопутствующие JSON‑метаданные (`Codable`) + `UserDefaults` для настроек.
- **Services** — Permissions, Background, Haptics, AppStateLock, WaveformCache.
- **Routing** — простой enum‑роутер/Sheet (в рамках одного экрана Record/Play + модалки).
  
**Потоки и realtime:**
- Обработка аудио на аудиопотоке; UI обновления меток — через `DispatchSourceTimer`/`CADisplayLink` (≤50 Гц).
- Все файло‑операции — на фоновой очереди, с прогрессом.

**Audio Session:**
- `AVAudioSessionCategoryPlayAndRecord`, mode `.spokenAudio`/`.default`, опции: `.allowBluetooth`, `.defaultToSpeaker`, `.mixWithOthers` (по настройке).
- Обработка прерываний (входящий звонок), смен источника/маршрута, Remote Control (доп. этап).