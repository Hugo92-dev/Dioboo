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
    @State private var elapsedTime: TimeInterval = 0
    @State private var animationTimer: Timer?
    @State private var startTime: Date?
    @State private var timestamp: TimeInterval = 0
    @State private var sceneOpacity: Double = 0

    private let cycleDuration: TimeInterval = 10.0
    private let riseHeight: CGFloat = 180

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sky gradient - exact from HTML
                // #1a3a5a 0%, #2a5a7a 15%, #4a8aaa 35%, #7ab4d4 55%, #a8d4e8 70%, #d4e8f0 85%, #e8f4f8 100%
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "1a3a5a"), location: 0.0),
                        .init(color: Color(hex: "2a5a7a"), location: 0.15),
                        .init(color: Color(hex: "4a8aaa"), location: 0.35),
                        .init(color: Color(hex: "7ab4d4"), location: 0.55),
                        .init(color: Color(hex: "a8d4e8"), location: 0.70),
                        .init(color: Color(hex: "d4e8f0"), location: 0.85),
                        .init(color: Color(hex: "e8f4f8"), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // High altitude clouds (top 8%)
                HotAirBalloonCloudsHighLayer(timestamp: timestamp)

                // Mid altitude clouds (top 25%)
                HotAirBalloonCloudsMidLayer(timestamp: timestamp)

                // Mist layer at 42%
                HotAirBalloonMistLayer(cycleProgress: cycleProgress, riseHeight: riseHeight)

                // Background balloons
                HotAirBalloonBackgroundBalloonsLayer(timestamp: timestamp)

                // Landscape with parallax
                HotAirBalloonLandscapeView(cycleProgress: cycleProgress, riseHeight: riseHeight)
                    .frame(width: geo.size.width * 1.2, height: geo.size.height * 0.55)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.90)

                // Main hot air balloon
                HotAirBalloonMainView(
                    cycleProgress: cycleProgress,
                    riseHeight: riseHeight,
                    timestamp: timestamp,
                    isInhaling: isInhaling
                )
                .position(x: geo.size.width / 2, y: geo.size.height * 0.45)

                // UI Overlay
                VStack {
                    // Back button - glass effect matching HTML
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
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 42, height: 42)
                                .opacity(0.5)
                        )
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()

                    // Phase text - exact from HTML
                    Text(isInhaling ? "INHALE" : "EXHALE")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(Color(hex: "F5F7FF"))
                        .tracking(6)
                        .shadow(color: Color(hex: "003250").opacity(0.4), radius: 15, y: 2)
                        .padding(.bottom, 8)

                    // Timer text
                    Text(formatTime(remaining: max(0, Double(duration * 60) - elapsedTime)))
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(Color.white.opacity(0.8))
                        .padding(.bottom, 8)

                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 3)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.8))
                            .frame(width: max(0, (elapsedTime / Double(duration * 60)) * (geo.size.width - 90)), height: 3)
                    }
                    .padding(.horizontal, 45)
                    .padding(.bottom, 50)
                }
            }
            .opacity(sceneOpacity)
        }
        .onAppear {
            // Fade in animation matching HTML (1s ease, 0.3s delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 1.0)) {
                    sceneOpacity = 1.0
                }
            }
            // Start breathing animation after 1.2s (matching HTML)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                startAnimation()
            }
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }

    private func formatTime(remaining: TimeInterval) -> String {
        let secs = Int(ceil(remaining))
        let minutes = secs / 60
        let seconds = secs % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startAnimation() {
        startTime = Date()

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            guard let start = startTime else { return }
            let elapsed = Date().timeIntervalSince(start)
            timestamp = elapsed * 1000 // Convert to milliseconds for consistency with HTML
            elapsedTime = elapsed

            // Check if complete
            if elapsed >= Double(duration * 60) {
                animationTimer?.invalidate()
                onComplete()
                return
            }

            let progress = (elapsed.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            cycleProgress = progress
            isInhaling = progress < 0.5
        }
    }
}

// MARK: - High Altitude Clouds (8% from top)

struct HotAirBalloonCloudsHighLayer: View {
    let timestamp: TimeInterval

