import CoreHaptics
import SwiftUI

struct RecorderMainScreen: View {
    @StateObject var viewModel: RecorderViewModel
    @StateObject private var fileListVM = FileListViewModel(fileReader: AppState.fileReader())
    @StateObject private var playbackVM = PlaybackViewModel()
    @State private var selectedFile: RecordingFileInfo? = nil

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

    // MARK: - Lock Overlay View

    var lockOverlay: some View {
        VStack {
            Spacer()
            Text("Hold to unlock")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 4)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: unlockProgress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
            }
            .gesture(
                LongPressGesture(minimumDuration: 2.0)
                    .onChanged { _ in
                        // No-op for visual feedback handled by timer
                    }
                    .onEnded { _ in
                        unlockUI()
                    }
            )
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
        .transition(.opacity)
        .onAppear(perform: startUnlockProgress)
        .onDisappear(perform: stopUnlockProgress)
    }

    // MARK: - Unlock Progress Timer

    @State private var unlockTimer: Timer?

    func startUnlockProgress() {
        unlockProgress = 0
        unlockTimer?.invalidate()
        unlockTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if unlockProgress < 1.0 {
                unlockProgress += 0.01
                playHapticProgress()
            } else {
                timer.invalidate()
            }
        }
    }

    func stopUnlockProgress() {
        unlockTimer?.invalidate()
        unlockTimer = nil
        unlockProgress = 0
    }

    // MARK: - Unlock Action

    func unlockUI() {
        stopUnlockProgress()
        isLocked = false
        playHapticSuccess()
    }

    // MARK: - Haptics

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to start haptic engine: \(error)")
            hapticEngine = nil
        }
    }

    func playHapticProgress() {
        guard let engine = hapticEngine else { return }
        let intensity = CHHapticEventParameter(
            parameterID: .hapticIntensity, value: Float(unlockProgress))
        let sharpness = CHHapticEventParameter(
            parameterID: .hapticSharpness, value: Float(unlockProgress))
        let event = CHHapticEvent(
            eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0,
            duration: 0.02)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic progress: \(error)")
        }
    }

    func playHapticSuccess() {
        guard let engine = hapticEngine else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(
            eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic success: \(error)")
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
