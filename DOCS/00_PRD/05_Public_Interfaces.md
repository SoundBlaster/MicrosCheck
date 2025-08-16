```markdown
## 5) Публичные интерфейсы (для разделения ответственности)

```swift
protocol RecorderService {
    var isRecording: Bool { get }
    var elapsed: TimeInterval { get } // общее время записи (с учётом пауз)
    var meters: (lAvg: Float, lPeak: Float, rAvg: Float, rPeak: Float) { get }
    var currentMeta: FileMeta? { get }

    func configure(_ settings: RecordingSettings) throws
    func selectInput(_ route: RecorderInputRoute) throws // built-in / headset / bluetooth
    func start() throws
    func pause() throws
    func resume() throws
    func stopAndSave(name: String?) async throws -> FileMeta
}

protocol PlayerService {
    var isPlaying: Bool { get }
    var position: TimeInterval { get }
    var duration: TimeInterval { get }
    var meters: (lAvg: Float, lPeak: Float, rAvg: Float, rPeak: Float) { get }

    func load(_ file: AudioFileID) async throws
    func play() throws
    func pause() throws
    func stop() throws
    func seek(to: TimeInterval, smooth: Bool)
    func nudge(by seconds: TimeInterval) // ±10с
    func holdSeek(start direction: SeekDirection) // повторные шаги с интервалом
    func holdSeekStop()

    // DPC & громкость
    func setRate(_ v: Float)
    func setPitchCents(_ v: Float)
    func setMasterVolume(_ v: Float)
    func setChannelGains(lDb: Float, rDb: Float)

    // A-B
    func setAPoint(_ t: TimeInterval?)
    func setBPoint(_ t: TimeInterval?)
    func clearAB()
}

protocol FilesService {
    func list() async throws -> [FileMeta]
    func attributes(for id: AudioFileID) async throws -> FileMeta
    func copy(_ id: AudioFileID, to newName: String) async throws -> AudioFileID
    func delete(_ id: AudioFileID) async throws
    func freeDiskSpaceBytes() throws -> Int64
    func rename(_ id: AudioFileID, to newName: String) async throws -> AudioFileID
    func updateMeta(_ meta: FileMeta) async throws
}