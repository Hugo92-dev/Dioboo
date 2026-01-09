//
//  BreatheSeagullView.swift
//  Dioboo
//
//  Seagull breathing experience - matches breatheseagull.html exactly
//

import SwiftUI
import Combine

struct BreatheSeagullView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var cycleProgress: CGFloat = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var animationTimer: Timer?
    @State private var startTime: Date?

    // Movement parameters from HTML
    private let skyHeight: CGFloat = 180
    private let waterDepth: CGFloat = 60
    private let cycleDuration: TimeInterval = 10.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sky gradient - exact from HTML
                LinearGradient(
                    colors: [
                        Color(hex: "1a4a6a"),
                        Color(hex: "2a6a8a"),
                        Color(hex: "4a9aba"),
                        Color(hex: "7ac4e4"),
                        Color(hex: "a8e0f8")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geo.size.height * 0.6)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.3)

                // Clouds
                SeagullCloudsLayer()

                // Ocean
                SeagullOceanView(cycleProgress: cycleProgress, skyHeight: skyHeight, waterDepth: waterDepth)
                    .frame(height: geo.size.height * 0.48)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.76)

                // Horizon elements (island)
                SeagullIslandView()
                    .position(x: geo.size.width * 0.85, y: geo.size.height * 0.52)

                // Sailboats
                SeagullSailboatsLayer(screenWidth: geo.size.width, screenHeight: geo.size.height)

                // Seagull
                SeagullBirdView(
                    cycleProgress: cycleProgress,
                    skyHeight: skyHeight,
                    waterDepth: waterDepth
                )
                .position(x: geo.size.width / 2, y: geo.size.height * 0.52)

                // UI Overlay
                VStack {
                    // Back button - glass effect from HTML
                    HStack {
                        Button(action: onBack) {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .medium))
                                )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()

                    // Phase text - exact styling from HTML
                    Text(isInhaling ? "INHALE" : "EXHALE")
                        .font(.custom("Nunito", size: 22).weight(.regular))
                        .foregroundColor(Color(hex: "F5F7FF"))
                        .tracking(6)
                        .shadow(color: Color(hex: "003264").opacity(0.4), radius: 8, y: 2)
                        .padding(.bottom, 8)

                    // Timer
                    BreathingTimer(duration: duration, onComplete: onComplete)
                        .padding(.bottom, 40)
                }
            }
            .background(Color(hex: "1a4a6a"))
            .ignoresSafeArea()
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }

    private func startAnimation() {
        startTime = Date()

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            guard let start = startTime else { return }
            let elapsed = Date().timeIntervalSince(start)
            elapsedTime = elapsed

            // Calculate cycle progress (0 to 1)
            let progress = (elapsed.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            cycleProgress = progress

            // Update phase
            isInhaling = progress < 0.5
        }
    }
}

// MARK: - Clouds Layer

struct SeagullCloudsLayer: View {
    @State private var cloud1Offset: CGFloat = 0
    @State private var cloud2Offset: CGFloat = 0
    @State private var cloud3Offset: CGFloat = 0
    @State private var cloud4Offset: CGFloat = 0
    @State private var cloud5Offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Cloud 1
                Ellipse()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 100, height: 35)
                    .blur(radius: 20)
                    .offset(x: cloud1Offset)
                    .position(x: geo.size.width * 0.05 + 50, y: geo.size.height * 0.06)

                // Cloud 2
                Ellipse()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 40)
                    .blur(radius: 20)
                    .offset(x: cloud2Offset)
                    .position(x: geo.size.width * 0.55 + 60, y: geo.size.height * 0.18)

                // Cloud 3
                Ellipse()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 80, height: 25)
                    .blur(radius: 20)
                    .offset(x: cloud3Offset)
                    .position(x: geo.size.width * 0.20 + 40, y: geo.size.height * 0.30)

                // Cloud 4
                Ellipse()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 140, height: 45)
                    .blur(radius: 20)
                    .offset(x: cloud4Offset)
                    .position(x: -20, y: geo.size.height * 0.12)

                // Cloud 5
                Ellipse()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 90, height: 30)
                    .blur(radius: 20)
                    .offset(x: cloud5Offset)
                    .position(x: geo.size.width * 0.70 + 45, y: geo.size.height * 0.38)
            }
        }
        .onAppear {
            // Cloud drift animations matching HTML
            withAnimation(.easeInOut(duration: 45).repeatForever(autoreverses: true)) {
                cloud1Offset = 40
            }
            withAnimation(.easeInOut(duration: 60).repeatForever(autoreverses: true)) {
                cloud2Offset = -50
            }
            withAnimation(.easeInOut(duration: 50).repeatForever(autoreverses: true)) {
                cloud3Offset = 30
            }
            withAnimation(.linear(duration: 70).repeatForever(autoreverses: false)) {
                cloud4Offset = 450
            }
            withAnimation(.easeInOut(duration: 55).repeatForever(autoreverses: true)) {
                cloud5Offset = -35
            }
        }
    }
}

