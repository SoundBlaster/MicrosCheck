# Improvements for PRD

## 1. {NOT DONE} Balance the level of detail across sections

- [ ] **UI/UX**: Expand specifications with concrete details.  
  - [ ] Define expected animations (e.g., waveform updates, button state transitions, lock/unlock overlay).  
  - [ ] Enumerate UI states for all interactive elements (REC → PAUSE → RESUME → STOP, A/B loop states, lock/unlock).  
  - [ ] Document adherence to a design system (color palette, typography, spacing rules, iconography guidelines).  
- [ ] **Test Plan**: Strengthen by explicitly defining expected results for each scenario.  
  - [ ] Add negative test cases (e.g., attempting playback on corrupted file, deleting while recording, insufficient storage).  
  - [ ] Specify pass/fail criteria for UI flows (e.g., “After pressing REC, the timer must start within 200ms”).  

## 2. {NOT DONE} Extend Non-Functional Requirements (NFR)

- [ ] Add measurable targets for:  
  - [ ] **Latency**: end-to-end delay between microphone input and visual meter update / playback feedback.  
  - [ ] **Maximum recording length**: define supported continuous recording duration (e.g., ≥ 24h without crash).  
  - [ ] **AB-loop stability**: specify tolerance (e.g., ≤ 20 ms deviation at loop boundary, no audio artifacts).  
  - [ ] **Bookmark accuracy**: bookmarks must resolve to within ±50 ms of the intended position.  

## 3. {NOT DONE} Security and Privacy

- [ ] Define explicit **file storage policy**:  
  - [ ] Clarify whether files remain strictly local or are synchronized/backed up to iCloud.  
  - [ ] State if local storage uses encryption (at rest / in transit).  
- [ ] Specify the **file deletion model**:  
  - [ ] Permanent deletion (irreversible) vs. “soft delete” (move to in-app trash with recovery option).  
  - [ ] Define retention period if trash model is chosen.  

## 4. {NOT DONE} Integrations

- [ ] Include at least a **baseline file export scenario**:  
  - [ ] Support iOS Share Sheet for exporting audio files to other apps (Mail, Messages, Drive, etc.).  
  - [ ] Define supported export formats (e.g., AAC by default; MP3 optional in roadmap).  
  - [ ] Specify metadata inclusion (filename, duration, creation date) in exported payload.  

## 5. {NOT DONE} QA and Stress Testing

- [ ] Introduce a dedicated **Stress Test** section covering:  
  - [ ] Very long recordings (e.g., 8h+) to validate memory stability and file integrity.  
  - [ ] Battery drain test: measure % per hour during continuous recording and playback.  
  - [ ] Disk space exhaustion: behavior when storage runs low (graceful stop, error messaging, file integrity preserved).  
  - [ ] Large library handling: smooth UI performance with thousands of recordings.  
