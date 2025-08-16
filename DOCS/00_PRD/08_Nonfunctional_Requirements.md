# 8. NFT - Nonfunctional Requirements

- **Performance:** CPU ≤ 25% during recording/playback on mid-range devices; avoid allocations in the realtime path.
- **Memory:** ≤ 150 MB for one hour of recording (excluding the file itself).
- **Energy:** background recording ≤5%/hour.
- **Reliability:** resilience to interruptions and route changes.
- **Security/Privacy:** only local files; `NSMicrophoneUsageDescription`.
- **Accessibility:** VoiceOver support for main controls; contrast ≥ 4.5:1.
- **Logging/Diagnostics:** os_log with privacy, debug flags.
- **Scalability:** file list up to 5k items without lags (lazy loading, metadata cache).