// MARK: - Ocean View

struct SeagullOceanView: View {
    let cycleProgress: CGFloat
    let skyHeight: CGFloat
    let waterDepth: CGFloat

    @State private var waveOffset1: CGFloat = 0
    @State private var waveOffset2: CGFloat = 0
    @State private var waveOffset3: CGFloat = 0
    @State private var foamOffset1: CGFloat = 0
    @State private var foamOffset2: CGFloat = 0

    var body: some View {
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = verticalWave * (skyHeight + waterDepth) / 2 - (skyHeight - waterDepth) / 2
        let normalizedPos = (verticalPos + skyHeight) / (skyHeight + waterDepth)
        let oceanScale = 0.9 + normalizedPos * 0.2

        GeometryReader { geo in
            ZStack {
                // Ocean gradient - exact from HTML
                LinearGradient(
                    colors: [
                        Color(hex: "4a9aba"),
                        Color(hex: "3a7a9a"),
                        Color(hex: "2a5a7a"),
                        Color(hex: "1a3a5a")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Horizon glow
                LinearGradient(
                    colors: [
                        Color(hex: "FFE6C8").opacity(0.2),
                        Color(hex: "FFD2AA").opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 50)
                .position(x: geo.size.width / 2, y: 25)

                // Sun reflection path
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFF0C8").opacity(0.35),
                                Color(hex: "FFE6B4").opacity(0.2),
                                Color(hex: "FFDCA0").opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: geo.size.height * 0.8)
                    .blur(radius: 4)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.4)

                // Animated waves
                SeagullWavesView()

                // Foam patches
                Ellipse()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 30, height: 8)
                    .offset(x: foamOffset1)
                    .position(x: geo.size.width * 0.2, y: 45)

                Ellipse()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 40, height: 10)
                    .offset(x: foamOffset2)
                    .position(x: geo.size.width * 0.7, y: 90)
            }
            .scaleEffect(oceanScale)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                foamOffset1 = 20
            }
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                foamOffset2 = -20
            }
        }
    }
}

struct SeagullWavesView: View {
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var phase3: CGFloat = 0
    @State private var phase4: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Wave 1
                WavePath(amplitude: 15, wavelength: 100, phase: phase1)
                    .stroke(Color.white.opacity(0.25), lineWidth: 3)
                    .offset(y: 30)

                // Wave 2
                WavePath(amplitude: 12, wavelength: 120, phase: phase2)
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .offset(y: 70)

                // Wave 3
                WavePath(amplitude: 10, wavelength: 140, phase: phase3)
                    .stroke(Color.white.opacity(0.15), lineWidth: 2)
                    .offset(y: 120)

                // Wave 4
                WavePath(amplitude: 8, wavelength: 160, phase: phase4)
                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    .offset(y: 180)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                phase1 = .pi
            }
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                phase2 = .pi
            }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                phase3 = .pi
            }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                phase4 = .pi
            }
        }
    }
}

