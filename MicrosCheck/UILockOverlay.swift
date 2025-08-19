import SwiftUI

public struct UILockOverlay: View {
    public var onUnlock: () -> Void
    public var holdDuration: Double?
    @State private var unlocked: Bool = false
    @GestureState private var isPressing = false

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
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(10)
            }
            .scaleEffect(isPressing ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.18), value: isPressing)
        }
        .gesture(
            LongPressGesture(minimumDuration: holdDuration ?? 2.0)
                .updating($isPressing) { value, state, _ in
                    state = value
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        unlocked.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onUnlock()
                    }
                }
        )
    }
}

// preview
struct UILockOverlay_Previews: PreviewProvider {
    static var previews: some View {
        UILockOverlay(onUnlock: {})
    }
}
