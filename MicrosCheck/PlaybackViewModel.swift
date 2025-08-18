@preconcurrency import AVFoundation
import Foundation
import SwiftUI

/// ViewModel to manage playback state, controls, and progress for a selected recording file.
@MainActor
final class PlaybackViewModel: ObservableObject {
    // MARK: - Shared FileListViewModel for bookmark integration
    static var sharedFileListViewModel: FileListViewModel?

    // MARK: - Mock Data for Preview and Tests
    static func mockForPreview() -> PlaybackViewModel {
        let vm = PlaybackViewModel()
        vm.isPlaying = true
        vm.duration = 120
        vm.position = 45
        vm.leftLevel = -10
        vm.rightLevel = -20
        vm.currentFile = RecordingFileInfo(
            url: URL(fileURLWithPath: "/tmp/rec1.m4a"),
            name: "20240612_01.m4a",
            size: 2_100_000,
            created: Date(),
            duration: 120)
        vm.rate = 1.25
        vm.pitchCents = 300
        vm.masterVolume = 0.8
        vm.volumeL = -7
        vm.volumeR = -21
        return vm
    }

    // MARK: - Published Properties for UI Binding
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var position: TimeInterval = 0
    @Published private(set) var leftLevel: Float = -60
    @Published private(set) var rightLevel: Float = -60
    @Published private(set) var currentFile: RecordingFileInfo?

    @Published var aPoint: TimeInterval? = nil
    @Published var bPoint: TimeInterval? = nil

    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    private var meterTimer: Timer?
    private var progressTimer: Timer?
    private var holdSeekTimer: Timer?
    private var holdSeekDirection: TimeInterval = 0
    @Published var isHoldingSeek: Bool = false

    // MARK: - DPC Properties
    @Published var rate: Float = 1.0 {
        didSet {
            updatePlaybackRate()
        }
    }
    @Published var pitchCents: Float = 0.0 {
        didSet {
            updatePlaybackPitch()
        }
    }

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var timePitchNode: AVAudioUnitTimePitch?
    private var audioFile: AVAudioFile?

    // MARK: - Volume Control Properties
    @Published var masterVolume: Float = 1.0 {
        didSet {
            updateMasterVolume()
        }
    }
    @Published var volumeL: Float = 0.0 {
        didSet {
            updateChannelVolumes()
        }
    }
    @Published var volumeR: Float = 0.0 {
        didSet {
            updateChannelVolumes()
        }
    }

    // MARK: - Initialization
    init() {}

    // MARK: - Bookmark Integration

    /// Adds a bookmark at the current playback position.
    func addCurrentBookmark(title: String? = nil, note: String? = nil) async throws {
        guard let file = currentFile else { return }
        let bookmark = Bookmark(time: position, title: title, note: note)
        try await addBookmark(to: file, bookmark: bookmark)
    }

    /// Adds a bookmark to a file using shared FileListViewModel.
    private func addBookmark(to file: RecordingFileInfo, bookmark: Bookmark) async throws {
        guard let fileListVM = PlaybackViewModel.sharedFileListViewModel else {
            fatalError(
                "PlaybackViewModel: sharedFileListViewModel not set for bookmark integration")
        }
        try await fileListVM.addBookmark(
            to: file, time: bookmark.time, title: bookmark.title, note: bookmark.note)
    }

    // MARK: - Playback Control

    /// Loads the audio file for playback.
    /// - Parameter file: The recording file info to load.
    func load(file: RecordingFileInfo) {
        stop()
        currentFile = file
        setupAudioEngine(url: file.url)
    }

    private func setupAudioEngine(url: URL) {
        audioEngine?.stop()
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        timePitchNode = AVAudioUnitTimePitch()

        guard let audioEngine = audioEngine,
            let playerNode = playerNode,
            let timePitchNode = timePitchNode
        else {
            print("PlaybackViewModel: Failed to create audio engine components")
            return
        }

        audioEngine.attach(playerNode)
        audioEngine.attach(timePitchNode)

        audioEngine.connect(playerNode, to: timePitchNode, format: nil)
        audioEngine.connect(timePitchNode, to: audioEngine.mainMixerNode, format: nil)

        // Set initial volume levels
        updateMasterVolume()
        updateChannelVolumes()

        do {
            audioFile = try AVAudioFile(forReading: url)
            guard let audioFile = audioFile else { return }
            duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            position = 0

            try audioEngine.start()
            playerNode.scheduleFile(audioFile, at: nil, completionHandler: playbackEnded)

            updatePlaybackRate()
            updatePlaybackPitch()

            isPlaying = false
        } catch {
            print("PlaybackViewModel: Failed to setup audio engine: \(error)")
            audioEngine.stop()
            self.audioEngine = nil
            playerNode.stop()
            self.playerNode = nil
            self.timePitchNode = nil
            audioFile = nil
            duration = 0
            position = 0
            isPlaying = false
        }
    }

    private func playbackEnded() {
        DispatchQueue.main.async { [weak self] in
            self?.stop()
        }
    }