struct WavePath: Shape {
    var amplitude: CGFloat
    var wavelength: CGFloat
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))

        for x in stride(from: 0, through: rect.width, by: 5) {
            let y = rect.midY + amplitude * sin((x / wavelength) * 2 * .pi + phase)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

// MARK: - Island View

struct SeagullIslandView: View {
    var body: some View {
        Canvas { context, size in
            // Sand mound
            let sandPath1 = Path(ellipseIn: CGRect(x: 2, y: 33, width: 52, height: 16))
            context.fill(sandPath1, with: .color(Color(hex: "d4b896")))

            let sandPath2 = Path(ellipseIn: CGRect(x: 6, y: 30, width: 44, height: 12))
            context.fill(sandPath2, with: .color(Color(hex: "e0c9a6")))

            // Palm trunk
            var trunkPath = Path()
            trunkPath.move(to: CGPoint(x: 28, y: 36))
            trunkPath.addQuadCurve(to: CGPoint(x: 28, y: 18), control: CGPoint(x: 26, y: 28))
            context.stroke(trunkPath, with: .color(Color(hex: "8b6914")), lineWidth: 3)

            // Palm leaves
            let leaf1 = Path(ellipseIn: CGRect(x: 10, y: 12, width: 20, height: 8))
            context.fill(leaf1, with: .color(Color(hex: "5a9a4a")))

            let leaf2 = Path(ellipseIn: CGRect(x: 26, y: 12, width: 20, height: 8))
            context.fill(leaf2, with: .color(Color(hex: "4a8a3a")))

            let leaf3 = Path(ellipseIn: CGRect(x: 20, y: 8, width: 16, height: 8))
            context.fill(leaf3, with: .color(Color(hex: "6aaa5a")))

            let leaf4 = Path(ellipseIn: CGRect(x: 15, y: 10, width: 18, height: 7))
            context.fill(leaf4, with: .color(Color(hex: "5a9a4a")))

            let leaf5 = Path(ellipseIn: CGRect(x: 23, y: 10, width: 18, height: 7))
            context.fill(leaf5, with: .color(Color(hex: "4a8a3a")))
        }
        .frame(width: 55, height: 45)
    }
}

// MARK: - Sailboats Layer

struct SeagullSailboatsLayer: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var boat1X: CGFloat = -0.15
    @State private var boat2X: CGFloat = 1.1
    @State private var bobOffset1: CGFloat = 0
    @State private var bobOffset2: CGFloat = 0

    var body: some View {
        ZStack {
            // Sailboat 1 - large, goes right
            SeagullSailboat(size: 45, flipped: false)
                .offset(y: bobOffset1)
                .position(x: screenWidth * boat1X, y: screenHeight * 0.88)

            // Sailboat 2 - medium, goes left
            SeagullSailboat(size: 32, flipped: true)
                .offset(y: bobOffset2)
                .position(x: screenWidth * boat2X, y: screenHeight * 0.72)
        }
        .onAppear {
            // Boat movement
            withAnimation(.linear(duration: 50).repeatForever(autoreverses: false)) {
                boat1X = 1.1
            }
            withAnimation(.linear(duration: 65).repeatForever(autoreverses: false)) {
                boat2X = -0.15
            }
            // Bob animation
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                bobOffset1 = 3
            }
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                bobOffset2 = 3
            }
        }
    }
}

struct SeagullSailboat: View {
    let size: CGFloat
    let flipped: Bool

    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 24

            context.scaleBy(x: flipped ? -scale : scale, y: scale)
            if flipped {
                context.translateBy(x: -24, y: 0)
            }

            // Hull
            var hullPath = Path()
            hullPath.move(to: CGPoint(x: 4, y: 28))
            hullPath.addQuadCurve(to: CGPoint(x: 20, y: 28), control: CGPoint(x: 12, y: 31))
            hullPath.addLine(to: CGPoint(x: 18, y: 24))
            hullPath.addLine(to: CGPoint(x: 6, y: 24))
            hullPath.closeSubpath()
            context.fill(hullPath, with: .color(Color(hex: "6a4a3a")))

            // Mast
            var mastPath = Path()
            mastPath.move(to: CGPoint(x: 12, y: 24))
            mastPath.addLine(to: CGPoint(x: 12, y: 6))
            context.stroke(mastPath, with: .color(Color(hex: "5a3a2a")), lineWidth: 1.5)

            // Main sail
            var sailPath = Path()
            sailPath.move(to: CGPoint(x: 12, y: 7))
            sailPath.addLine(to: CGPoint(x: 12, y: 22))
            sailPath.addLine(to: CGPoint(x: 21, y: 22))
            sailPath.addQuadCurve(to: CGPoint(x: 12, y: 7), control: CGPoint(x: 16, y: 14))
            context.fill(sailPath, with: .color(Color.white.opacity(0.9)))

            // Small sail
            var smallSailPath = Path()
            smallSailPath.move(to: CGPoint(x: 12, y: 9))
            smallSailPath.addLine(to: CGPoint(x: 12, y: 18))
            smallSailPath.addLine(to: CGPoint(x: 5, y: 18))
            smallSailPath.addQuadCurve(to: CGPoint(x: 12, y: 9), control: CGPoint(x: 8, y: 13))
            context.fill(smallSailPath, with: .color(Color.white.opacity(0.75)))
        }
        .frame(width: size, height: size * 35 / 24)
    }
}

