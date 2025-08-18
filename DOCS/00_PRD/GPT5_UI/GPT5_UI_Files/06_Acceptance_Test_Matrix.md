# 6. Acceptance Test Matrix (Core)

# 6. Acceptance Test Matrix (Core)

# 6. Acceptance Test Matrix (Core)

| ID   | Scenario           | Steps                           | Expected Result                                                                                  | Notes                                               |
|-------|--------------------|---------------------------------|------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| T01   | Start Recording     | From idle state, tap REC button  | App state transitions to recording within ≤ 200ms; recording timer starts counting; audio level meters animate in real-time | Verify low latency and accurate UI feedback         |
| T02   | Pause / Resume      | While recording, tap REC to pause; tap REC to resume | App switches to paused mode within ≤ 100ms, then back to recording mode within ≤ 100ms after resume | Ensure audio is muted during pause                   |
| T03   | Stop Saves File     | While recording, tap STOP button | Recording stops; app state transitions to idle; recorded file URL is non-nil; file size grows and then finalizes properly | Verify file integrity and playback capability        |
| T04   | T-MARK Accuracy    | While recording, press T-MARK button | A bookmark is created with timestamp within ± 50ms of current recording position; haptic feedback triggered | Confirm bookmark accuracy and user feedback          |
| T05   | A-B Loop Playback  | Play an audio file; tap A point; after ~3 seconds tap B point | Playback loops seamlessly between A and B points with boundary accuracy ≤ ± 20ms | Check for audio glitches or drift during looping     |
| T06   | DPC Cycle          | Tap Display Playback Control (DPC) button repeatedly | Playback rate cycles through predefined rates smoothly without audio artifacts or glitches | Confirm rate changes correspond to UI indicator      |
| T07   | Lock UI            | Enable the lock feature          | All UI controls become inert (disabled) except the lock control; long press of 1 second unlocks UI controls | Verify controls accessibility and lock/unlock behavior |
| T08   | Meters Cadence     | Record audio continuously for 30 minutes | Audio level meters update at a minimum frequency of 20 Hz; UI remains responsive with no freezes; peak hold meter functionality works correctly | Monitor performance and resource usage               |
| T09   | Route Change       | While playing audio, unplug headphones | Playback automatically pauses; user-visible banner notification appears; ongoing recording session remains unaffected | Validate system audio route management                |
| T10   | Permission Denied  | User has no microphone permission; tap REC button | System permission prompt appears on first attempt; subsequent attempts show inline permission sheet; REC button remains disabled until permission granted | Ensure proper permission handling and user guidance  |
