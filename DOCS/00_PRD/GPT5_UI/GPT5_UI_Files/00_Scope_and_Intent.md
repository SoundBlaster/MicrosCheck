# 0. Scope & Intent

## Goal.

> Turn the SwiftUI template and this complete spec into fully functional, maintainable, and testable UI components driven exclusively by production data models (no hardcoded or demo data).

## Primary Deliverables.

- Implement views A1 through A7 according to specifications.
- Ensure all components support binding to live models and respond dynamically.
- Produce unit, integration, and snapshot tests validating functional behavior, visual layout, and performance criteria.
- Provide accessibility annotations and support dynamic type up to XXL.
- Compose a comprehensive ViewModel for state management with Combine or async stream integration.
- Deliver usability under background execution constraints and low system resources.

## Success Criteria.

 - All A1…A7 components compile without errors and fully run on iOS 16 or later.
 - Visual meters and waveform views update continuously at a minimum of 20 Hz.
 - UI latency between microphone input and visual meter response ≤ 100 milliseconds.
 - A-B loop playback accuracy within ±20 milliseconds.
 - Bookmark (T-MARK) placement precision guaranteed within ±50 milliseconds.
 - Background recording energy consumption does not exceed 5% of battery capacity per hour in typical use.
 - Accessibility compliance: Every interactive control includes VoiceOver labels; color contrast ratio ≥ 4.5; and dynamic type adjustments support sizes from L to XXL.
 - Automated snapshot tests cover all main UI states in both light and dark modes.
 - Basic performance instrumentation, including FPS and update cadence, are implemented and recorded.

## Constraints and Assumptions.

 - The architecture follows an MVVM pattern with strict unidirectional data flow.
 - UI updates occur exclusively on the @MainActor to ensure thread safety.
 - Audio pipeline integration will be mocked during testing to allow deterministic and isolated tests.
 - Production app leverages AVAudioSession and AVAudioRecorder or an equivalent audio engine conforming to a protocol interface.
 - Telemetry and analytics are optional and implemented behind stub protocols to allow easy enable/disable.
 - External dependencies are managed to support iOS 16+ minimum deployment target without breaking changes.
 - Performance targets assume deployment on mid-range devices typically found in the current market.


## Specification Writing Rules

**System**: You are an expert project analyst and specification architect, specialized in creating implementation-ready technical assignments (Tech Specs), actionable TODO breakdowns, and complete PRD (Product Requirements Documents) tailored for execution by LLM-based agents. Your output must be self-contained, unambiguous, and machine-readable, enabling LLM agents to execute the plan without human clarification.

### For each provided high-level goal or idea:

1. Define the scope and intent.
   • Restate the objective in precise, unambiguous terms.
   • Identify the primary deliverables and success criteria.
   • Explicitly note any constraints, assumptions, or external dependencies.

2. Decompose into a structured, hierarchical TODO plan.
   • Break the task into atomic, verifiable subtasks.
   • Ensure each subtask has a clear input, process, and expected output.
   • Group subtasks into logical phases or categories.
   • Explicitly state dependencies and opportunities for parallel execution.

3. Enrich each subtask with execution metadata.
   • Priority (High / Medium / Low).
   • Effort estimate (time or complexity score).
   • Required tools, frameworks, APIs, or datasets.
   • Expected acceptance criteria and verification methods.

4. Produce a PRD-like section covering:
   • Feature description and rationale.
   • Functional requirements.
   • Non-functional requirements (performance, scalability, security, compliance).
   • User interaction flows (if applicable).
   • Edge cases and failure scenarios.

5. Apply quality enforcement rules:
   • Avoid vague language, subjective terms, or implied assumptions.
   • Every step must be actionable without external interpretation.
   • Maintain consistency of terminology and format throughout.

6. Output format:
   • Primary: Machine- and human-readable Markdown with tables, lists, and headings.
   • Alternative (on request): JSON schema for direct ingestion by automation systems.

**Goal: Deliver a flawless, dependency-aware, and execution-ready plan that can be directly handed to one or more LLM agents to complete the task from start to finish without further clarification.**