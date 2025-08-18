import Combine
import Foundation
import SwiftUI

/// ViewModel for binding Recorder backend to SwiftUI UI.
/// Handles polling meters, exposing state, and main recording actions.
@MainActor
final class RecorderViewModel: ObservableObject {
    // MARK: - Published Properties for UI Binding
    @Published var isRecording: Bool = false
    @Published var isPrepared: Bool = false
    @Published var elapsed: TimeInterval = 0
    @Published var fileName: String = ""
    @Published var fileSize: UInt64 = 0
    @Published var format: String = "AAC 128kbps"
    @Published var leftLevel: Float = -60
    @Published var rightLevel: Float = -60

    // MARK: - Dependencies
    private let appState: AppState
    private var meterTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    @Published var availableInputs: [String] = []
    @Published var selectedInputName: String = .notSelectedInputName

    init(appState: AppState) {
        self.appState = appState
        setupBindings()
        loadAvailableInputs()
        selectedInputName = appState.selectedInputName
    }

    private func setupBindings() {
        // Observe isRecording to start/stop metering
        $isRecording
            .sink { [weak self] isRec in
                guard let self else { return }
                if isRec {
                    self.startMetering()
                } else {
                    self.stopMetering()
                }
            }
            .store(in: &cancellables)

        // Observe selectedInputName changes and update AppState and recorder input
        $selectedInputName
            .sink { [weak self] newName in
                guard let self else { return }
                Task {
                    await self.selectInput(name: newName)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Meter Polling
    private func startMetering() {
        meterTimer?.invalidate()
        meterTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) {
            [weak self] _ in
            self?.updateMeters()
        }
    }

    func loadAvailableInputs() {
        let inputs = appState.recorder.availableInputs()
        availableInputs = inputs.map { $0.name }
    }

    func selectInput(name: String) async {
        guard name != .notSelectedInputName else { return }
        guard let input = appState.recorder.availableInputs().first(where: { $0.name == name })
        else { return }
        do {
            try appState.recorder.selectInput(input)
            appState.selectedInputName = name
        } catch {
            print("Failed to select input: \(error)")
        }
    }

    private func stopMetering() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private func updateMeters() {
        let recorder = appState.recorder
        guard recorder.recording else { return }
        // Use KVC to access AVAudioRecorder if possible (internal)
        if let avRecorder = recorder.value(forKey: "audioRecorder") as? AVAudioRecorder {
            avRecorder.updateMeters()
            leftLevel = avRecorder.averagePower(forChannel: 0)
            if avRecorder.numberOfChannels > 1 {
                rightLevel = avRecorder.averagePower(forChannel: 1)
            } else {
                rightLevel = leftLevel
            }
            elapsed = avRecorder.currentTime
        }
        fileName = recorder.activeUrl?.lastPathComponent ?? ""
        fileSize = appState.fileReader.fileSize(
            for: recorder.activeUrl ?? appState.fileReader.recordURL())
        updateFormat()
    }

    /// Update the audio format string based on recorder settings or defaults.
    private func updateFormat() {
        // For now, hardcoded to AAC 128kbps, can be extended to read actual format from recorder
        format = "AAC 128kbps"
    }

    /// Applies given recording settings to the recorder.
    private func applyRecordingSettings(_ settings: RecordingSettings) {
        // Here you would configure the recorder with settings such as sample rate, bitrate, channels, and format.
        // The current RecorderImpl does not expose these directly, so this is a placeholder for future extension.
        // For example:
        // try? appState.recorder.configure(settings)
        // For now, just log the settings.
        print("Applying recording settings: \(settings)")
    }

    // MARK: - Actions
    func prepare() async {
        do {
            // Apply current recording settings to recorder before prepare
            applyRecordingSettings(appState.recordingSettingsStore.currentSettings)
            _ = try appState.recorder.prepare()
            isPrepared = true
        } catch {
            isPrepared = false
        }
    }

    func record() {
        do {
            _ = try appState.recorder.record()
            isRecording = true
            updateCurrentMeta()
        } catch {
            isRecording = false
        }
    }

    func pause() {
        do {
            _ = try appState.recorder.pause()
            isRecording = false
            updateCurrentMeta()
        } catch {}
    }

    func stop() {
        do {
            _ = try appState.recorder.stop()
            isRecording = false
            updateCurrentMeta()
        } catch {}
        /// Updates the current metadata fields (fileName, fileSize, format) from the recorder state.
        func updateCurrentMeta() {
            let recorder = appState.recorder
            fileName = recorder.activeUrl?.lastPathComponent ?? ""
            fileSize = appState.fileReader.fileSize(
                for: recorder.activeUrl ?? appState.fileReader.recordURL())
            updateFormat()
        }
    }
}