    var body: some View {
        GeometryReader { geo in
            // Cloud H1 - left: 5%, width: 80px, height: 25px, 50s animation
            let drift1 = sin(timestamp / 50000 * .pi * 2) * 30
            Ellipse()
                .fill(Color.white.opacity(0.4))
                .frame(width: 80, height: 25)
                .blur(radius: 15)
                .position(x: geo.size.width * 0.05 + 40 + drift1, y: geo.size.height * 0.08)

            // Cloud H2 - left: 60%, width: 100px, height: 30px, opacity: 0.3, 60s reverse
            let drift2 = -sin(timestamp / 60000 * .pi * 2) * 30
            Ellipse()
                .fill(Color.white.opacity(0.3))
                .frame(width: 100, height: 30)
                .blur(radius: 15)
                .position(x: geo.size.width * 0.60 + 50 + drift2, y: geo.size.height * 0.08)
        }
    }
}

// MARK: - Mid Altitude Clouds (25% from top)

struct HotAirBalloonCloudsMidLayer: View {
    let timestamp: TimeInterval

    var body: some View {
        GeometryReader { geo in
            // Cloud M1 - left: -10%, width: 120px, height: 35px, opacity: 0.35, 45s linear
            let drift1 = (timestamp.truncatingRemainder(dividingBy: 45000)) / 45000 * 60
            Ellipse()
                .fill(Color.white.opacity(0.35))
                .frame(width: 120, height: 35)
                .blur(radius: 15)
                .position(x: geo.size.width * -0.10 + 60 + drift1, y: geo.size.height * 0.25)

            // Cloud M2 - left: 50%, width: 90px, height: 28px, opacity: 0.25, 55s
            let drift2 = sin(timestamp / 55000 * .pi * 2) * 30
            Ellipse()
                .fill(Color.white.opacity(0.25))
                .frame(width: 90, height: 28)
                .blur(radius: 15)
                .position(x: geo.size.width * 0.50 + 45 + drift2, y: geo.size.height * 0.25)

            // Cloud M3 - left: 80%, width: 70px, height: 22px, opacity: 0.3, 40s reverse
            let drift3 = -sin(timestamp / 40000 * .pi * 2) * 30
            Ellipse()
                .fill(Color.white.opacity(0.3))
                .frame(width: 70, height: 22)
                .blur(radius: 15)
                .position(x: geo.size.width * 0.80 + 35 + drift3, y: geo.size.height * 0.25)
        }
    }
}

// MARK: - Mist Layer (42% from top)

struct HotAirBalloonMistLayer: View {
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
                        stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.white.opacity(0.15), location: 0.3),
                            .init(color: Color.white.opacity(0.25), location: 0.5),
                            .init(color: Color.white.opacity(0.15), location: 0.7),
                            .init(color: Color.clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: geo.size.width * 1.2, height: 60)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.42)
                .opacity(0.3 + max(0, mistProximity) * 0.4)
        }
    }
}

// MARK: - Background Balloons

struct HotAirBalloonBackgroundBalloonsLayer: View {
    let timestamp: TimeInterval

    var body: some View {
        GeometryReader { geo in
            // Balloon 1 - Far, top: 12%, left: 8%, size: 28x42, opacity: 0.4
            // Animation: 25s, moves to (8px, -15px), (15px, -5px), (5px, -20px)
            let t1 = (timestamp.truncatingRemainder(dividingBy: 25000)) / 25000
            let offset1 = balloonOffset1(t: t1)
            HotAirBalloonSmallSVG(colors: [
                Color(hex: "6a7a9a"),
                Color(hex: "8090b0"),
                Color(hex: "a0b0d0")
            ])
            .frame(width: 28, height: 42)
            .opacity(0.4)
            .offset(x: offset1.x, y: offset1.y)
            .position(x: geo.size.width * 0.08 + 14, y: geo.size.height * 0.12)

            // Balloon 2 - Mid, top: 28%, right: 12%, size: 38x57, opacity: 0.55
            // Animation: 30s, moves to (-10px, -20px), (-5px, 10px)
            let t2 = (timestamp.truncatingRemainder(dividingBy: 30000)) / 30000
            let offset2 = balloonOffset2(t: t2)
            HotAirBalloonSmallSVG(colors: [
                Color(hex: "4a8a7a"),
                Color(hex: "5aa090"),
                Color(hex: "7ac0b0"),
                Color(hex: "a0e0d0")
            ])
            .frame(width: 38, height: 57)
            .opacity(0.55)
            .offset(x: offset2.x, y: offset2.y)
            .position(x: geo.size.width * 0.88, y: geo.size.height * 0.28)

            // Balloon 3 - Near, top: 48%, left: 5%, size: 45x68, opacity: 0.5
            // Animation: 22s, moves to (12px, -25px)
            let t3 = (timestamp.truncatingRemainder(dividingBy: 22000)) / 22000
            let offset3X = sin(t3 * .pi * 2) * 6 + sin(t3 * .pi) * 6
            let offset3Y = -abs(sin(t3 * .pi)) * 25
            HotAirBalloonSmallSVG(colors: [
                Color(hex: "9a5a7a"),
                Color(hex: "b07090"),
                Color(hex: "c890a8"),
                Color(hex: "e0b0c0")
            ])
            .frame(width: 45, height: 68)
            .opacity(0.5)
            .offset(x: offset3X, y: offset3Y)
            .position(x: geo.size.width * 0.05 + 22, y: geo.size.height * 0.48)
        }
    }

