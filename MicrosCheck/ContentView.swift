//
//  ContentView.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 23.04.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var state = AppState()

    var body: some View {
        
        ButtonsView()

        Form {
            
            Section("Настройки") {
                if !state.isRecording {
                    if state.recorder.availableInputs().count > 0 {
//                        Text("Выберите микрофон")
                        let _ = print(state.recorder.availableInputs())
                        Picker("Выберите микрофон", selection: $state.selectedInputName) {
                            ForEach(state.recorder.availableInputs(), id: \.name) {
                                Text($0.name)
                            }
                        }

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
                    if !state.isRecording {
                        HStack {
                            Spacer()
                            Button(action: {
                                do {
                                    try state.recorder
                                        .prepare()
                                        .record()
                                } catch {
                                    print("Recorder initialization was failed! \(error)")
                                }
                                state.isRecording = true
                            }, label:{ Text("Начать запись!") })
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button(action: {
                                state.recorder
                                    .stop()
                                state.isRecording = false
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
                            case true:
                                state.player?.stop()
                                state.isPlaying = false
                                print("Stop button tapped")
                            default:
                                state.player = AudioPlayerImpl(file: FileImpl(url: FileReader.recordURL()))
                                state.player?.play()
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

#Preview {
    ContentView()
}
