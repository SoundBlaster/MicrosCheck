import SwiftUI

struct UIOverviewDemoView: View {
    var body: some View {
        VStack(spacing: 16) {
            // A1 - Top Waveform and Timeline
            VStack(spacing: 4) {
                Label("A1a Live Waveform Visualization", systemImage: "waveform.path.ecg")
                Label("A1b Vertical Decibel Level Ruler", systemImage: "ruler.vertical")
                Label("A1c Time Ruler H-M-S", systemImage: "clock")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .border(Color.gray)
            .overlay(
                Text("A1 Top Waveform and Timeline").font(.headline).padding(.bottom, 36),
                alignment: .top)

            // A2 - Recording Information Panel
            HStack(spacing: 16) {
                // A2a Left Block
                VStack(spacing: 4) {
                    Label(
                        "A2a1 Current Recording Status Indicator REC", systemImage: "record.circle")
                    Label("A2a2 Elapsed Time Display", systemImage: "timer")
                    Label("A2a3 Audio Format & Bitrate Info", systemImage: "info.circle")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .border(Color.gray)
                .overlay(
                    Text("A2a Left Block - Vertical Stack").font(.caption).padding(.top, -6),
                    alignment: .top)

                // A2b Right Block
                VStack(spacing: 4) {
                    Label("A2b1 File Name of Active Recording", systemImage: "doc.text")
                    Label("A2b2 File Size Indicator", systemImage: "archivebox")

                    // A2b3 Audio Meter Display
                    VStack(spacing: 2) {
                        Label(
                            "A2b3a Left Channel Level Meter -60 to 0 dB",
                            systemImage: "speaker.wave.2")
                        Label("A2b3a1 Current Loudness", systemImage: "waveform")
                        Label(
                            "A2b3a2 Trailing dB Readings", systemImage: "chart.line.uptrend.xyaxis")
                        Label(
                            "A2b3b Right Channel Level Meter -60 to 0 dB",
                            systemImage: "speaker.wave.2.fill")
                        Label("A2b3b1 Current Loudness", systemImage: "waveform")
                        Label(
                            "A2b3b2 Trailing dB Readings", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .padding(4)
                    .border(Color.secondary)
                    .overlay(
                        Text("A2b3 Audio Meter Display").font(.caption2).padding(.top, -2),
                        alignment: .top)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .border(Color.gray)
                .overlay(
                    Text("A2b Right Block - Vertical Stack").font(.caption).padding(.top, -6),
                    alignment: .top)
            }
            .padding(.horizontal)
            .border(Color.black.opacity(0.6))
            .overlay(
                Text("A2 Recording Information Panel").font(.headline).padding(.bottom, 36),
                alignment: .top)

            // A3 - Navigation and Action Buttons
            HStack(spacing: 12) {
                Label("A3a Back Button < Back", systemImage: "arrow.left")
                Label("A3b Home Button", systemImage: "house")
                Label("A3c Time-Mark T-MARK Button", systemImage: "mappin")
                Label("A3d Options/Settings Button", systemImage: "gearshape")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .border(Color.gray)
            .overlay(
                Text("A3 Navigation and Action Buttons").font(.headline).padding(.bottom, 36),
                alignment: .top)

            // A4 - Search and Filter Controls Panel
            HStack {
                Label("A4a Search Text Input - Leading Edge", systemImage: "magnifyingglass")
                Spacer()
                HStack(spacing: 10) {
                    Label("A4b Appearance Mode Switch Button", systemImage: "sun.max")
                    Label("A4c Favorites Access Button", systemImage: "star")
                    Label("A4d Waveform View Style Toggle Button", systemImage: "waveform.path.ecg")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .border(Color.gray)
            .overlay(
                Text("A4 Search and Filter Controls Panel").font(.headline).padding(.bottom, 36),
                alignment: .top)

            // A5 - Transport Controls Panel
            HStack(spacing: 20) {
                Label("A5a Large Circular Stop Button - Left", systemImage: "stop.circle")
                VStack(spacing: 2) {
                    Label("A5b1 Label RECORDING", systemImage: "record.circle.fill")
                    Label("A5b2 Blinking Red Recording Indicator", systemImage: "circle.fill")
                        .foregroundColor(.red)
                }
                Label(
                    "A5c Large Circular Record/Pause Button - Bottom", systemImage: "pause.circle")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .border(Color.gray)
            .overlay(
                Text("A5 Transport Controls").font(.headline).padding(.bottom, 36), alignment: .top)

            // A6 - Central Circular Playback Control
            VStack(spacing: 8) {
                HStack {
                    Label("A6b Left Segment - Rewind Button", systemImage: "backward.fill")
                    Spacer()
                    Label("A6c Right Segment - Fast Forward Button", systemImage: "forward.fill")
                }
                HStack {
                    Label("A6a Center Circle - Play/Pause Button", systemImage: "playpause.fill")
                        .frame(maxWidth: .infinity)
                }
                HStack {
                    Label(
                        "A6d Bottom Segment - A-B Loop Toggle Indicator A-B ˇ",
                        systemImage: "repeat")
                    Spacer()
                    Label("A6e Top Segment - DPC Toggle DPC ˆ", systemImage: "bolt.fill")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .border(Color.gray)
            .overlay(
                Text("A6 Central Circular Playback Control").font(.headline).padding(.bottom, 36),
                alignment: .top)

            // A7 - UI Lock and Info Icons
            HStack {
                Label("A7a Lock Button - Bottom Left Screen Corner", systemImage: "lock.fill")
                Spacer()
                Label("A7b Info Button - Bottom Right Screen Corner", systemImage: "info.circle")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .border(Color.gray)
            .overlay(
                Text("A7 UI Lock and Info Icons").font(.headline).padding(.bottom, 36),
                alignment: .top)

        }
        .padding()
    }
}

struct UIOverviewDemoView_Previews: PreviewProvider {
    static var previews: some View {
        UIOverviewDemoView()
            .previewLayout(.sizeThatFits)
    }
}
