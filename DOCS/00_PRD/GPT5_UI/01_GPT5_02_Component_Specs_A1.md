# 2) Component Specs: A1 Top Waveform & Timeline

### A1a Live Waveform Visualization
Inputs: TimelineState, float arrays or images.  
Outputs: none.  
States: fixed viewport with playhead.  
Acceptance Criteria: update ≥ 20Hz, latency ≤ 16ms drift.

### A1b Vertical Decibel Level Ruler
Inputs: dB min/max.  
AC: ticks readable.

### A1c Time Ruler H-M-S
Inputs: TimelineState.  
AC: aligned ticks, accuracy ±50ms.
