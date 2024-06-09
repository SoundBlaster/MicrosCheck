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

class InputImpl: Input {

    let name: String
    let location: Location
    
    init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
    
}

extension InputImpl: Hashable {

    var hashValue: Int {
        name.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
}

extension InputImpl: Equatable {

    static func == (lhs: InputImpl, rhs: InputImpl) -> Bool {
        lhs.name == rhs.name
    }
    
}

extension InputImpl {
    
    static var unknownInput: InputImpl {
        InputImpl(name: .notSelectedInputName, location: .unknown)
    }
    
}

extension InputImpl: CustomStringConvertible {
    
    var description: String {
        "\(type(of: self)), name: '\(name)', location: '\(location)'"
    }

}