// MARK: - Seagull Bird View

struct SeagullBirdView: View {
    let cycleProgress: CGFloat
    let skyHeight: CGFloat
    let waterDepth: CGFloat

    var body: some View {
        // Calculate position and rotation from HTML logic
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = verticalWave * (skyHeight + waterDepth) / 2 - (skyHeight - waterDepth) / 2
        let horizontalPos = sin(cycleProgress * .pi * 2) * 40

        // Velocity for banking
        let horizontalVelocity = cos(cycleProgress * .pi * 2)
        let verticalVelocity = -sin(cycleProgress * .pi * 2)

        // Pitch and roll
        let pitch = verticalVelocity * 25
        let roll = horizontalVelocity * 10

        // Wing fold during dive
        let wingFold = max(0, verticalVelocity * 12)

        // Shadow opacity
        let distanceFromWater = abs(verticalPos)
        let shadowVisibility = max(0, 1 - distanceFromWater / 100)
        let shadowScale = 0.5 + shadowVisibility * 0.5

        ZStack {
            // Shadow on water
            Ellipse()
                .fill(Color(hex: "00283C").opacity(0.25))
                .frame(width: 80, height: 20)
                .blur(radius: 5)
                .scaleEffect(shadowScale)
                .opacity(shadowVisibility * 0.5)
                .offset(y: 80)

            // Seagull
            SeagullShape(wingFold: wingFold)
                .frame(width: 140, height: 60)
                .rotation3DEffect(.degrees(roll), axis: (x: 0, y: 1, z: 0))
                .rotationEffect(.degrees(pitch))
        }
        .offset(x: horizontalPos, y: verticalPos)
    }
}

struct SeagullShape: View {
    let wingFold: CGFloat

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let centerY = size.height / 2

            // Left wing
            var leftWingPath = Path()
            leftWingPath.move(to: CGPoint(x: centerX, y: centerY - 2))
            leftWingPath.addQuadCurve(
                to: CGPoint(x: centerX - 65, y: centerY + 2 + wingFold),
                control: CGPoint(x: centerX - 35, y: centerY - 4)
            )
            leftWingPath.addLine(to: CGPoint(x: centerX - 62, y: centerY + 4 + wingFold))
            leftWingPath.addQuadCurve(
                to: CGPoint(x: centerX, y: centerY + 2),
                control: CGPoint(x: centerX - 30, y: centerY + 5)
            )
            leftWingPath.closeSubpath()

            let wingGradient = Gradient(colors: [
                Color(hex: "f5f5f5"),
                Color(hex: "e0e0e0"),
                Color(hex: "c0c0c0")
            ])
            context.fill(leftWingPath, with: .linearGradient(
                wingGradient,
                startPoint: CGPoint(x: centerX, y: centerY - 10),
                endPoint: CGPoint(x: centerX, y: centerY + 10)
            ))

            // Left wing tip (dark)
            var leftTipPath = Path()
            leftTipPath.move(to: CGPoint(x: centerX - 60, y: centerY + 1 + wingFold))
            leftTipPath.addQuadCurve(
                to: CGPoint(x: centerX - 68, y: centerY - 3 + wingFold),
                control: CGPoint(x: centerX - 67, y: centerY + wingFold)
            )
            leftTipPath.addLine(to: CGPoint(x: centerX - 65, y: centerY + wingFold))
            leftTipPath.addQuadCurve(
                to: CGPoint(x: centerX - 60, y: centerY + 2 + wingFold),
                control: CGPoint(x: centerX - 62, y: centerY + 3 + wingFold)
            )
            context.fill(leftTipPath, with: .linearGradient(
                Gradient(colors: [Color(hex: "3a3a3a"), Color(hex: "1a1a1a")]),
                startPoint: CGPoint(x: centerX - 60, y: centerY - 5),
                endPoint: CGPoint(x: centerX - 60, y: centerY + 5)
            ))

