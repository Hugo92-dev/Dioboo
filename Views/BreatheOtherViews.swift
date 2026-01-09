//
//  BreatheOtherViews.swift
//  Dioboo
//
//  Other breathing experiences (Premium parcours)
//

import SwiftUI

// MARK: - Ferris Wheel

struct BreatheFerriswheelView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var rotation: Double = 0
    @State private var breatheTimer: Timer?

    private let breatheDuration: Double = 5.0

    var body: some View {
        GenericBreatheView(
            duration: duration,
            onComplete: onComplete,
            onBack: onBack,
            backgroundColor: LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                startPoint: .top,
                endPoint: .bottom
            ),
            isInhaling: $isInhaling
        ) {
            // Ferris wheel
            ZStack {
                // City lights in background
                CityLights()

                // Ferris wheel structure
                FerrisWheel(rotation: rotation)
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            startBreathingCycle()
        }
        .onDisappear {
            breatheTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        withAnimation(.easeInOut(duration: breatheDuration)) {
            rotation = 30
        }

        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
            withAnimation(.easeInOut(duration: breatheDuration)) {
                rotation += isInhaling ? 30 : 30
            }
        }
    }
}

struct FerrisWheel: View {
    let rotation: Double

    var body: some View {
        ZStack {
            // Main wheel
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 4)

            // Spokes
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 2, height: 125)
                    .offset(y: -62.5)
                    .rotationEffect(.degrees(Double(i) * 45 + rotation))
            }

            // Cabins
            ForEach(0..<8) { i in
                Circle()
                    .fill(Color(hex: "FFD700"))
                    .frame(width: 20, height: 20)
                    .offset(y: -115)
                    .rotationEffect(.degrees(Double(i) * 45 + rotation))
            }

            // Center hub
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 20, height: 20)
        }
    }
}

struct CityLights: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<30) { i in
                Circle()
                    .fill(Color(hex: "FFD700").opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 3...8))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: geo.size.height - CGFloat.random(in: 50...200)
                    )
            }
        }
    }
}

// MARK: - Astronaut

struct BreatheAstronautView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var astronautY: CGFloat = 0.5
    @State private var breatheTimer: Timer?

    private let breatheDuration: Double = 5.0

    var body: some View {
        GenericBreatheView(
            duration: duration,
            onComplete: onComplete,
            onBack: onBack,
            backgroundColor: LinearGradient(
                colors: [Color(hex: "000000"), Color(hex: "0a0a2e"), Color(hex: "1a1a4e")],
                startPoint: .top,
                endPoint: .bottom
            ),
            isInhaling: $isInhaling
        ) {
            ZStack {
                // Stars
                StarsBackground()

                // Earth in distance
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "4B9CD3"), Color(hex: "228B22"), Color(hex: "1a1a4e")],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 150, height: 150)
                    .offset(x: 100, y: 200)

                // Astronaut
                AstronautShape()
                    .fill(Color.white)
                    .frame(width: 60, height: 80)
                    .offset(y: UIScreen.main.bounds.height * (astronautY - 0.5))
            }
        }
        .onAppear {
            startBreathingCycle()
        }
        .onDisappear {
            breatheTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        withAnimation(.easeInOut(duration: breatheDuration)) {
            astronautY = 0.4
        }

        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
            withAnimation(.easeInOut(duration: breatheDuration)) {
                astronautY = isInhaling ? 0.4 : 0.6
            }
        }
    }
}

struct StarsBackground: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<50) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...1.0)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
            }
        }
    }
}

struct AstronautShape: View {
    var body: some View {
        ZStack {
            // Helmet
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .offset(y: -25)

            // Visor
            Circle()
                .fill(Color(hex: "4B9CD3").opacity(0.6))
                .frame(width: 30, height: 30)
                .offset(y: -25)

            // Body
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: 35, height: 45)
                .offset(y: 10)
        }
    }
}

// MARK: - Hot Air Balloon

