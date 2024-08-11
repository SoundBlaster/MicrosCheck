import AVFoundation

/// Interruption from AudioSession
/// https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_interruptions?language=objc
@MainActor
internal final class RecorderDelegate: NSObject, AVAudioRecorderDelegate {

    let recorder: Recorder
    let fileReader: FileReader

    init(recorder: Recorder, fileReader: FileReader) {
        self.recorder = recorder
        self.fileReader = fileReader
    }

    // MARK: AVAudioRecorderDelegate

    nonisolated
    func audioRecorderDidFinishRecording(_ avRecorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording successfully:\(flag)")
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let activeUrl = recorder.activeUrl else {
                assertionFailure("Recoder has no active URL!")
                return
            }

            if fileReader.hasFile(at: activeUrl) {
                print("Audio successully written at \(activeUrl) \(fileReader.fileSize(for: activeUrl))")
            } else {
                assertionFailure("There is no file at \(activeUrl)")
            }
        }
    }

    nonisolated
    func audioRecorderEncodeErrorDidOccur(_ avRecorder: AVAudioRecorder, error: Error?) {
        print("audioRecorderEncodeErrorDidOccur error: \(error?.localizedDescription ?? "")")
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let activeUrl = recorder.activeUrl else {
                assertionFailure("Recoder has no active URL!")
                return
            }
            if fileReader.hasFile(at: activeUrl) {
                print("Audio successully written at \(activeUrl) \(fileReader.fileSize(for: activeUrl))")
            } else {
                assertionFailure("There is no file at \(activeUrl)")
            }
        }
    }
}
