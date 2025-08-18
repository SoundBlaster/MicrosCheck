# 9. SwiftUI Composition

## Goal

Define a clear, maintainable, and testable SwiftUI view composition architecture for the GPT5 UI that strictly adheres to MVVM principles, supports immutable data flow, and enables seamless interaction with the recording engine via a dedicated ViewModel. This composition ensures UI responsiveness, testability, and accessibility compliance.

---

## Primary Deliverables

- A structured hierarchy of views named `RecorderScreen` and its child views (A1 through A7).
- Immutable properties and callback-based communication for all views.
- A comprehensive ViewModel mediating between the recording engine and the UI views.
- Clear binding of dynamic outputs from the recording engine to the UI elements.
- Integration of accessibility annotations, dynamic type support, and performance optimizations.
- Documentation of view responsibilities and interaction flow.

---

## Success Criteria

- All views accept only immutable props and callbacks, with no internal mutable state affecting UI consistency.
- The ViewModel fully adapts the underlying `RecordingEngine` data and events into view-compatible props and callback handlers.
- UI updates reflect recording state and data changes with a latency under 100 milliseconds.
- Views implement accessibility standards including VoiceOver, color contrast, and dynamic type scaling.
- The composition supports unit testing and snapshot testing for all visual states.
- Layout responds robustly to different device sizes and orientations, supporting iOS 18+.

---

## Constraints and Assumptions

- Architecture conforms to MVVM with unidirectional data flow.
- All UI updates occur on the @MainActor to ensure thread safety.
- The `RecordingEngine` provides live recording data streams and control interfaces.
- The ViewModel acts as a source of truth and adapter layer for the views.
- External dependencies are minimized; utilize only SwiftUI and Combine/async streams.
- The design supports future expandability without breaking existing contracts.

---

## Detailed TODO Plan

### 1. Define `RecorderScreen` Root View

- **Scope:** Compose child views A1 through A7 into a single container view representing the main recording screen.
- **Subtasks:**
  - Set up the container with layout accommodating all children.
  - Pass immutable props from the ViewModel to child views.
  - Propagate user interactions from children as callbacks to the ViewModel.
- **Priority:** High
- **Effort:** Medium
- **Acceptance:** All child views render correctly and receive correct props with callback wiring verified.

### 2. Child Views (A1 - A7) Specification

- **Scope:** Each child view encapsulates a specific portion of the UI, handling display and user input purely through props and callbacks.
- **Children:**
  - A1WaveformTimelineView: Displays audio waveform timeline updated live.
  - A2RecordingInfoPanel: Shows recording metadata and state info.
  - A3NavActionsBar: Navigation controls and actions bar.
  - A4SearchFilterBar: Provides searchable filtering UI.
  - A5TransportBar: Play, pause, rewind, forward controls.
  - A6CircularPad: Central control pad with record and control buttons.
  - A7CornerButtons: Additional contextual buttons placed at screen corners.
- **Subtasks:**
  - Define immutable props structure for each view.
  - Implement accessibility labels and dynamic type support.
  - Verify interaction callbacks correctly invoke ViewModel logic.
- **Priority:** High
- **Effort:** Medium to High per view depending on complexity.
- **Acceptance:** Each view is independently testable and visually validated in isolation.

### 3. ViewModel Design and Integration

- **Scope:** Implement a ViewModel adapting `RecordingEngine` outputs and injecting callbacks for UI interaction.
- **Subtasks:**
  - Map recording engine state streams to ViewModel published properties or async streams.
  - Provide callback handlers for UI-triggered actions (e.g., transport controls).
  - Ensure the ViewModel runs on @MainActor.
  - Test ViewModel logic and data transformations independently.
- **Priority:** High
- **Effort:** High
- **Acceptance:** ViewModel mediates all interactions and updates, driving UI state correctly without side effects.

---

## PRD-like Summary

### Feature Description and Rationale

The SwiftUI composition follows a strict MVVM design to keep UI declarative, testable, and robust. By dividing the main screen into well-defined subviews with immutable props and callbacks, the architecture reduces state management complexity and enhances maintainability. The ViewModel acts as the single source of truth, transforming raw recording engine data into UI-ready state and handling user actions cleanly.

### Functional Requirements

- All views accept immutable props and user interaction callbacks.
- UI updates propagate from ViewModel state changes with minimal latency.
- The ViewModel supports all necessary recording controls and state representations.
- Accessibility support is baked into each component.
- Component reusability is maximized with clear interface contracts.

### Non-functional Requirements

- Performance: UI refreshes at ≥20 Hz with latency ≤100 ms for recording updates.
- Scalability: The architecture supports additional views or modified layouts without refactoring.
- Compliance: Follows iOS 18+ system conventions for threading and UI guarantees.

### User Interaction Flows

- User interacts with buttons in A3NavActionsBar, A5TransportBar, and A6CircularPad which invoke ViewModel callbacks.
- A1WaveformTimelineView animates live audio waveform changes from recording data.
- A2RecordingInfoPanel displays metadata updated live.
- Search filters and corner buttons respond to user input and update state accordingly.

### Edge Cases and Failures

- ViewModel buffering state updates to avoid UI jank on high-frequency changes.
- Handling loss of recording engine connection gracefully.
- View actions disabled appropriately when recording is inactive or permissions denied.
- Fallback UI states for partial data availability.

---
