//
//  RecordingSettings.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 2025-08-19.
//

import Foundation

struct RecordingSettings: Codable, Equatable {
    var sampleRate: Double  // e.g., 44100 or 48000
    var bitrateKbps: Int  // e.g., 128, 256, 320
    var channels: Int  // 1 or 2
    var format: String  // e.g., "aac", "mp3"

    static let `default` = RecordingSettings(
        sampleRate: 44100.0,
        bitrateKbps: 128,
        channels: 2,
        format: "aac"
    )
}

@MainActor
final class RecordingSettingsStore {

    private let userDefaultsKey = "RecordingSettingsKey"

    private let defaults: UserDefaults

    @Published private(set) var currentSettings: RecordingSettings

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        if let data = userDefaults.data(forKey: userDefaultsKey),
            let settings = try? JSONDecoder().decode(RecordingSettings.self, from: data)
        {
            self.currentSettings = settings
        } else {
            self.currentSettings = RecordingSettings.default
            save(settings: self.currentSettings)
        }
    }

    func save(settings: RecordingSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: userDefaultsKey)
            currentSettings = settings
        }
    }

    func update(
        sampleRate: Double? = nil, bitrateKbps: Int? = nil, channels: Int? = nil,
        format: String? = nil
    ) {
        var newSettings = currentSettings
        if let sampleRate = sampleRate {
            newSettings.sampleRate = sampleRate
        }
        if let bitrateKbps = bitrateKbps {
            newSettings.bitrateKbps = bitrateKbps
        }
        if let channels = channels {
            newSettings.channels = channels
        }
        if let format = format {
            newSettings.format = format
        }
        save(settings: newSettings)
    }
}
