//
//  BreatheContainerView.swift
//  Dioboo
//
//  Container that routes to the correct breathing experience
//

import SwiftUI

struct BreatheContainerView: View {
    let parcours: BreatheParcours
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    var body: some View {
        // Route to the appropriate breathe experience based on parcours
        switch parcours {
        case .chairlift:
            BreatheChairliftView(duration: duration, onComplete: onComplete, onBack: onBack)
        case .seagull:
            BreatheSeagullView(duration: duration, onComplete: onComplete, onBack: onBack)
        case .ferriswheel:
            BreatheFerriswheelView(duration: duration, onComplete: onComplete, onBack: onBack)
        case .astronaut:
            BreatheAstronautView(duration: duration, onComplete: onComplete, onBack: onBack)
        case .hotairballoon:
            BreatheHotairballoonView(duration: duration, onComplete: onComplete, onBack: onBack)
        case .wave:
            BreatheWaveView(duration: duration, onComplete: onComplete, onBack: onBack)
        case .branch:
            BreatheBranchView(duration: duration, onComplete: onComplete, onBack: onBack)
        case .buoy:
            BreatheBuoyView(duration: duration, onComplete: onComplete, onBack: onBack)
        case .glidingbird:
            BreatheGlidingbirdView(duration: duration, onComplete: onComplete, onBack: onBack)
        }
    }
}

// MARK: - Base Breathe View Protocol

protocol BreatheExperienceView: View {
    var duration: Int { get }
    var onComplete: () -> Void { get }
    var onBack: () -> Void { get }
}

// MARK: - Breathing Timer Component

struct BreathingTimer: View {
    let duration: Int
    let onComplete: () -> Void

    @State private var timeRemaining: Int
    @State private var progress: Double = 0
    @State private var timer: Timer?

    init(duration: Int, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: duration * 60)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Time remaining
            Text(timeString)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(DiobooTheme.texteSecondaire.opacity(0.6))

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(DiobooTheme.textePrincipal.opacity(0.1))
                        .frame(height: 2)

                    Rectangle()
                        .fill(DiobooTheme.textePrincipal.opacity(0.4))
                        .frame(width: geo.size.width * progress, height: 2)
                }
            }
            .frame(width: 60, height: 2)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startTimer() {
        let totalSeconds = Double(duration * 60)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                withAnimation(.linear(duration: 1)) {
                    progress = 1 - (Double(timeRemaining) / totalSeconds)
                }
            } else {
                timer?.invalidate()
                onComplete()
            }
        }
    }
}

// MARK: - Breathing Indicator

struct BreathingIndicator: View {
    @Binding var isInhaling: Bool

    var body: some View {
        Text(isInhaling ? "Inhale" : "Exhale")
            .font(.system(size: 16, weight: .light, design: .rounded))
            .foregroundColor(DiobooTheme.textePrincipal.opacity(0.8))
            .animation(.easeInOut(duration: 0.5), value: isInhaling)
    }
}
