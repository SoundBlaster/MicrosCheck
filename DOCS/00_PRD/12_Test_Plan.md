# 12. Test Plan

## 1. Unit Tests

**Purpose:** To verify the correctness of individual components in isolation.

**Contents:**

- Meters: Test RMS (Root Mean Square) and Peak audio levels.
- Recording Accuracy: Ensure the length of recordings is as expected.
- DPC Without Clicks: Validate "DPC" (possibly "Direct Playback Control" or similar) operates noiselessly.
- A-B Boundaries: Confirm A-B repeat/marking boundaries function as intended.

## 2. Instrumental Tests

**Purpose:** To measure system-level metrics and performance.

**Contents:**

- CPU/Energy: Measure CPU usage and energy consumption during operation.
- Background Recording: Record in the background for 60 minutes to ensure stability and accuracy.

## 3. UI Tests

**Purpose:** To ensure user interface flows work as expected.

**Contents:**

- REC → PAUSE → RESUME → STOP: Test main recording flow scenarios.
- Rewinds: Verify rewind functionality.
- Bookmarks: Ensure adding and navigating bookmarks works.
- File Deletion: Confirm users can delete recordings as intended.

## 4. Regression Tests

**Purpose:** To confirm that core features continue to work after changes.

**Contents:**

- 20 Scripts: Run scripted tests covering all core features.
- Smoke Tests: Perform basic checks on app launch and essential operations.
