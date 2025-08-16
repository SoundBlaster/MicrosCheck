# 11. Edge Cases and Failures

## AudioCore & Audio Session
- **No free space:** Gracefully stop recording, warn the user, auto-save partial file if possible. 
- **Audio session interruption (e.g., call):** Pause recording/playback, attempt to resume when possible. Notify user if full recovery is not possible.
- **Loss of input route (e.g., unplug headset):** Auto-switch to built-in microphone, notify user.
- **Corrupted audio file or metadata:** Move affected files to `Recordings/_Corrupted/`, attempt recovery from metadata backup.
- **Zero signal (silence):** Optional auto-pause feature (planned for future).

## Persistence
- **File system errors (rename, delete, copy):** Show error message, retry or roll back to last known good state.
- **Metadata/audio file mismatch:** Detect and quarantine for user review. Provide restore or delete options.
- **Simultaneous file access (race condition):** Use atomic file operations and locking for safety.

## Services
- **Denied permissions (microphone, files, background audio):** Inform the user, provide link to Settings to enable, and disable affected features.
- **Background execution terminated (system kill):** Save state frequently, warn user of possible data loss.
- **Haptic feedback unavailable or failed:** Fall back to visual cues only; do not block critical flows.
- **Waveform cache corruption:** Regenerate waveform data on next access, mark old cache as invalid.

## UI
- **UI lock fails to engage or disengage:** Prevent actions until resolved, require user confirmation.
- **Unresponsive controls:** Watchdog timers and fallback UI path (e.g., hard stop button).
- **Accessibility feature conflict:** Provide alternate navigation/control path, warn user.

## General
- **Unexpected app termination (crash, force quit):** Auto-save state and recover on next launch.
- **Unsupported audio file format:** Inform user, block import/playback, suggest supported formats.

- Review and expand this list as new scenarios arise during development and testing.
