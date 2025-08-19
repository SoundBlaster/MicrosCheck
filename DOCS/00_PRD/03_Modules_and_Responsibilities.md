# 3. Architecture Separation: Backend Modules and Frontend UI

This document separates the product requirements and design specification for the Dictaphone app into two complementary parts: "Backend Modules" responsible for core audio, file, and logic layers, and "Frontend UI" focused on views, controls, and user interaction layers. This clear division supports modular development, maintainability, and testability.

## Part 1: Backend Modules

See detailed backend module specifications:

- [[03_Modules/03_01_RecorderModule.md]]
- [[03_Modules/03_02_PlayerModule.md]]
- [[03_Modules/03_03_FileManagerModule.md]]
- [[03_Modules/03_04_BookmarksModule.md]]
- [[03_Modules/03_05_WaveformModule.md]]

## Part 2: Frontend UI

The frontend UI layer provides interactive views, controls, and user experience flows. It binds to backend modules using observable state, protocols, or direct communication, translating backend data into visual components and user gestures into backend commands.

See detailed frontend UI module specifications:

- [[03_06_UI_Overview]]
- [[03_Modules/03_07_ViewsAndControls.md]]
- [[03_Modules/03_08_StateAndViewModels.md]]
- [[03_Modules/03_09_InteractionAndNavigation.md]]

---

## Integration Guidelines

- Backend modules expose clean Swift protocols encapsulating core functionality.
- Frontend UI imports these protocols and injects concrete backend instances via environment or dependency injection.
- Communication is primarily unidirectional:
  - UI sends user requests to backend APIs.
  - Backend publishes state updates or sends delegate callback events.
- Modular separation allows backend unit tests and frontend UI tests in isolation.
- Future extensions can add more services or advanced UI components without disrupting existing layers.

---

## Summary

This division into Backend Modules and Frontend UI ensures a scalable architecture for the Dictaphone app:

| Layer            | Contains                            | Key Characteristics                              |
|------------------|-----------------------------------|-------------------------------------------------|
| **Backend Modules** | Recorder, Player, FileManager, Bookmarks, Waveform | Core audio logic, file and metadata management, business rules. Platform/UI independent. |
| **Frontend UI**    | SwiftUI Views, Controls, ViewModels, Routing | Interactive UI components, animations, accessibility, user workflows. |

This separation will enable efficient parallel development and clear responsibility boundaries aligning with the PRD and implementation plan.
