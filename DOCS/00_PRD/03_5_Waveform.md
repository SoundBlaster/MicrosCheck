# Waveform

### Live Waveform Rendering
Continuously samples RMS audio buffers in real time and renders the waveform using Canvas or Metal technologies to provide responsive visual feedback during recording and playback.

### Offline Waveform Generation
Processes audio files offline to generate preview waveform data, which is cached in `.wave` format (JSON or binary) for fast and efficient UI rendering later.

### Waveform Caching
Caches waveform data to optimize performance and reduce processing when displaying waveforms for large or multiple audio files.

### Custom Rendering
Supports customization of waveform display styles, including different color schemes, zoom levels, and scaling options.

### Performance Optimization
Utilizes efficient algorithms and hardware acceleration to ensure smooth waveform rendering with minimal latency and CPU load.

### Error Handling
Detects and manages errors related to waveform data generation or rendering failures, maintaining application stability.
