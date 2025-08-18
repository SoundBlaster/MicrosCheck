# 7. Unit/UI Test List by Components

- A1 Waveform: decimator unit test; timeline alignment; memory growth < 2 MB over 30 min (mock stream).
- A2 Meters: level→bar mapping; clip indicator timing.
- A3 T-MARK: debounce (≥150 ms) prevents double marks.
- A5 States: state machine transitions (idle↔recording↔paused) property tests.
- A6 AB: state table (A=nil/B=nil, A set, B set, invalid order) + fast seek edges.
- A7 Lock: gesture minimum duration; exclusion zones.

## UI - XCTest + ViewInspector/Snapshot

- dark/light
- localization en/ru
- Dynamic Type L/XXL