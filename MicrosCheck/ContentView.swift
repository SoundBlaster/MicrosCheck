//
//  ContentView.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 23.04.2023.
//

import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var recording: Bool = false
    @Published var selectedInputName: String = .notSelectedInputName
    @Published var isPlaying: Bool = false
    
    let recorder: Recorder = Recorder()
    let player: AudioPlayer = AudioPlayer()
    
    init() {
        _ = FileReader.deleteFile(at: FileReader.recordURL())
    }
}

struct ContentView: View {
    
    @StateObject var state = AppState()
    
    var body: some View {
        
        Form {
            
            Section("Настройки") {
                if !state.recording {
                    if state.recorder.availableInputs().count > 0 {
                        Text("Выберите микрофон")
//                        Picker("Выберите микрофон", selection: state.selectedInputName) {
//                            ForEach(state.recorder.availableInputs(), id: \.name) {
//                                Text($0.name)
//                            }
//                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Идёт поиск устройств...")
                            Spacer()
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("Идёт запись...")
                        Spacer()
                    }
                }
            }
            
            if state.recorder.availableInputs().count > 0 {
                Section {
                    if !state.recording {
                        HStack {
                            Spacer()
                            Button(action: {
                                do {
                                    try state.recorder
                                        .prepare()
                                        .record()
                                } catch {
                                    print("Recorder initialization was failed!")
                                }
                                state.recording = true
                            }, label:{ Text("Начать запись!") })
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button(action: {
                                state.recorder
                                    .stop()
                                state.recording = false
                            }, label:{ Text("Остановить запись") })
                            Spacer()
                        }
                    }
                }
            }
            
            Section("Записи") {
                if FileReader.hasFile(at: FileReader.recordURL()) {
                    HStack {
                        Spacer()
                        Button(action: {
                            switch state.isPlaying {
                            case true :
                                state.player.stop()
                                state.isPlaying = false
                                print("Stop button tapped")
                            default :
                                state.player.fileURL = FileReader.recordURL()
                                state.player.play()
                                state.isPlaying = true
                                print("Play button tapped")
                            }
                        }, label:{
                            switch state.isPlaying {
                            case true :
                                Text("Остановить проигрывание")
                            default :
                                Text("Прослушать запись")
                            }
                        })
                        Spacer()
                    }
                }
            }
            
        }
        
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
