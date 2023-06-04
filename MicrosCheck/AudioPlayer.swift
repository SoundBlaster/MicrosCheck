//
//  AudioPlayer.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 07.05.2023.
//

import Foundation
import AVFAudio

class AudioPlayer {
    
    enum State {
        case inited
        case playing(progress: TimeInterval)
        case paused
        case stopped
        case error(error: NSError)
    }
    
    deinit {
        print("AudioPlayer deinit")
    }
    
    var state: State {
        _state
    }
    
    var fileURL: URL? {
        didSet {
            guard let fileURL else {
                _player = nil
                print("Failed to set nil in fileURL!")
                return
            }
            
            do {
                print("AudioPlayer: Try create AVAudioPlayer with path: \(fileURL)")
                let fileSize = FileReader.fileSize(for: fileURL)
                print("AudioPlayer: File size for playing: \(fileSize)")
//                guard fileSize > 0 else {
//                    print("AudioPlayer: Failed to prepare audio session for playing!")
//                    return
//                }
                _player = try AVAudioPlayer(contentsOf: fileURL)
                guard let _player else {
                    print("AudioPlayer: Failed to create AVAudioPlayer with \(fileURL)!")
                    return
                }
                _player.delegate = avDelegate
                avDelegate.audioPlayer = self
                guard _player.prepareToPlay() else {
                    print("AudioPlayer: AVAudioPlayer could not be prepared!")
                    return
                }
            } catch {
                print("AudioPlayer: AVAudioPlayer preparing was failed!")
            }
        }
    }
    
    func play() {
        do {
            try prepareAudioSession()
        } catch {
            print("Failed to prepare audio session for playing!")
        }
        guard let player = _player else {
            print("AudioPlayer: Error! There is no AVAudioPlayer in _player!")
            return
        }
        print("AudioPlayer: play \(player.duration)")
        player.play()
        _state = .playing(progress: player.currentTime)
    }
    
    func pause() {
        guard let player = _player else {
            print("Error! There is no AVAudioPlayer in _player!")
            return
        }
        print("AudioPlayer: pause")
        player.pause()
        _state = .paused
    }
    
    func stop() {
        guard let player = _player else {
            print("Error! There is no AVAudioPlayer in _player!")
            return
        }
        print("AudioPlayer: stop")
        player.stop()
        _state = .stopped
    }
    
    // MARK: Private

    fileprivate var _state: State = .inited
    private var _player: AVAudioPlayer?
    private let avDelegate = AudioPlayerAVDelegate()
    private var audioSession: AVAudioSession?
    
    func prepareAudioSession() throws {
        audioSession = AVAudioSession.sharedInstance()
        guard let audioSession else {
            print("AudioPlayer: There is no audio session!")
            return
        }
        try audioSession.setCategory(.playback)
        try audioSession.setActive(true)
        print("AudioPlayer: activate AVAudioSession with category: \(audioSession.category)")
    }
}

class AudioPlayerAVDelegate: NSObject, AVAudioPlayerDelegate {
    
    weak var audioPlayer: AudioPlayer?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("AudioPlayerAVDelegate: audioPlayerDidFinishPlaying: \(player), successfully \(flag)")
        guard let audioPlayer else {
            print("AudioPlayerAVDelegate: There is no audioPlayer!")
            return
        }
        
        audioPlayer._state = .stopped
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let audioPlayer else {
            print("AudioPlayerAVDelegate: There is no audioPlayer!")
            return
        }
        
        if let error {
            audioPlayer._state = .error(error: error as NSError)
            print("AudioPlayerAVDelegate: fails with error \(error).")
        } else {
            audioPlayer._state = .stopped
            print("AudioPlayerAVDelegate: fails with no error.")
        }
        
    }
    
}
