import SwiftUI

public struct UILockOverlay: View {
    public var onUnlock: () -> Void
    public let holdDuration: Double?
    
    @GestureState private var isPressing = false
    @State private var unlocked: Bool = false
    @State private var countdownBaseDate: Date? = nil
    @State private var countdown: Double? = nil
    @State private var timer: Timer? = nil

    public init(holdDuration: Double? = nil, onUnlock: @escaping () -> Void) {
        self.holdDuration = holdDuration
        self.onUnlock = onUnlock
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: unlocked ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                    .contentTransition(.symbolEffect(.replace))
                
                Text("Hold to Unlock")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
                    .overlay(
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                            Text(countdownText)
                                .font(.headline)
                                .foregroundColor(.white)
                                .monospacedDigit()
                        }
                        .opacity(isPressing ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: isPressing)
                    )
            }
            .scaleEffect(isPressing ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.18), value: isPressing)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        countdown = nil
                        countdownBaseDate = nil
                        timer?.invalidate()
                        timer = nil
                    }
            )
        }
        .gesture(
            LongPressGesture(minimumDuration: holdDuration ?? 2.0)
                .updating($isPressing) { value, state, _ in
                    if value && countdownBaseDate == nil {
                        countdownBaseDate = Date()
                        countdown = holdDuration ?? 2.0
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                            guard let baseDate = countdownBaseDate else { return }
                            let remaining = max((holdDuration ?? 2.0) - Date().timeIntervalSince(baseDate), 0)
                            countdown = remaining
                        }
                    }
                    state = value
                }
                .onChanged { value in
                    if !value {
                        countdown = nil
                        countdownBaseDate = nil
                        timer?.invalidate()
                        timer = nil
                    }
                }
                .onEnded { value in
                    countdown = nil
                    countdownBaseDate = nil
                    timer?.invalidate()
                    timer = nil
                    withAnimation(.spring()) {
                        unlocked.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onUnlock()
                    }
                }
                .simultaneously(with:
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            countdown = nil
                            countdownBaseDate = nil
                            timer?.invalidate()
                            timer = nil
                        }
                )
        )
    }
    
    private var countdownText: String {
        if let remaining = countdown, remaining > 0 {
            return String(format: "%.1f", remaining)
        } else {
            return "0"
        }
    }
}

// preview
struct UILockOverlay_Previews: PreviewProvider {
    static var previews: some View {
        UILockOverlay(onUnlock: {})
    }
}