    private func balloonOffset1(t: CGFloat) -> CGPoint {
        // 0%: (0,0), 25%: (8,-15), 50%: (15,-5), 75%: (5,-20), 100%: (0,0)
        if t < 0.25 {
            let p = t / 0.25
            return CGPoint(x: p * 8, y: p * -15)
        } else if t < 0.5 {
            let p = (t - 0.25) / 0.25
            return CGPoint(x: 8 + p * 7, y: -15 + p * 10)
        } else if t < 0.75 {
            let p = (t - 0.5) / 0.25
            return CGPoint(x: 15 - p * 10, y: -5 - p * 15)
        } else {
            let p = (t - 0.75) / 0.25
            return CGPoint(x: 5 - p * 5, y: -20 + p * 20)
        }
    }

    private func balloonOffset2(t: CGFloat) -> CGPoint {
        // 0%: (0,0), 33%: (-10,-20), 66%: (-5,10), 100%: (0,0)
        if t < 0.33 {
            let p = t / 0.33
            return CGPoint(x: p * -10, y: p * -20)
        } else if t < 0.66 {
            let p = (t - 0.33) / 0.33
            return CGPoint(x: -10 + p * 5, y: -20 + p * 30)
        } else {
            let p = (t - 0.66) / 0.34
            return CGPoint(x: -5 + p * 5, y: 10 - p * 10)
        }
    }
}

// Small background balloon SVG
struct HotAirBalloonSmallSVG: View {
    let colors: [Color]

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let envelopeHeight = size.height * 0.65
            let envelopeCenterY = envelopeHeight / 2
            let basketY = size.height * 0.80
            let basketHeight = size.height * 0.12

            // Draw envelope layers from outer to inner
            for i in 0..<min(colors.count, 4) {
                let factor = 1 - CGFloat(i) * 0.22
                let radiusX = (size.width / 2 - 2) * factor
                let radiusY = (envelopeHeight / 2 - 2) * factor
                let envelope = Path(ellipseIn: CGRect(
                    x: centerX - radiusX,
                    y: envelopeCenterY - radiusY,
                    width: radiusX * 2,
                    height: radiusY * 2
                ))
                context.fill(envelope, with: .color(colors[i]))
            }

            // Basket
            let basketWidth = size.width * 0.28
            let basketRect = CGRect(
                x: centerX - basketWidth / 2,
                y: basketY,
                width: basketWidth,
                height: basketHeight
            )
            context.fill(Path(roundedRect: basketRect, cornerRadius: 1), with: .color(Color(hex: "8a7060")))

            // Ropes
            let ropeColor = Color(hex: "7a6050")
            var rope1 = Path()
            rope1.move(to: CGPoint(x: centerX - 2, y: envelopeHeight))
            rope1.addLine(to: CGPoint(x: centerX - basketWidth / 2 + 1, y: basketY))
            context.stroke(rope1, with: .color(ropeColor), lineWidth: 0.6)

