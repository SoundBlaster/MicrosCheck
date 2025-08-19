import SwiftUI

public struct UILockOverlay: View {
    public var onUnlock: () -> Void
    public var holdDuration: Double?
    @State private var unlocked: Bool = false
    @GestureState private var isPressing = false
    
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
                
                Text(displayText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(10)
            }
            .scaleEffect(isPressing ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.18), value: isPressing)
        }
        .gesture(
            LongPressGesture(minimumDuration: holdDuration ?? 2.0)
                .updating($isPressing) { value, state, _ in
                    if value && countdownBaseDate == nil {
                        countdownBaseDate = Date()
                        countdown = holdDuration ?? 2.0
                        
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                            if let baseDate = countdownBaseDate {
                                let remaining = max((holdDuration ?? 2.0) - Date().timeIntervalSince(baseDate), 0)
                                countdown = remaining
                            }
                        }
                    }
                    if !value {
                        countdownBaseDate = nil
                        countdown = nil
                        timer?.invalidate()
                        timer = nil
                    }
                    state = value
                }
                .onEnded { _ in
                    timer?.invalidate()
                    timer = nil
                    withAnimation(.spring()) {
                        unlocked.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onUnlock()
                    }
                }
        )
    }
    
    private var displayText: String {
        if isPressing, let remaining = countdown {
            return String(format: "%.1f", remaining)
        } else {
            return "Hold to Unlock"
        }
    }
}

// preview
struct UILockOverlay_Previews: PreviewProvider {
    static var previews: some View {
        UILockOverlay(onUnlock: {})
    }
}
