//
//  WaveformGenerator.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 2024-06-12.
//

import AVFoundation
import Foundation

/// Represents sample summary data for a waveform segment.
struct WaveformSegment: Codable, Equatable {
    /// RMS amplitude in decibels for segment.
    let rmsDb: Float
    /// Peak amplitude in decibels for segment.
    let peakDb: Float
}

/// WaveformData holds an array of waveform segments representing the whole audio file.
struct WaveformData: Codable, Equatable {
    let segments: [WaveformSegment]
    let segmentDuration: TimeInterval
    let totalDuration: TimeInterval
}

/// Provides offline waveform generation, caching, and loading from cache.
@MainActor
final class WaveformGenerator {

    /// The folder URL where cached waveform data files are stored.
    let cacheDirectory: URL

    /// Initializes the generator with a directory for cache files.
    /// Ensures the cache directory exists.
    init(cacheDirectory: URL) {
        self.cacheDirectory = cacheDirectory
        ensureCacheDirectoryExists()
    }

    /// Generate waveform data for a given audio file URL, asynchronously.
    /// If a cached waveform exists for the file and matches duration, it is loaded instead.
    /// - Parameter fileURL: The audio file URL.
    /// - Returns: Cached or newly generated waveform data.
    func generateWaveform(for fileURL: URL) async throws -> WaveformData {
        // Check if cached waveform exists and is valid
        if let cached = try? loadCachedWaveform(for: fileURL) {
            return cached
        }

        let waveform = try await computeWaveform(for: fileURL)
        try saveCachedWaveform(waveform, for: fileURL)
        return waveform
    }

    /// Loads cached waveform data for a file URL.
    /// - Parameter fileURL: The audio file URL.
    /// - Returns: Cached waveform data if valid.
    private func loadCachedWaveform(for fileURL: URL) throws -> WaveformData? {
        let cacheURL = cacheFileURL(for: fileURL)
        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            return nil
        }
        let data = try Data(contentsOf: cacheURL)
        let waveform = try JSONDecoder().decode(WaveformData.self, from: data)

