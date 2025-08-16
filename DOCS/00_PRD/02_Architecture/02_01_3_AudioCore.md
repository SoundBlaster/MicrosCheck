# AudioCore (AVAudioEngine & AVAudioPlayer)

- Provides a unified, robust audio processing layer for both recording and playback.

## Record Pipeline
- Uses `AVAudioEngine` to capture microphone input, support configurable formats, and flexible routing.
- Writes audio data to file while enabling real-time metering for left/right channels.
- Metering data is exposed to UI for visualization (waveform, levels).

## Play Pipeline
- Uses `AVAudioPlayer` for simple playback scenarios (efficient, minimal setup).
- For advanced playback (time/pitch shifting, effects, or custom mixing), uses `AVAudioEngine` pipeline:
  - Reads audio files, applies time/pitch changes, manages stereo mixing, and provides post-mix meters.
- Metering available for both simple and advanced playback.

- Design ensures high-fidelity, low-latency audio, clear separation between record and playback, and future extensibility.
