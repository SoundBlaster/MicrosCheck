import AVFoundation

@MainActor
internal final class RecorderImpl: Recorder {

    final class StateHolder: StateMachine {

        var state: RecorderState = .inited

        var routes: [RecorderState: [RecorderState]] = {
            [
                .inited: [.prepared],
                .prepared: [.recording],
                .recording: [.paused, .stopped],
                .paused: [.recording, .stopped],
                .stopped: [.prepared],
            ]
        }()

        @discardableResult
        func updateState(to nextState: RecorderState) throws -> RecorderState {
            print("updateState: \(state) -> \(nextState)")
            print(
                "updateState \(String(describing: routes[state]?.contains(where: { $0 == nextState })))"
            )

            if routes[state]?.contains(where: { $0 == nextState }) == false {
                throw RecorderError.impossibleStateChange(state: state, nextState: nextState)
            }
            state = nextState
            return state
        }

    }

    // MARK: Public interface

    let fileReader: FileReader

    init(
        fileReader: FileReader, audioSession: AVAudioSession? = nil,
        audioRecorder: AVAudioRecorder? = nil, activeUrl: URL? = nil
    ) {
        self.fileReader = fileReader
        self.audioSession = audioSession
        self.audioRecorder = audioRecorder
        self.activeUrl = activeUrl
    }

    // MARK: Recorder

    var state: RecorderState {
        stateHolder.state
    }

    var recording: Bool {
        audioRecorder?.isRecording ?? false
    }

    func availableInputs() -> [Input] {
        let empty: [Input] = []
        guard let audioSession else {
            return empty
        }
        do {
            let a = try availableInputsPortDescription(with: preferredPort, in: audioSession)
            let dataSources = a?.dataSources  // на Mac датасорс пуст
            return try dataSources?.map {
                InputImpl(
                    name: $0.dataSourceName, location: try Location.fromOrientation($0.orientation))
            } ?? empty
        } catch {
            return empty
        }
    }

    @discardableResult
    public func prepare() throws -> Recorder {

        guard audioRecorder == nil else {
            assertionFailure("Recoder: already has have the instance of AVAudioRecorder!")
            return self
        }

        // audio recorder
        activeUrl = fileReader.recordURL()

        guard let activeUrl else {
            assertionFailure("Recoder: has no active URL!")
            return self
        }

        // cleanup
        guard fileReader.deleteFile(at: activeUrl) else {
            assertionFailure("Recoder: can not cleanup the active URL!")
            return self
        }

        let settings = [AVEncoderBitRatePerChannelKey: 96000]
        audioRecorder = try AVAudioRecorder(url: activeUrl, settings: settings)
        audioRecorder?.delegate = audioRecorderDelegate
        audioRecorder?.isMeteringEnabled = true
        try prepareAudioSession { [weak self] granted in
            print(
                "Recorder: audio session is\(granted == true ? "" : " not") prerared for recording."
            )
            do {
                try self?.stateHolder.updateState(to: .prepared)
            } catch {
                print("Recorder: Recorder preparation was failed!")
            }
            print("availableInputs: \(String(describing: self?.availableInputs()))")
        }
        // success return
        return self
    }

    public func selectInput(_ input: Input) throws {
        guard let audioSession = AVAudioSession.sharedInstance() as AVAudioSession? else {
            throw RecorderError.noAudioSession
        }
        guard
            let port = try availableInputsPortDescription(
                with: inputPortType(from: input.name), in: audioSession)
        else {
            throw RecorderError.noAudioInputPort
        }
        // Find data source matching input name
        if let dataSource = port.dataSources?.first(where: { $0.dataSourceName == input.name }) {
            try port.setPreferredDataSource(dataSource)
        }
        try audioSession.setPreferredInput(port)
        print("Recorder: Selected input \(input.name)")
    }

    private func inputPortType(from name: String) -> AVAudioSession.Port {
        // Map input name to port type, fallback to builtInMic
        let lowerName = name.lowercased()
        if lowerName.contains("bluetooth") {
            return .bluetoothHFP
        } else if lowerName.contains("headset") {
            return .headsetMic
        } else if lowerName.contains("built-in") || lowerName.contains("builtin") {
            return .builtInMic
        }
        return .builtInMic
    }

    @discardableResult
    public func record() throws -> Recorder {
        try prepareAudioSession(completion: { [weak self] granted in
            guard let self else {
                assertionFailure("Recorder: Recorder was deallocated!")
                return
            }
            guard granted else {
                assertionFailure("Recorder: There is no access to audio recording!")
                return
            }
            guard let audioRecorder else {
                assertionFailure("Recorder: There is no audioRecorder!")
                return
            }
            print("Recorder: start record.")
            audioRecorder.record()
        })
        return self
    }

    @discardableResult
    public func pause() throws -> Recorder {
        guard let audioRecorder else {
            assertionFailure("Recorder: There is no audioRecorder!")
            return self
        }
        audioRecorder.pause()
        return self
    }

    @discardableResult
    public func stop() throws -> Recorder {
        guard let audioRecorder else {
            assertionFailure("Recorder: There is no audioRecorder!")
            return self
        }
        audioRecorder.stop()
        return self
    }

    // MARK: Private vars & functions

    private let stateHolder = StateHolder()
    private let preferredPort: AVAudioSession.Port = .builtInMic
    private var audioSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    private var audioRecorderDelegate: RecorderDelegate {
        RecorderDelegate(recorder: self, fileReader: fileReader)
    }
    var activeUrl: URL?

    private func availableInputsPortDescription(
        with portType: AVAudioSession.Port, in session: AVAudioSession
    ) throws -> AVAudioSessionPortDescription? {
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
        guard let port = try availableInputsPortDescription(with: preferredPort, in: audioSession)
        else {
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
            audioSession.requestRecordPermission { allowed in
                print("Recorder: requestRecordPermission() allowed=\(allowed)")
                completion(allowed)
            }
        }
    }

}
