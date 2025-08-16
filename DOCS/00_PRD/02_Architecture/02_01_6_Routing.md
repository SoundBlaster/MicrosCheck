# Routing

- Employs a simple, enum-based router to manage navigation between core app screens (Record, Play, File Manager) and to present modals/sheets for secondary flows (options, bookmarks, info, etc.).
- All routing logic is contained within a single main screen context, reducing navigation complexity and making state transitions explicit.
- Routing decisions are triggered by ViewModel state changes or direct user actions, ensuring a declarative and testable navigation flow.
- The design avoids deep navigation stacks, supports smooth modal transitions, and keeps UI logic straightforward.
- The routing layer is easily extensible for more advanced navigation patterns (deep links, split views) as the app evolves.
