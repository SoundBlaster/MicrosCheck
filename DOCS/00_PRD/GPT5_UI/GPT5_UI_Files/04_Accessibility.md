# 4. Accessibility (Global Guidelines and Requirements)

This document defines the accessibility standards and detailed implementation rules applicable across all UI components within the MicrosCheck app to ensure usability for users with disabilities and compliance with iOS accessibility guidelines.

---

## 4.1 General Principles and Objectives

- Ensure full compliance with Apple’s Human Interface Guidelines (HIG) for Accessibility.
- Provide an intuitive and consistent experience for VoiceOver users that mirrors visual interaction.
- Support Dynamic Type scaling up to XXL font sizes without truncating critical information.
- Maintain sufficient color contrast according to WCAG AA standards (minimum 4.5:1 contrast ratio).
- Avoid reliance on color alone to convey information; use shapes, textures, and states.
- Ensure hit targets meet or exceed IOS minimum of 44x44 points for tappable controls.
- Provide clear and concise accessibility labels, hints, and traits for all interactable elements.

---

## 4.2 Text and Typography

- Text elements must support Dynamic Type with system font scaling.
- Layouts must adapt fluidly to increased font sizes, avoiding clipped or overlapping content.
- Provide marquee scrolling or truncation with accessible full-text alternatives for long file names or labels.
- Headings and important informational text should be marked with appropriate accessibility traits.

---

## 4.3 Buttons, Controls, and Interactive Elements

- All buttons, toggles, sliders, and interactive controls must have descriptive `.accessibilityLabel` texts.
- Supply `.accessibilityHint` where the button or control’s action is not obvious.
- Use `.accessibilityTraits` for roles (e.g., `.button`, `.adjustable`, `.selected`) to improve navigation.
- Hit areas must be at least 44x44 points. Larger targets are encouraged for complex gestures or when multiple fingers are used.
- Circular or segmented controls (e.g., the circular playback control) must have each segment at least a 48° arc and a minimum height of 56 points.

---

## 4.4 VoiceOver Behavior and Navigation

- VoiceOver focus order should be logical and consistent with the visual layout.
- For dynamically updated elements (e.g., meters, timers):
  - Use `UIAccessibility.post(notification: .announcement, argument: "...")` judiciously to notify users of critical state changes without overwhelming them.
  - Avoid verbatim announcements on every meter update to reduce noise; summarize changes only on significant events.
- Group related controls into logical accessibility containers using `.accessibilityElement(children: .contain)`.

---

## 4.5 Visual Contrast and Color Usage

- All UI elements must maintain a contrast ratio ≥ 4.5:1 against their background.
- Red and green colors must not be the only means to communicate state; use shapes, patterns, or icons as an additional differentiator.
- Provide alternative styling for color-blind users, especially for status indicators (e.g., clip indicators, error banners).

---

## 4.6 Focus and Interaction Management

- Ensure that modal dialogs, sheets, and overlays trap VoiceOver focus within their bounds.
- When modals open or close, announce the change to VoiceOver and update focus appropriately.
- Disable interactive elements under the lock mode with clear accessible status announcements.
- Ensure gesture-based controls (e.g., long-press to unlock) provide verbal feedback on hold duration and completion.

---

## 4.7 Accessibility Testing Guidelines

- Perform routine testing on actual iOS devices using VoiceOver enabled.
- Test all UI states including error states, disabled controls, and loading/processing indicators.
- Validate Dynamic Type support by toggling font sizes up to the maximum (XXL).
- Confirm sufficient visual contrast using software tools or manual inspection.
- Ensure that keyboard navigation (hardware keyboard or switch control) is usable where applicable.
- Include accessibility validations in Snapshot and UI tests where possible using testing frameworks (XCTest, ViewInspector).

---

## 4.8 Internationalization and Localization

- Accessibility labels and hints must be localizable into supported languages (English, Russian).
- Ensure right-to-left (RTL) language support does not break layout or accessibility order.
- Provide localized audio cues and haptic feedback descriptions as needed.

---

## 4.9 Summary Accessibility Checklist

| Requirement                           | Description                                                  | Verification Method               |
|-------------------------------------|--------------------------------------------------------------|---------------------------------|
| Dynamic Type Support                 | Text scales smoothly up to XXL size without truncation      | Device testing, UI snapshots    |
| VoiceOver Labels and Hints          | Clear, concise, and descriptive labels and hints            | VoiceOver manual exploration    |
| Logical Focus Order                 | Sequential, intuitive traversal of UI elements              | VoiceOver exploration, audits   |
| Visual Contrast                     | Minimum 4.5:1 contrast across all UI elements                | Contrast analyzers, visual tests|
| Hit Target Size                    | Minimum 44x44 point tappable controls                         | Manual interaction tests        |
| Color Independence                 | Information not conveyed by color alone                       | Manual tests with color filters |
| Modal Focus Management             | Focus trapped within modals and announcements updated        | VoiceOver modal tests            |
| Gesture Feedback                  | Verbal and haptic feedback for gesture interactions           | Manual test with VoiceOver       |
| Localization                      | Accessibility texts localizable and adapted for RTL          | Localization audits              |

---

By strictly following these guidelines and verifying them through automated and manual tests, MicrosCheck will provide an inclusive and accessible experience for all users.
