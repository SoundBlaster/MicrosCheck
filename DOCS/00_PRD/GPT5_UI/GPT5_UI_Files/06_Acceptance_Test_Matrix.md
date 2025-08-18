# 6. Acceptance Test Matrix (Core)

# 6. Acceptance Test Matrix (Core)

| ID  | Scenario           | Steps                    | Expected                                         |
|------|--------------------|--------------------------|-------------------------------------------------|
| T01  | Start recording     | Idle → tap REC            | State = recording ≤ 200ms; timer runs; meters animate |
| T02  | Pause/resume        | Recording → tap REC → tap REC | Modes: paused ≤ 100ms → recording ≤ 100ms      |
| T03  | Stop saves file     | Recording → tap STOP      | State = idle; file URL non-nil; size increases then finalizes |
| T04  | T-MARK accuracy     | While recording, press T-MARK | Mark time within ± 50ms of current; haptic success |
| T05  | AB loop            | Play file; tap A; after ~3s tap B | Playback loops inside [A,B]; boundary ≤ ± 20ms |
| T06  | DPC cycle          | Tap DPC repeatedly        | Rates follow cycle; playback continues without artifacts |
| T07  | Lock UI             | Enable lock               | All controls inert except lock; long-press 1s unlocks |
| T08  | Meters cadence      | Record 30 min             | Update ≥ 20Hz; no UI freezes; peak hold behavior valid |
| T09  | Route change        | Playing → unplug headphones | Playback pauses; banner shown; recording unaffected |
| T10  | Permission denied   | No mic permission → tap REC | System prompt first time; then inline sheet; REC disabled |