            var rope2 = Path()
            rope2.move(to: CGPoint(x: centerX + 2, y: envelopeHeight))
            rope2.addLine(to: CGPoint(x: centerX + basketWidth / 2 - 1, y: basketY))
            context.stroke(rope2, with: .color(ropeColor), lineWidth: 0.6)
        }
    }
}

// MARK: - Landscape View with Parallax

struct HotAirBalloonLandscapeView: View {
    let cycleProgress: CGFloat
    let riseHeight: CGFloat

    var body: some View {
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = (1 - verticalWave) / 2 * riseHeight
        let balloonAltitude = verticalPos / riseHeight
        // Parallax: landscapeScale = 1 + (1 - balloonAltitude) * 0.15
        // landscapeY = balloonAltitude * 30
        let landscapeScale = 1 + (1 - balloonAltitude) * 0.15
        let landscapeY = balloonAltitude * 30

        Canvas { context, size in
            // Distant hills - #7a9a8a to #5a7a6a
            var distantHills = Path()
            distantHills.move(to: CGPoint(x: 0, y: size.height * 0.40))
            distantHills.addQuadCurve(
                to: CGPoint(x: size.width * 0.25, y: size.height * 0.35),
                control: CGPoint(x: size.width * 0.125, y: size.height * 0.25)
            )
            distantHills.addQuadCurve(
                to: CGPoint(x: size.width * 0.50, y: size.height * 0.30),
                control: CGPoint(x: size.width * 0.375, y: size.height * 0.20)
            )
            distantHills.addQuadCurve(
                to: CGPoint(x: size.width * 0.75, y: size.height * 0.275),
                control: CGPoint(x: size.width * 0.625, y: size.height * 0.15)
            )
            distantHills.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.325),
                control: CGPoint(x: size.width * 0.875, y: size.height * 0.225)
            )
            distantHills.addLine(to: CGPoint(x: size.width, y: size.height))
            distantHills.addLine(to: CGPoint(x: 0, y: size.height))
            distantHills.closeSubpath()
            context.fill(distantHills, with: .linearGradient(
                Gradient(colors: [Color(hex: "7a9a8a"), Color(hex: "5a7a6a")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Mid hills - #5a8a5a to #3a6a4a
            var midHills = Path()
            midHills.move(to: CGPoint(x: 0, y: size.height * 0.55))
            midHills.addQuadCurve(
                to: CGPoint(x: size.width * 0.30, y: size.height * 0.50),
                control: CGPoint(x: size.width * 0.15, y: size.height * 0.40)
            )
            midHills.addQuadCurve(
                to: CGPoint(x: size.width * 0.60, y: size.height * 0.475),
                control: CGPoint(x: size.width * 0.45, y: size.height * 0.35)
            )
            midHills.addQuadCurve(
                to: CGPoint(x: size.width * 0.90, y: size.height * 0.45),
                control: CGPoint(x: size.width * 0.75, y: size.height * 0.375)
            )
            midHills.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.50),
                control: CGPoint(x: size.width * 0.95, y: size.height * 0.425)
            )
            midHills.addLine(to: CGPoint(x: size.width, y: size.height))
            midHills.addLine(to: CGPoint(x: 0, y: size.height))
            midHills.closeSubpath()
            context.fill(midHills, with: .linearGradient(
                Gradient(colors: [Color(hex: "5a8a5a"), Color(hex: "3a6a4a")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Forest layer - #3a6a3a to #2a4a2a
            var forest = Path()
            forest.move(to: CGPoint(x: 0, y: size.height * 0.70))
            forest.addQuadCurve(
                to: CGPoint(x: size.width * 0.20, y: size.height * 0.675),
                control: CGPoint(x: size.width * 0.10, y: size.height * 0.625)
            )
            forest.addQuadCurve(
                to: CGPoint(x: size.width * 0.40, y: size.height * 0.65),
                control: CGPoint(x: size.width * 0.30, y: size.height * 0.60)
            )
            forest.addQuadCurve(
                to: CGPoint(x: size.width * 0.60, y: size.height * 0.64),
                control: CGPoint(x: size.width * 0.50, y: size.height * 0.575)
            )
            forest.addQuadCurve(
                to: CGPoint(x: size.width * 0.80, y: size.height * 0.66),
                control: CGPoint(x: size.width * 0.70, y: size.height * 0.59)
            )
            forest.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.675),
                control: CGPoint(x: size.width * 0.90, y: size.height * 0.61)
            )
            forest.addLine(to: CGPoint(x: size.width, y: size.height))
            forest.addLine(to: CGPoint(x: 0, y: size.height))
            forest.closeSubpath()
            context.fill(forest, with: .linearGradient(
                Gradient(colors: [Color(hex: "3a6a3a"), Color(hex: "2a4a2a")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Tree silhouettes - #2a5030
            let treeColor = Color(hex: "2a5030")
            let treeGroups: [(positions: [(x: CGFloat, base: CGFloat, h: CGFloat)], baseY: CGFloat)] = [
                // Group 1
                ([(0.075, 0.70, 0.10), (0.1125, 0.70, 0.125), (0.1625, 0.70, 0.075)], 0.70),
                // Group 2
                ([(0.30, 0.675, 0.125), (0.35, 0.69, 0.08)], 0.675),
                // Group 3
                ([(0.50, 0.65, 0.125), (0.5625, 0.665, 0.09), (0.6125, 0.675, 0.075)], 0.65),
                // Group 4
                ([(0.75, 0.66, 0.10), (0.80, 0.675, 0.085)], 0.66),
                // Group 5
                ([(0.90, 0.65, 0.11), (0.95, 0.665, 0.075)], 0.65)
            ]

            for group in treeGroups {
                for tree in group.positions {
                    var treePath = Path()
                    let treeX = size.width * tree.x
                    let treeBase = size.height * tree.base
                    let treeHeight = size.height * tree.h
                    let treeWidth = treeHeight * 0.7

                    treePath.move(to: CGPoint(x: treeX - treeWidth / 2, y: treeBase))
                    treePath.addLine(to: CGPoint(x: treeX, y: treeBase - treeHeight))
                    treePath.addLine(to: CGPoint(x: treeX + treeWidth / 2, y: treeBase))
                    treePath.closeSubpath()
                    context.fill(treePath, with: .color(treeColor))
                }
            }

            // Foreground - #2a5a2a to #1a3a1a
            var foreground = Path()
            foreground.move(to: CGPoint(x: 0, y: size.height * 0.825))
            foreground.addQuadCurve(
                to: CGPoint(x: size.width * 0.50, y: size.height * 0.81),
                control: CGPoint(x: size.width * 0.25, y: size.height * 0.775)
            )
            foreground.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.84),
                control: CGPoint(x: size.width * 0.75, y: size.height * 0.79)
            )
            foreground.addLine(to: CGPoint(x: size.width, y: size.height))
            foreground.addLine(to: CGPoint(x: 0, y: size.height))
            foreground.closeSubpath()
            context.fill(foreground, with: .linearGradient(
                Gradient(colors: [Color(hex: "2a5a2a"), Color(hex: "1a3a1a")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Bushes - #1a4020
            let bushColor = Color(hex: "1a4020")
            let bushes: [(x: CGFloat, y: CGFloat, rx: CGFloat, ry: CGFloat)] = [
                (0.15, 0.86, 15, 8),
                (0.375, 0.84, 12, 6),
                (0.70, 0.85, 18, 7),
                (0.875, 0.875, 14, 6)
            ]

            for bush in bushes {
                let bushPath = Path(ellipseIn: CGRect(
                    x: size.width * bush.x - bush.rx,
                    y: size.height * bush.y - bush.ry,
                    width: bush.rx * 2,
                    height: bush.ry * 2
                ))
                context.fill(bushPath, with: .color(bushColor))
            }
        }
        .scaleEffect(landscapeScale)
        .offset(y: -landscapeY)
    }
}

// MARK: - Main Hot Air Balloon View

struct HotAirBalloonMainView: View {
    let cycleProgress: CGFloat
    let riseHeight: CGFloat
    let timestamp: TimeInterval
    let isInhaling: Bool

    private func easeInOutSine(_ t: CGFloat) -> CGFloat {
        return -(cos(.pi * t) - 1) / 2
    }

    var body: some View {
        // Calculate all positions matching HTML exactly
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = (1 - verticalWave) / 2 * riseHeight
        let horizontalDrift = sin(cycleProgress * .pi * 2) * 15

        // Micro floating oscillation
        let floatY = sin(timestamp / 1500) * 4
        let floatX = cos(timestamp / 2000) * 3

        // Basket sway
        let basketSway = sin(timestamp / 800) * 1.5

        // Flame intensity
        let flameIntensity = isInhaling ? easeInOutSine(min(1, cycleProgress * 2)) : 0

        // Balloon altitude for shadow
        let balloonAltitude = verticalPos / riseHeight

        ZStack {
            // Balloon shadow
            HotAirBalloonShadowView(balloonAltitude: balloonAltitude)
                .offset(y: 250)

            // Main balloon with flame glow
            ZStack {
                // Flame glow effect (behind balloon)
                if flameIntensity > 0 {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "ffc864").opacity(0.6),
                                    Color(hex: "ff9632").opacity(0.3),
                                    Color.clear
                                ],
                                center: .bottom,
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                        .frame(width: 30, height: 40)
                        .blur(radius: 8)
                        .offset(y: 15)
                        .opacity(flameIntensity * 0.7)
                }

                // Main balloon envelope
                HotAirBalloonEnvelopeView(flameIntensity: flameIntensity, timestamp: timestamp)
                    .frame(width: 120, height: 180)
            }
            .rotationEffect(.degrees(basketSway))
        }
        .offset(x: horizontalDrift + floatX, y: -verticalPos - floatY)
    }
}

// Shadow view
struct HotAirBalloonShadowView: View {
    let balloonAltitude: CGFloat

    var body: some View {
        let shadowVisibility = max(0, 1 - balloonAltitude * 1.2)
        let shadowScale = 0.5 + shadowVisibility * 0.8

        Ellipse()
            .fill(
                RadialGradient(
                    colors: [Color(hex: "001e14").opacity(0.3), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 30
                )
            )
            .frame(width: 60, height: 20)
            .blur(radius: 8)
            .scaleEffect(shadowScale)
            .opacity(shadowVisibility * 0.4)
    }
}

// Main balloon envelope with all details
struct HotAirBalloonEnvelopeView: View {
    let flameIntensity: CGFloat
    let timestamp: TimeInterval

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let envelopeRadiusX: CGFloat = 45
            let envelopeRadiusY: CGFloat = 55
            let envelopeCenterY: CGFloat = 50

            // Create clip path for envelope
            let envelopeClipPath = Path(ellipseIn: CGRect(
                x: centerX - 44,
                y: envelopeCenterY - 54,
                width: 88,
                height: 108
            ))

            // Base envelope - white gradient
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

            // Clip context for stripes
            context.clip(to: envelopeClipPath)

            // Red stripe - outermost
            var redStripe = Path()
            redStripe.move(to: CGPoint(x: 15, y: envelopeCenterY))
            redStripe.addQuadCurve(to: CGPoint(x: centerX, y: -5), control: CGPoint(x: 15, y: 0))
            redStripe.addQuadCurve(to: CGPoint(x: 105, y: envelopeCenterY), control: CGPoint(x: 105, y: 0))
            redStripe.addQuadCurve(to: CGPoint(x: centerX, y: 105), control: CGPoint(x: 105, y: 90))
            redStripe.addQuadCurve(to: CGPoint(x: 15, y: envelopeCenterY), control: CGPoint(x: 15, y: 90))
            redStripe.closeSubpath()
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
            orangeStripe.closeSubpath()
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
            yellowStripe.closeSubpath()
            context.fill(yellowStripe, with: .linearGradient(
                Gradient(colors: [Color(hex: "c4a44a"), Color(hex: "e8c860"), Color(hex: "c4a44a")]),
                startPoint: CGPoint(x: 0, y: envelopeCenterY),
                endPoint: CGPoint(x: size.width, y: envelopeCenterY)
            ))

            // White center stripe
            var whiteCenter = Path()
            whiteCenter.move(to: CGPoint(x: 45, y: envelopeCenterY))
            whiteCenter.addQuadCurve(to: CGPoint(x: centerX, y: 18), control: CGPoint(x: 45, y: 25))
            whiteCenter.addQuadCurve(to: CGPoint(x: 75, y: envelopeCenterY), control: CGPoint(x: 75, y: 25))
            whiteCenter.addQuadCurve(to: CGPoint(x: centerX, y: 82), control: CGPoint(x: 75, y: 72))
            whiteCenter.addQuadCurve(to: CGPoint(x: 45, y: envelopeCenterY), control: CGPoint(x: 45, y: 72))
            whiteCenter.closeSubpath()
            context.fill(whiteCenter, with: .linearGradient(
                Gradient(colors: [Color(hex: "d8d8d0"), Color(hex: "f5f5f0"), Color(hex: "d8d8d0")]),
                startPoint: CGPoint(x: 0, y: envelopeCenterY),
                endPoint: CGPoint(x: size.width, y: envelopeCenterY)
            ))

            // Reset clip for remaining elements
            context.clip(to: Path(CGRect(origin: .zero, size: size)))

            // Bottom opening - #4a3020
            let openingPath = Path(ellipseIn: CGRect(x: centerX - 12, y: 95, width: 24, height: 10))
            context.fill(openingPath, with: .color(Color(hex: "4a3020")))

            // Highlight on envelope
            let highlightPath = Path(ellipseIn: CGRect(x: 33, y: 17, width: 24, height: 36))
            context.fill(highlightPath, with: .color(Color.white.opacity(0.2)))

            // Ropes - #5a4030
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

            // Basket rim - #8a6040
            let rimRect = CGRect(x: 40, y: 138, width: 40, height: 5)
            context.fill(Path(roundedRect: rimRect, cornerRadius: 2), with: .color(Color(hex: "8a6040")))

            // Basket - gradient from #a08060 to #705030
            let basketRect = CGRect(x: 42, y: 140, width: 36, height: 25)
            context.fill(Path(roundedRect: basketRect, cornerRadius: 3), with: .linearGradient(
                Gradient(colors: [Color(hex: "a08060"), Color(hex: "705030")]),
                startPoint: CGPoint(x: 0, y: 140),
                endPoint: CGPoint(x: 0, y: 165)
            ))

            // Basket weave pattern - #5a4020 opacity 0.5
            let weaveColor = Color(hex: "5a4020").opacity(0.5)

            // Horizontal lines
            context.stroke(Path { p in
                p.move(to: CGPoint(x: 42, y: 148))
                p.addLine(to: CGPoint(x: 78, y: 148))
            }, with: .color(weaveColor), lineWidth: 0.5)

            context.stroke(Path { p in
                p.move(to: CGPoint(x: 42, y: 156))
                p.addLine(to: CGPoint(x: 78, y: 156))
            }, with: .color(weaveColor), lineWidth: 0.5)

            // Vertical lines
            for x in [50, 60, 70] as [CGFloat] {
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: x, y: 140))
                    p.addLine(to: CGPoint(x: x, y: 165))
                }, with: .color(weaveColor), lineWidth: 0.5)
            }

            // Flame (when active during inhale)
            if flameIntensity > 0 {
                // Flame flicker effect
                let flicker = 0.8 + (sin(timestamp / 50) * 0.2)

                // Outer flame - #ff9030
                let flameOuterRect = CGRect(
                    x: centerX - 6,
                    y: 118 - 12 * flicker,
                    width: 12,
                    height: 24 * flicker
                )
                context.fill(Path(ellipseIn: flameOuterRect), with: .color(Color(hex: "ff9030").opacity(Double(flameIntensity) * 0.9)))

                // Middle flame - #ffb050
                let flameMidRect = CGRect(
                    x: centerX - 4,
                    y: 115 - 8 * flicker,
                    width: 8,
                    height: 16 * flicker
                )
                context.fill(Path(ellipseIn: flameMidRect), with: .color(Color(hex: "ffb050").opacity(Double(flameIntensity) * 0.9)))

                // Inner flame - #ffe080
                let flameInnerRect = CGRect(
                    x: centerX - 2,
                    y: 112 - 5 * flicker,
                    width: 4,
                    height: 10 * flicker
                )
                context.fill(Path(ellipseIn: flameInnerRect), with: .color(Color(hex: "ffe080").opacity(Double(flameIntensity) * 0.9)))
            }
        }
    }
}

#Preview {
    BreatheHotairballoonView(duration: 3, onComplete: {}, onBack: {})
}
