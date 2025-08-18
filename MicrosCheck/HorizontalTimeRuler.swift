//
//  HorizontalTimeRuler.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 2024-06-12.
//

import SwiftUI

/// A horizontal time ruler that displays time grid ticks and labels aligned with a playback timeline.
/// Shows major ticks every `tickStep` seconds, labels in hh:mm:ss or mm:ss format, and a playhead marker.
/// Supports dynamic updates for current playhead position and total duration.
struct HorizontalTimeRuler: View {
    // Total duration of the timeline in seconds
    let duration: TimeInterval
    // Current position of the playhead in seconds
    let currentTime: TimeInterval
    // Tick step in seconds for major ticks and labels (default 5s)
    let tickStep: TimeInterval
    // Height of the ruler view
    let rulerHeight: CGFloat
    // Color for ticks and labels
    let tickColor: Color
    // Color for playhead line and label
    let playheadColor: Color

    init(
        duration: TimeInterval,
        currentTime: TimeInterval,
        tickStep: TimeInterval = 5,
        rulerHeight: CGFloat = 30,
        tickColor: Color = .primary,
        playheadColor: Color = .accentColor
    ) {
        self.duration = max(0, duration)
        self.currentTime = min(max(0, currentTime), duration)
        self.tickStep = tickStep > 0 ? tickStep : 5
        self.rulerHeight = rulerHeight
        self.tickColor = tickColor
        self.playheadColor = playheadColor
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = rulerHeight
            // Number of ticks to draw, rounded up
            let numberOfTicks = Int(ceil(duration / tickStep)) + 1
            // Horizontal spacing between ticks
            let tickSpacing = width / CGFloat(duration == 0 ? 1 : duration) * CGFloat(tickStep)

            ZStack(alignment: .topLeading) {
                // Draw ticks and labels
                ForEach(0..<numberOfTicks, id: \.self) { index in
                    let tickTime = Double(index) * tickStep
                    let xPos = CGFloat(tickTime / duration) * width

                    VStack(spacing: 2) {
                        // Tick line
                        Rectangle()
                            .fill(tickColor)
                            .frame(width: 1, height: 8)

                        // Label text formatted by time
                        Text(timeLabel(for: tickTime))
                            .font(.caption2)
                            .foregroundColor(tickColor)
                            .fixedSize()
                    }
                    .position(x: xPos, y: 15)  // position with some padding from top
                }

                // Playhead line
                if duration > 0 {
                    let playheadX = CGFloat(currentTime / duration) * width
                    Rectangle()
                        .fill(playheadColor)
                        .frame(width: 2, height: height)
                        .position(x: playheadX, y: height / 2)

                    // Playhead time label
                    Text(timeLabel(for: currentTime))
                        .font(.caption2)
                        .bold()
                        .foregroundColor(playheadColor)
                        .background(Color(white: 1.0, opacity: 0.8))
                        .cornerRadius(4)
                        .offset(x: playheadX < 40 ? 20 : -20, y: height - 12)
                        .position(x: playheadX, y: height - 8)
                }
            }
            .frame(height: height)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Playback time ruler")
            .accessibilityValue(
                "Current time \(accessibilityFormattedTime(for: currentTime)) of total \(accessibilityFormattedTime(for: duration))"
            )
        }
        .frame(height: rulerHeight)
    }

    /// Format time for label display as h:mm:ss or mm:ss
    private func timeLabel(for time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "--:--" }
        let totalSeconds = Int(time)
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    /// Format time for accessibility announcement (spoken)
    private func accessibilityFormattedTime(for time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "unknown" }
        let totalSeconds = Int(time)
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        var components: [String] = []
        if h > 0 { components.append("\(h) hour\(h > 1 ? "s" : "")") }
        if m > 0 { components.append("\(m) minute\(m > 1 ? "s" : "")") }
        components.append("\(s) second\(s != 1 ? "s" : "")")
        return components.joined(separator: ", ")
    }
}

#if DEBUG
    struct HorizontalTimeRuler_Previews: PreviewProvider {
        struct PreviewWrapper: View {
            @State private var currentTime: TimeInterval = 0
            let duration: TimeInterval = 203  // 3min 23s

            var body: some View {
                VStack(spacing: 20) {
                    HorizontalTimeRuler(
                        duration: duration,
                        currentTime: currentTime,
                        tickStep: 5
                    )
                    .frame(height: 40)
                    Slider(value: $currentTime, in: 0...duration)
                        .padding()
                }
                .padding()
            }
        }

        static var previews: some View {
            PreviewWrapper()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)

            PreviewWrapper()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
#endif
