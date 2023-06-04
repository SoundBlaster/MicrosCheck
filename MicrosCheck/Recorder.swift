//
//  Recorder.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 30.04.2023.
//

import AVFoundation

enum Location {
    case top
    case bottom
    case front
    case back
    case left
    case right
    case unknown
}

enum LocationError: Error {
    case unknown
}

extension Location {
    
    static func fromOrientation(_ orientation: AVAudioSession.Orientation?) throws -> Location {
        guard let orientation else { throw LocationError.unknown }
        switch orientation {
        case .top: return .top // AVAudioSessionOrientationTop
        case .bottom: return .bottom // AVAudioSessionOrientationBottom
        case .front: return .front // AVAudioSessionOrientationFront
        case .back: return .back // AVAudioSessionOrientationBack
        case .left: return .left // AVAudioSessionOrientationLeft
        case .right: return .right // AVAudioSessionOrientationRight
        default:
            throw LocationError.unknown
//            return .unknown
        }
    }
    
}

extension String {
    static let notSelectedInputName: String = ""
}

class Input {
    
    let name: String
    let location: Location
    
    init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
    
}

extension Input: Hashable {
    
    var hashValue: Int {
        name.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
}

extension Input: Equatable {
    
    static func == (lhs: Input, rhs: Input) -> Bool {
        lhs.name == rhs.name 
    }
    
}

extension Input {
    
    static var unknownInput: Input {
        Input(name: .notSelectedInputName, location: .unknown)
    }
    
}

enum RecorderError: Error {
    case noAudioSession
    case noAudioInput
    case noAudioInputPort
    case noInternalRecorder
}

class Recorder {
    
    // MARK: Public interface
    
    var recording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    private let preferredPort: AVAudioSession.Port = .builtInMic
    
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
    
    private func availableInputsPortDescription(with portType: AVAudioSession.Port, in session: AVAudioSession) throws -> AVAudioSessionPortDescription? {
        session.availableInputs?.first {
            $0.portType == portType
        }
    }
    
    func prepare() throws -> Recorder {
        
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
        
//        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44_100.0, channels: 2, interleaved: true)
//        audioRecorder = try AVAudioRecorder(url: activeUrl, format: format!)
        let settings = [AVEncoderBitRatePerChannelKey: 96000]
        audioRecorder = try AVAudioRecorder(url: activeUrl, settings: settings)
        audioRecorderDelegate.recorder = self
        audioRecorder?.delegate = audioRecorderDelegate
        audioRecorder?.isMeteringEnabled = true
        // success return
        return self
    }
    
    func record() {
        do {
            try prepareAudioSession(completion: { [weak self] granted in
                guard let self else {
                    print("Recorder: Recorder was deallocated!")
                    return
                }
                guard granted else {
                    print("Recorder: There is access to audio recording!")
                    return
                }
                guard let audioRecorder else {
                    print("Recorder: There is no audioRecorder!")
                    return
                }
                print("Recorder: start record.")
                audioRecorder.record()
            })
        } catch {
            print("Recorder: Audio session preparing was failed!")
        }
    }
    
    func stop() {
        guard let audioRecorder else {
            print("Recorder: There is no audioRecorder!")
            return
        }
        audioRecorder.stop()
        self.audioRecorder = nil
    }
    
    // MARK: Private vars
    
    private var audioSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    private var audioRecorderDelegate: RecorderDelegate = RecorderDelegate()
    
    fileprivate var activeUrl: URL?
    
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
        try port.setPreferredDataSource(port.dataSources?.last)
        print("Recorder: activate AVAudioSession with category: \(audioSession.category)")
        audioSession.requestRecordPermission() { allowed in
            print("Recorder: requestRecordPermission() allowed=\(allowed)")
            completion(allowed)
        }
    }
    
}

/// Interruption from AudioSession 
/// https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_interruptions?language=objc
class RecorderDelegate: NSObject, AVAudioRecorderDelegate {
    
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
