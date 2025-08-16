# ViewModels (ObservableObject)

- Serve as a bridge between SwiftUI views and the app's core logic and services.
- Implement the ObservableObject (or Observable) protocol, allowing views to reactively update in response to state changes.
- Responsibilities include:
  - Maintaining presentation state for each feature or screen
  - Exposing events and actions from the UI, routing them to core logic/services
  - Handling debouncing, timers, and transient UI logic (e.g., progress, meters)
  - Validating user input and transforming model data for presentation
- ViewModels receive user actions from the UI and communicate with AudioCore, File, and Service layers.
- Avoid direct business logic; focus on state orchestration and deriving UI-friendly outputs.
