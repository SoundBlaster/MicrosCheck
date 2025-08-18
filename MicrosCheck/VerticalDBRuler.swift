//
//  VerticalDBRuler.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 2024-06-12.
//

import SwiftUI

/// A vertical decibel level ruler view that displays tick marks and labels from minDb to maxDb.
/// Tick marks are spaced by `tickStep` decibels. Labels scale with Dynamic Type.
/// Designed to align vertically with audio meter bars for consistent UX.
struct VerticalDBRuler: View {

    /// Minimum decibel level (usually -60).
    let minDb: Int

    /// Maximum decibel level (usually 0).
    let maxDb: Int

    /// Tick step value in decibels (e.g., 10).
    let tickStep: Int

    /// The width of the ruler in points.
    let rulerWidth: CGFloat

    /// The color of tick marks and labels.
    let tickColor: Color

    /// Internal spacing between ticks vertically will be computed.

    /// Initialize with default parameters commonly used for audio meters.
    init(
        minDb: Int = -60,
        maxDb: Int = 0,
        tickStep: Int = 10,
        rulerWidth: CGFloat = 30,
        tickColor: Color = .primary
    ) {
        self.minDb = minDb
        self.maxDb = maxDb
        self.tickStep = tickStep
        self.rulerWidth = rulerWidth
        self.tickColor = tickColor
    }

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let totalTicks = (maxDb - minDb) / tickStep + 1

            // Vertical spacing between ticks
            let tickSpacing = height / CGFloat(totalTicks - 1)

            ZStack(alignment: .leading) {
                // Draw ticks and labels
                ForEach(0..<totalTicks, id: \.self) { index in
                    let dbValue = maxDb - index * tickStep
                    // y-position from top down
                    let yPosition = CGFloat(index) * tickSpacing

                    Group {
                        // Tick line
                        Rectangle()
                            .fill(tickColor)
                            .frame(width: 8, height: 1)
                            .position(x: 8, y: yPosition)

                        // Label text, right aligned and vertically centered with tick
                        Text("\(dbValue)dB")
                            .font(.footnote)
                            .foregroundColor(tickColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(width: rulerWidth - 12, alignment: .trailing)
                            .position(x: rulerWidth - (rulerWidth - 12) / 2, y: yPosition)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Decibel level ruler")
        }
        .frame(width: rulerWidth)
    }
}

#if DEBUG
    struct VerticalDBRuler_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                VStack {
                    VerticalDBRuler()
                        .frame(height: 200)
                        .padding()
                    Text("Default VerticalDBRuler").foregroundColor(.secondary)
                }
                .previewLayout(.sizeThatFits)

                VStack {
                    VerticalDBRuler(
                        minDb: -80, maxDb: 0, tickStep: 20, rulerWidth: 40, tickColor: .red
                    )
                    .frame(height: 300)
                    .padding()
                    Text("Custom VerticalDBRuler with red ticks").foregroundColor(.secondary)
                }
                .previewLayout(.sizeThatFits)

                VStack {
                    VerticalDBRuler()
                        .frame(height: 200)
                        .padding()
                        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                    Text("Accessibility XXL Dynamic Type").foregroundColor(.secondary)
                }
                .previewLayout(.sizeThatFits)
            }
        }
    }
#endif
