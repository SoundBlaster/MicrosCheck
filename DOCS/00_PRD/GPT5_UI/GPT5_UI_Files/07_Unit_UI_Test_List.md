# 7. Unit/UI Test List by Components

This test list provides precise objectives, boundaries, and test conditions to ensure robust coverage for both logic and UI components.

## Component-Specific Unit Tests

- **A1 Waveform**
  - Verify decimation algorithm correctness against known input.
  - Validate timeline alignment precision within ±10ms tolerance.
  - Assert memory usage growth stays below 2 MB during continuous 30-minute mock audio stream.
  - Test response to empty and edge-case audio data.

- **A2 Meters**
  - Confirm audio level to visual bar mapping accuracy across full dynamic range.
  - Validate clip indicator triggers and clears with correct timing semantics.
  - Test meter update frequency adheres to ≥ 20 Hz minimum update rate.

- **A3 T-MARK**
  - Ensure debounce logic prevents multiple marks within 150 ms window.
  - Verify correct timestamp is logged for each mark created.
  - Test behavior under rapid tapping scenarios.

- **A5 States (Recorder State Machine)**
  - Validate state transitions among idle, recording, and paused states.
  - Property-based tests for invalid transitions and recovery behavior.
  - Confirm state-related side effects (e.g., UI updates, audio processing) occur as expected.

- **A6 AB Loop Control**
  - Exhaustive testing of state table scenarios:
    - A and B points both nil.
    - Only A point set.
    - Both A and B points set in valid order.
    - Invalid order of A and B settings.
  - Validate fast seek edge cases, ensuring looping behavior is consistent and within ±20ms accuracy.

- **A7 Lock Control**
  - Verify minimum gesture duration enforcement for lock/unlock (≥ 1 second).
  - Confirm UI exclusion zones prevent accidental unlock or interaction during locked mode.
  - Test visual feedback for locked/unlocked states.

## UI - XCTest + ViewInspector + Snapshot Tests

- Validate visual correctness in both dark and light color schemes.
- Localization support testing with English (`en`) and Russian (`ru`) locales.
- Dynamic Type support test for minimum (L) and maximum (XXL) accessibility text sizes.
- Snapshot tests covering all main UI states including idle, recording, paused, locked, and error states.
