/*
 UILockOverlay.swift

 Scope & Intent:
 ---------------
 
 Objective:
 - Provide a reusable SwiftUI View component that presents a semi-transparent overlay with a lock icon and a hold-to-unlock interaction.
 - The overlay requires the user to press and hold for a configurable duration to trigger an unlock action.
 - Once unlocked, the view visually updates and calls a provided callback closure.

 Deliverables:
 - A SwiftUI View named UILockOverlay.
 - Configurable hold duration (default 2 seconds).
 - Visual feedback during press including countdown timer.
 - Unlock state toggle with appropriate animations.
 - Safe handling of gesture interruptions or cancellations.
 - Integration-ready for use in any SwiftUI context.

 Constraints:
 - Must support iOS 15+ SwiftUI environment.
 - Use system SF Symbols for lock states.
 - Visual styling consistent with dark overlay and white text/icons.
 - Minimal external dependencies.
 - Thread-safe task-based countdown handling.

 Assumptions:
 - The overlay will cover the entire screen area.
 - The unlock action callback can be any closure supplied by the integrator.
 - User can cancel the hold by releasing or dragging away.
 - The hold duration is non-negative and reasonably small (seconds scale).

 Inputs:
 - holdDuration: Optional Double indicating seconds to hold before unlock (default 2.0s).
 - onUnlock: Closure () -> Void called after successful unlock.

 Processes:
 - Detect long press gestures with customizable minimum duration.
 - Track gesture state and update internal countdown timer using a Swift concurrency Task.
 - Update UI elements: lock icon, countdown text, scaling animation.
 - Manage task lifecycle safely to update countdown display.
 - Handle gesture cancellation and resets.
 - Upon completion, transition state to unlocked, animate changes, and invoke callback.

 Outputs:
 - Visual overlay UI showing lock icon, countdown, and instructions.
 - State change reflected in UI and callback invocation.

 Dependencies:
 - SwiftUI framework.
 - Swift Concurrency (Task) and Foundation for Date.

 Priorities:
 1. Accurate and responsive gesture detection.
 2. Clear and intuitive visual feedback.
 3. Safe and leak-free task management.
 4. Smooth animations on state changes.
 5. Robust handling of gesture interruptions.

 Execution Metadata:
 -------------------

 Feature: Hold-to-Unlock Interaction
 Priority: High
 Effort: Medium
 Acceptance Criteria:
 - Long press gesture triggers countdown.
 - Countdown updates every 0.05s.
 - UI shows correct remaining time in monospaced font.
 - Unlock icon changes on completion.
 - onUnlock callback invoked after unlock animation.

 Feature: Visual Overlay Styling
 Priority: Medium
 Effort: Low
 Acceptance Criteria:
 - Overlay covers full safe area with translucent black background.
 - Lock icon and text are white and legible.
 - Countdown overlay appears only while pressing.
 - Animations are smooth and consistent.

 Feature: Gesture Handling Robustness
 Priority: High
 Effort: Medium
 Acceptance Criteria:
 - Countdown task is cancelled on gesture end or cancel.
 - Countdown resets on interruption.
 - Drag gestures cancel hold appropriately.
 - No crashes or freezes on rapid gesture changes.

 PRD-like Details:
 -----------------

 Feature Description:
 UILockOverlay is a SwiftUI View that overlays the existing UI with a darkened screen and a centered lock icon accompanied by text instructing the user to "Hold to Unlock." The user must press and hold anywhere on the overlay for a configurable duration (default 2 seconds) to unlock. During the hold, a countdown timer visually updates on the text background. Upon completion, the lock icon changes from locked to unlocked state with a smooth animation, and a callback closure is triggered to let the host app respond to the unlock event.

 Rationale:
 This component provides a secure and clear user interaction pattern to prevent accidental unlocks and ensure intentional access. By requiring a hold gesture with visual feedback, users are informed of the action and its timing.

 Functional Requirements:
 - Display a full-screen black translucent overlay.
 - Show a lock icon in center that toggles between "locked" and "unlocked" SF Symbols.
 - Show text "Hold to Unlock" with a countdown overlay visible only while pressing.
 - Detect long press gesture with configurable duration.
 - Update countdown text every 0.05 seconds during hold using a Swift concurrency Task.
 - Cancel countdown and reset UI if press is interrupted or drag occurs.
 - Animate the lock icon change on unlock.
 - Invoke onUnlock callback after a short delay post animation.

 Non-Functional Requirements:
 - Responsive UI with smooth animations.
 - Minimal CPU usage for countdown updates.
 - Safe task cancellation to avoid memory leaks.
 - Clear, accessible text and icon sizes.
 - Gesture handling that does not interfere with other UI components.

 User Interaction Flows:
 1. User sees the overlay with locked icon and "Hold to Unlock" text.
 2. User presses and holds anywhere on the overlay.
 3. The countdown text appears and updates in real-time from holdDuration down to zero.
 4. If user releases before countdown ends or drags finger away, countdown resets and overlay remains locked.
 5. If user holds for full duration, lock icon animates to unlocked state.
 6. After a brief delay, the onUnlock closure is called.
 7. Overlay remains showing unlocked icon until dismissed externally.

 Edge Cases and Failure Modes:
 - User taps quickly or releases early: countdown resets without side effects.
 - User drags finger during long press: countdown and task are canceled.
 - Hold duration changed during hold: countdown resets on next gesture.
 - Task is cancelled on view disappearance or gesture end to prevent leaks.
 - Multiple simultaneous gestures do not cause inconsistent states.
 - UI remains stable if onUnlock closure takes time or causes UI changes.

 This detailed documentation enables any developer or LLM agent to implement, test, and maintain the UILockOverlay component consistently and reliably.
*/

import SwiftUI

public struct UILockOverlay: View {
    public var onUnlock: () -> Void
    public let holdDuration: Double?
    
    @GestureState private var isPressing = false
    @State private var unlocked: Bool = false
    @State private var countdownBaseDate: Date? = nil
    @State private var countdown: Double? = nil
    
    @State private var countdownTask: Task<Void, Never>? = nil

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
                        cancelCountdown()
                    }
            )
        }
        .gesture(
            LongPressGesture(minimumDuration: holdDuration ?? 2.0)
                .updating($isPressing) { value, state, _ in
                    if value && countdownBaseDate == nil {
                        startCountdown()
                    }
                    state = value
                }
                .onChanged { value in
                    if !value {
                        cancelCountdown()
                    }
                }
                .onEnded { _ in
                    cancelCountdown()
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
                            cancelCountdown()
                        }
                )
        )
        .onDisappear {
            cancelCountdown()
        }
    }
    
    @MainActor
    private func startCountdown() {
        countdownBaseDate = Date()
        countdown = holdDuration ?? 2.0
        
        countdownTask?.cancel()
        countdownTask = Task {
            let interval: UInt64 = 50_000_000 // 0.05s in nanoseconds
            while !Task.isCancelled {
                await MainActor.run {
                    guard let baseDate = countdownBaseDate else { return }
                    let remaining = max((holdDuration ?? 2.0) - Date().timeIntervalSince(baseDate), 0)
                    countdown = remaining
                }
                if let remaining = countdown, remaining <= 0 {
                    break
                }
                try? await Task.sleep(nanoseconds: interval)
            }
        }
    }
    
    @MainActor
    private func cancelCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        countdown = nil
        countdownBaseDate = nil
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

