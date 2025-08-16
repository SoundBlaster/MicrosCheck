# Services

- Provides centralized, system-level utilities and helpers that support core app features and enhance user experience.

## Core Services
- **Permissions**: Manages runtime authorization for microphone, file storage, and background audio; prompts user as needed and reports status to ViewModels.
- **Background Execution**: Enables and monitors background audio modes, ensuring uninterrupted recording and playback when app is backgrounded.
- **Haptics Service**: Delivers haptic feedback in response to key user actions (record, play, seek, lock/unlock, etc.), improving interactivity.
- **App State Lock (UI Lock)**: Implements overlay lock to prevent accidental UI input; requires deliberate user action to unlock.
- **Waveform Cache**: Generates, stores, and retrieves waveform data for each audio file, supporting smooth and efficient waveform rendering in UI.

- All services expose clean APIs to ViewModels and core logic, abstracting platform-specific details.
- The architecture supports easy addition of new services as the app evolves.
