//
//  ContentView.swift
//  MicrosCheck
//
//  Created by Egor Merkushev on 23.04.2023.
//

import SwiftUI

func log<T>(_ something: T) -> T {
    print("log: \(something)")
    return something
}

struct ContentView: View {

    @Environment(AppState.self) private var appState

    var body: some View {

        @Bindable var state = appState

        ButtonsView()

        Form {

#if DEBUG_UI
            Section("DBG state.recorder.state") {
                switch state.recorder.state {
                case .inited:
                    Text("inited")
                case .prepared:
                    Text("prepared")
                case .recording:
                    Text("recording")
                case .paused:
                    Text("paused")
                case .stopped:
                    Text("stopped")
                }
            }

            Section("DBG state.isPrepared") {
                switch state.isPrepared {
                case true:
                    Text("prepared")
                case false:
                    Text("not prepared")
                }
            }

            Section("DBG state.recorder.availableInputs()") {
                let _ = log(state.recorder.availableInputs())
                ForEach(state.recorder.availableInputs(), id: \.name) {
                    Text($0.name)
                }
            }
#endif

            Section("Источник") {
                if state.isPrepared {
                    if state.recorder.availableInputs().count > 0 {
                        Picker("Выберите микрофон", selection: $state.selectedInputName) {
                            Text("\(String.notSelectedInputName)").tag(String.notSelectedInputName as String)
                            ForEach(state.recorder.availableInputs(), id: \.name) {
                                Text($0.name).tag($0.name as String)
                            }
                        }
                    } else {
                        Spacer()
                        Text("Устройства не найдены...")
                        Spacer()
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("Идёт поиск устройств...")
                        Spacer()
                    }
                    .task {
                        do {
                            _ = try state.recorder
                                .prepare()
                            state.isPrepared = true
                        } catch {
                            print("Recorder initialization was failed! \(error)")
                        }
                    }
                }
            }
            
            if state.isPrepared && state.recorder.availableInputs().count > 0 {
                Section("Запись") {
                    if state.isRecording {
                        HStack {
                            Spacer()
                            Button(action: {
                                do {
                                    try state.recorder
                                        .stop()
                                    state.isRecording = false
                                } catch {
                                    print("Stop recording failed! \(error)")
                                }
                            }, label:{ Text("Остановить запись") })
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button(action: {
                                do {
                                    try state.recorder
                                        .record()
                                } catch {
                                    print("Recording failed! \(error)")
                                }
                                state.isRecording = true
                            }, label:{ Text("Начать запись!") })
                            Spacer()
                        }
                    }
                }
            }

            if state.fileReader.hasFile(at: state.fileReader.recordURL()) {
                Section("Записи") {
                    HStack {
                        Spacer()
                        Button(action: {
                            switch state.isPlaying {
                            case true:
                                state.player?.stop()
                                state.isPlaying = false
                                print("Stop button tapped")
                            default:
                                state.player = AudioPlayerImpl(file: FileImpl(url: state.fileReader.recordURL()), fileReader: state.fileReader)
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
                }.disabled(state.isRecording)
            }
        }
    }
}

#Preview {
    ContentView()
}
