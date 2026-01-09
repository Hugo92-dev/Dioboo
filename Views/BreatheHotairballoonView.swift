//
//  BreatheHotairballoonView.swift
//  Dioboo
//
//  Hot Air Balloon breathing experience - matches breathehotairballoon.html exactly
//

import SwiftUI
import Combine

struct BreatheHotairballoonView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var cycleProgress: CGFloat = 0
    @State private var animationTimer: Timer?
    @State private var startTime: Date?
    @State private var timestamp: TimeInterval = 0

    private let cycleDuration: TimeInterval = 10.0
    private let riseHeight: CGFloat = 180

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sky gradient - exact from HTML
                LinearGradient(
                    colors: [
                        Color(hex: "1a3a5a"),
                        Color(hex: "2a5a7a"),
                        Color(hex: "4a8aaa"),
                        Color(hex: "7ab4d4"),
                        Color(hex: "a8d4e8"),
                        Color(hex: "d4e8f0"),
                        Color(hex: "e8f4f8")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // High altitude clouds
                BalloonCloudsHighLayer()

                // Mid altitude clouds
                BalloonCloudsMidLayer()

                // Mist layer
                BalloonMistLayer(cycleProgress: cycleProgress, riseHeight: riseHeight)

                // Background balloons
                BalloonBackgroundBalloonsLayer()

                // Landscape
                BalloonLandscapeView(cycleProgress: cycleProgress, riseHeight: riseHeight)
                    .frame(height: geo.size.height * 0.55)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.85)

                // Main hot air balloon
                BalloonMainView(
                    cycleProgress: cycleProgress,
                    riseHeight: riseHeight,
                    timestamp: timestamp,
                    isInhaling: isInhaling
                )
                .position(x: geo.size.width / 2, y: geo.size.height * 0.45)

                // UI Overlay
                VStack {
                    // Back button - glass effect
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

                    // Phase text
                    Text(isInhaling ? "INHALE" : "EXHALE")
                        .font(.custom("Nunito", size: 22).weight(.regular))
                        .foregroundColor(Color(hex: "F5F7FF"))
                        .tracking(6)
                        .shadow(color: Color(hex: "003250").opacity(0.4), radius: 8, y: 2)
                        .padding(.bottom, 8)

                    // Timer
                    BreathingTimer(duration: duration, onComplete: onComplete)
                        .padding(.bottom, 40)
                }
            }
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
            timestamp = elapsed * 1000 // Convert to milliseconds for consistency

            let progress = (elapsed.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            cycleProgress = progress
            isInhaling = progress < 0.5
        }
    }
}

// MARK: - High Altitude Clouds

struct BalloonCloudsHighLayer: View {
    @State private var offset1: CGFloat = 0
    @State private var offset2: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            Ellipse()
                .fill(Color.white.opacity(0.4))
                .frame(width: 80, height: 25)
                .blur(radius: 15)
                .offset(x: offset1)
                .position(x: geo.size.width * 0.05 + 40, y: geo.size.height * 0.08)

            Ellipse()
                .fill(Color.white.opacity(0.3))
                .frame(width: 100, height: 30)
                .blur(radius: 15)
                .offset(x: offset2)
                .position(x: geo.size.width * 0.60 + 50, y: geo.size.height * 0.08)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 50).repeatForever(autoreverses: true)) {
                offset1 = 60
            }
            withAnimation(.easeInOut(duration: 60).repeatForever(autoreverses: true)) {
                offset2 = -60
            }
        }
    }
}

// MARK: - Mid Altitude Clouds

struct BalloonCloudsMidLayer: View {
    @State private var offset1: CGFloat = 0
    @State private var offset2: CGFloat = 0
    @State private var offset3: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            Ellipse()
                .fill(Color.white.opacity(0.35))
                .frame(width: 120, height: 35)
                .blur(radius: 15)
                .offset(x: offset1)
                .position(x: -10, y: geo.size.height * 0.25)

            Ellipse()
                .fill(Color.white.opacity(0.25))
                .frame(width: 90, height: 28)
                .blur(radius: 15)
                .offset(x: offset2)
                .position(x: geo.size.width * 0.50 + 45, y: geo.size.height * 0.25)

