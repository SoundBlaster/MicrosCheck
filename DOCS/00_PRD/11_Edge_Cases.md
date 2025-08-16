# 11. Edge Cases and Failures

- No free space → soft stop of recording, warning, auto-save partial file.
- Loss of input route (headset unplugged) → auto-switch to built-in microphone with notification.
- Audio session interruption → pause recording/playback, correct resumption.
- Corrupted files/metadata → quarantine in `Recordings/_Corrupted/` and restore from backup meta.
- Zero signal (silence) → optional auto-pause (later).
