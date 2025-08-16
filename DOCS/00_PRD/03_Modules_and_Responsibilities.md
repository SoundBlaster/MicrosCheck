# 3. Modules and Responsibilities

## RecorderModule

- States: `idle → recording → paused → stopping → saving → idle`
- Source: built-in microphone/headset (switchable), config: sampleRate, bitrate, mono/stereo.
- Meters: RMS/Peak per channel (interface for UI).
- Metadata of the current recording (file name, size, format, tags).

## PlayerModule

- Transport: `stopped | playing | paused | seeking`
- Seeking: tap ±10s; hold — repeated steps every 200ms + “with sound”.
- DPC: `AVAudioUnitTimePitch` (`rate` 0.5–2.0, `pitch` ±1200 cents).
- Volume: master (0–200%) and L/R (‑60…+12 dB) via `AVAudioMixerNode` and panner/mix.
- A‑B loop: set A, then B; loop; reset.
- UI Lock: overlay-lock, removed by holding for 2s.

## FileManagerModule

- Directory `Recordings/`. Operations: list/attrs/copy/delete/space.
- Metadata: `*.json` next to the file: lastPosition, bookmarks[], tags, userNotes, audioInfo.
- Extraction of audio attributes via `AVAsset`.

## Bookmarks (T‑MARK)

- Quick mark of current time; name/comment (modal on “Option”).

## Waveform

- Live: sampling RMS buffers → rendering in Canvas/Metal.
- Offline: generating preview for file (cache in `.wave` JSON/bin).
