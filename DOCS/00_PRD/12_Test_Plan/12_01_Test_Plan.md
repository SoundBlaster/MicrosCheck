# 12.1. Detailed Test Plan

## 1. Unit Tests

- Test audioRecorder starts recording when `startRecording()` is called.
- Test audioRecorder stops recording when `stopRecording()` is called.
- Test audioPlayer plays audio file when `play()` is called.
- Test audioPlayer stops playing when `stop()` is called.
- Test that `audioRecorder` returns an error when trying to record without microphone permission.
- Test handling of corrupted audio file input for audioPlayer.
- Test error thrown when file to be played does not exist.

## 2. Instrumental Tests

- Verify that the app launches and the main screen is displayed.
- Verify that the recording indicator appears when recording starts.
- Verify that playback controls are disabled during recording.
- Verify that playback controls are enabled after recording stops.
- Verify the app gracefully handles interruptions (e.g., phone call) during recording.
- Negative test: Confirm app behavior when microphone access is revoked during recording.
- Negative test: Verify app response on attempting to play an unsupported audio format.

## 3. UI Tests

### Basic Test Cases

- **REC → PAUSE → RESUME → STOP**
  - Press REC to start recording.
  - Press PAUSE to pause recording.
  - Press RESUME to continue recording.
  - Press STOP to end recording.
  - Verify that the recorded audio file is saved and playable.

  **Pass/Fail Criteria:**
  - Timer starts within 200ms after pressing REC.
  - Pause action freezes timer and audio input within 100ms.
  - Resume resumes timer and audio input within 150ms.
  - Stop ends recording promptly and saves file without error.
  - UI updates correctly reflect each state change.
  
- **Playback Test**
  - Play the recorded audio file.
  - Pause playback.
  - Stop playback.

  **Pass/Fail Criteria:**
  - Playback starts within 300ms.
  - Pause stops audio and timer immediately.
  - Stop ends playback without crash or freeze.
  - UI shows correct playback state at all times.

### Negative Test Cases

- **Playback on Corrupted File**
  - Attempt to play an audio file known to be corrupted.
  
  **Expected Behavior:**
  - UI presents an error message indicating playback failure.
  - Playback does not start.
  - App remains stable without crashing.

- **Deleting While Recording**
  - Attempt to delete a recording while it is currently being recorded.
  
  **Expected Behavior:**
  - Delete action is disabled or prompts warning.
  - Recording continues uninterrupted if delete is prevented.
  - If deletion is allowed, recording stops and file is deleted safely.
  - No data corruption or app crashes.

- **Insufficient Storage**
  - Start recording when device storage is nearly full.
  
  **Expected Behavior:**
  - Recording stops automatically or is prevented from starting.
  - UI shows error or warning about insufficient storage.
  - No data loss or app crash.
