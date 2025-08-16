# Threads and Realtime
- Audio processing performed on the dedicated audio thread for real-time reliability.
- UI label updates for meters use `DispatchSourceTimer` or `CADisplayLink` (≤50 Hz) for smooth, accurate metering.
- All file operations dispatched to a background queue, ensuring no UI blocking (progress is tracked and reported).
