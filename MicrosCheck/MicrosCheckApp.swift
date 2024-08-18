//
//  MicrosCheckApp.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 23.04.2023.
//

import SwiftUI

@main
struct MyApp: App {

    @State
    private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
