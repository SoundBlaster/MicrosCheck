import SwiftUI

/// A central circular playback control with segmented tappable areas:
/// - Left: rewind/seek backward
/// - Right: fast forward/seek forward
/// - Center: play/pause toggle
/// - Bottom: A-B loop control (set A, set B, clear loop)
/// - Top: DPC rate selector cycling playback speeds
@MainActor
struct CircularPlaybackControl: View {
    // MARK: - Props

    /// Playback state: playing or paused
    let isPlaying: Bool

    /// Playback rate for DPC, e.g., 1.0 is normal
    let playbackRate: Float

    /// A point for A-B loop, optional
    let aPoint: TimeInterval?

    /// B point for A-B loop, optional
    let bPoint: TimeInterval?

    /// Callbacks for user interactions
    let onPlayPause: () -> Void
    let onSeekBackward: () -> Void
    let onSeekForward: () -> Void
    let onABLoopTapped: () -> Void
    let onDPCRateCycle: () -> Void

    // MARK: - UI constants

    private let circleDiameter: CGFloat = 180
    private let centerButtonDiameter: CGFloat = 80

    var body: some View {
        ZStack {
            // Base circular background
            Circle()
                .fill(Color(.secondarySystemBackground))
                .frame(width: circleDiameter, height: circleDiameter)
                .shadow(radius: 4)

            // Left segment: rewind
            segmentButton(
                label: "Rewind",
                systemImage: "gobackward.10",
                alignment: .leading,
                action: onSeekBackward
            )

            // Right segment: fast forward
            segmentButton(
                label: "Fast Forward",
                systemImage: "goforward.10",
                alignment: .trailing,
                action: onSeekForward
            )

            // Bottom segment: A-B Loop
            VStack {
                Spacer()
                Button(action: onABLoopTapped) {
                    Text(
                        aPoint == nil ? "Set A" : bPoint == nil ? "Set B" : "Clear Loop"
                    )
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.2))
                    .foregroundColor(Color.accentColor)
                    .cornerRadius(20)
                }
                .accessibilityLabel("A B Loop Control")
                .padding(.bottom, 12)
            }
            .frame(width: circleDiameter, height: circleDiameter)

            // Center segment: Play/Pause
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: centerButtonDiameter, height: centerButtonDiameter)
                    .foregroundColor(Color.accentColor)
            }
            .accessibilityLabel(isPlaying ? "Pause playback" : "Play playback")
            .buttonStyle(PlainButtonStyle())

            // Top segment: Dynamic Playback Control (DPC) Rate Selector
            VStack {
                Button(action: onDPCRateCycle) {
                    Text(rateLabel)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(6)
                        .frame(minWidth: 40)
                        .background(Color.accentColor.opacity(0.3))
                        .foregroundColor(Color.accentColor)
                        .cornerRadius(12)
                }
                .accessibilityLabel("Playback speed \(rateLabel)")
                Spacer()
            }
            .frame(width: circleDiameter, height: circleDiameter)
            .padding(.top, 8)
        }
        .frame(width: circleDiameter, height: circleDiameter)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Helpers

    private var rateLabel: String {
        String(format: "%.2fx", playbackRate)
    }

    private func segmentButton(
        label: String,
        systemImage: String,
        alignment: HorizontalAlignment,
        action: @escaping () -> Void
    ) -> some View {
        GeometryReader { geo in
            let size = geo.size
            // Button width approx 1/3rd circle width
            let buttonWidth = size.width / 3
            let buttonHeight = size.height

            HStack {
                if alignment == .leading {
                    Button(action: action) {
                        VStack {
                            Image(systemName: systemImage)
                                .font(.title)
                                .foregroundColor(.primary)
                            Text(label)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(width: buttonWidth, height: buttonHeight)
                        .contentShape(Rectangle())
                    }
                    Spacer()
                } else {  // trailing
                    Spacer()
                    Button(action: action) {
                        VStack {
                            Image(systemName: systemImage)
                                .font(.title)
                                .foregroundColor(.primary)
                            Text(label)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(width: buttonWidth, height: buttonHeight)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
        .frame(width: circleDiameter, height: circleDiameter)
    }
}

// MARK: - Preview

#if DEBUG
    struct CircularPlaybackControl_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                CircularPlaybackControl(
                    isPlaying: true,
                    playbackRate: 1.0,
                    aPoint: nil,
                    bPoint: nil,
                    onPlayPause: { print("PlayPause tapped") },
                    onSeekBackward: { print("Seek Backward tapped") },
                    onSeekForward: { print("Seek Forward tapped") },
                    onABLoopTapped: { print("AB Loop tapped") },
                    onDPCRateCycle: { print("DPC Cycle tapped") }
                )
                .padding()
                .previewLayout(.sizeThatFits)
            }
        }
    }
#endif
