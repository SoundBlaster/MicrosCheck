# 3. Cross-Cutting: Error & Edge Cases

- Mic permission denied → disable REC with tooltip; pressing shows system prompt once, then app sheet.
- Disk full → stop recording with error banner; partial file preserved if format allows.
- Route change (headphones unplug) → continue recording; if playing, pause with banner.
- Background: continuing recording; pausing playback; lock UI persists.