            // Right wing
            var rightWingPath = Path()
            rightWingPath.move(to: CGPoint(x: centerX, y: centerY - 2))
            rightWingPath.addQuadCurve(
                to: CGPoint(x: centerX + 65, y: centerY + 2 + wingFold),
                control: CGPoint(x: centerX + 35, y: centerY - 4)
            )
            rightWingPath.addLine(to: CGPoint(x: centerX + 62, y: centerY + 4 + wingFold))
            rightWingPath.addQuadCurve(
                to: CGPoint(x: centerX, y: centerY + 2),
                control: CGPoint(x: centerX + 30, y: centerY + 5)
            )
            rightWingPath.closeSubpath()
            context.fill(rightWingPath, with: .linearGradient(
                wingGradient,
                startPoint: CGPoint(x: centerX, y: centerY - 10),
                endPoint: CGPoint(x: centerX, y: centerY + 10)
            ))

            // Right wing tip (dark)
            var rightTipPath = Path()
            rightTipPath.move(to: CGPoint(x: centerX + 60, y: centerY + 1 + wingFold))
            rightTipPath.addQuadCurve(
                to: CGPoint(x: centerX + 68, y: centerY - 3 + wingFold),
                control: CGPoint(x: centerX + 67, y: centerY + wingFold)
            )
            rightTipPath.addLine(to: CGPoint(x: centerX + 65, y: centerY + wingFold))
            rightTipPath.addQuadCurve(
                to: CGPoint(x: centerX + 60, y: centerY + 2 + wingFold),
                control: CGPoint(x: centerX + 62, y: centerY + 3 + wingFold)
            )
            context.fill(rightTipPath, with: .linearGradient(
                Gradient(colors: [Color(hex: "3a3a3a"), Color(hex: "1a1a1a")]),
                startPoint: CGPoint(x: centerX + 60, y: centerY - 5),
                endPoint: CGPoint(x: centerX + 60, y: centerY + 5)
            ))

            // Body
            let bodyGradient = Gradient(colors: [
                Color.white,
                Color(hex: "f0f0f0"),
                Color(hex: "d8d8d8")
            ])
            let bodyPath = Path(ellipseIn: CGRect(x: centerX - 22, y: centerY - 8, width: 44, height: 20))
            context.fill(bodyPath, with: .linearGradient(
                bodyGradient,
                startPoint: CGPoint(x: centerX, y: centerY - 10),
                endPoint: CGPoint(x: centerX, y: centerY + 10)
            ))

            // Tail
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: centerX - 22, y: centerY + 2))
            tailPath.addQuadCurve(
                to: CGPoint(x: centerX - 32, y: centerY + 2),
                control: CGPoint(x: centerX - 28, y: centerY)
            )
            tailPath.addQuadCurve(
                to: CGPoint(x: centerX - 22, y: centerY + 2),
                control: CGPoint(x: centerX - 28, y: centerY + 4)
            )
            context.fill(tailPath, with: .color(Color(hex: "e8e8e8")))

            // Head
            let headPath = Path(ellipseIn: CGRect(x: centerX + 15, y: centerY - 10, width: 20, height: 16))
            context.fill(headPath, with: .linearGradient(
                bodyGradient,
                startPoint: CGPoint(x: centerX + 25, y: centerY - 12),
                endPoint: CGPoint(x: centerX + 25, y: centerY + 4)
            ))

            // Eye
            let eyePath = Path(ellipseIn: CGRect(x: centerX + 26, y: centerY - 6, width: 4, height: 4))
            context.fill(eyePath, with: .color(Color(hex: "1a1a1a")))

            // Eye highlight
            let eyeHighlightPath = Path(ellipseIn: CGRect(x: centerX + 27, y: centerY - 5.5, width: 1, height: 1))
            context.fill(eyeHighlightPath, with: .color(.white))

            // Beak
            var beakPath = Path()
            beakPath.move(to: CGPoint(x: centerX + 35, y: centerY - 2))
            beakPath.addLine(to: CGPoint(x: centerX + 48, y: centerY))
            beakPath.addLine(to: CGPoint(x: centerX + 35, y: centerY + 2))
            beakPath.addQuadCurve(
                to: CGPoint(x: centerX + 35, y: centerY - 2),
                control: CGPoint(x: centerX + 37, y: centerY)
            )
            context.fill(beakPath, with: .color(Color(hex: "e8a030")))

            // Beak line
            var beakLinePath = Path()
            beakLinePath.move(to: CGPoint(x: centerX + 35, y: centerY))
            beakLinePath.addLine(to: CGPoint(x: centerX + 48, y: centerY))
            context.stroke(beakLinePath, with: .color(Color(hex: "c08020")), lineWidth: 0.5)
        }
    }
}

#Preview {
    BreatheSeagullView(duration: 3, onComplete: {}, onBack: {})
}
