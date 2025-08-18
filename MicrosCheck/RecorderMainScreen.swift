import SwiftUI

struct RecorderMainScreen: View {
    @StateObject var viewModel: RecorderViewModel
    @StateObject private var fileListVM = FileListViewModel(fileReader: AppState.fileReader())
    @StateObject private var playbackVM = PlaybackViewModel()
    @State private var selectedFile: RecordingFileInfo? = nil

    var body: some View {
        VStack(spacing: 24) {
            // Top waveform placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 60)
                .overlay(Text("Waveform (coming soon)").font(.caption))

            // Info Card
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isRecording ? "● REC" : "Ready")
                        .foregroundColor(viewModel.isRecording ? .red : .secondary)
                        .font(.headline)
                    Text(formatElapsed(viewModel.elapsed))
                        .font(.title2)
                        .monospacedDigit()
                    Text(viewModel.format)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.fileName)
                        .font(.callout)
                        .lineLimit(1)
                    Text("\(formatSize(viewModel.fileSize))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        MeterBar(level: viewModel.leftLevel, label: "L")
                        MeterBar(level: viewModel.rightLevel, label: "R")
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

            // Main Controls
            HStack(spacing: 24) {
                Button(action: { viewModel.stop() }) {
                    Label("Stop", systemImage: "stop.circle")
                }
                .disabled(!viewModel.isRecording)
                .font(.title2)

                Button(action: {
                    viewModel.isRecording ? viewModel.pause() : viewModel.record()
                }) {
                    Label(
                        viewModel.isRecording ? "Pause" : "Record",
                        systemImage: viewModel.isRecording ? "pause.circle" : "record.circle")
                }
                .foregroundColor(viewModel.isRecording ? .orange : .red)
                .disabled(!viewModel.isPrepared)
                .font(.title2)
            }

            // File list integration
            FileListView(viewModel: fileListVM) { file in
                selectedFile = file
                playbackVM.load(file: file)
            }
            .frame(maxHeight: 220)
            .padding(.top, 8)

            if let selected = selectedFile {
                PlaybackView(viewModel: playbackVM)
                    .frame(maxHeight: 280)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            Task { await viewModel.prepare() }
        }
    }

    // MARK: - Helpers
    func formatElapsed(_ t: TimeInterval) -> String {
        let s = Int(t) % 60
        let m = (Int(t) / 60) % 60
        let h = Int(t) / 3600
        return String(format: "%02dh%02dm%02ds", h, m, s)
    }
    func formatSize(_ bytes: UInt64) -> String {
        let mb = Double(bytes) / 1024.0 / 1024.0
        return String(format: "%.1f mb", mb)
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
                .fill(Color.blue)
                .frame(width: 8, height: CGFloat(max(2, (level + 60) * 2)))
                .cornerRadius(2)
            Text(String(format: "%.0fdB", level))
                .font(.caption2)
        }
    }
}

#if DEBUG
    struct RecorderMainScreen_Previews: PreviewProvider {
        class DummyVM: RecorderViewModel {
            init() {
                super.init(appState: .init())
                self.isRecording = true
                self.isPrepared = true
                self.elapsed = 67
                self.fileName = "20240611_01.m4a"
                self.fileSize = 2_100_000
                self.format = "AAC 128kbps"
                self.leftLevel = -7
                self.rightLevel = -21
            }
        }
        static var previews: some View {
            RecorderMainScreen(viewModel: DummyVM())
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
#endif
