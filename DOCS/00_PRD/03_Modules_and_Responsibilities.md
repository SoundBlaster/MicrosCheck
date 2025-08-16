# 3. Modules and Responsibilities

## RecorderModule

### State Management
Manages the lifecycle of recording sessions with clearly defined states: `idle → recording → paused → stopping → saving → idle`. Ensures correct transitions between states and guards against illegal or unexpected state changes to maintain recording integrity.

### Input Source Selection
Allows users to switch between input sources such as the built-in microphone and headset. Handles relevant configuration options including hardware availability checks, permissions, and fallback scenarios.

### Audio Configuration
Supports configurable audio parameters like sample rate, bitrate, and channel mode (mono/stereo). Enables users to select recording quality settings appropriate for their needs.

### Level Meters
Provides real-time RMS and peak audio level monitoring per channel. Exposes an interface for the UI to display accurate visual feedback of audio input levels.

### Recording Metadata
Maintains detailed metadata for the current recording session, including file name, file size, audio format, recording timestamps, and user-defined tags.

### Pause/Resume Support
Enables seamless pausing and resuming of recordings, preserving state and ensuring no data loss or corruption.

### Error Handling
Detects and reports errors such as hardware access failure, storage limitations, or permission denials to the UI for user notification and recovery actions.

### Extensibility
Designed with extensibility in mind to support future enhancements such as additional input devices (e.g., Bluetooth microphones) and new audio encoding formats.

## PlayerModule

### Transport Controls
Implements core playback state machine with states: `stopped`, `playing`, `paused`, and `seeking`. Manages transition logic and updates UI accordingly to reflect current playback status.

### Seeking Functionality
Supports user interaction for seeking within playback:
- Tap gestures to seek ±10 seconds.
- Holding triggers repeated seek steps every 200ms.
- Optionally provides audible feedback ("with sound") during seeking for better orientation.

### Playback Speed and Pitch Control (DPC)
Integrates `AVAudioUnitTimePitch` to allow dynamic adjustment of playback rate (0.5x to 2.0x) and pitch shifts (±1200 cents), enabling flexible audio playback effects.

### Volume and Balance
Provides comprehensive volume control including:
- Master volume ranging from 0% to 200%.
- Independent left and right channel gain adjustments between -60 dB and +12 dB.
Implemented via `AVAudioMixerNode` combined with spatial panning and mixing nodes.

### A–B Looping
Allows users to define an A point and a B point in the audio timeline to loop playback continuously between the two markers. Includes functions to reset or clear the loop.

### UI Lock
Offers an overlay lock feature to prevent accidental UI interactions during playback. Unlocking requires holding the lock button for 2 seconds to ensure intentional user action.

### Error Management
Gracefully handles playback errors such as missing files or unsupported formats, notifying the user and preventing crashes.

### Bookmark Integration
Supports integration with bookmarks, allowing quick jumps to bookmarked positions and resuming from last saved playback positions.


## FileManagerModule

### Directory Management
Manages the `Recordings/` directory, handling creation, listing, and organization of recording files. Calculates and reports disk usage and available space.

### Metadata Handling
Associates each audio file with a corresponding `*.json` metadata file containing last playback position, bookmarks, tags, user notes, and detailed audio information.

### File Operations
Supports core file operations including copy, delete, rename, and attribute queries on both audio files and their metadata files.

### Audio Attribute Extraction
Leverages `AVAsset` to extract detailed audio attributes such as duration, format, number of channels, and sample rate for use in the UI and metadata.

### Import/Export
Facilitates importing audio and metadata from external sources and exporting files and associated metadata for backup or sharing.

### Error Handling
Detects and manages file-related errors such as storage limitations, permission issues, file corruption, or missing files to maintain stability.

## Bookmarks (T‑MARK)

### Quick Marking
Enables users to instantly add a timestamped bookmark during playback or recording with a simple tap for quick reference.

### Bookmark Details
Provides a modal interface for entering bookmark names or comments, activated by holding the mark button ("Option"), allowing detailed annotation.

### Bookmark Listing
Displays all bookmarks associated with a recording file in a list with functionalities to jump to, edit, or delete individual bookmarks.

### Bookmark Persistence
Saves bookmarks persistently in the associated metadata file and restores them when the audio file is reloaded.

### Sharing/Export
Supports exporting bookmarks and notes for sharing with other apps or for backup purposes.

## Waveform

### Live Waveform Rendering
Continuously samples RMS audio buffers in real time and renders the waveform using Canvas or Metal technologies to provide responsive visual feedback during recording and playback.

### Offline Waveform Generation
Processes audio files offline to generate preview waveform data, which is cached in `.wave` format (JSON or binary) for fast and efficient UI rendering later.

### Waveform Caching
Caches waveform data to optimize performance and reduce processing when displaying waveforms for large or multiple audio files.

### Custom Rendering
Supports customization of waveform display styles, including different color schemes, zoom levels, and scaling options.

### Performance Optimization
Utilizes efficient algorithms and hardware acceleration to ensure smooth waveform rendering with minimal latency and CPU load.

### Error Handling
Detects and manages errors related to waveform data generation or rendering failures, maintaining application stability.
