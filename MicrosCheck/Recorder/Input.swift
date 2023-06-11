//
//  Input.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 11.06.2023.
//

import AVFoundation

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