    func play() {
        guard let playerNode = playerNode, let audioEngine = audioEngine else { return }

        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                print("PlaybackViewModel: Failed to start audio engine: \(error)")
                isPlaying = false
                stopTimers()
                return
            }
        }
        playerNode.play()
        isPlaying = true
        startTimers()
    }

    func pause() {
        playerNode?.pause()
        isPlaying = false
        stopTimers()
    }

    func stop() {
        playerNode?.stop()
        audioEngine?.pause()
        position = 0
        isPlaying = false
        stopTimers()
        stopHoldSeek()
    }

    func seek(to time: TimeInterval) {
        guard let playerNode = playerNode,
              let audioFile = audioFile,
              let audioEngine = audioEngine
        else { return }

        var clampedTime = max(0, min(time, duration))

        // Enforce A-B loop boundaries if set
        if let a = aPoint, let b = bPoint {
            if clampedTime < a {
                clampedTime = a
            } else if clampedTime > b {
                clampedTime = b
            }
        }

        position = clampedTime
        playerNode.stop()

        let framePosition = AVAudioFramePosition(clampedTime * audioFile.fileFormat.sampleRate)
        let framesToPlay = AVAudioFrameCount(audioFile.length - framePosition)

        playerNode.scheduleSegment(
            audioFile, startingFrame: framePosition, frameCount: framesToPlay, at: nil,
            completionHandler: playbackEnded)

        if isPlaying {
            do {
                try audioEngine.start()
                playerNode.play()
            } catch {
                print("PlaybackViewModel: Failed to restart audio engine after seek: \(error)")
            }
        }
    }

    func nudge(by delta: TimeInterval) {
        let newPosition = position + delta
        let clampedPosition: TimeInterval
        if newPosition < 0 {
            clampedPosition = 0
        } else if newPosition > duration {
            clampedPosition = duration
        } else {
            clampedPosition = newPosition
        }
        seek(to: clampedPosition)
    }

    // MARK: - DPC Rate/Pitch

    private func updatePlaybackRate() {
        timePitchNode?.rate = rate
    }

    private func updatePlaybackPitch() {
        timePitchNode?.pitch = pitchCents
    }

    // MARK: - Timers for Progress and Metering

    private func startTimers() {
        stopTimers()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            [weak self] _ in
            self?.updateProgress()
        }
        meterTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) {
            [weak self] _ in
            self?.updateMeters()
        }
    }

    private func stopTimers() {
        progressTimer?.invalidate()
        progressTimer = nil
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private func updateProgress() {
        guard let playerNode = playerNode,
              let audioFile = audioFile
        else { return }

        if isPlaying {
            guard let nodeTime = playerNode.lastRenderTime else { return }
            guard let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else { return }

            let newPosition = Double(playerTime.sampleTime) / playerTime.sampleRate

            // Avoid abrupt position changes beyond short tolerance
            let maxJump: Double = 5.0 // seconds allowed jump distance
            if abs(newPosition - position) > maxJump {
                // Clamp to last known position if jump too large
                position = position
            } else {
                position = newPosition
            }
        }

        if !isPlaying {
            stopTimers()
            stopHoldSeek()
        }
    }

    private func updateMeters() {
        guard let audioEngine = audioEngine else { return }
        let mixer = audioEngine.mainMixerNode
        mixer.outputVolume = 1.0
        // Metering on AVAudioEngine is more complex; for now, we skip meter updates or implement later.
    }

    // MARK: - Volume Control Updates

    private func updateMasterVolume() {
        audioEngine?.mainMixerNode.outputVolume = masterVolume
    }

    private func updateChannelVolumes() {
        guard let playerNode = playerNode else { return }
        // AVAudioPlayerNode does not support direct channel gain control.
        // This requires more advanced audio processing with mixer nodes.
        // For now, this is a placeholder to show where channel volume would be applied.
        // Future: Implement AVAudioMixerNode with separate channel controls.
        // For now, we log the intended channel volumes.
        print("Set channel volumes L: \(volumeL) dB, R: \(volumeR) dB (not implemented)")
    }

    // MARK: - Seek Hold (Continuous Seek)

    /// Starts continuous seeking in the given direction (+ for forward, - for backward).
    func holdSeek(start direction: TimeInterval) {
        guard isPlaying else { return }
        holdSeekDirection = direction
        holdSeekTimer?.invalidate()
        holdSeekTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {
            [weak self] _ in
            self?.nudge(by: direction)
        }
        isHoldingSeek = true
    }

    /// Stops continuous seeking.
    func stopHoldSeek() {
        holdSeekTimer?.invalidate()
        holdSeekTimer = nil
        holdSeekDirection = 0
        isHoldingSeek = false
    }

    // MARK: - Deinitialization

    deinit {
        Task { @MainActor in self.stopTimers() }
        audioPlayer?.stop()
        audioPlayer = nil
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
        timePitchNode = nil
        audioFile = nil
    }
}

