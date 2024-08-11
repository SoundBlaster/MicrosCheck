import Foundation

enum RecorderState: String, CustomStringConvertible, Sendable {
    case inited
    case prepared
    case recording
    case paused
    case stopped

    // CustomStringConvertible
    public var description: String {
        self.rawValue
    }
}

enum RecorderError: Error {
    case noAudioSession
    case noAudioInput
    case noAudioInputPort
    case noInternalRecorder
    case impossibleStateChange(state: RecorderState, nextState: RecorderState)
}

@MainActor
protocol Recorder: Sendable {
    var state: RecorderState { get }
    var recording: Bool { get }
    var activeUrl: URL? { get }
    func availableInputs() -> [Input]
    @discardableResult
    func prepare() throws -> Recorder
    @discardableResult
    func record() throws -> Recorder
    @discardableResult
    func stop() throws -> Recorder
}