        // Validate cache is consistent with file duration
        if let asset = audioAsset(for: fileURL),
            abs(asset.duration.seconds - waveform.totalDuration) < 0.5
        {
            return waveform
        }
        // Cache is stale or inconsistent, delete
        try? FileManager.default.removeItem(at: cacheURL)
        return nil
    }

    /// Saves waveform data to cache for a file URL.
    /// - Parameters:
    ///   - waveform: Waveform data to save.
    ///   - fileURL: Audio file URL.
    private func saveCachedWaveform(_ waveform: WaveformData, for fileURL: URL) throws {
        let cacheURL = cacheFileURL(for: fileURL)
        let data = try JSONEncoder().encode(waveform)
        try data.write(to: cacheURL, options: [.atomic])
    }

    /// Computes the waveform data offline by reading audio file samples.
    /// - Parameter fileURL: Audio file URL.
    /// - Returns: Computed waveform data.
    private func computeWaveform(for fileURL: URL) async throws -> WaveformData {
        // Read audio asset
        guard let asset = audioAsset(for: fileURL) else {
            throw WaveformGeneratorError.invalidAudioFile
        }

        let totalDuration = asset.duration.seconds
        let segmentsCount = 1000  // Number of segments to divide waveform into
        let segmentDuration = totalDuration / Double(segmentsCount)

        // Prepare AVAssetReader to read PCM data
        let reader = try AVAssetReader(asset: asset)
        guard let track = asset.tracks(withMediaType: .audio).first else {
            throw WaveformGeneratorError.noAudioTrack
        }

        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false,
            AVSampleRateKey: track.naturalTimeScale,
        ]

        let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(trackOutput)
        reader.startReading()

        var segments = [WaveformSegment](
            repeating: WaveformSegment(rmsDb: -60, peakDb: -60), count: segmentsCount)

        // Buffer segment data accumulators
        var currentSegmentIndex = 0
        var samplesInSegment: [Int16] = []
        let samplesPerSegmentEstimate = Int(track.naturalTimeScale) * Int(segmentDuration)

        // Helper function to compute dB from samples
        func computeRMSAndPeakDb(samples: [Int16]) -> WaveformSegment {
            guard samples.count > 0 else {
                return WaveformSegment(rmsDb: -60, peakDb: -60)
            }
            // Convert Int16 samples to floats normalized between -1 and 1
            let floats = samples.map { Float($0) / 32768.0 }
            let squaresSum = floats.reduce(0) { $0 + $1 * $1 }
            let rms = sqrt(squaresSum / Float(samples.count))
            let rmsDb = 20 * log10(rms == 0 ? 0.0001 : rms)

            let peak = floats.max(by: { abs($0) < abs($1) }) ?? 0
            let peakDb = 20 * log10(abs(peak) == 0 ? 0.0001 : abs(peak))

            return WaveformSegment(rmsDb: max(rmsDb, -60), peakDb: max(peakDb, -60))
        }

        while reader.status == .reading {
            guard let sampleBuffer = trackOutput.copyNextSampleBuffer(),
                let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer)
            else {
                break
            }

            let length = CMBlockBufferGetDataLength(blockBuffer)
            var data = Data(count: length)

            data.withUnsafeMutableBytes { (rawBufferPointer: UnsafeMutableRawBufferPointer) in
                guard let baseAddress = rawBufferPointer.baseAddress else { return }
                CMBlockBufferCopyDataBytes(
                    blockBuffer, atOffset: 0, dataLength: length, destination: baseAddress)
            }

            let sampleCount = length / MemoryLayout<Int16>.size
            data.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) in
                let samplesPtr = bufferPointer.bindMemory(to: Int16.self)
                for i in 0..<sampleCount {
                    let sample = samplesPtr[i]
                    samplesInSegment.append(sample)

                    if samplesInSegment.count >= samplesPerSegmentEstimate {
                        // Process accumulated segment
                        let segmentData = computeRMSAndPeakDb(samples: samplesInSegment)
                        if currentSegmentIndex < segmentsCount {
                            segments[currentSegmentIndex] = segmentData
                        }
                        currentSegmentIndex += 1
                        samplesInSegment.removeAll(keepingCapacity: true)

                        if currentSegmentIndex >= segmentsCount {
                            break
                        }
                    }
                }
            }

            CMSampleBufferInvalidate(sampleBuffer)

            if currentSegmentIndex >= segmentsCount {
                break
            }
        }

        // Process remaining samples, if any
        if !samplesInSegment.isEmpty, currentSegmentIndex < segmentsCount {
            segments[currentSegmentIndex] = computeRMSAndPeakDb(samples: samplesInSegment)
        }

        return WaveformData(
            segments: segments, segmentDuration: segmentDuration, totalDuration: totalDuration)
    }

    /// Ensures the cache directory exists and is a directory.
    private func ensureCacheDirectoryExists() {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: cacheDirectory.path, isDirectory: &isDir) {
            if !isDir.boolValue {
                try? fm.removeItem(at: cacheDirectory)
                try? fm.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            }
        } else {
            try? fm.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    /// Returns the cache file URL for a given audio file URL.
    /// Uses a hash of the file path for filename uniqueness.
    private func cacheFileURL(for fileURL: URL) -> URL {
        let fileNameHash = String(fileURL.path.hashValue)
        return cacheDirectory.appendingPathComponent(fileNameHash).appendingPathExtension("wave")
    }

    /// Creates an AVAsset for a given file URL.
    private func audioAsset(for fileURL: URL) -> AVAsset? {
        let asset = AVURLAsset(url: fileURL)
        return asset.tracks(withMediaType: .audio).isEmpty ? nil : asset
    }
}

/// Errors thrown during waveform generation.
enum WaveformGeneratorError: Error, LocalizedError {
    case invalidAudioFile
    case noAudioTrack

    var errorDescription: String? {
        switch self {
        case .invalidAudioFile:
            return "Invalid or unreadable audio file."
        case .noAudioTrack:
            return "No audio track available in file."
        }
    }
}