            Ellipse()
                .fill(Color.white.opacity(0.3))
                .frame(width: 70, height: 22)
                .blur(radius: 15)
                .offset(x: offset3)
                .position(x: geo.size.width * 0.80 + 35, y: geo.size.height * 0.25)
        }
        .onAppear {
            withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) {
                offset1 = 400
            }
            withAnimation(.easeInOut(duration: 55).repeatForever(autoreverses: true)) {
                offset2 = 60
            }
            withAnimation(.easeInOut(duration: 40).repeatForever(autoreverses: true)) {
                offset3 = -60
            }
        }
    }
}

// MARK: - Mist Layer

struct BalloonMistLayer: View {
    let cycleProgress: CGFloat
    let riseHeight: CGFloat

    var body: some View {
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = (1 - verticalWave) / 2 * riseHeight
        let balloonAltitude = verticalPos / riseHeight
        let mistProximity = 1 - abs(balloonAltitude - 0.4) * 3

        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 60)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.42)
                .opacity(0.3 + max(0, mistProximity) * 0.4)
        }
    }
}

// MARK: - Background Balloons

struct BalloonBackgroundBalloonsLayer: View {
    @State private var balloon1Offset: CGPoint = .zero
    @State private var balloon2Offset: CGPoint = .zero
    @State private var balloon3Offset: CGPoint = .zero

    var body: some View {
        GeometryReader { geo in
            // Far balloon - blue/purple tones
            BalloonSmallSVG(colors: [Color(hex: "6a7a9a"), Color(hex: "8090b0"), Color(hex: "a0b0d0")])
                .frame(width: 28, height: 42)
                .opacity(0.4)
                .offset(x: balloon1Offset.x, y: balloon1Offset.y)
                .position(x: geo.size.width * 0.08 + 14, y: geo.size.height * 0.12)

            // Mid balloon - green/teal tones
            BalloonSmallSVG(colors: [Color(hex: "4a8a7a"), Color(hex: "5aa090"), Color(hex: "7ac0b0")])
                .frame(width: 38, height: 57)
                .opacity(0.55)
                .offset(x: balloon2Offset.x, y: balloon2Offset.y)
                .position(x: geo.size.width * 0.88, y: geo.size.height * 0.28)

            // Near balloon - pink/magenta tones
            BalloonSmallSVG(colors: [Color(hex: "9a5a7a"), Color(hex: "b07090"), Color(hex: "c890a8")])
                .frame(width: 45, height: 68)
                .opacity(0.5)
                .offset(x: balloon3Offset.x, y: balloon3Offset.y)
                .position(x: geo.size.width * 0.05 + 22, y: geo.size.height * 0.48)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 25).repeatForever(autoreverses: true)) {
                balloon1Offset = CGPoint(x: 15, y: -20)
            }
            withAnimation(.easeInOut(duration: 30).repeatForever(autoreverses: true)) {
                balloon2Offset = CGPoint(x: -10, y: -20)
            }
            withAnimation(.easeInOut(duration: 22).repeatForever(autoreverses: true)) {
                balloon3Offset = CGPoint(x: 12, y: -25)
            }
        }
    }
}

struct BalloonSmallSVG: View {
    let colors: [Color]

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let envelopeHeight = size.height * 0.65
            let basketY = size.height * 0.85

            // Envelope layers
            for i in 0..<min(colors.count, 3) {
                let radiusX = (size.width / 2) * (1 - CGFloat(i) * 0.2)
                let radiusY = envelopeHeight / 2 * (1 - CGFloat(i) * 0.2)
                let envelope = Path(ellipseIn: CGRect(
                    x: centerX - radiusX,
                    y: envelopeHeight / 2 - radiusY,
                    width: radiusX * 2,
                    height: radiusY * 2
                ))
                context.fill(envelope, with: .color(colors[i]))
            }

            // Basket
            let basketWidth = size.width * 0.3
            let basketHeight = size.height * 0.12
            let basketRect = CGRect(x: centerX - basketWidth / 2, y: basketY, width: basketWidth, height: basketHeight)
            context.fill(Path(roundedRect: basketRect, cornerRadius: 1), with: .color(Color(hex: "7a6050")))

            // Ropes
            var rope1 = Path()
            rope1.move(to: CGPoint(x: centerX - 3, y: envelopeHeight))
            rope1.addLine(to: CGPoint(x: centerX - basketWidth / 2 + 2, y: basketY))
            context.stroke(rope1, with: .color(Color(hex: "6a5040")), lineWidth: 0.5)

