# 12. Hand-off Notes for the Coding Agent

- Use SwiftUI + Combine, minimum iOS 18.
- Render A1 with Swift Charts. If impossible - Keep heavy rendering (A1) in a CALayer/Metal-backed view if needed, but expose a SwiftUI wrapper.
- No blocking work on the main thread; schedule engine callbacks on main.
- Provide Preview mocks for: idle, recording (-12 dB), paused, playing, long file (≥ 1h), AB active.
- Every public view has a Props struct + Callbacks struct to make it LLM-friendly.