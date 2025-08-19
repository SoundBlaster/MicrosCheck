import SwiftUI

/// Displays a list of audio recordings with metadata and allows selection for playback.
struct FileListView: View {
    @ObservedObject var viewModel: FileListViewModel
    /// Called when a file is selected for playback.
    var onSelect: (RecordingFileInfo) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Recordings")
                    .font(.headline)
                Spacer()
                Button(action: {
                    Task { await viewModel.reload() }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Reload recordings list")
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.files.isEmpty {
                Text("No recordings found")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                List(viewModel.files) { file in
                    Button(action: { onSelect(file) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(file.name)
                                    .font(.body)
                                    .lineLimit(1)
                                HStack(spacing: 12) {
                                    Text(formatSize(file.size))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    if let duration = file.duration {
                                        Text(formatDuration(duration))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    if let date = file.created {
                                        Text(formatDate(date))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                // Waveform preview under metadata
                                if let cache = viewModel.waveformCache[file.url] {
                                    WaveformPreviewView(waveformData: cache)
                                        .frame(height: 40)
                                        .padding(.top, 4)
                                } else {
                                    WaveformPreviewView(waveformData: nil)
                                        .frame(height: 40)
                                        .padding(.top, 4)
                                }
                            }
                            Spacer()
                            Image(systemName: "play.circle")
                                .foregroundColor(.accentColor)
                                .font(.title3)
                        }
                    }
                    .contextMenu {
                        Button("Copy") {
                            Task {
                                do {
                                    let newName = file.name + " Copy.m4a"
                                    try await viewModel.copy(file: file, to: newName)
                                } catch {
                                    print("Copy failed: \(error)")
                                }
                            }
                        }
                        Button("Rename") {
                            Task {
                                // For simplicity, rename to file.name + "_renamed.m4a"
                                do {
                                    let newName = file.name.replacingOccurrences(
                                        of: ".m4a", with: "_renamed.m4a")
                                    try await viewModel.rename(file: file, to: newName)
                                } catch {
                                    print("Rename failed: \(error)")
                                }
                            }
                        }
                        Button("Delete", role: .destructive) {
                            Task {
                                do {
                                    try await viewModel.delete(file: file)
                                } catch {
                                    print("Delete failed: \(error)")
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Helpers

    func formatSize(_ bytes: UInt64) -> String {
        let mb = Double(bytes) / 1024.0 / 1024.0
        return String(format: "%.1f MB", mb)
    }

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

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#if DEBUG
struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = FileListViewModel(fileReader: DummyFileReader())
        vm.files = [
            RecordingFileInfo(
                url: URL(fileURLWithPath: "/tmp/rec1.m4a"),
                name: "20240612_01.m4a",
                size: 2_100_000,
                created: Date(),
                duration: 67.3
            ),
            RecordingFileInfo(
                url: URL(fileURLWithPath: "/tmp/rec2.m4a"),
                name: "20240611_02.m4a",
                size: 1_500_000,
                created: Date().addingTimeInterval(-3600),
                duration: 120.0
            ),
        ]
        return FileListView(viewModel: vm, onSelect: { _ in })
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }

    /// Dummy file reader for preview
    final class DummyFileReader: FileReader {
        func getRecordingsDirectory() -> URL { return URL(fileURLWithPath: "/tmp") }
        func hasFile(at url: URL) -> Bool { true }
        func deleteFile(at url: URL) -> Bool { true }
        func fileForRecord() -> File { FileImpl(url: URL(fileURLWithPath: "/tmp/rec.m4a")) }
        func recordURL() -> URL { URL(fileURLWithPath: "/tmp/rec.m4a") }
        func fileSize(for fileURL: URL) -> UInt64 { 2_000_000 }
        func getDocumentsDirectory() -> URL { URL(fileURLWithPath: "/tmp") }
    }
}
#endif
