# 12. Hand-off Notes for the Coding Agent

## Overview

These notes provide essential guidance and technical constraints to ensure consistent, maintainable, and performant implementation of the GPT5 UI components in SwiftUI. Adherence to the MVVM pattern and binding to live production data models is critical. All work should align with iOS 18+ deployment targets and target seamless user experiences including accessibility and responsiveness.

---

## Technical Stack and Architecture

- Use **SwiftUI** for all user interface views, strictly following MVVM design principles.
- Use **Combine** or Swift concurrency async/await streams for data binding and event handling.
- Target **minimum iOS 18 deployment**, with compatibility and performance optimizations for mid-range devices.
- All UI updates must occur on the **@MainActor** to guarantee thread safety.
- Avoid blocking the main thread: schedule callbacks and heavy processing off the main queue.

---

## Views and Composition

- The root view is `RecorderScreen`, composed of subviews A1 through A7 as specified.
- Each public view **must declare a Props struct** for immutable input data.
- Each public view **must declare a Callbacks struct** encapsulating all user interaction handlers.
- Views are strictly passive: no internal mutable state is allowed outside of UI mechanisms (e.g. animations).
- Accessibility annotations (VoiceOver, dynamic type, contrast) must be integrated in every view.
- Support dynamic type up to XXL, ensuring layouts adapt gracefully.

---

## Rendering Notes

- For `A1WaveformTimelineView`, **use Swift Charts** if feasible for rendering waveforms.
- If complex real-time rendering is required and Swift Charts proves insufficient:
  - Implement the waveform rendering in a **UIViewRepresentable** backed by a performant CALayer or Metal view.
  - Expose a clean SwiftUI wrapper for integration.
- UI updates reflecting recording state must happen at a minimum of **20 Hz** frequency with latency ≤ 100ms.

---

## Preview and Testing

- Provide SwiftUI **PreviewProvider mocks** for all distinct UI states:
  - Idle state
  - Active recording (e.g., -12 dB level)
  - Paused recording
  - Playback state
  - Long recording files (≥ 1 hour)
  - A-B loop active state
- Use **deterministic data** in mocks for repeatability and snapshot testing consistency.
- Response callbacks in Callbacks structs must be wired and validated in previews.

---

## Performance and Resource Management

- Heavy audio engine or waveform processing **must not block** the main thread.
- Optimize memory and CPU usage to adhere to background execution constraints.
- Meet power consumption target: background recording shall not consume more than 5% battery capacity per hour.
- Performance metrics (FPS, update latencies) must be logged and accessible for validation.

---

## Additional Guidelines

- All error presentation UIs (e.g., banners and toasts) must be reusable components with accessibility.
- Settings-related components must be driven by production data models without hardcoded values.
- Haptics and analytics integrations must be pluggable via protocols and optionally stubbed.
- Localization support must be integrated from the start; all strings should be localizable.
- Provide complete unit, integration, and snapshot tests alongside components.
- Document each view’s Props and Callbacks structs thoroughly, specifying inputs, outputs, and expected behaviors.

---

## Summary

This hand-off note ensures that implementation is machine-friendly, testable, and maintains a high standard of quality. The project requires rigor around immutability, thread safety, accessibility, and performance, aligned with requirements described in the main PRD documentation.

Adherence to these notes will ensure maintainability and straightforward further automation or LLM-assisted development cycles.
