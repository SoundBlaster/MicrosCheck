//
//  WaveformPreviewView.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 2024-06-12.
//

import SwiftUI

/// A SwiftUI view that renders a compact waveform preview from cached waveform data.
/// Suitable for display in file lists or detail views as a static waveform image.
///
/// Displays RMS or peak segment data as a simplified bar graph or line.
///
/// Usage:
/// Bind to a optional WaveformData instance. If nil, a placeholder is shown.
///
struct WaveformPreviewView: View {
    // Cached waveform data to render
    let waveformData: WaveformData?

    /// Color for the waveform bars or line
    let waveformColor: Color

    /// Height of the waveform preview view
    let maxHeight: CGFloat

    /// Whether to show RMS or peak values
    let usePeakValues: Bool

    init(
        waveformData: WaveformData?,
        waveformColor: Color = .accentColor,
        maxHeight: CGFloat = 40,
        usePeakValues: Bool = true
    ) {
        self.waveformData = waveformData
        self.waveformColor = waveformColor
        self.maxHeight = maxHeight
        self.usePeakValues = usePeakValues
    }

    var body: some View {
        GeometryReader { geo in
            if let waveformData = waveformData {
                let width = geo.size.width
                let height = geo.size.height
                let segmentCount = waveformData.segments.count
                let barWidth = max(width / CGFloat(segmentCount), 1)

                Canvas { ctx, size in
                    var path = Path()
                    for (index, segment) in waveformData.segments.enumerated() {
                        // Choose RMS or peak value in dB
                        let db = usePeakValues ? segment.peakDb : segment.rmsDb
                        let normalized = normalizedDb(db)
                        let barHeight = CGFloat(normalized) * height
                        let x = CGFloat(index) * barWidth + barWidth / 2

                        let rect = CGRect(
                            x: x - barWidth / 2,
                            y: height - barHeight,
                            width: barWidth,
                            height: barHeight)

                        path.addRect(rect)
                    }
                    ctx.fill(path, with: .color(waveformColor))
                }
                .accessibilityLabel(Text("Waveform preview"))
                .accessibilityAddTraits(.isImage)

            } else {
                // Placeholder when no waveform data
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Text("No waveform")
                            .font(.caption)
                            .foregroundColor(.gray)
                    )
            }
        }
        .frame(height: maxHeight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(Color.black.opacity(0.05))
    }

    /// Normalize dB level from typical range (-60 to 0) to 0...1 linear scale for UI.
    /// Values below -60 dB treated as 0.
    private func normalizedDb(_ db: Float) -> Float {
        let minDb: Float = -60
        if db < minDb { return 0 }
        return max(0, min(1, (db - minDb) / (-minDb)))
    }
}

#if DEBUG
    struct WaveformPreviewView_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 16) {
                WaveformPreviewView(
                    waveformData: sampleWaveformData, waveformColor: .green, maxHeight: 60
                )
                .frame(height: 60)
                .padding()
                WaveformPreviewView(
                    waveformData: sampleWaveformData, waveformColor: .orange, maxHeight: 40,
                    usePeakValues: false
                )
                .frame(height: 40)
                .padding()
                WaveformPreviewView(waveformData: nil, maxHeight: 40)
                    .frame(height: 40)
                    .padding()
            }
            .previewLayout(.sizeThatFits)
            .background(Color(white: 0.95))
        }

        static var sampleWaveformData: WaveformData {
            let segments = (0..<100).map { i -> WaveformSegment in
                let rms = sin(Float(i) / 10) * 20 - 40
                let peak = max(rms, rms + 10)
                return WaveformSegment(rmsDb: max(-60, min(0, rms)), peakDb: max(-60, min(0, peak)))
            }
            return WaveformData(segments: segments, segmentDuration: 0.1, totalDuration: 10)
        }
    }
#endif