            var rope2 = Path()
            rope2.move(to: CGPoint(x: centerX + 3, y: envelopeHeight))
            rope2.addLine(to: CGPoint(x: centerX + basketWidth / 2 - 2, y: basketY))
            context.stroke(rope2, with: .color(Color(hex: "6a5040")), lineWidth: 0.5)
        }
    }
}

// MARK: - Landscape View

struct BalloonLandscapeView: View {
    let cycleProgress: CGFloat
    let riseHeight: CGFloat

    var body: some View {
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = (1 - verticalWave) / 2 * riseHeight
        let balloonAltitude = verticalPos / riseHeight
        let landscapeScale = 1 + (1 - balloonAltitude) * 0.15
        let landscapeY = balloonAltitude * 30

        Canvas { context, size in
            // Distant hills
            var distantHills = Path()
            distantHills.move(to: CGPoint(x: 0, y: size.height * 0.4))
            distantHills.addQuadCurve(to: CGPoint(x: size.width * 0.25, y: size.height * 0.35), control: CGPoint(x: size.width * 0.125, y: size.height * 0.25))
            distantHills.addQuadCurve(to: CGPoint(x: size.width * 0.5, y: size.height * 0.3), control: CGPoint(x: size.width * 0.375, y: size.height * 0.2))
            distantHills.addQuadCurve(to: CGPoint(x: size.width * 0.75, y: size.height * 0.28), control: CGPoint(x: size.width * 0.625, y: size.height * 0.15))
            distantHills.addQuadCurve(to: CGPoint(x: size.width, y: size.height * 0.33), control: CGPoint(x: size.width * 0.875, y: size.height * 0.22))
            distantHills.addLine(to: CGPoint(x: size.width, y: size.height))
            distantHills.addLine(to: CGPoint(x: 0, y: size.height))
            distantHills.closeSubpath()
            context.fill(distantHills, with: .linearGradient(
                Gradient(colors: [Color(hex: "7a9a8a"), Color(hex: "5a7a6a")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Mid hills
            var midHills = Path()
            midHills.move(to: CGPoint(x: 0, y: size.height * 0.55))
            midHills.addQuadCurve(to: CGPoint(x: size.width * 0.3, y: size.height * 0.5), control: CGPoint(x: size.width * 0.15, y: size.height * 0.4))
            midHills.addQuadCurve(to: CGPoint(x: size.width * 0.6, y: size.height * 0.48), control: CGPoint(x: size.width * 0.45, y: size.height * 0.35))
            midHills.addQuadCurve(to: CGPoint(x: size.width, y: size.height * 0.5), control: CGPoint(x: size.width * 0.8, y: size.height * 0.38))
            midHills.addLine(to: CGPoint(x: size.width, y: size.height))
            midHills.addLine(to: CGPoint(x: 0, y: size.height))
            midHills.closeSubpath()
            context.fill(midHills, with: .linearGradient(
                Gradient(colors: [Color(hex: "5a8a5a"), Color(hex: "3a6a4a")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Forest layer
            var forest = Path()
            forest.move(to: CGPoint(x: 0, y: size.height * 0.7))
            forest.addQuadCurve(to: CGPoint(x: size.width * 0.2, y: size.height * 0.68), control: CGPoint(x: size.width * 0.1, y: size.height * 0.62))
            forest.addQuadCurve(to: CGPoint(x: size.width * 0.4, y: size.height * 0.65), control: CGPoint(x: size.width * 0.3, y: size.height * 0.6))
            forest.addQuadCurve(to: CGPoint(x: size.width * 0.6, y: size.height * 0.64), control: CGPoint(x: size.width * 0.5, y: size.height * 0.58))
            forest.addQuadCurve(to: CGPoint(x: size.width * 0.8, y: size.height * 0.66), control: CGPoint(x: size.width * 0.7, y: size.height * 0.59))
            forest.addQuadCurve(to: CGPoint(x: size.width, y: size.height * 0.68), control: CGPoint(x: size.width * 0.9, y: size.height * 0.61))
            forest.addLine(to: CGPoint(x: size.width, y: size.height))
            forest.addLine(to: CGPoint(x: 0, y: size.height))
            forest.closeSubpath()
            context.fill(forest, with: .linearGradient(
                Gradient(colors: [Color(hex: "3a6a3a"), Color(hex: "2a4a2a")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Trees
            let treePositions: [(x: CGFloat, h: CGFloat)] = [
                (0.08, 0.15), (0.12, 0.18), (0.18, 0.12),
                (0.30, 0.18), (0.35, 0.12),
                (0.50, 0.20), (0.55, 0.14), (0.60, 0.12),
                (0.75, 0.15), (0.80, 0.13),
                (0.90, 0.17), (0.95, 0.12)
            ]

            for tree in treePositions {
                var treePath = Path()
                let treeX = size.width * tree.x
                let treeBase = size.height * 0.70
                let treeHeight = size.height * tree.h
                let treeWidth = treeHeight * 0.5

                treePath.move(to: CGPoint(x: treeX, y: treeBase))
                treePath.addLine(to: CGPoint(x: treeX - treeWidth / 2, y: treeBase))
                treePath.addLine(to: CGPoint(x: treeX, y: treeBase - treeHeight))
                treePath.addLine(to: CGPoint(x: treeX + treeWidth / 2, y: treeBase))
                treePath.closeSubpath()
                context.fill(treePath, with: .color(Color(hex: "2a5030")))
            }

            // Foreground
            var foreground = Path()
            foreground.move(to: CGPoint(x: 0, y: size.height * 0.82))
            foreground.addQuadCurve(to: CGPoint(x: size.width * 0.5, y: size.height * 0.81), control: CGPoint(x: size.width * 0.25, y: size.height * 0.78))
            foreground.addQuadCurve(to: CGPoint(x: size.width, y: size.height * 0.84), control: CGPoint(x: size.width * 0.75, y: size.height * 0.79))
            foreground.addLine(to: CGPoint(x: size.width, y: size.height))
            foreground.addLine(to: CGPoint(x: 0, y: size.height))
            foreground.closeSubpath()
            context.fill(foreground, with: .linearGradient(
                Gradient(colors: [Color(hex: "2a5a2a"), Color(hex: "1a3a1a")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Bushes
            let bushPositions: [(x: CGFloat, y: CGFloat, rx: CGFloat, ry: CGFloat)] = [
                (0.15, 0.86, 15, 8),
                (0.40, 0.84, 12, 6),
                (0.70, 0.85, 18, 7),
                (0.88, 0.88, 14, 6)
            ]

            for bush in bushPositions {
                let bushPath = Path(ellipseIn: CGRect(
                    x: size.width * bush.x - bush.rx,
                    y: size.height * bush.y - bush.ry,
                    width: bush.rx * 2,
                    height: bush.ry * 2
                ))
                context.fill(bushPath, with: .color(Color(hex: "1a4020")))
            }
        }
        .scaleEffect(landscapeScale)
        .offset(y: -landscapeY)
    }
}

// MARK: - Main Balloon View

struct BalloonMainView: View {
    let cycleProgress: CGFloat
    let riseHeight: CGFloat
    let timestamp: TimeInterval
    let isInhaling: Bool

    private func easeInOutSine(_ t: CGFloat) -> CGFloat {
        return -(cos(.pi * t) - 1) / 2
    }

    var body: some View {
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = (1 - verticalWave) / 2 * riseHeight
        let horizontalDrift = sin(cycleProgress * .pi * 2) * 15
        let floatY = sin(timestamp / 1500) * 4
        let floatX = cos(timestamp / 2000) * 3
        let basketSway = sin(timestamp / 800) * 1.5
        let flameIntensity = isInhaling ? easeInOutSine(cycleProgress * 2) : 0

        ZStack {
            // Balloon shadow
            BalloonShadowView(cycleProgress: cycleProgress, riseHeight: riseHeight)
                .offset(y: 250)

            // Main balloon
            BalloonEnvelopeView(flameIntensity: flameIntensity)
                .frame(width: 120, height: 180)
                .rotationEffect(.degrees(basketSway))
        }
        .offset(x: horizontalDrift + floatX, y: -verticalPos - floatY)
    }
}

struct BalloonShadowView: View {
    let cycleProgress: CGFloat
    let riseHeight: CGFloat

    var body: some View {
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = (1 - verticalWave) / 2 * riseHeight
        let balloonAltitude = verticalPos / riseHeight
        let shadowVisibility = max(0, 1 - balloonAltitude * 1.2)
        let shadowScale = 0.5 + shadowVisibility * 0.8

        Ellipse()
            .fill(Color(hex: "001e14").opacity(0.3))
            .frame(width: 60, height: 20)
            .blur(radius: 8)
            .scaleEffect(shadowScale)
            .opacity(shadowVisibility * 0.4)
    }
}

struct BalloonEnvelopeView: View {
    let flameIntensity: CGFloat

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let envelopeRadiusX: CGFloat = 45
            let envelopeRadiusY: CGFloat = 55
            let envelopeCenterY: CGFloat = 50

            // Main envelope - white base
            let envelopePath = Path(ellipseIn: CGRect(
                x: centerX - envelopeRadiusX,
                y: envelopeCenterY - envelopeRadiusY,
                width: envelopeRadiusX * 2,
                height: envelopeRadiusY * 2
            ))
            context.fill(envelopePath, with: .linearGradient(
                Gradient(colors: [Color(hex: "d8d8d0"), Color(hex: "f5f5f0"), Color(hex: "d8d8d0")]),
                startPoint: CGPoint(x: 0, y: envelopeCenterY),
                endPoint: CGPoint(x: size.width, y: envelopeCenterY)
            ))

            // Red stripe
            var redStripe = Path()
            redStripe.move(to: CGPoint(x: 15, y: envelopeCenterY))
            redStripe.addQuadCurve(to: CGPoint(x: centerX, y: -5), control: CGPoint(x: 15, y: 0))
            redStripe.addQuadCurve(to: CGPoint(x: 105, y: envelopeCenterY), control: CGPoint(x: 105, y: 0))
            redStripe.addQuadCurve(to: CGPoint(x: centerX, y: 105), control: CGPoint(x: 105, y: 90))
            redStripe.addQuadCurve(to: CGPoint(x: 15, y: envelopeCenterY), control: CGPoint(x: 15, y: 90))
            context.clip(to: envelopePath)
            context.fill(redStripe, with: .linearGradient(
                Gradient(colors: [Color(hex: "c44a40"), Color(hex: "e85a50"), Color(hex: "c44a40")]),
                startPoint: CGPoint(x: 0, y: envelopeCenterY),
                endPoint: CGPoint(x: size.width, y: envelopeCenterY)
            ))

            // Orange stripe
            var orangeStripe = Path()
            orangeStripe.move(to: CGPoint(x: 25, y: envelopeCenterY))
            orangeStripe.addQuadCurve(to: CGPoint(x: centerX, y: 2), control: CGPoint(x: 25, y: 10))
            orangeStripe.addQuadCurve(to: CGPoint(x: 95, y: envelopeCenterY), control: CGPoint(x: 95, y: 10))
            orangeStripe.addQuadCurve(to: CGPoint(x: centerX, y: 98), control: CGPoint(x: 95, y: 85))
            orangeStripe.addQuadCurve(to: CGPoint(x: 25, y: envelopeCenterY), control: CGPoint(x: 25, y: 85))
            context.fill(orangeStripe, with: .linearGradient(
                Gradient(colors: [Color(hex: "d4854a"), Color(hex: "f0a060"), Color(hex: "d4854a")]),
                startPoint: CGPoint(x: 0, y: envelopeCenterY),
                endPoint: CGPoint(x: size.width, y: envelopeCenterY)
            ))

            // Yellow stripe
            var yellowStripe = Path()
            yellowStripe.move(to: CGPoint(x: 35, y: envelopeCenterY))
            yellowStripe.addQuadCurve(to: CGPoint(x: centerX, y: 10), control: CGPoint(x: 35, y: 18))
            yellowStripe.addQuadCurve(to: CGPoint(x: 85, y: envelopeCenterY), control: CGPoint(x: 85, y: 18))
            yellowStripe.addQuadCurve(to: CGPoint(x: centerX, y: 90), control: CGPoint(x: 85, y: 78))
            yellowStripe.addQuadCurve(to: CGPoint(x: 35, y: envelopeCenterY), control: CGPoint(x: 35, y: 78))
            context.fill(yellowStripe, with: .linearGradient(
                Gradient(colors: [Color(hex: "c4a44a"), Color(hex: "e8c860"), Color(hex: "c4a44a")]),
                startPoint: CGPoint(x: 0, y: envelopeCenterY),
                endPoint: CGPoint(x: size.width, y: envelopeCenterY)
            ))

            // White center
            var whiteCenter = Path()
            whiteCenter.move(to: CGPoint(x: 45, y: envelopeCenterY))
            whiteCenter.addQuadCurve(to: CGPoint(x: centerX, y: 18), control: CGPoint(x: 45, y: 25))
            whiteCenter.addQuadCurve(to: CGPoint(x: 75, y: envelopeCenterY), control: CGPoint(x: 75, y: 25))
            whiteCenter.addQuadCurve(to: CGPoint(x: centerX, y: 82), control: CGPoint(x: 75, y: 72))
            whiteCenter.addQuadCurve(to: CGPoint(x: 45, y: envelopeCenterY), control: CGPoint(x: 45, y: 72))
            context.fill(whiteCenter, with: .linearGradient(
                Gradient(colors: [Color(hex: "d8d8d0"), Color(hex: "f5f5f0"), Color(hex: "d8d8d0")]),
                startPoint: CGPoint(x: 0, y: envelopeCenterY),
                endPoint: CGPoint(x: size.width, y: envelopeCenterY)
            ))

            // Bottom opening
            let openingPath = Path(ellipseIn: CGRect(x: centerX - 12, y: 95, width: 24, height: 10))
            context.fill(openingPath, with: .color(Color(hex: "4a3020")))

            // Highlight
            let highlightPath = Path(ellipseIn: CGRect(x: 33, y: 17, width: 24, height: 36))
            context.fill(highlightPath, with: .color(Color.white.opacity(0.2)))

            // Ropes
            let ropeColor = Color(hex: "5a4030")
            var rope1 = Path()
            rope1.move(to: CGPoint(x: 48, y: 100))
            rope1.addLine(to: CGPoint(x: 45, y: 140))
            context.stroke(rope1, with: .color(ropeColor), lineWidth: 1)

            var rope2 = Path()
            rope2.move(to: CGPoint(x: 72, y: 100))
            rope2.addLine(to: CGPoint(x: 75, y: 140))
            context.stroke(rope2, with: .color(ropeColor), lineWidth: 1)

            var rope3 = Path()
            rope3.move(to: CGPoint(x: 55, y: 103))
            rope3.addLine(to: CGPoint(x: 52, y: 140))
            context.stroke(rope3, with: .color(ropeColor), lineWidth: 1)

            var rope4 = Path()
            rope4.move(to: CGPoint(x: 65, y: 103))
            rope4.addLine(to: CGPoint(x: 68, y: 140))
            context.stroke(rope4, with: .color(ropeColor), lineWidth: 1)

            // Basket rim
            let rimRect = CGRect(x: 40, y: 138, width: 40, height: 5)
            context.fill(Path(roundedRect: rimRect, cornerRadius: 2), with: .color(Color(hex: "8a6040")))

            // Basket
            let basketRect = CGRect(x: 42, y: 140, width: 36, height: 25)
            context.fill(Path(roundedRect: basketRect, cornerRadius: 3), with: .linearGradient(
                Gradient(colors: [Color(hex: "a08060"), Color(hex: "705030")]),
                startPoint: CGPoint(x: 0, y: 140),
                endPoint: CGPoint(x: 0, y: 165)
            ))

            // Basket weave
            let weaveColor = Color(hex: "5a4020").opacity(0.5)
            context.stroke(Path { p in
                p.move(to: CGPoint(x: 42, y: 148))
                p.addLine(to: CGPoint(x: 78, y: 148))
            }, with: .color(weaveColor), lineWidth: 0.5)
            context.stroke(Path { p in
                p.move(to: CGPoint(x: 42, y: 156))
                p.addLine(to: CGPoint(x: 78, y: 156))
            }, with: .color(weaveColor), lineWidth: 0.5)

            for x in [50, 60, 70] {
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: CGFloat(x), y: 140))
                    p.addLine(to: CGPoint(x: CGFloat(x), y: 165))
                }, with: .color(weaveColor), lineWidth: 0.5)
            }

            // Flame (when inhaling)
            if flameIntensity > 0 {
                let flameOuter = Path(ellipseIn: CGRect(x: centerX - 6, y: 106, width: 12, height: 24))
                context.fill(flameOuter, with: .color(Color(hex: "ff9030").opacity(Double(flameIntensity) * 0.9)))

                let flameMid = Path(ellipseIn: CGRect(x: centerX - 4, y: 107, width: 8, height: 16))
                context.fill(flameMid, with: .color(Color(hex: "ffb050").opacity(Double(flameIntensity) * 0.9)))

                let flameInner = Path(ellipseIn: CGRect(x: centerX - 2, y: 107, width: 4, height: 10))
                context.fill(flameInner, with: .color(Color(hex: "ffe080").opacity(Double(flameIntensity) * 0.9)))
            }
        }
    }
}

#Preview {
    BreatheHotairballoonView(duration: 3, onComplete: {}, onBack: {})
}
