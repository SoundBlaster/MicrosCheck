//
//  Location.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 11.06.2023.
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
        }
    }
    
}