struct BreatheHotairballoonView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var balloonY: CGFloat = 0.5
    @State private var breatheTimer: Timer?

    private let breatheDuration: Double = 5.0

    var body: some View {
        GenericBreatheView(
            duration: duration,
            onComplete: onComplete,
            onBack: onBack,
            backgroundColor: LinearGradient(
                colors: [Color(hex: "87CEEB"), Color(hex: "B0E0E6"), Color(hex: "F0F8FF")],
                startPoint: .top,
                endPoint: .bottom
            ),
            isInhaling: $isInhaling
        ) {
            ZStack {
                // Clouds
                ForEach(0..<5) { i in
                    Cloud()
                        .offset(x: CGFloat(i * 100) - 200, y: CGFloat(i * 80))
                }

                // Hot air balloon
                HotAirBalloon()
                    .frame(width: 120, height: 180)
                    .offset(y: UIScreen.main.bounds.height * (balloonY - 0.5))
            }
        }
        .onAppear {
            startBreathingCycle()
        }
        .onDisappear {
            breatheTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        withAnimation(.easeInOut(duration: breatheDuration)) {
            balloonY = 0.35
        }

        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
            withAnimation(.easeInOut(duration: breatheDuration)) {
                balloonY = isInhaling ? 0.35 : 0.55
            }
        }
    }
}

struct HotAirBalloon: View {
    var body: some View {
        ZStack {
            // Balloon
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FF6B6B"), Color(hex: "FFE66D")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 100, height: 120)
                .offset(y: -30)

            // Stripes
            ForEach(0..<4) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 15, height: 100)
                    .offset(x: CGFloat(i * 25) - 35, y: -30)
            }
            .mask(
                Ellipse()
                    .frame(width: 100, height: 120)
                    .offset(y: -30)
            )

            // Basket ropes
            Path { path in
                path.move(to: CGPoint(x: 35, y: 30))
                path.addLine(to: CGPoint(x: 45, y: 70))
                path.move(to: CGPoint(x: 85, y: 30))
                path.addLine(to: CGPoint(x: 75, y: 70))
            }
            .stroke(Color(hex: "8B4513"), lineWidth: 2)

            // Basket
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: "8B4513"))
                .frame(width: 40, height: 25)
                .offset(y: 80)
        }
    }
}

// MARK: - Ocean Wave

struct BreatheWaveView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var wavePhase: CGFloat = 0
    @State private var breatheTimer: Timer?
    @State private var animationTimer: Timer?

    private let breatheDuration: Double = 5.0

    var body: some View {
        GenericBreatheView(
            duration: duration,
            onComplete: onComplete,
            onBack: onBack,
            backgroundColor: LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "1E90FF")],
                startPoint: .top,
                endPoint: .bottom
            ),
            isInhaling: $isInhaling
        ) {
            OceanWaves(offset: wavePhase)
        }
        .onAppear {
            startBreathingCycle()
            startWaveAnimation()
        }
        .onDisappear {
            breatheTimer?.invalidate()
            animationTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
        }
    }

    private func startWaveAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            wavePhase += 2
        }
    }
}

// MARK: - Tree Branch

struct BreatheBranchView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var swayAngle: Double = 0
    @State private var breatheTimer: Timer?

    private let breatheDuration: Double = 5.0

    var body: some View {
        GenericBreatheView(
            duration: duration,
            onComplete: onComplete,
            onBack: onBack,
            backgroundColor: LinearGradient(
                colors: [Color(hex: "87CEEB"), Color(hex: "90EE90"), Color(hex: "228B22")],
                startPoint: .top,
                endPoint: .bottom
            ),
            isInhaling: $isInhaling
        ) {
            ZStack {
                // Tree branches swaying
                ForEach(0..<5) { i in
                    BranchShape()
                        .stroke(Color(hex: "8B4513"), lineWidth: 3)
                        .frame(width: 200, height: 100)
                        .rotationEffect(.degrees(swayAngle + Double(i * 5)))
                        .offset(y: CGFloat(i * 50) - 100)
                }

                // Leaves
                ForEach(0..<20) { i in
                    Ellipse()
                        .fill(Color(hex: "228B22").opacity(0.8))
                        .frame(width: 20, height: 30)
                        .rotationEffect(.degrees(Double(i * 18) + swayAngle))
                        .offset(
                            x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -150...150)
                        )
                }
            }
        }
        .onAppear {
            startBreathingCycle()
        }
        .onDisappear {
            breatheTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        withAnimation(.easeInOut(duration: breatheDuration)) {
            swayAngle = 10
        }

        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
            withAnimation(.easeInOut(duration: breatheDuration)) {
                swayAngle = isInhaling ? 10 : -10
            }
        }
    }
}

struct BranchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY - 20),
            control: CGPoint(x: rect.midX, y: rect.midY - 30)
        )
        return path
    }
}

