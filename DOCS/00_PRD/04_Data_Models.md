# 4. Codable Data Models

```swift
enum AudioFormat: String, Codable { case aac /*default*/, pcm, alac /*…*/ }

struct RecordingSettings: Codable {
    var sampleRate: Double // 44100 | 48000
    var bitrateKbps: Int   // 128..320 (for AAC)
    var channels: Int      // 1|2
    var format: AudioFormat
}

struct AudioFileID: Hashable, Codable { let path: String }

struct Bookmark: Codable, Identifiable {
    let id: UUID
    var time: TimeInterval
    var title: String?
    var note: String?
    var createdAt: Date
}

struct AudioAttributes: Codable {
    var duration: TimeInterval
    var bitrateKbps: Int?
    var sampleRate: Double
    var channels: Int
    var format: AudioFormat
    var fileSizeBytes: Int64
}

struct FileMeta: Codable {
    var id: AudioFileID
    var displayName: String
    var createdAt: Date
    var lastPlayedPosition: TimeInterval?
    var bookmarks: [Bookmark]
    var audio: AudioAttributes
    var userTags: [String]
    var custom: [String:String]?
}

struct PlaybackState: Codable {
    var position: TimeInterval
    var rate: Float      // 0.5..2.0
    var pitchCents: Float // -1200..+1200
    var volumeMaster: Float // 0..2
    var volumeL: Float      // in dB
    var volumeR: Float
    var aPoint: TimeInterval?
    var bPoint: TimeInterval?
}
```
