# Improvements for PRD

## 1. Balance the level of detail across sections

### 1.1. **UI/UX**: Expand specifications with concrete details. 
 
- [x] Define expected animations (e.g., waveform updates, button state transitions, lock/unlock overlay).  
- [x] Enumerate UI states for all interactive elements (REC → PAUSE → RESUME → STOP, A/B loop states, lock/unlock).  
- [x] Document adherence to a design system (color palette, typography, spacing rules, iconography guidelines).  

### 1.2. **Test Plan**: Strengthen by explicitly defining expected results for each scenario.  

- [x] Add negative test cases (e.g., attempting playback on corrupted file, deleting while recording, insufficient storage).  
- [x] Specify pass/fail criteria for UI flows (e.g., “After pressing REC, the timer must start within 200ms”).  

## 2. Extend Non-Functional Requirements (NFR)

### 2.1. Add measurable targets for:
  
- [x] **Latency**: end-to-end delay between microphone input and visual meter update / playback feedback.  
- [x] **Maximum recording length**: define supported continuous recording duration (e.g., ≥ 24h without crash).  
- [x] **AB-loop stability**: specify tolerance (e.g., ≤ 20 ms deviation at loop boundary, no audio artifacts).  
- [x] **Bookmark accuracy**: bookmarks must resolve to within ±50 ms of the intended position.  

## 3. Security and Privacy

### 3.1. Define explicit **file storage policy**:

  **REQUIRED:** This section must explicitly document the application's file storage policy, including: 

  - [x] Clarify whether files remain strictly local or are synchronized/backed up to iCloud.  
  - [x] State if local storage uses encryption (at rest / in transit).   
  - [x] Storage location (local sandbox only, e.g., `/Documents/Recordings/…`).  
  - [x] Whether files are synchronized or backed up to iCloud (be explicit if not).  
  - [x] Encryption-at-rest and in-transit status for all stored data (audio files, metadata, etc.).  
  - [x] Reference and align with non-functional requirements (see section 8) and security/privacy statements elsewhere in the PRD.  
  - [x] Any exceptions or roadmap notes regarding remote/cloud storage.

### 3.2. Specify the **file deletion model**:  

  - [x] Permanent deletion (irreversible) vs. “soft delete” (move to in-app trash with recovery option). 
  - [x] Define retention period if trash model is chosen.  

## 4. Integrations

### 4.1. Include at least a **baseline file export scenario**:
  
- [x] Support iOS Share Sheet for exporting audio files to other apps (Mail, Messages, Drive, etc.).  
- [x] Define supported export formats (e.g., AAC by default; MP3 optional in roadmap).  
- [x] Specify metadata inclusion (filename, duration, creation date) in exported payload.  

## 5. QA and Stress Testing

### 5.1. Introduce a dedicated **Stress Test** section covering:
  
- [x] Very long recordings (e.g., 8h+) to validate memory stability and file integrity.  
- [x] Battery drain test: measure % per hour during continuous recording and playback.  
- [x] Disk space exhaustion: behavior when storage runs low (graceful stop, error messaging, file integrity preserved).  
- [x] Large library handling: smooth UI performance with thousands of recordings.  
