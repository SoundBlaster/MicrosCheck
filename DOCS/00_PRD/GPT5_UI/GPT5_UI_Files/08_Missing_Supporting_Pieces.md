# 8. Missing/Supporting Pieces

## Goal

To define the scope, deliverables, success criteria, and detailed technical requirements for the missing or supporting UI components and infrastructure required to fully implement the GPT5 UI project. These components are essential for completing the user experience, configuration capabilities, and systemic consistency specified in the overall product requirements document.

---

## Primary Deliverables

- Settings Sheet integration for user preferences.
- Error Banner/Toast reusable UI component.
- Permission Explainer Sheet for post-denial user guidance.
- Theming system incorporating tokens for spacing, radius, and typography.
- Support services protocols for Haptics and Analytics.
- Preview Providers with deterministic mocks & fixtures for golden level/wave chunk data.
- Localization infrastructure enabling multi-language support.

---

## Success Criteria

- All supporting components bind dynamically to production data models.
- Settings Sheet allows full configuration for recording formats, pre-roll toggling, DPC cycle selection, and UI theme with persistence.
- Error Banner provides consistent, accessible, and reusable feedback for error states across views.
- Permission Explainer Sheet appears post denial with clear user messaging and action options.
- Theming tokens enable consistent styling and support dynamic type scaling and accessibility.
- Haptics and Analytics services conform to defined protocols and allow easy enable/disable.
- Preview Providers generate deterministic mock data for repeatable testing and snapshot validation.
- Localization system supports seamless language switching with correct integration into UI strings and formats.

---

## Constraints and Assumptions

- Architecture follows MVVM with strict unidirectional data flow and all UI updates on @MainActor.
- All components support iOS 16+ minimum deployment.
- Data binding uses Combine or async streams as per project standards.
- External dependencies must be lightweight and maintain compatibility with target iOS versions.
- Haptics and Analytics are optional with stub implementations allowed.
- Localization infrastructure supports runtime language changes and pluralization rules.
- All UI elements meet accessibility standards for VoiceOver, color contrast, and dynamic type.

---

## Detailed TODO Plan

### 1. Settings Sheet

- **Scope:** Implement the Settings Sheet UI that allows users to configure recording format presets, toggle pre-roll, manage DPC cycle lists, and select app theme.
- **Subtasks:**
  - Define data models for recording formats, pre-roll flag, DPC cycles, and theme selection.
  - Create SwiftUI views that bind and update these models.
  - Implement persistence for settings changes.
  - Add accessibility labels and dynamic type support.
- **Priority:** High
- **Effort Estimate:** Medium
- **Acceptance:** Settings should reflect model state and persist after app restarts.

### 2. Error Banner / Toast Component

- **Scope:** Develop a reusable error banner component that can display error messages in a dismissible banner/toast style.
- **Subtasks:**
  - Define error message model and state management.
  - Build reusable SwiftUI component with animation and dismissal actions.
  - Ensure accessibility with descriptive VoiceOver hints.
- **Priority:** High
- **Effort Estimate:** Low
- **Acceptance:** Component is reusable in multiple views and accessibility verified.

### 3. Permission Explainer Sheet

- **Scope:** Provide a modal sheet shown after user denies critical permissions, explaining why the permissions are needed and how to enable them.
- **Subtasks:**
  - Design explanation text and actionable buttons.
  - Bind visibility state to permission check results.
  - Integrate with system authorization flow.
- **Priority:** Medium
- **Effort Estimate:** Low
- **Acceptance:** Sheet appears consistently post-denial and guides user correctly.

### 4. Theming Tokens

- **Scope:** Define a set of design tokens for spacing, border radius, and typography to unify UI appearance.
- **Subtasks:**
  - Create token definitions in a Swift-friendly structure.
  - Refactor existing views to consume tokens.
  - Support dynamic type scaling and color scheme changes.
- **Priority:** High
- **Effort Estimate:** Medium
- **Acceptance:** All components consume tokens without visual regressions.

### 5. Haptics Service Protocol

- **Scope:** Design and implement a protocol for haptic feedback services with stub and production implementations.
- **Subtasks:**
  - Define protocol interface.
  - Provide mock implementation for testing.
  - Integrate production implementation using UIKit haptics API.
- **Priority:** Medium
- **Effort Estimate:** Low
- **Acceptance:** Service can be switched out without breaking consuming components.

### 6. Analytics Service Protocol

- **Scope:** Define a protocol to track user interactions and events, with stub and optionally real implementations.
- **Subtasks:**
  - Define event logging interface.
  - Implement stub that disables analytics.
  - Optionally integrate real analytics backend (outside scope).
- **Priority:** Low
- **Effort Estimate:** Low
- **Acceptance:** Analytics calls do not impact UI performance and can be disabled.

### 7. Preview Providers with Deterministic Mocks

- **Scope:** Create preview data providers supplying fixed, repeatable data samples including golden levels and waveform chunks for UI preview and snapshot testing.
- **Subtasks:**
  - Define mock data sets and fixtures.
  - Implement PreviewProvider extensions using these mocks.
  - Validate previews under light and dark mode.
- **Priority:** Medium
- **Effort Estimate:** Medium
- **Acceptance:** Snapshots match expected output consistently.

### 8. Localization Infrastructure

- **Scope:** Establish support for multiple languages and locale-sensitive formats in the UI.
- **Subtasks:**
  - Implement base localization file structure.
  - Integrate localized strings into views.
  - Support runtime language switching.
  - Ensure pluralization and accessibility compliance.
- **Priority:** Medium
- **Effort Estimate:** High
- **Acceptance:** UI text translates correctly and switches without restart.

---

## PRD-like Summary

### Feature Description and Rationale

These supporting pieces are crucial for delivering a complete, user-friendly, and maintainable GPT5 UI system. Introducing modular settings management, clear error feedback, permission guidance, unified theming, haptic and analytic feedback mechanisms, deterministic previewing, and multilingual support ensures product quality meets user expectations and project success criteria.

### Functional Requirements

- UI elements bind dynamically to data and persist user selections.
- Components support accessibility and dynamic type.
- Error and permission flows guide users effectively.
- Services for haptics and analytics are pluggable and optional.
- Preview and localization systems enable thorough testing and wider audience reach.

### Non-functional Requirements

- Performance: UI updates must remain smooth, and ancillary services must not degrade core app responsiveness.
- Scalability: The theming and localization systems allow easy extension to new styles and languages.
- Security and Compliance: Permissions explanations respect user privacy and app store requirements.

### User Interaction Flows

- User sets preferences in Settings Sheet, which immediately apply and persist.
- Errors show promptly with dismissible banners.
- After denying permissions, the user sees an explainer with clear next steps.
- UI theme changes adapt instantly to user mode choice or system settings.
- Localization switches seamlessly without disrupting active workflows.

### Edge Cases and Failures

- Persistence failures fall back to default preferences gracefully.
- Permission explainer handles repeated denial without blocking main UI.
- Error banners stack or queue gracefully if multiple errors occur in quick succession.
- Analytics service failures or disablement do not propagate errors or delays.
- Localization missing keys fall back to a default language without crashing.

---