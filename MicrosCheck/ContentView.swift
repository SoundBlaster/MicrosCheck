import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RecorderMainScreen(viewModel: RecorderViewModel(appState: appState))
    }
}

#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            let appState = AppState()
            RecorderMainScreen(viewModel: RecorderViewModel(appState: appState))
                .preferredColorScheme(.dark)
        }
    }
#endif
