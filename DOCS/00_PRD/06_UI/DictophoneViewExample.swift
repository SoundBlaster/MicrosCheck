/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The main UI view for the Dictophone.
*/

import SwiftUI

struct DictophoneView: View {
    @StateObject var dictophone = Dictophone()
    @State private var isLocked = false

    var body: some View {
        VStack(spacing: 20) {
            // Top Waveform Timeline
            WaveformView(dictophone: dictophone)
                .frame(height: 100)
                .padding()
            /*
            UI States & Animations:
            - Key States: idle, playing, paused, stopped.
            - Animations: real-time waveform updates synchronized with dictophone beats; smooth animations on beat changes.
            
            Design System Application:
            - Uses primary brand colors for waveform peaks and troughs.
            - Typography for labels follows the main title style.
            - Consistent spacing aligned with overall layout grid.
            */

            // Info Card
            InfoCardView(dictophone: dictophone)
                .padding(.horizontal)
            /*
            UI States & Animations:
            - States: expanded, collapsed, loading.
            - Animations: smooth transition when expanding/collapsing; fade-in of updated info.
            
            Design System Application:
            - Background and text colors follow secondary palette.
            - Typography uses body and caption styles from design system.
            - Spacing consistent with card component guidelines.
            */

            // Toolbar Row
            ToolbarView(isLocked: $isLocked)
                .padding(.horizontal)
            /*
            UI States & Animations:
            - States: enabled, disabled, active button pressed.
            - Animations: button press highlight; toolbar slide-in/out on state change.
            
            Design System Application:
            - Toolbar uses designated toolbar background color.
            - Icon buttons adhere to standard sizes and colors.
            - Spacing and padding consistent with toolbar specs.
            */

            // Quick Action Buttons
            QuickActionButtons(dictophone: dictophone)
                .padding()
            /*
            UI States & Animations:
            - States: normal, pressed, disabled.
            - Animations: button press scaling; color changes on activation.
            
            Design System Application:
            - Buttons use brand accent colors for active state.
            - Typography uses bold button font style.
            - Icons are consistent with action semantics.
            */

            // Transport Controls
            TransportControls(dictophone: dictophone)
                .padding(.horizontal)
            /*
            UI States & Animations:
            - Key States: STOP, REC, PAUSE, RESUME, disabled, transitioning.
            - Animations: button highlights on press; smooth transitions between states; visual feedback for recording.
            
            Design System Application:
            - Colors reflect active/inactive states using design system palette.
            - Typography consistent with control labels.
            - Icons standardized for transport actions.
            */

            // D-Pad
            DPadControl(dictophone: dictophone)
                .padding()
            /*
            UI States & Animations:
            - States: idle, pressed, held.
            - Animations: button highlight on press and hold; subtle scale effect on interaction.
            
            Design System Application:
            - Buttons use neutral tones with highlight on interaction.
            - Consistent iconography for directional controls.
            - Spacing follows control grouping guidelines.
            */

            // Lock Button
            LockButton(isLocked: $isLocked)
                .padding()
            /*
            UI States & Animations:
            - States: locked, unlocked.
            - Animations: fade and scale transition on toggle.
            
            Design System Application:
            - Uses color indicators for locked (e.g., red) and unlocked (e.g., green).
            - Icon reflects lock status consistent with design language.
            - Padding and size follow button design spec.
            */

            // Info Button
            InfoButton()
                .padding()
            /*
            UI States & Animations:
            - States: normal, pressed.
            - Animations: button press highlight; info panel slide-in.
            
            Design System Application:
            - Icon uses standard info symbol from icon set.
            - Colors consistent with secondary action buttons.
            - Typography aligned with info text styles.
            */
        }
    }
}

struct DictophoneView_Previews: PreviewProvider {
    static var previews: some View {
        DictophoneView()
    }
}
