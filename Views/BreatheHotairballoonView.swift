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

    @State private var startTime: Date?
    @State private var sceneOpacity: Double = 0
    @State private var hasCompleted: Bool = false

    private let cycleDuration: TimeInterval = 10.0
    private let riseHeight: CGFloat = 180

    private var totalDuration: Double {
        Double(duration * 60)
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = startTime.map { timeline.date.timeIntervalSince($0) } ?? 0
            let timestamp = elapsedTime * 1000
            let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
            let isInhaling = cycleProgress < 0.5

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
                        Text(formatTime(remaining: max(0, totalDuration - elapsedTime)))
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
                                .frame(width: max(0, (elapsedTime / totalDuration) * (geo.size.width - 90)), height: 3)
                        }
                        .padding(.horizontal, 45)
                        .padding(.bottom, 50)
                    }
                }
                .opacity(sceneOpacity)
            }
            .onChange(of: elapsedTime >= totalDuration) { _, completed in
                if completed && !hasCompleted {
                    hasCompleted = true
                    onComplete()
                }
            }
        }
        .onAppear {
            // Fade in animation matching HTML (1s ease, 0.3s delay)
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000)
                withAnimation(.easeOut(duration: 1.0)) {
                    sceneOpacity = 1.0
                }
            }
            // Start breathing animation after 1.2s (matching HTML)
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                startTime = Date()
            }
        }
    }

    private func formatTime(remaining: TimeInterval) -> String {
        let secs = Int(ceil(remaining))
        let minutes = secs / 60
        let seconds = secs % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - High Altitude Clouds (8% from top)

struct HotAirBalloonCloudsHighLayer: View {
    let timestamp: TimeInterval

    var body: some View {
        GeometryReader { geo in
            // Cloud H1 - left: 5%, width: 80px, height: 25px, 50s animation
            let drift1 = CGFloat(sin(timestamp / 50000 * .pi * 2) * 30)
            Ellipse()
                .fill(Color.white.opacity(0.4))
                .frame(width: 80, height: 25)
                .blur(radius: 15)
                .position(x: geo.size.width * 0.05 + 40 + drift1, y: geo.size.height * 0.08)

            // Cloud H2 - left: 60%, width: 100px, height: 30px, opacity: 0.3, 60s reverse
            let drift2 = CGFloat(-sin(timestamp / 60000 * .pi * 2) * 30)
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
            let drift1 = CGFloat((timestamp.truncatingRemainder(dividingBy: 45000)) / 45000 * 60)
            Ellipse()
                .fill(Color.white.opacity(0.35))
                .frame(width: 120, height: 35)
                .blur(radius: 15)
                .position(x: geo.size.width * -0.10 + 60 + drift1, y: geo.size.height * 0.25)

            // Cloud M2 - left: 50%, width: 90px, height: 28px, opacity: 0.25, 55s
            let drift2 = CGFloat(sin(timestamp / 55000 * .pi * 2) * 30)
            Ellipse()
                .fill(Color.white.opacity(0.25))
                .frame(width: 90, height: 28)
                .blur(radius: 15)
                .position(x: geo.size.width * 0.50 + 45 + drift2, y: geo.size.height * 0.25)

            // Cloud M3 - left: 80%, width: 70px, height: 22px, opacity: 0.3, 40s reverse
            let drift3 = CGFloat(-sin(timestamp / 40000 * .pi * 2) * 30)
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
        let verticalWave = CGFloat(cos(Double(cycleProgress) * .pi * 2))
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
        let verticalWave = CGFloat(cos(Double(cycleProgress) * .pi * 2))
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
        let verticalWave = CGFloat(cos(Double(cycleProgress) * .pi * 2))
        let verticalPos = (1 - verticalWave) / 2 * riseHeight
        let horizontalDrift = CGFloat(sin(Double(cycleProgress) * .pi * 2) * 15)

        // Micro floating oscillation
        let floatY = CGFloat(sin(timestamp / 1500) * 4)
        let floatX = CGFloat(cos(timestamp / 2000) * 3)

        // Basket sway
        let basketSway = CGFloat(sin(timestamp / 800) * 1.5)

        // Flame intensity - visible during INHALE (ascending)
        let flameIntensity: CGFloat = isInhaling ? easeInOutSine(min(1, cycleProgress * 2)) : 0

        // Balloon altitude for shadow
        let balloonAltitude = verticalPos / riseHeight

        ZStack {
            // Balloon shadow
            HotAirBalloonShadowView(balloonAltitude: balloonAltitude)
                .offset(y: 280)

            // Main balloon assembly
            VStack(spacing: 0) {
                // Balloon envelope (proper teardrop shape)
                HotAirBalloonEnvelopeOnly()
                    .frame(width: 130, height: 155)

                // Burner area with ropes and flame (between envelope and basket)
                HotAirBalloonBurnerView(flameIntensity: flameIntensity, timestamp: timestamp)
                    .frame(width: 60, height: 40)
                    .offset(y: -8)

                // Basket/Nacelle
                HotAirBalloonBasketView()
                    .frame(width: 55, height: 35)
                    .offset(y: -14)
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

// Balloon envelope only (without basket) - proper teardrop shape
struct HotAirBalloonEnvelopeOnly: View {
    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            // Envelope fills most of the canvas, with proper proportions
            let envelopeWidth = size.width * 0.88
            let envelopeHeight = size.height * 0.92
            let topY: CGFloat = size.height * 0.04  // Small margin at top

            // Create teardrop/balloon shape path
            func createEnvelopePath(widthFactor: CGFloat, heightFactor: CGFloat) -> Path {
                var path = Path()
                let w = envelopeWidth * widthFactor
                let h = envelopeHeight * heightFactor
                let cx = centerX
                let startY = topY + (envelopeHeight - h) / 2

                // Start at bottom center
                path.move(to: CGPoint(x: cx, y: startY + h))

                // Left side curve (bottom to top)
                path.addCurve(
                    to: CGPoint(x: cx, y: startY),
                    control1: CGPoint(x: cx - w * 0.55, y: startY + h * 0.85),
                    control2: CGPoint(x: cx - w * 0.5, y: startY + h * 0.15)
                )

                // Right side curve (top to bottom)
                path.addCurve(
                    to: CGPoint(x: cx, y: startY + h),
                    control1: CGPoint(x: cx + w * 0.5, y: startY + h * 0.15),
                    control2: CGPoint(x: cx + w * 0.55, y: startY + h * 0.85)
                )

                path.closeSubpath()
                return path
            }

            // Base white layer
            let basePath = createEnvelopePath(widthFactor: 1.0, heightFactor: 1.0)
            context.fill(basePath, with: .linearGradient(
                Gradient(colors: [Color(hex: "d8d8d0"), Color(hex: "f5f5f0"), Color(hex: "d8d8d0")]),
                startPoint: CGPoint(x: 0, y: size.height / 2),
                endPoint: CGPoint(x: size.width, y: size.height / 2)
            ))

            // Clip to base envelope
            context.clip(to: basePath)

            // Red stripe (outermost colored band)
            let redPath = createEnvelopePath(widthFactor: 0.92, heightFactor: 0.95)
            context.fill(redPath, with: .linearGradient(
                Gradient(colors: [Color(hex: "c44a40"), Color(hex: "e85a50"), Color(hex: "c44a40")]),
                startPoint: CGPoint(x: 0, y: size.height / 2),
                endPoint: CGPoint(x: size.width, y: size.height / 2)
            ))

            // Orange stripe
            let orangePath = createEnvelopePath(widthFactor: 0.75, heightFactor: 0.88)
            context.fill(orangePath, with: .linearGradient(
                Gradient(colors: [Color(hex: "d4854a"), Color(hex: "f0a060"), Color(hex: "d4854a")]),
                startPoint: CGPoint(x: 0, y: size.height / 2),
                endPoint: CGPoint(x: size.width, y: size.height / 2)
            ))

            // Yellow stripe
            let yellowPath = createEnvelopePath(widthFactor: 0.58, heightFactor: 0.80)
            context.fill(yellowPath, with: .linearGradient(
                Gradient(colors: [Color(hex: "c4a44a"), Color(hex: "e8c860"), Color(hex: "c4a44a")]),
                startPoint: CGPoint(x: 0, y: size.height / 2),
                endPoint: CGPoint(x: size.width, y: size.height / 2)
            ))

            // White/cream center
            let whitePath = createEnvelopePath(widthFactor: 0.38, heightFactor: 0.70)
            context.fill(whitePath, with: .linearGradient(
                Gradient(colors: [Color(hex: "e8e8e0"), Color(hex: "fffff8"), Color(hex: "e8e8e0")]),
                startPoint: CGPoint(x: 0, y: size.height / 2),
                endPoint: CGPoint(x: size.width, y: size.height / 2)
            ))

            // Highlight on envelope (top-left)
            let highlightPath = Path(ellipseIn: CGRect(
                x: size.width * 0.22,
                y: size.height * 0.08,
                width: size.width * 0.22,
                height: size.height * 0.28
            ))
            context.fill(highlightPath, with: .color(Color.white.opacity(0.3)))
        }
    }
}

// Burner frame with ropes and flame
struct HotAirBalloonBurnerView: View {
    let flameIntensity: CGFloat
    let timestamp: TimeInterval

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let ropeColor = Color(hex: "6a5040")

            // Left outer rope
            var rope1 = Path()
            rope1.move(to: CGPoint(x: centerX - 18, y: 0))
            rope1.addLine(to: CGPoint(x: centerX - 22, y: size.height))
            context.stroke(rope1, with: .color(ropeColor), lineWidth: 1.5)

            // Left inner rope
            var rope2 = Path()
            rope2.move(to: CGPoint(x: centerX - 8, y: 0))
            rope2.addLine(to: CGPoint(x: centerX - 10, y: size.height))
            context.stroke(rope2, with: .color(ropeColor), lineWidth: 1.5)

            // Right inner rope
            var rope3 = Path()
            rope3.move(to: CGPoint(x: centerX + 8, y: 0))
            rope3.addLine(to: CGPoint(x: centerX + 10, y: size.height))
            context.stroke(rope3, with: .color(ropeColor), lineWidth: 1.5)

            // Right outer rope
            var rope4 = Path()
            rope4.move(to: CGPoint(x: centerX + 18, y: 0))
            rope4.addLine(to: CGPoint(x: centerX + 22, y: size.height))
            context.stroke(rope4, with: .color(ropeColor), lineWidth: 1.5)

            // Burner frame (horizontal bar at top)
            let burnerFrameColor = Color(hex: "5a4a3a")
            let frameRect = CGRect(x: centerX - 20, y: 2, width: 40, height: 6)
            context.fill(Path(roundedRect: frameRect, cornerRadius: 2), with: .color(burnerFrameColor))

            // Flame (when active) - positioned in center of burner area
            if flameIntensity > 0 {
                let flicker = CGFloat(0.85 + sin(timestamp / 40) * 0.15)
                let baseFlameHeight: CGFloat = 28
                let flameHeight = baseFlameHeight * flicker * flameIntensity
                let flameWidth: CGFloat = 14 * flameIntensity

                let flameY = size.height * 0.25 // Position flame in upper portion of burner area

                // Outer flame glow (red-orange)
                let outerGlowPath = Path(ellipseIn: CGRect(
                    x: centerX - flameWidth * 0.8,
                    y: flameY - flameHeight * 0.3,
                    width: flameWidth * 1.6,
                    height: flameHeight * 1.2
                ))
                context.fill(outerGlowPath, with: .color(Color(hex: "ff4020").opacity(Double(flameIntensity) * 0.5)))

                // Middle flame (orange)
                let middleFlamePath = Path(ellipseIn: CGRect(
                    x: centerX - flameWidth * 0.55,
                    y: flameY - flameHeight * 0.15,
                    width: flameWidth * 1.1,
                    height: flameHeight * 0.9
                ))
                context.fill(middleFlamePath, with: .color(Color(hex: "ff8030").opacity(Double(flameIntensity) * 0.8)))

                // Inner flame (yellow-white, brightest)
                let innerFlamePath = Path(ellipseIn: CGRect(
                    x: centerX - flameWidth * 0.3,
                    y: flameY,
                    width: flameWidth * 0.6,
                    height: flameHeight * 0.6
                ))
                context.fill(innerFlamePath, with: .color(Color(hex: "ffdd60").opacity(Double(flameIntensity) * 0.95)))

                // Core (white hot)
                let corePath = Path(ellipseIn: CGRect(
                    x: centerX - flameWidth * 0.15,
                    y: flameY + flameHeight * 0.15,
                    width: flameWidth * 0.3,
                    height: flameHeight * 0.35
                ))
                context.fill(corePath, with: .color(Color(hex: "ffffee").opacity(Double(flameIntensity) * 0.9)))
            }
        }
    }
}

// Ropes connecting envelope to basket (simple version without flame)
struct HotAirBalloonRopesView: View {
    var body: some View {
        Canvas { context, size in
            let ropeColor = Color(hex: "6a5040")
            let centerX = size.width / 2

            // Left outer rope
            var rope1 = Path()
            rope1.move(to: CGPoint(x: centerX - 12, y: 0))
            rope1.addLine(to: CGPoint(x: centerX - 22, y: size.height))
            context.stroke(rope1, with: .color(ropeColor), lineWidth: 1.5)

            // Left inner rope
            var rope2 = Path()
            rope2.move(to: CGPoint(x: centerX - 5, y: 0))
            rope2.addLine(to: CGPoint(x: centerX - 10, y: size.height))
            context.stroke(rope2, with: .color(ropeColor), lineWidth: 1.5)

            // Right inner rope
            var rope3 = Path()
            rope3.move(to: CGPoint(x: centerX + 5, y: 0))
            rope3.addLine(to: CGPoint(x: centerX + 10, y: size.height))
            context.stroke(rope3, with: .color(ropeColor), lineWidth: 1.5)

            // Right outer rope
            var rope4 = Path()
            rope4.move(to: CGPoint(x: centerX + 12, y: 0))
            rope4.addLine(to: CGPoint(x: centerX + 22, y: size.height))
            context.stroke(rope4, with: .color(ropeColor), lineWidth: 1.5)
        }
    }
}

// Basket/Nacelle view
struct HotAirBalloonBasketView: View {
    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let basketWidth = size.width * 0.85
            let basketHeight = size.height * 0.70

            // Basket rim (top edge)
            let rimRect = CGRect(
                x: centerX - basketWidth / 2 - 2,
                y: 0,
                width: basketWidth + 4,
                height: size.height * 0.18
            )
            context.fill(Path(roundedRect: rimRect, cornerRadius: 2), with: .color(Color(hex: "9a7050")))

            // Main basket body
            let basketRect = CGRect(
                x: centerX - basketWidth / 2,
                y: size.height * 0.12,
                width: basketWidth,
                height: basketHeight
            )
            context.fill(Path(roundedRect: basketRect, cornerRadius: 4), with: .linearGradient(
                Gradient(colors: [Color(hex: "a08060"), Color(hex: "806040"), Color(hex: "604830")]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Basket weave pattern - horizontal lines
            let weaveColor = Color(hex: "5a4020").opacity(0.6)
            let basketLeft = centerX - basketWidth / 2
            let basketRight = centerX + basketWidth / 2
            let basketTop = size.height * 0.12

            for i in 1...3 {
                let y = basketTop + CGFloat(i) * basketHeight / 4
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: basketLeft + 2, y: y))
                    p.addLine(to: CGPoint(x: basketRight - 2, y: y))
                }, with: .color(weaveColor), lineWidth: 1)
            }

            // Vertical weave lines
            let numVertical = 5
            let spacing = basketWidth / CGFloat(numVertical + 1)
            for i in 1...numVertical {
                let x = basketLeft + CGFloat(i) * spacing
                context.stroke(Path { p in
                    p.move(to: CGPoint(x: x, y: basketTop + 2))
                    p.addLine(to: CGPoint(x: x, y: basketTop + basketHeight - 2))
                }, with: .color(weaveColor), lineWidth: 1)
            }

            // Basket bottom edge (darker)
            let bottomRect = CGRect(
                x: centerX - basketWidth / 2 + 2,
                y: basketTop + basketHeight - 4,
                width: basketWidth - 4,
                height: 4
            )
            context.fill(Path(roundedRect: bottomRect, cornerRadius: 2), with: .color(Color(hex: "4a3020")))
        }
    }
}

#Preview {
    BreatheHotairballoonView(duration: 3, onComplete: {}, onBack: {})
}
