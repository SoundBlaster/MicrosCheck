//
//  LiveWaveformView.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 2024-06-12.
//

import Combine
import SwiftUI

/// A SwiftUI view that renders live audio waveform bars from a stream of audio amplitude samples.
/// It expects an array of recent RMS or peak decibel values for left or right audio channel and
/// draws them as vertical bars or line waveform.
///
/// The view supports smooth horizontal scrolling to visualize audio timeline progression.
///
/// Usage:
/// Bind the `samples` property to your ViewModel or audio engine's published audio level data, updated ≥ 20 Hz.
///
struct LiveWaveformView: View {
    // MARK: - Public Props

    /// Recent audio level samples in dB, typically -60 to 0. The oldest sample is at index 0.
    let samples: [Float]

    /// Color of the waveform bars.
    let waveformColor: Color

    /// Max displayable height for the waveform bars in points.
    let maxBarHeight: CGFloat

    /// Max number of samples to keep. Used for trimming samples if needed.
    let maxSamplesCount: Int

    // MARK: - Init

    init(
        samples: [Float],
        waveformColor: Color = .accentColor,
        maxBarHeight: CGFloat = 60,
        maxSamplesCount: Int = 100
    ) {
        self.samples = Array(samples.suffix(maxSamplesCount))
        self.waveformColor = waveformColor
        self.maxBarHeight = maxBarHeight
        self.maxSamplesCount = maxSamplesCount
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            let stepWidth = width / CGFloat(maxSamplesCount)
            let baseline = height / 2

            Canvas { ctx, size in
                var path = Path()
                for (index, level) in samples.enumerated() {
                    // Normalize dB level from -60...0 to 0...1
                    let normalized = normalizedDb(level)

                    // Map normalized level to bar height
                    let barHeight = CGFloat(normalized) * maxBarHeight
                    // Center bars vertically around baseline
                    let x = CGFloat(index) * stepWidth + stepWidth / 2

                    // Draw vertical bar as a rounded rectangle
                    let rect = CGRect(
                        x: x - stepWidth / 3,
                        y: baseline - barHeight / 2,
                        width: stepWidth * 2 / 3,
                        height: barHeight)

                    path.addRoundedRect(
                        in: rect, cornerSize: CGSize(width: stepWidth / 4, height: stepWidth / 4))
                }
                ctx.fill(path, with: .color(waveformColor))
            }
            .accessibilityLabel(Text("Live audio waveform"))
            .accessibilityAddTraits(.isImage)
        }
        .frame(height: maxBarHeight)
        .background(Color.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Helpers

    /// Normalize dB level from typical range (-60 to 0) to 0...1 linear scale for UI.
    /// Values below -60 dB treated as 0.
    private func normalizedDb(_ db: Float) -> Float {
        let minDb: Float = -60
        if db < minDb { return 0 }
        return max(0, min(1, (db - minDb) / (-minDb)))
    }
}

// MARK: - Preview

#if DEBUG
    struct LiveWaveformView_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 16) {
                LiveWaveformView(
                    samples: sampleLevels1,
                    waveformColor: .green,
                    maxBarHeight: 80
                )
                .frame(height: 80)

                LiveWaveformView(
                    samples: sampleLevels2,
                    waveformColor: .orange,
                    maxBarHeight: 60
                )
                .frame(height: 60)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .background(Color(white: 0.95))
        }

        static let sampleLevels1: [Float] = (0..<100).map {
            sin(Float($0) / 100 * 2.0 * .pi) * -30 + -30
        }

        static let sampleLevels2: [Float] = (0..<100).map {
            let v = sin(Float($0) / 10) * 20
            return max(-60, min(0, v))
        }
    }
#endif
