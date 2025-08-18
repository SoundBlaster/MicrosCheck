import CoreHaptics
import SwiftUI

struct RecorderMainScreen: View {
    @StateObject var viewModel: RecorderViewModel
    @StateObject private var fileListVM = FileListViewModel(fileReader: AppState.fileReader())
    @StateObject private var playbackVM = PlaybackViewModel()
    @State private var selectedFile: RecordingFileInfo? = nil

    // Search text binding for filter panel
    @State private var searchText: String = ""

    // Favorites filter state (can be propagated to view model if needed)
    @State private var favoritesFilterOn: Bool = false

    // UI Lock state
    @State private var isLocked: Bool = false
    @State private var unlockProgress: Double = 0.0
    @State private var hapticEngine: CHHapticEngine?

    var body: some View {
        ZStack {
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
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

                // Input Source Picker
                if viewModel.isPrepared {
                    Picker("Select Microphone", selection: $viewModel.selectedInputName) {
                        Text(String.notSelectedInputName).tag(String.notSelectedInputName)
                        ForEach(viewModel.availableInputs, id: \.self) { input in
                            Text(input).tag(input)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(isLocked)
                    .padding(.horizontal)
                }

                // Search and filter panel integration
                SearchFilterPanel(
                    searchText: $searchText,
                    onSearch: { query in
                        // Implement search filter logic, e.g., update files in FileListViewModel
                        Task {
                            await applySearchFilter(query)
                        }
                    },
                    onToggleTheme: {
                        // Implement theme toggle logic here
                        print("Theme toggle tapped")
                    },
                    onToggleFavorites: {
                        favoritesFilterOn.toggle()
                        // Implement favorites filter logic
                        Task {
                            await applyFavoritesFilter(favoritesFilterOn)
                        }
                    },
                    onWaveformDensity: { step in
                        // Implement waveform density change handling
                        print("Waveform density set to \(step)")
                    }
                )
                .disabled(isLocked)
                .padding(.horizontal)

                // Main Controls
                HStack(spacing: 24) {
                    Button(action: { viewModel.stop() }) {
                        Label("Stop", systemImage: "stop.circle")
                    }
                    .disabled(!viewModel.isRecording || isLocked)
                    .font(.title2)

                    Button(action: {
                        if !isLocked {
                            viewModel.isRecording ? viewModel.pause() : viewModel.record()
                        }
                    }) {
                        Label(
                            viewModel.isRecording ? "Pause" : "Record",
                            systemImage: viewModel.isRecording ? "pause.circle" : "record.circle")
                    }
                    .foregroundColor(viewModel.isRecording ? .orange : .red)
                    .disabled(!viewModel.isPrepared || isLocked)
                    .font(.title2)
                }

                // File list integration
                FileListView(viewModel: fileListVM) { file in
                    selectedFile = file
                    playbackVM.load(file: file)
                }
                .frame(maxHeight: 220)
                .padding(.top, 8)
                .disabled(isLocked)

                if let selected = selectedFile {
                    PlaybackView(viewModel: playbackVM)
                        .frame(maxHeight: 280)
                        .padding(.top, 8)
                        .disabled(isLocked)
                }

                Spacer()
            }
            .blur(radius: isLocked ? 5 : 0)
            .disabled(isLocked)

            if isLocked {
                lockOverlay
            }
        }
        .onAppear {
            Task { await viewModel.prepare() }
            prepareHaptics()
        }
    }

    // MARK: - Helpers for Search/Filter

    private func applySearchFilter(_ query: String) async {
        // Simple filter example: filter fileListVM files by name containing query (case-insensitive)
        let lowerQuery = query.lowercased()
        if query.isEmpty {
            await fileListVM.reload()
        } else {
            // Filter local files for demonstration, extend logic as needed
            let filteredFiles = fileListVM.files.filter { file in
                file.name.lowercased().contains(lowerQuery)
            }
            await MainActor.run {
                fileListVM.files = filteredFiles
            }
        }
    }

    private func applyFavoritesFilter(_ enabled: Bool) async {
        // Placeholder logic: no favorites in current data, so just reload all files
        await fileListVM.reload()
        // Extend with real favorites filter logic when supported
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