// MARK: - Buoy

struct BreatheBuoyView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var buoyY: CGFloat = 0
    @State private var waveOffset: CGFloat = 0
    @State private var breatheTimer: Timer?
    @State private var animationTimer: Timer?

    private let breatheDuration: Double = 5.0

    var body: some View {
        GenericBreatheView(
            duration: duration,
            onComplete: onComplete,
            onBack: onBack,
            backgroundColor: LinearGradient(
                colors: [Color(hex: "FF9A8B"), Color(hex: "87CEEB"), Color(hex: "1E90FF")],
                startPoint: .top,
                endPoint: .bottom
            ),
            isInhaling: $isInhaling
        ) {
            ZStack {
                OceanWaves(offset: waveOffset)

                // Buoy
                BuoyShape()
                    .frame(width: 60, height: 100)
                    .offset(y: buoyY)
            }
        }
        .onAppear {
            startBreathingCycle()
            startWaveAnimation()
        }
        .onDisappear {
            breatheTimer?.invalidate()
            animationTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        withAnimation(.easeInOut(duration: breatheDuration)) {
            buoyY = -20
        }

        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
            withAnimation(.easeInOut(duration: breatheDuration)) {
                buoyY = isInhaling ? -20 : 20
            }
        }
    }

    private func startWaveAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            waveOffset += 1
        }
    }
}

struct BuoyShape: View {
    var body: some View {
        ZStack {
            // Top dome
            Circle()
                .fill(Color(hex: "FF0000"))
                .frame(width: 50, height: 50)
                .offset(y: -30)

            // Body
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FF0000"), Color.white, Color(hex: "FF0000")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 40, height: 60)
                .offset(y: 10)
        }
    }
}

// MARK: - Gliding Bird

struct BreatheGlidingbirdView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var birdY: CGFloat = 0.5
    @State private var canyonOffset: CGFloat = 0
    @State private var breatheTimer: Timer?
    @State private var animationTimer: Timer?

    private let breatheDuration: Double = 5.0

    var body: some View {
        GenericBreatheView(
            duration: duration,
            onComplete: onComplete,
            onBack: onBack,
            backgroundColor: LinearGradient(
                colors: [Color(hex: "87CEEB"), Color(hex: "FFA07A"), Color(hex: "CD853F")],
                startPoint: .top,
                endPoint: .bottom
            ),
            isInhaling: $isInhaling
        ) {
            ZStack {
                // Canyon walls
                CanyonWalls(offset: canyonOffset)

                // Gliding bird
                SeagullShape(isFlapping: false)
                    .fill(Color(hex: "2F4F4F"))
                    .frame(width: 100, height: 50)
                    .offset(y: UIScreen.main.bounds.height * (birdY - 0.5))
            }
        }
        .onAppear {
            startBreathingCycle()
            startCanyonAnimation()
        }
        .onDisappear {
            breatheTimer?.invalidate()
            animationTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        withAnimation(.easeInOut(duration: breatheDuration)) {
            birdY = 0.4
        }

        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
            withAnimation(.easeInOut(duration: breatheDuration)) {
                birdY = isInhaling ? 0.4 : 0.6
            }
        }
    }

    private func startCanyonAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            canyonOffset += 1
        }
    }
}

struct CanyonWalls: View {
    let offset: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Left wall
                ForEach(0..<10) { i in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "CD853F").opacity(0.8))
                        .frame(width: 80, height: CGFloat.random(in: 200...400))
                        .offset(
                            x: -geo.size.width / 2 + 30,
                            y: (CGFloat(i * 100) + offset).truncatingRemainder(dividingBy: geo.size.height) - geo.size.height / 2
                        )
                }

                // Right wall
                ForEach(0..<10) { i in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "CD853F").opacity(0.8))
                        .frame(width: 80, height: CGFloat.random(in: 200...400))
                        .offset(
                            x: geo.size.width / 2 - 30,
                            y: (CGFloat(i * 100) + offset + 50).truncatingRemainder(dividingBy: geo.size.height) - geo.size.height / 2
                        )
                }
            }
        }
    }
}

// MARK: - Generic Breathe View Template

struct GenericBreatheView<Content: View, Background: ShapeStyle>: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void
    let backgroundColor: Background
    @Binding var isInhaling: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(backgroundColor)
                .ignoresSafeArea()

            // Custom content
            content()

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
    }
}
