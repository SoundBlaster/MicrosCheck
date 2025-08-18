import SwiftUI

struct PlaybackView: View {
    @ObservedObject var viewModel: PlaybackViewModel

    var body: some View {
        VStack(spacing: 16) {
            // File info
            if let file = viewModel.currentFile {
                VStack(alignment: .leading, spacing: 4) {
                    Text(file.name)
                        .font(.headline)
                        .lineLimit(1)
                    HStack(spacing: 12) {
                        Text(formatSize(file.size))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let duration = file.duration {
                            Text(formatDuration(duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No file loaded")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            // Progress bar
            ProgressView(value: viewModel.position, total: viewModel.duration)
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                .padding(.horizontal)

            // Playback time labels
            HStack {
                Text(formatDuration(viewModel.position))
                    .font(.caption2)
                Spacer()
                Text(formatDuration(viewModel.duration))
                    .font(.caption2)
            }
            .padding(.horizontal)

            // Playback controls
            HStack(spacing: 40) {
                Button(action: {
                    viewModel.nudge(by: -10)
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.title)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !viewModel.isHoldingSeek {
                                viewModel.holdSeek(start: -10)
                                viewModel.isHoldingSeek = true
                            }
                        }
                        .onEnded { _ in
                            viewModel.stopHoldSeek()
                            viewModel.isHoldingSeek = false
                        }
                )
                .disabled(viewModel.currentFile == nil)

                Button(action: {
                    if viewModel.isPlaying {
                        viewModel.pause()
                    } else {
                        viewModel.play()
                    }
                }) {
                    Image(
                        systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill"
                    )
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
                }
                .disabled(viewModel.currentFile == nil)

                Button(action: {
                    viewModel.nudge(by: 10)
                }) {
                    Image(systemName: "goforward.10")
                        .font(.title)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !viewModel.isHoldingSeek {
                                viewModel.holdSeek(start: 10)
                                viewModel.isHoldingSeek = true
                            }
                        }
                        .onEnded { _ in
                            viewModel.stopHoldSeek()
                            viewModel.isHoldingSeek = false
                        }
                )
                .disabled(viewModel.currentFile == nil)
            }
            .padding(.vertical)

            // Audio meters
            HStack(spacing: 40) {
                MeterBar(level: viewModel.leftLevel, label: "L")
                MeterBar(level: viewModel.rightLevel, label: "R")
            }
            .padding(.horizontal)

            // DPC Controls
            VStack(spacing: 16) {
                HStack {
                    Text("Playback Rate")
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.rate) },
                            set: { viewModel.rate = Float($0) }
                        ), in: 0.5...2.0, step: 0.05)
                    Text(String(format: "%.2fx", viewModel.rate))
                        .frame(width: 50)
                }
                HStack {
                    Text("Pitch (cents)")
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.pitchCents) },
                            set: { viewModel.pitchCents = Float($0) }
                        ), in: -1200...1200, step: 10)
                    Text(String(format: "%.0f", viewModel.pitchCents))
                        .frame(width: 50)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }

    // MARK: - Helpers

    func formatDuration(_ t: TimeInterval) -> String {
        let s = Int(t) % 60
        let m = (Int(t) / 60) % 60
        let h = Int(t) / 3600
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%d:%02d", m, s)
        }
    }

    func formatSize(_ bytes: UInt64) -> String {
        let mb = Double(bytes) / 1024.0 / 1024.0
        return String(format: "%.1f MB", mb)
    }
}

struct MeterBar: View {
    let level: Float
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
            Rectangle()
                .fill(Color.green)
                .frame(width: 8, height: CGFloat(max(2, (level + 60) * 2)))
                .cornerRadius(2)
            Text(String(format: "%.0fdB", level))
                .font(.caption2)
        }
    }
}

#if DEBUG
    struct PlaybackView_Previews: PreviewProvider {
        class DummyPlaybackVM: PlaybackViewModel {
            override init() {
                super.init()
                self.isPlaying = true
                self.duration = 120
                self.position = 45
                self.leftLevel = -10
                self.rightLevel = -20
                self.currentFile = RecordingFileInfo(
                    url: URL(fileURLWithPath: "/tmp/rec1.m4a"),
                    name: "20240612_01.m4a",
                    size: 2_100_000,
                    created: Date(),
                    duration: 120
                )
                self.rate = 1.25
                self.pitchCents = 300
            }
        }

        static var previews: some View {
            PlaybackView(viewModel: DummyPlaybackVM())
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
#endif
