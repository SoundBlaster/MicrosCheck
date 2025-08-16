# 8. Non-Functional Requirements (NFR)

## Performance

 - Latency: End-to-end delay between microphone input and visual meter update / playback feedback shall not exceed 150 ms.
 - AB-loop stability: Loop boundaries shall not deviate more than ±20 ms; no audible clicks/pops at loop points.
 - Bookmark accuracy: Bookmarks shall resolve within ±50 ms of the intended audio position.
 - Responsiveness: UI thread shall process input events within ≤200 ms even under heavy load (e.g., scrolling a list of 5k items).
 - Stress: App shall sustain 8+ hour continuous recording/playback sessions without crash, memory leak, or data loss.
 - Battery drain: In-app battery consumption shall be measured under continuous recording and playback, and shall not exceed 15% per hour on a standard battery benchmark device.

## Capacity

 - Maximum recording length: Continuous recording of at least 24 hours without crash, data loss, or memory leaks.
 - File list scalability: Support smooth UI performance and search with libraries of up to 5,000 recordings, including batch operations (delete, export).

## Resource Utilization

 - Memory: ≤ 150 MB RAM during typical operation (excluding audio file size).
 - CPU: ≤ 25% average load during recording and playback on mid-range iOS devices.
 - File integrity: No data loss or corruption allowed even if storage becomes full during recording. App must gracefully stop recording, display a clear error, and preserve existing data.
 - Energy efficiency:
 - Foreground: App shall complete 8 hours of continuous recording on a single battery charge on supported devices.
 - Background: Battery consumption ≤ 5%/hour during background recording.

## Reliability

 - Interruptions: Recording shall automatically resume after system interruptions (e.g., phone call, route change).
 - Data integrity: No audio data loss or corruption during unexpected app termination or power loss.

## Security & Privacy

 - Local storage only: Audio files shall be stored exclusively on device storage (no remote upload by default).
 - Permission handling: Use NSMicrophoneUsageDescription in Info.plist with explicit user consent.
 - Encryption: Temporary buffers and cached metadata shall not be written to unencrypted storage.

### Storage & Deletion Policy

- All audio files and associated metadata are stored strictly on-device in the app's sandbox; there is no synchronization or backup to iCloud, CloudKit, or any remote/cloud service in the current release.
- Persistent audio files and metadata are not encrypted at rest or in transit by the app (device-level iOS security applies; the app does not implement its own encryption layer).
- File deletion is permanent and immediate; there is no "Trash" or retention period.
- Any form of iCloud/remote/cloud storage is not supported in the current version. See roadmap/extensions for possible future changes.

## Accessibility

 - VoiceOver: All primary controls shall be labeled and operable via VoiceOver.
 - Contrast ratio: UI elements must achieve at least 4.5:1 contrast ratio.
 - Dynamic Type: App shall respect system text scaling settings.

## Diagnostics & Logging

 - Logging: Use os_log with proper privacy levels (.public / .private).
 - Debug flags: Enable additional diagnostic logging in debug builds only.
 - Crash reporting: Record non-PII diagnostics on fatal errors for QA verification.
