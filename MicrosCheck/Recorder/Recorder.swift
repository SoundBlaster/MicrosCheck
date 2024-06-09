//
//  Recorder.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 30.04.2023.
//

import AVFoundation

protocol StateMachine {
    associatedtype S: Hashable, CustomStringConvertible
    var state: S { get }
    mutating func updateState(to nextState: S) throws -> S
    var routes: [S: [S]] { get }
}

class Recorder {

    enum RecorderError: Error {
        case noAudioSession
        case noAudioInput
        case noAudioInputPort
        case noInternalRecorder
        case impossibleStateChange(state: CustomStringConvertible, nextState: CustomStringConvertible) 
    }
    
    class StateHolder: StateMachine {
        
        enum State: String, CustomStringConvertible {
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
        
        var state: State = .inited
        
        var routes: [State: [State]] = {
            [
                .inited : [.prepared],
                .prepared : [.recording],
                .recording : [.paused, .stopped],
                .paused : [.recording, .stopped],
                .stopped : [.prepared],
            ]
        }()
        
        func updateState(to nextState: State) throws -> State {
            print("updateState: \(state)")
//            print("updateState: \(state) -> \(nextState)")
            print("updateState \(String(describing: routes[state]?.contains(where: { $0 == nextState })))")
            
            if routes[state]?.contains(where: { $0 == nextState }) == false {
                throw RecorderError.impossibleStateChange(state: state, nextState: nextState)
            }
            state = nextState
            return state
        }
        
    }
    
    // MARK: Public interface
    
    var state: StateHolder.State {
        stateHolder.state
    }
    
    var recording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    func availableInputs() -> [Input] {
        let empty: [Input] = [.unknownInput]
        guard let audioSession else {
            return empty
        }
        do {
            return try availableInputsPortDescription(with: preferredPort, in: audioSession)?
                .dataSources?.map {
                    Input(name: $0.dataSourceName, location: try Location.fromOrientation($0.orientation))
                } ?? empty
        } catch {
            return empty
        }
    }
    
    @discardableResult
    public func prepare() throws -> Recorder {
        
        guard audioRecorder == nil else {
            assertionFailure("Recoder: has no instance of AVAudioRecorder!")
            return self
        }
        
        // audio recorder
        activeUrl = FileReader.recordURL()
        
        guard let activeUrl else {
            assertionFailure("Recoder: has no active URL!")
            return self
        }
        
        let settings = [AVEncoderBitRatePerChannelKey: 96000]
        audioRecorder = try AVAudioRecorder(url: activeUrl, settings: settings)
        audioRecorderDelegate.recorder = self
        audioRecorder?.delegate = audioRecorderDelegate
        audioRecorder?.isMeteringEnabled = true
        // success return
        return self
    }
    
    @discardableResult
    public func record() throws -> Recorder {
        try prepareAudioSession(completion: { [weak self] granted in
            guard let self else {
                print("Recorder: Recorder was deallocated!")
                return
            }
            guard granted else {
                print("Recorder: There is no access to audio recording!")
                return
            }
            guard let audioRecorder else {
                print("Recorder: There is no audioRecorder!")
                return
            }
            print("Recorder: start record.")
            audioRecorder.record()
        })
        return self
    }
    
    @discardableResult
    public func pause() -> Recorder {
        guard let audioRecorder else {
            print("Recorder: There is no audioRecorder!")
            return self
        }
        audioRecorder.pause()
        return self
    }
    
    @discardableResult
    public func stop() -> Recorder {
        guard let audioRecorder else {
            print("Recorder: There is no audioRecorder!")
            return self
        }
        audioRecorder.stop()
        self.audioRecorder = nil
        return self
    }
    
    // MARK: Private vars & functions
    
    private let stateHolder = StateHolder()
    private let preferredPort: AVAudioSession.Port = .builtInMic
    private var audioSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    private var audioRecorderDelegate: RecorderDelegate = RecorderDelegate()
    fileprivate var activeUrl: URL?
    
    private func availableInputsPortDescription(with portType: AVAudioSession.Port, in session: AVAudioSession) throws -> AVAudioSessionPortDescription? {
        session.availableInputs?.first {
            $0.portType == portType
        }
    }
    
    private func prepareAudioSession(completion: @escaping (Bool) -> Void) throws {
        // audio session
        audioSession = AVAudioSession.sharedInstance()
        guard let audioSession else {
            print("Recorder: There is no audio session!")
            throw RecorderError.noAudioSession
        }
        
        try audioSession.setCategory(.record)
        try audioSession.setActive(true)
        guard audioSession.isInputAvailable else {
            print("Recorder: There is no one audio input!")
            throw RecorderError.noAudioInput
        }
        guard let port = try availableInputsPortDescription(with: preferredPort, in: audioSession) else {
            print("Recorder: There is no one audio input port!")
            throw RecorderError.noAudioInputPort
        }
        print("Selected data source: \(String(describing: port.selectedDataSource))")
        print("Preferred data source: \(String(describing: port.preferredDataSource))")
        port.dataSources?.forEach {
            print("Data source: \($0)")
        }
        if let dataSource = port.dataSources?.last {
            try port.setPreferredDataSource(dataSource)
        }
        print("Recorder: activate AVAudioSession with category: \(audioSession.category)")
        // record permissions
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { allowed in
                print("Recorder: requestRecordPermission() allowed=\(allowed)")
                completion(allowed)
            }
        } else {
            audioSession.requestRecordPermission() { allowed in
                print("Recorder: requestRecordPermission() allowed=\(allowed)")
                completion(allowed)
            }
        }
    }
    
}

/// Interruption from AudioSession 
/// https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_interruptions?language=objc
fileprivate class RecorderDelegate: NSObject, AVAudioRecorderDelegate {
    
    weak var recorder: Recorder?
    
    func audioRecorderDidFinishRecording(_ avRecorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording successfully:\(flag)")
        
        guard let activeUrl = recorder?.activeUrl else {
            assertionFailure("Recoder has no active URL!")
            return
        }
        
        if FileReader.hasFile(at: activeUrl) {
            print("Audio successully written at \(activeUrl) \(FileReader.fileSize(for: activeUrl))")
        } else {
            assertionFailure("There is no file at \(activeUrl)")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ avRecorder: AVAudioRecorder, error: Error?) {
        print("audioRecorderEncodeErrorDidOccur error: \(error?.localizedDescription ?? "")")
    }
    
}
