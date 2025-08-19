import SwiftUI

public struct UILockOverlay: View {
    public var onUnlock: () -> Void
    public var holdDuration: Double?

    public init(holdDuration: Double? = nil, onUnlock: @escaping () -> Void) {
        self.holdDuration = holdDuration
        self.onUnlock = onUnlock
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                Text("Hold to Unlock")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(10)
            }
        }
        .onLongPressGesture(minimumDuration: holdDuration ?? 2.0) {
            onUnlock()
        }
    }
}

// preview
struct UILockOverlay_Previews: PreviewProvider {
    static var previews: some View {
        UILockOverlay(onUnlock: {})
    }
}
