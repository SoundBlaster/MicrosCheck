# UI Structure and Hierarchy Diagram (Mermaid)

```mermaid
graph TD
    A[Main Screen]

    %% Main divisions
    A --> A1[Top Waveform and Timeline]
    A --> A2[Recording Information Panel]
    A --> A3[Navigation and Action Buttons]
    A --> A4[Search and Filter Controls Panel]
    A --> A5[Transport Controls]
    A --> A6[Central Circular Playback Control]
    A --> A7[UI Lock and Info Icons]

    %% A1 - Top Waveform and Timeline details
    A1 --> A1a[Live Waveform Visualization]
    A1 --> A1b[Vertical Decibel Level Ruler]
    A1 --> A1c[Time Ruler (H:M:S)]

    %% A2 - Recording Information Panel
    A2 --> A2a[Left Block (Vertical Stack)]
    A2 --> A2b[Right Block (Vertical Stack)]

    %% A2a details
    A2a --> A2a1[Current Recording Status Indicator ([• REC])]
    A2a --> A2a2[Elapsed Time Display]
    A2a --> A2a3[Audio Format & Bitrate Info]

    %% A2b details
    A2b --> A2b1[File Name of Active Recording]
    A2b --> A2b2[File Size Indicator]
    A2b --> A2b3[Audio Meter Display]

    %% A2b3 audio meter display details
    A2b3 --> A2b3a[Left Channel Level Meter (-60 to 0 dB)]
    A2b3 --> A2b3b[Right Channel Level Meter (-60 to 0 dB)]
    A2b3a --> A2b3a1[Current Loudness]
    A2b3a --> A2b3a2[Trailing dB Readings]
    A2b3b --> A2b3b1[Current Loudness]
    A2b3b --> A2b3b2[Trailing dB Readings]

    %% A3 - Navigation and Action Buttons
    A3 --> A3a[Back Button (< Back)]
    A3 --> A3b[Home Button]
    A3 --> A3c[Time-Mark (T-MARK) Button]
    A3 --> A3d[Options/Settings Button]

    %% A4 - Search and Filter Controls
    A4 --> A4a[Search Text Input]
    A4 --> A4b[Appearance Mode Switch Button]
    A4 --> A4c[Favorites Access Button]
    A4 --> A4d[Waveform View Style Toggle Button]

    %% A5 - Transport Controls
    A5 --> A5a[Large Circular Stop Button]
    A5 --> A5b[Recording Status Vertical Stack]
    A5 --> A5c[Large Circular Record/Pause Button]

    %% A5b Recording Status details
    A5b --> A5b1[Label [RECORDING]]
    A5b --> A5b2[Blinking Red Recording Indicator]

    %% A6 - Central Circular Playback Control
    A6 --> A6a[Center Play/Pause Button]
    A6 --> A6b[Left Segment Rewind Button]
    A6 --> A6c[Right Segment Fast Forward Button]
    A6 --> A6d[Bottom Segment A-B Loop Toggle Indicator ([A-B ˇ])]
    A6 --> A6e[Top Segment DPC Toggle ([DPC ˆ])]

    %% A7 - UI Lock and Info Icons
    A7 --> A7a[Lock Button (Bottom Left Corner)]
    A7 --> A7b[Info Button (Bottom Right Corner)]

```
