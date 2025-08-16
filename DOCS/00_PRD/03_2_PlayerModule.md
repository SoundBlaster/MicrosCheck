# PlayerModule

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
