//
//  BreatheSeagullView.swift
//  Dioboo
//
//  Seagull breathing experience - Glide above the sea
//

import SwiftUI
import Combine

struct BreatheSeagullView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var breatheProgress: CGFloat = 0
    @State private var waveOffset: CGFloat = 0
    @State private var seagullY: CGFloat = 0.4
    @State private var breatheTimer: Timer?
    @State private var animationTimer: Timer?

    private let breatheDuration: Double = 5.0

    var body: some View {
        ZStack {
            // Sky gradient - sunset ocean
            LinearGradient(
                colors: [
                    Color(hex: "FF9A8B"),
                    Color(hex: "FF6B95"),
                    Color(hex: "FF8E72"),
                    Color(hex: "FFC796"),
                    Color(hex: "87CEEB")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Sun
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "FFD93D"), Color(hex: "FF9A8B").opacity(0)],
                        center: .center,
                        startRadius: 30,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .offset(x: 80, y: -150)

            // Ocean waves
            OceanWaves(offset: waveOffset)

            // Seagull
            SeagullShape(isFlapping: isInhaling)
                .fill(Color.white)
                .frame(width: 80, height: 40)
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * seagullY)

            // UI Overlay
            VStack {
                HStack {
                    Button(action: onBack) {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                BreathingIndicator(isInhaling: $isInhaling)
                    .padding(.bottom, 20)

                BreathingTimer(duration: duration, onComplete: onComplete)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            startBreathingCycle()
            startAnimations()
        }
        .onDisappear {
            breatheTimer?.invalidate()
            animationTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        withAnimation(.easeInOut(duration: breatheDuration)) {
            seagullY = 0.3
        }

        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
            withAnimation(.easeInOut(duration: breatheDuration)) {
                seagullY = isInhaling ? 0.3 : 0.5
            }
        }
    }

    private func startAnimations() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            waveOffset += 1
        }
    }
}

// MARK: - Ocean Waves

struct OceanWaves: View {
    let offset: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Multiple wave layers
                ForEach(0..<3) { i in
                    WaveShape(offset: offset + CGFloat(i * 50), amplitude: 20 - CGFloat(i * 5))
                        .fill(Color(hex: "1E90FF").opacity(0.3 + Double(i) * 0.2))
                        .offset(y: geo.size.height * 0.6 + CGFloat(i * 30))
                }

                // Ocean body
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1E90FF"), Color(hex: "000080")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: geo.size.height * 0.7)
            }
        }
    }
}

struct WaveShape: Shape {
    var offset: CGFloat
    var amplitude: CGFloat

    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let wavelength: CGFloat = 100

        path.move(to: CGPoint(x: 0, y: rect.height))

        for x in stride(from: 0, through: rect.width, by: 5) {
            let y = amplitude * sin((x + offset) * .pi / wavelength)
            path.addLine(to: CGPoint(x: x, y: y + rect.height / 2))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 2))
        path.addLine(to: CGPoint(x: 0, y: rect.height * 2))
        path.closeSubpath()

        return path
    }
}

// MARK: - Seagull Shape

struct SeagullShape: Shape {
    var isFlapping: Bool

    var animatableData: CGFloat {
        get { isFlapping ? 1 : 0 }
        set { }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let wingAngle: CGFloat = isFlapping ? 0.3 : -0.1

        // Body
        path.move(to: CGPoint(x: rect.midX, y: rect.midY))

        // Left wing
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY - rect.height * wingAngle),
            control: CGPoint(x: rect.midX * 0.5, y: rect.midY - rect.height * 0.3)
        )

        path.move(to: CGPoint(x: rect.midX, y: rect.midY))

        // Right wing
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY - rect.height * wingAngle),
            control: CGPoint(x: rect.midX * 1.5, y: rect.midY - rect.height * 0.3)
        )

        // Head
        path.addEllipse(in: CGRect(x: rect.midX - 8, y: rect.midY - 15, width: 16, height: 12))

        return path
    }
}

#Preview {
    BreatheSeagullView(duration: 3, onComplete: {}, onBack: {})
}
