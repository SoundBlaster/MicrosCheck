import CoreHaptics
import SwiftUI

struct RecorderMainScreen: View {
    @StateObject var viewModel: RecorderViewModel
    @StateObject private var fileListVM = FileListViewModel(fileReader: FileReaderImpl())
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

    @State private var blinkOpacity: Double = 1.0

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                LiveWaveformView(
                    samples: viewModel.liveWaveformSamples
                )
                .frame(height: 60)
                .padding(.horizontal)

                HorizontalTimeRuler(
                    duration: viewModel.elapsed,
                    currentTime: viewModel.elapsed,
                    tickStep: 5,
                    rulerHeight: 30
                )
                .padding(.horizontal)

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
                        Text("\(formatSize(Int(viewModel.fileSize)))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            MeterBar(level: viewModel.leftLevel, label: "L")
                            MeterBar(level: viewModel.rightLevel, label: "R")
                            // Vertical decibel level ruler added here
                            VerticalDBRuler()
                                .frame(width: 30, height: 60)
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

                // A3 Navigation Buttons
                HStack(spacing: 24) {
                    Button(action: {
                        print("Back button tapped")
                        // Implement back navigation logic, e.g., dismiss or pop
                    }) {
                        Label("Back", systemImage: "arrow.left")
                    }
                    .disabled(isLocked)

                    Button(action: {
                        print("Home button tapped")
                        // Implement home navigation logic, e.g., navigate to root screen
                    }) {
                        Label("Home", systemImage: "house")
                    }
                    .disabled(isLocked)

                    Button(action: {
                        print("T-MARK button tapped")
                        if viewModel.isRecording {
                            viewModel.record()
                        }
                        // Implement add bookmark or marker
                    }) {
                        Label("T-MARK", systemImage: "mappin")
                    }
                    .disabled(isLocked)

                    Button(action: {
                        print("Options button tapped")
                        // Implement options/settings display
                    }) {
                        Label("Options", systemImage: "gearshape")
                    }
                    .disabled(isLocked)
                }
                .padding()
                .font(.headline)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
                .disabled(isLocked)
                .padding(.horizontal)

                // A7 Lock and Info Buttons HStack
                HStack {
                    Button(action: {
                        isLocked.toggle()
                        if isLocked {
                            // Show overlay and haptic handled in state
                            playHapticSuccess()
                        }
                    }) {
                        Image(systemName: isLocked ? "lock.fill" : "lock.open")
                            .font(.title)
                            .foregroundColor(isLocked ? .red : .primary)
                    }
                    .accessibilityLabel(isLocked ? "Unlock UI" : "Lock UI")
                    .padding()

                    Spacer()

                    Button(action: {
                        print("Info button tapped")
                        // Implement info modal or sheet presentation logic here
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                    .accessibilityLabel("Info")
                    .padding()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)

                // Main Controls
                HStack(spacing: 24) {
                    Button(action: { viewModel.stop() }) {
                        Label("Stop", systemImage: "stop.circle")
                    }
                    .disabled(!viewModel.isRecording || isLocked)
                    .font(.title2)

                    // Recording label and blinking red indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 14, height: 14)
                            .opacity(viewModel.isRecording ? blinkOpacity : 0)
                            .animation(
                                viewModel.isRecording
                                    ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                                    : .default,
                                value: blinkOpacity
                            )

                        Text(viewModel.isRecording ? "Recording" : "Not Recording")
                            .font(.headline)
                            .foregroundColor(viewModel.isRecording ? .red : .secondary)
                    }
                    .onAppear {
                        if viewModel.isRecording {
                            startBlinking()
                        }
                    }
                    .onChange(of: viewModel.isRecording) { isRec in
                        if isRec {
                            startBlinking()
                        } else {
                            stopBlinking()
                        }
                    }

                    Button(action: {
                        if !isLocked {
                            if viewModel.isRecording {
                                viewModel.pause()
                            } else {
                                viewModel.record()
                            }
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

                    CircularPlaybackControl(
                        isPlaying: playbackVM.isPlaying,
                        playbackRate: playbackVM.rate,
                        aPoint: playbackVM.aPoint,
                        bPoint: playbackVM.bPoint,
                        onPlayPause: { playbackVM.isPlaying ? playbackVM.pause() : playbackVM.play() },
                        onSeekBackward: { playbackVM.nudge(by: -5) },
                        onSeekForward: { playbackVM.nudge(by: 5) },
                        onABLoopTapped: {
                            if playbackVM.aPoint == nil {
                                playbackVM.aPoint = playbackVM.position
                                playbackVM.bPoint = nil
                            } else if playbackVM.bPoint == nil {
                                if playbackVM.position > playbackVM.aPoint! {
                                    playbackVM.bPoint = playbackVM.position
                                } else {
                                    let temp = playbackVM.aPoint
                                    playbackVM.aPoint = playbackVM.position
                                    playbackVM.bPoint = temp
                                }
                            } else {
                                playbackVM.aPoint = nil
                                playbackVM.bPoint = nil
                            }
                        },
                        onDPCRateCycle: {
                            // Cycle through preset rates: 1.0 → 1.25 → 1.5 → 1.75 → 2.0 → 0.75 → 0.5 → 1.0
                            let rates: [Float] = [1.0, 1.25, 1.5, 1.75, 2.0, 0.75, 0.5]
                            if let index = rates.firstIndex(of: playbackVM.rate) {
                                let nextIndex = (index + 1) % rates.count
                                playbackVM.rate = rates[nextIndex]
                            } else {
                                playbackVM.rate = 1.0
                            }
                        }
                    )
                    .frame(width: 180, height: 180)
                    .padding()
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

    // MARK: - Blink control

    func startBlinking() {
        let baseAnimation = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        withAnimation(baseAnimation) {
            blinkOpacity = 0.0
        }
    }
    func stopBlinking() {
        withAnimation(.default) {
            blinkOpacity = 1.0
        }
    }

    // MARK: - Format and Haptic Stubs

    private func formatSize(_ size: Int) -> String { "\(size) bytes" }
    private func formatElapsed(_ seconds: Double) -> String { String(format: "%02d:%02d", Int(seconds)/60, Int(seconds)%60) }
    private func prepareHaptics() { /* stub */ }
    private func playHapticSuccess() { /* stub */ }
    private var lockOverlay: some View { Color.black.opacity(0.3).ignoresSafeArea().overlay(Text("Locked").font(.largeTitle).foregroundColor(.white)) }
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
    static var previews: some View {
        let vm = RecorderViewModel(appState: .init())
        vm.isRecording = true
        vm.isPrepared = true
        vm.elapsed = 67
        vm.fileName = "20240611_01.m4a"
        vm.fileSize = 2_100_000
        vm.format = "AAC 128kbps"
        vm.leftLevel = -7
        vm.rightLevel = -21

        return RecorderMainScreen(viewModel: vm)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
#endif
