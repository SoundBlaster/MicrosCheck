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

    init(appState: AppState) {
        self.appState = appState
        setupBindings()
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
    }

    // MARK: - Meter Polling
    private func startMetering() {
        meterTimer?.invalidate()
        meterTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) {
            [weak self] _ in
            self?.updateMeters()
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
    }

    // MARK: - Actions
    func prepare() async {
        do {
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
        } catch {
            isRecording = false
        }
    }

    func pause() {
        do {
            _ = try appState.recorder.pause()
            isRecording = false
        } catch {}
    }

    func stop() {
        do {
            _ = try appState.recorder.stop()
            isRecording = false
        } catch {}
    }
}
