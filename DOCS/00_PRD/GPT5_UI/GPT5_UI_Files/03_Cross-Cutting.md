# 3. Cross-Cutting: Error & Edge Cases

This section defines global error handling and edge case management that affect multiple components across the app to ensure consistent user experience, accessibility compliance, and robust error recovery.

---

## 3.1 Microphone Permission Denied

### Condition
- The app detects that the system microphone permission is denied or restricted for the current user/session.

### UI Behavior
- The REC (record) button is disabled visually with 40% opacity to indicate inactivity.
- An accessible tooltip or inline message explains that microphone access is required to start recording.
- The first press on this disabled REC button triggers the system's permission prompt if not permanently denied.
- If the permission is persistently denied, an in-app explainer sheet is shown guiding the user to the system settings to enable microphone access.
- All UI elements dependent on microphone input (e.g., meters, waveform) show disabled/placeholder states accordingly.

### Accessibility
- Disabled REC button and tooltip have VoiceOver focus and descriptive announcements.
- The explainer sheet offers accessible navigation and instructions.

### Functional & Telemetry
- The user cannot start recording until permission is granted.
- Analytics event `permission_denied` is logged once per app session when microphone access is blocked.

### Recovery
- The user can retry the permission prompt via dedicated UI control.
- Normal operation resumes upon permission grant.

---

## 3.2 Disk Full Condition

### Detection
- Continuous monitoring of available device storage to detect when space is insufficient for ongoing recording.

### UI Behavior
- Upon reaching critical low disk space during recording, the recording is stopped gracefully to avoid file corruption.
- Display a prominent, accessible error banner at the top of the screen for 3 seconds with the message: "Storage full: Recording stopped."
- If supported by the audio format, a partial recording file is preserved and remains accessible.
- Recommend user actions in the banner or linked help, such as freeing up space or exporting existing recordings.
- Disable REC and related controls until sufficient storage is restored.

### Accessibility
- Error banner has accessible labels and is announced by VoiceOver.
- Controls visually indicate their disabled state and do not respond to input.

### Functional & Telemetry
- File is correctly committed or partially saved without corruption.
- Analytics event `disk_full` with timestamp and storage metrics is logged.

### Recovery
- Recording controls are enabled again once storage is above the required threshold.
- Inform the user on recovery with accessible UI prompts.

---

## 3.3 Audio Route Changes (e.g., Headphones Unplug)

### Detection
- Monitoring system audio route changes, particularly headphones unplugged or new devices connected.

### Behavior
- When audio playback is active and a route change occurs (e.g., headphones unplugged), playback is immediately paused.
- Show an accessible, non-intrusive banner message for 3 seconds: "Playback paused: audio route changed."
- Recording continues without interruption or quality degradation regardless of route change.
- The app handles any audio session reconfiguration internally to maintain stability.

### Accessibility
- Banner message is announced via VoiceOver.
- Focus remains on active UI elements without disruption.

### Functional & Telemetry
- Event `route_change` is logged with new device info where available.

### Recovery
- User manually resumes playback as desired.
- App automatically adapts to new route without crashes or audio glitches.

---

## 3.4 Background Mode

### Behavior
- If recording, the app continues audio capture uninterrupted while in background, conforming to system capabilities and limitations.
- Active playback automatically pauses when the app transitions to the background unless system-permitted for background audio.
- The UI locked state remains persistent through background and foreground transitions, preventing accidental input.
- Error banners or toast notifications triggered while in background are deferred and surfaced upon re-entry to foreground.

### Accessibility
- All UI state and accessibility focus is restored appropriately when returning to foreground.

### Functional & Telemetry
- Energy consumption for background recording must meet the target threshold (≤5% battery usage per hour).
- Background errors or interruptions (e.g., system resource revokes) are recorded for diagnostics.

### Recovery
- Proper restoration of user interface state and user controls on foregrounding the app.
- Clear communication of any errors encountered during background execution.

---

## 3.5 General UI and UX Rules for Errors

- All error message banners or toasts:
  - Appear visibly at the top of the screen.
  - Auto-dismiss after 3 seconds but allow manual dismissal when applicable.
  - Support full accessibility with language and screen reader announcements.
  - Are non-blocking, allowing the user to continue interacting with unaffected UI without disruptions.
- Interactive controls visually convey disabled state with at least 40% opacity and ignore all interactions to avoid confusion.
- Application logging integrates seamlessly with telemetry systems, respecting user privacy and data security policies.

---

## 3.6 Analytics and Telemetry

- All critical error and state transitions emit well-defined analytics events with standardized payloads including:
  - Event type (e.g., `permission_denied`, `disk_full`, `route_change`, `background_error`).
  - Timestamp of occurrence.
  - Relevant detailed context or metadata (e.g., current playback position, device state).
- Telemetry data collection complies with all privacy regulations and user consent mechanisms.
- Event emission retries and error handling ensure reliable logging without impacting app performance or user experience.

---

**These cross-cutting policies and behaviors are uniformly applied across all UI components and flows to ensure a consistent, high-quality user experience and robust error management throughout the app. Comprehensive testing under simulated adverse conditions must verify adherence to these standards.**