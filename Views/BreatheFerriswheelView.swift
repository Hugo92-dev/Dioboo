//
//  BreatheFerriswheelView.swift
//  Dioboo
//
//  Ferris Wheel (London Eye) breathing experience - matches breatheferriswheel.html exactly
//

import SwiftUI

struct BreatheFerriswheelView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var cycleProgress: CGFloat = 0
    @State private var totalElapsed: TimeInterval = 0
    @State private var animationTimer: Timer?
    @State private var startTime: Date?
    @State private var isComplete: Bool = false

    private let inhaleDuration: TimeInterval = 5.0
    private let exhaleDuration: TimeInterval = 5.0
    private var cycleDuration: TimeInterval { inhaleDuration + exhaleDuration }
    private var totalDuration: TimeInterval { TimeInterval(duration) * 60.0 }

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            ZStack {
                // Night sky gradient - exact from HTML
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "070A14"), location: 0.0),
                        .init(color: Color(hex: "0a0e1a"), location: 0.20),
                        .init(color: Color(hex: "0d1322"), location: 0.40),
                        .init(color: Color(hex: "101828"), location: 0.55),
                        .init(color: Color(hex: "141e32"), location: 0.70),
                        .init(color: Color(hex: "182440"), location: 0.85),
                        .init(color: Color(hex: "1a2844"), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Stars layer (top 55% of screen)
                FerrisStarsView(screenWidth: screenWidth, screenHeight: screenHeight)

                // Moon
                FerrisMoonView()
                    .position(x: screenWidth - 60, y: 95)

                // Clouds
                FerrisCloudsView()
                    .frame(width: screenWidth, height: screenHeight * 0.45)
                    .position(x: screenWidth / 2, y: screenHeight * 0.225)

                // City far layer (bottom: 22%, height: 20%, opacity: 0.4)
                FerrisCityFarView(scale: screenWidth / 351)
                    .frame(width: screenWidth, height: screenHeight * 0.20)
                    .position(x: screenWidth / 2, y: screenHeight * 0.68)
                    .opacity(0.4)

                // City mid layer with Big Ben (bottom: 20%, height: 22%, opacity: 0.7)
                FerrisCityMidView(scale: screenWidth / 351)
                    .frame(width: screenWidth, height: screenHeight * 0.22)
                    .position(x: screenWidth / 2, y: screenHeight * 0.69)
                    .opacity(0.7)

                // City front layer (bottom: 18%, height: 18%)
                FerrisCityFrontView(scale: screenWidth / 351)
                    .frame(width: screenWidth, height: screenHeight * 0.18)
                    .position(x: screenWidth / 2, y: screenHeight * 0.73)

                // Bridge (bottom: 17%, height: 12%)
                FerrisBridgeView(scale: screenWidth / 351)
                    .frame(width: screenWidth, height: screenHeight * 0.12)
                    .position(x: screenWidth / 2, y: screenHeight * 0.77)

                // Mist layer
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.clear, location: 0.0),
                                .init(color: Color(hex: "0f1630").opacity(0.3), location: 0.5),
                                .init(color: Color(hex: "0f1630").opacity(0.5), location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: screenWidth, height: screenHeight * 0.25)
                    .position(x: screenWidth / 2, y: screenHeight * 0.695)
                    .allowsHitTesting(false)

                // Embankment
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1a2030"), Color(hex: "141820")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: screenWidth, height: screenHeight * 0.04)
                    .position(x: screenWidth / 2, y: screenHeight * 0.81)

                // Embankment line
                Rectangle()
                    .fill(Color(hex: "2a3040"))
                    .frame(width: screenWidth, height: 2)
                    .position(x: screenWidth / 2, y: screenHeight * 0.79)

                // Lampposts
                FerrisLamppostsView(scale: screenWidth / 351)
                    .position(x: screenWidth / 2, y: screenHeight * 0.785)

                // Wheel glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "86A6FF").opacity(0.1),
                                Color(hex: "C6A6FF").opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .position(x: screenWidth / 2, y: screenHeight * 0.60)

                // Water (Thames) - bottom 18%
                FerrisWaterView(screenWidth: screenWidth, screenHeight: screenHeight)

                // Water surface line
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.clear, location: 0.0),
                                .init(color: Color(hex: "86A6FF").opacity(0.15), location: 0.2),
                                .init(color: Color(hex: "86A6FF").opacity(0.25), location: 0.5),
                                .init(color: Color(hex: "86A6FF").opacity(0.15), location: 0.8),
                                .init(color: Color.clear, location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: screenWidth, height: 3)
                    .position(x: screenWidth / 2, y: screenHeight * 0.822)

                // Moon reflection on water
                FerrisMoonReflectionView(screenWidth: screenWidth, screenHeight: screenHeight)

                // Boats
                FerrisBoatsView(screenWidth: screenWidth, screenHeight: screenHeight)

                // London Eye wheel
                FerrisWheelView()
                    .frame(width: 280, height: 280)
                    .position(x: screenWidth / 2, y: screenHeight * 0.60)

                // Capsule and its reflection
                FerrisCapsuleAnimatedView(
                    cycleProgress: cycleProgress,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )

                // UI Overlay
                VStack(spacing: 0) {
                    // Back button
                    HStack {
                        Button(action: onBack) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "0f1630").opacity(0.8))
                                    .frame(width: 42, height: 42)

                                Circle()
                                    .stroke(Color(hex: "1A2552"), lineWidth: 1)
                                    .frame(width: 42, height: 42)

                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color(hex: "B8C0E6"))
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()

                    // Phase text
                    Text(isInhaling ? "INHALE" : "EXHALE")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(Color(hex: "F5F7FF"))
                        .tracking(6)
                        .opacity(0.9)
                        .padding(.bottom, 8)

                    // Timer text
                    Text(formatTime(remaining: max(0, totalDuration - totalElapsed)))
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(Color(hex: "B8C0E6"))
                        .padding(.bottom, 16)

                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "1A2552"))
                            .frame(height: 3)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "86A6FF"))
                            .frame(width: (screenWidth - 90) * CGFloat(totalElapsed / totalDuration), height: 3)
                    }
                    .frame(width: screenWidth - 90)
                    .padding(.bottom, 50)
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

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            guard let start = startTime else { return }
            let elapsed = Date().timeIntervalSince(start)
            totalElapsed = elapsed

            if elapsed >= totalDuration && !isComplete {
                isComplete = true
                animationTimer?.invalidate()
                onComplete()
                return
            }

            let cycleTime = elapsed.truncatingRemainder(dividingBy: cycleDuration)
            cycleProgress = cycleTime / cycleDuration
            isInhaling = cycleProgress < 0.5
        }
    }

    private func formatTime(remaining: TimeInterval) -> String {
        let totalSeconds = Int(ceil(remaining))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Stars View

struct FerrisStarsView: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var starData: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double, isBright: Bool)] = []
    @State private var twinklePhases: [Double] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for (index, star) in starData.enumerated() {
                    let baseOpacity = star.opacity
                    var finalOpacity = baseOpacity

                    // Twinkling animation for bright stars
                    if star.isBright && index < twinklePhases.count {
                        let phase = twinklePhases[index]
                        let twinkle = sin(time * 2 + phase) * 0.3 + 0.7
                        finalOpacity = baseOpacity * twinkle
                    }

                    let starPath = Path(ellipseIn: CGRect(
                        x: star.x - star.size / 2,
                        y: star.y - star.size / 2,
                        width: star.size,
                        height: star.size
                    ))

                    context.fill(starPath, with: .color(Color(hex: "F5F7FF").opacity(finalOpacity)))

                    // Glow for bright stars
                    if star.isBright {
                        let glowPath = Path(ellipseIn: CGRect(
                            x: star.x - star.size,
                            y: star.y - star.size,
                            width: star.size * 2,
                            height: star.size * 2
                        ))
                        context.fill(glowPath, with: .color(Color(hex: "F5F7FF").opacity(finalOpacity * 0.3)))
                    }
                }
            }
        }
        .onAppear {
            generateStars()
        }
    }

    private func generateStars() {
        var stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double, isBright: Bool)] = []
        var phases: [Double] = []

        // Regular stars (40)
        for _ in 0..<40 {
            let x = CGFloat.random(in: 0...screenWidth)
            let y = CGFloat.random(in: 0...(screenHeight * 0.55))
            let size = CGFloat.random(in: 1...2.5)
            let opacity = Double.random(in: 0.2...0.5)
            stars.append((x: x, y: y, size: size, opacity: opacity, isBright: false))
            phases.append(Double.random(in: 0...(.pi * 2)))
        }

        // Bright stars (4)
        for _ in 0..<4 {
            let x = CGFloat.random(in: (screenWidth * 0.1)...(screenWidth * 0.9))
            let y = CGFloat.random(in: (screenHeight * 0.05)...(screenHeight * 0.40))
            stars.append((x: x, y: y, size: 2.5, opacity: 0.7, isBright: true))
            phases.append(Double.random(in: 0...(.pi * 2)))
        }

        starData = stars
        twinklePhases = phases
    }
}

// MARK: - Moon View

struct FerrisMoonView: View {
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color(hex: "f5f5f0").opacity(0.08))
                .frame(width: 95, height: 95)
                .blur(radius: 20)

            // Middle glow
            Circle()
                .fill(Color(hex: "f5f5f0").opacity(0.15))
                .frame(width: 55, height: 55)
                .blur(radius: 10)

            // Moon body
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: Color(hex: "f5f5f0"), location: 0.0),
                            .init(color: Color(hex: "e8e8e0"), location: 0.5),
                            .init(color: Color(hex: "d0d0c8"), location: 1.0)
                        ],
                        center: .init(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 17
                    )
                )
                .frame(width: 35, height: 35)
                .shadow(color: Color(hex: "f5f5f0").opacity(0.3), radius: 10)
                .shadow(color: Color(hex: "f5f5f0").opacity(0.15), radius: 20)
                .shadow(color: Color(hex: "f5f5f0").opacity(0.08), radius: 30)

            // Crater
            Circle()
                .fill(Color(hex: "b4b4aa").opacity(0.3))
                .frame(width: 8, height: 8)
                .offset(x: -3, y: -8)
        }
    }
}

// MARK: - Clouds View

struct FerrisCloudsView: View {
    @State private var cloud1Offset: CGFloat = -200
    @State private var cloud2Offset: CGFloat = -200
    @State private var cloud3Offset: CGFloat = -200

    var body: some View {
        GeometryReader { geo in
            // Cloud 1
            Ellipse()
                .fill(Color(hex: "86A6FF").opacity(0.03))
                .frame(width: 150, height: 50)
                .blur(radius: 25)
                .offset(x: cloud1Offset, y: 60)

            // Cloud 2
            Ellipse()
                .fill(Color(hex: "86A6FF").opacity(0.03))
                .frame(width: 180, height: 60)
                .blur(radius: 25)
                .offset(x: cloud2Offset, y: 120)

            // Cloud 3
            Ellipse()
                .fill(Color(hex: "86A6FF").opacity(0.03))
                .frame(width: 120, height: 45)
                .blur(radius: 25)
                .offset(x: cloud3Offset, y: 90)
        }
        .onAppear {
            withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                cloud1Offset = 600
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 150).repeatForever(autoreverses: false)) {
                    cloud2Offset = 600
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                    cloud3Offset = 600
                }
            }
        }
    }
}

// MARK: - City Far Layer

struct FerrisCityFarView: View {
    let scale: CGFloat

    var body: some View {
        Canvas { context, size in
            let buildings: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
                (-10, 100, 30, 60),
                (25, 80, 25, 80),
                (55, 110, 20, 50),
                (80, 70, 22, 90),
                (110, 95, 35, 65),
                (150, 60, 18, 100),
                (175, 85, 28, 75),
                (210, 105, 22, 55),
                (238, 75, 20, 85),
                (265, 90, 30, 70),
                (300, 100, 25, 60),
                (330, 85, 30, 75)
            ]

            let color = Color(hex: "0c1018")

            for b in buildings {
                let rect = CGRect(
                    x: b.x * scale,
                    y: b.y * scale,
                    width: b.w * scale,
                    height: b.h * scale
                )
                context.fill(Path(rect), with: .color(color))
            }
        }
    }
}

// MARK: - City Mid Layer with Big Ben

struct FerrisCityMidView: View {
    let scale: CGFloat

    @State private var windowFlicker: Double = 0.4

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.5)) { timeline in
            Canvas { context, size in
                let buildingColor = Color(hex: "0a0e16")

                // Regular buildings
                let buildings: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
                    (0, 120, 28, 55),
                    (32, 95, 35, 80),
                    (72, 115, 22, 60),
                    (120, 100, 40, 75),
                    (225, 105, 30, 70),
                    (260, 120, 25, 55),
                    (290, 100, 32, 75),
                    (327, 110, 30, 65)
                ]

                for b in buildings {
                    let rect = CGRect(x: b.x * scale, y: b.y * scale, width: b.w * scale, height: b.h * scale)
                    context.fill(Path(rect), with: .color(buildingColor))
                }

                // Big Ben
                context.fill(Path(CGRect(x: 98 * scale, y: 40 * scale, width: 18 * scale, height: 135 * scale)), with: .color(buildingColor))
                context.fill(Path(CGRect(x: 94 * scale, y: 35 * scale, width: 26 * scale, height: 10 * scale)), with: .color(buildingColor))

                // Big Ben spire
                var spire = Path()
                spire.move(to: CGPoint(x: 107 * scale, y: 35 * scale))
                spire.addLine(to: CGPoint(x: 100 * scale, y: 20 * scale))
                spire.addLine(to: CGPoint(x: 114 * scale, y: 20 * scale))
                spire.closeSubpath()
                context.fill(spire, with: .color(buildingColor))

                // Parliament
                context.fill(Path(CGRect(x: 165 * scale, y: 85 * scale, width: 55 * scale, height: 90 * scale)), with: .color(buildingColor))
                context.fill(Path(CGRect(x: 170 * scale, y: 80 * scale, width: 8 * scale, height: 10 * scale)), with: .color(buildingColor))
                context.fill(Path(CGRect(x: 190 * scale, y: 75 * scale, width: 8 * scale, height: 15 * scale)), with: .color(buildingColor))
                context.fill(Path(CGRect(x: 207 * scale, y: 80 * scale, width: 8 * scale, height: 10 * scale)), with: .color(buildingColor))

                // Window lights - warm yellow with flickering
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Yellow lights group 1
                let windows1: [(x: CGFloat, y: CGFloat)] = [
                    (40, 105), (50, 120), (103, 60), (103, 80), (130, 115),
                    (145, 130), (180, 100), (195, 110), (235, 120), (300, 115), (310, 130)
                ]
                let flicker1 = 0.3 + 0.3 * sin(time * 0.3)
                for pos in windows1 {
                    let rect = CGRect(x: pos.x * scale, y: pos.y * scale, width: 2 * scale, height: 3 * scale)
                    context.fill(Path(rect), with: .color(Color(hex: "ffd54f").opacity(flicker1)))
                }

                // Yellow lights group 2
                let windows2: [(x: CGFloat, y: CGFloat)] = [
                    (36, 115), (55, 108), (125, 125), (138, 115),
                    (185, 115), (240, 112), (295, 125), (305, 108)
                ]
                let flicker2 = 0.3 + 0.3 * sin(time * 0.3 + 2)
                for pos in windows2 {
                    let rect = CGRect(x: pos.x * scale, y: pos.y * scale, width: 2 * scale, height: 3 * scale)
                    context.fill(Path(rect), with: .color(Color(hex: "ffca28").opacity(flicker2)))
                }

                // Orange lights
                let windows3: [(x: CGFloat, y: CGFloat)] = [
                    (45, 130), (175, 120), (205, 95), (270, 135)
                ]
                let flicker3 = 0.3 + 0.2 * sin(time * 0.3 + 3)
                for pos in windows3 {
                    let rect = CGRect(x: pos.x * scale, y: pos.y * scale, width: 2 * scale, height: 3 * scale)
                    context.fill(Path(rect), with: .color(Color(hex: "ffb300").opacity(flicker3)))
                }

                // Cream lights
                let windows4: [(x: CGFloat, y: CGFloat)] = [
                    (103, 70), (190, 95), (250, 125)
                ]
                let flicker4 = 0.3 + 0.2 * sin(time * 0.3 + 5)
                for pos in windows4 {
                    let rect = CGRect(x: pos.x * scale, y: pos.y * scale, width: 2 * scale, height: 3 * scale)
                    context.fill(Path(rect), with: .color(Color(hex: "ffe082").opacity(flicker4)))
                }
            }
        }
    }
}

// MARK: - City Front Layer

struct FerrisCityFrontView: View {
    let scale: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.5)) { timeline in
            Canvas { context, size in
                let color = Color(hex: "080c12")

                let buildings: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
                    (-5, 100, 35, 45),
                    (35, 85, 28, 60),
                    (68, 105, 20, 40),
                    (280, 90, 25, 55),
                    (310, 100, 22, 45),
                    (337, 80, 20, 65)
                ]

                for b in buildings {
                    let rect = CGRect(x: b.x * scale, y: b.y * scale, width: b.w * scale, height: b.h * scale)
                    context.fill(Path(rect), with: .color(color))
                }

                let time = timeline.date.timeIntervalSinceReferenceDate

                // Window lights group 1
                let windows1: [(x: CGFloat, y: CGFloat)] = [
                    (8, 110), (18, 125), (45, 95), (290, 105), (320, 115)
                ]
                let flicker1 = 0.3 + 0.3 * sin(time * 0.3 + 5)
                for pos in windows1 {
                    let rect = CGRect(x: pos.x * scale, y: pos.y * scale, width: 2 * scale, height: 3 * scale)
                    context.fill(Path(rect), with: .color(Color(hex: "ffd54f").opacity(flicker1)))
                }

                // Window lights group 2
                let windows2: [(x: CGFloat, y: CGFloat)] = [
                    (12, 118), (50, 108), (295, 115), (345, 95)
                ]
                let flicker2 = 0.3 + 0.3 * sin(time * 0.3 + 7)
                for pos in windows2 {
                    let rect = CGRect(x: pos.x * scale, y: pos.y * scale, width: 2 * scale, height: 3 * scale)
                    context.fill(Path(rect), with: .color(Color(hex: "ffca28").opacity(flicker2)))
                }
            }
        }
    }
}

// MARK: - Bridge View

struct FerrisBridgeView: View {
    let scale: CGFloat

    var body: some View {
        Canvas { context, size in
            let bridgeColor = Color(hex: "0c1018")

            // Main deck
            context.fill(
                Path(CGRect(x: 0, y: 70 * scale, width: 351 * scale, height: 25 * scale)),
                with: .color(bridgeColor)
            )

            // Arches
            let archPositions: [(start: CGFloat, mid: CGFloat, end: CGFloat)] = [
                (0, 44, 88),
                (88, 132, 176),
                (176, 220, 264),
                (264, 308, 351)
            ]

            for arch in archPositions {
                var archPath = Path()
                archPath.move(to: CGPoint(x: arch.start * scale, y: 70 * scale))
                archPath.addQuadCurve(
                    to: CGPoint(x: arch.end * scale, y: 70 * scale),
                    control: CGPoint(x: arch.mid * scale, y: 45 * scale)
                )
                context.stroke(archPath, with: .color(bridgeColor), lineWidth: 8 * scale)
            }

            // Pillars
            context.fill(Path(CGRect(x: 83 * scale, y: 55 * scale, width: 10 * scale, height: 40 * scale)), with: .color(bridgeColor))
            context.fill(Path(CGRect(x: 171 * scale, y: 55 * scale, width: 10 * scale, height: 40 * scale)), with: .color(bridgeColor))
            context.fill(Path(CGRect(x: 259 * scale, y: 55 * scale, width: 10 * scale, height: 40 * scale)), with: .color(bridgeColor))

            // Bridge lights
            let lightPositions: [CGFloat] = [44, 132, 220, 308]
            for x in lightPositions {
                let lightPath = Path(ellipseIn: CGRect(x: (x - 2) * scale, y: 66 * scale, width: 4 * scale, height: 4 * scale))
                context.fill(lightPath, with: .color(Color(hex: "ffeecc").opacity(0.7)))
            }

            // Railing lights
            let railingPositions: [CGFloat] = [20, 60, 100, 140, 180, 220, 260, 300, 340]
            for x in railingPositions {
                let lightPath = Path(ellipseIn: CGRect(x: (x - 1.5) * scale, y: 68.5 * scale, width: 3 * scale, height: 3 * scale))
                context.fill(lightPath, with: .color(Color(hex: "ffeedd").opacity(0.5)))
            }
        }
    }
}

// MARK: - Lampposts View

struct FerrisLamppostsView: View {
    let scale: CGFloat

    var body: some View {
        let positions: [CGFloat] = [35, 95, 255, 315]

        Canvas { context, size in
            for x in positions {
                // Light glow
                let glowPath = Path(ellipseIn: CGRect(x: (x - 4) * scale, y: -3 * scale, width: 8 * scale, height: 8 * scale))
                context.fill(glowPath, with: .color(Color(hex: "ffeecc").opacity(0.3)))

                // Light
                let lightPath = Path(ellipseIn: CGRect(x: (x - 3) * scale, y: 0, width: 6 * scale, height: 6 * scale))
                let lightCenterX = (x - 3) * scale + 3 * scale
                let lightCenterY = 3 * scale
                context.fill(lightPath, with: .radialGradient(
                    Gradient(colors: [Color(hex: "ffeecc"), Color(hex: "ffdd99"), Color.clear]),
                    center: CGPoint(x: lightCenterX, y: lightCenterY),
                    startRadius: 0,
                    endRadius: 3 * scale
                ))

                // Pole
                context.fill(
                    Path(CGRect(x: (x - 1) * scale, y: 6 * scale, width: 2 * scale, height: 25 * scale)),
                    with: .color(
                        LinearGradient(
                            colors: [Color(hex: "3a4050"), Color(hex: "2a3040")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
            }
        }
        .frame(width: 351 * scale, height: 35 * scale)
    }
}

// MARK: - Water View

struct FerrisWaterView: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "0a1018"), location: 0.0),
                        .init(color: Color(hex: "0c1420"), location: 0.20),
                        .init(color: Color(hex: "0a1018"), location: 0.40),
                        .init(color: Color(hex: "081015"), location: 0.60),
                        .init(color: Color(hex: "060c12"), location: 0.80),
                        .init(color: Color(hex: "050a10"), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: screenWidth, height: screenHeight * 0.18)
            .position(x: screenWidth / 2, y: screenHeight * 0.91)
    }
}

// MARK: - Moon Reflection View

struct FerrisMoonReflectionView: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "f5f5f0").opacity(0.25), location: 0.0),
                        .init(color: Color(hex: "f5f5f0").opacity(0.15), location: 0.20),
                        .init(color: Color(hex: "f5f5f0").opacity(0.08), location: 0.50),
                        .init(color: Color(hex: "f5f5f0").opacity(0.03), location: 0.80),
                        .init(color: Color.clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 20 * (1 + shimmerPhase * 0.2), height: screenHeight * 0.17)
            .opacity(0.8 - shimmerPhase * 0.1)
            .position(x: screenWidth - 60, y: screenHeight * 0.905)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    shimmerPhase = 1
                }
            }
    }
}

// MARK: - Boats View

struct FerrisBoatsView: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var boat1X: CGFloat = -50
    @State private var boat2X: CGFloat = 450

    var body: some View {
        ZStack {
            // Boat 1 - drifts left to right
            FerrisBoatView()
                .frame(width: 80, height: 25)
                .position(x: boat1X, y: screenHeight * 0.92)

            // Boat 2 - drifts right to left (reversed)
            FerrisBoatView()
                .frame(width: 65, height: 20)
                .scaleEffect(x: -1)
                .position(x: boat2X, y: screenHeight * 0.95)
        }
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                boat1X = screenWidth + 100
            }
            withAnimation(.linear(duration: 90).repeatForever(autoreverses: false)) {
                boat2X = -100
            }
        }
    }
}

struct FerrisBoatView: View {
    var body: some View {
        Canvas { context, size in
            let scaleX = size.width / 80
            let scaleY = size.height / 25

            // Light trail on water
            context.fill(
                Path(ellipseIn: CGRect(x: 3 * scaleX, y: 17 * scaleY, width: 24 * scaleX, height: 6 * scaleY)),
                with: .color(Color(hex: "ffeecc").opacity(0.15))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: 13 * scaleX, y: 16 * scaleY, width: 16 * scaleX, height: 4 * scaleY)),
                with: .color(Color(hex: "ffeecc").opacity(0.1))
            )

            // Hull
            var hullPath = Path()
            hullPath.move(to: CGPoint(x: 40 * scaleX, y: 12 * scaleY))
            hullPath.addLine(to: CGPoint(x: 45 * scaleX, y: 18 * scaleY))
            hullPath.addLine(to: CGPoint(x: 70 * scaleX, y: 18 * scaleY))
            hullPath.addLine(to: CGPoint(x: 75 * scaleX, y: 12 * scaleY))
            hullPath.closeSubpath()
            context.fill(hullPath, with: .color(Color(hex: "1a1a2a")))

            // Cabin
            let cabinRect = CGRect(x: 50 * scaleX, y: 5 * scaleY, width: 15 * scaleX, height: 8 * scaleY)
            context.fill(Path(roundedRect: cabinRect, cornerRadius: 1), with: .color(Color(hex: "1a1a2a")))

            // Windows with warm light
            context.fill(
                Path(CGRect(x: 52 * scaleX, y: 7 * scaleY, width: 4 * scaleX, height: 4 * scaleY)),
                with: .color(Color(hex: "ffdd99").opacity(0.8))
            )
            context.fill(
                Path(CGRect(x: 59 * scaleX, y: 7 * scaleY, width: 4 * scaleX, height: 4 * scaleY)),
                with: .color(Color(hex: "ffeeaa").opacity(0.7))
            )

            // Front light
            context.fill(
                Path(ellipseIn: CGRect(x: 71 * scaleX, y: 8 * scaleY, width: 4 * scaleX, height: 4 * scaleY)),
                with: .color(Color(hex: "ffeecc").opacity(0.9))
            )

            // Back light (red)
            context.fill(
                Path(ellipseIn: CGRect(x: 41.5 * scaleX, y: 8.5 * scaleY, width: 3 * scaleX, height: 3 * scaleY)),
                with: .color(Color(hex: "ff6666").opacity(0.7))
            )

            // Light reflection on water
            context.fill(
                Path(ellipseIn: CGRect(x: 67 * scaleX, y: 20 * scaleY, width: 12 * scaleX, height: 4 * scaleY)),
                with: .color(Color(hex: "ffeecc").opacity(0.25))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: 45 * scaleX, y: 20 * scaleY, width: 20 * scaleX, height: 4 * scaleY)),
                with: .color(Color(hex: "ffdd99").opacity(0.15))
            )
        }
    }
}

// MARK: - London Eye Wheel View

struct FerrisWheelView: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 130

            // Main wheel rim (outer)
            var rimPath = Path()
            rimPath.addArc(center: center, radius: radius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(rimPath, with: .color(Color(hex: "4a5a7a")), lineWidth: 5)

            // Inner rim line
            var innerRimPath = Path()
            innerRimPath.addArc(center: center, radius: 125, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(innerRimPath, with: .color(Color(hex: "3a4a6a")), lineWidth: 2)

            // 16 Spokes - matching HTML exactly
            let spokeAngles: [Double] = [
                90, 112.5, 135, 157.5, 180, 202.5, 225, 247.5,
                270, 292.5, 315, 337.5, 0, 22.5, 45, 67.5
            ]

            for angleDeg in spokeAngles {
                let angleRad = angleDeg * .pi / 180
                var spokePath = Path()
                spokePath.move(to: center)
                spokePath.addLine(to: CGPoint(
                    x: center.x + cos(angleRad) * radius,
                    y: center.y - sin(angleRad) * radius
                ))
                context.stroke(spokePath, with: .color(Color(hex: "3a4a6a")), lineWidth: 1.5)
            }

            // Inner structural rings
            var ring1 = Path()
            ring1.addArc(center: center, radius: 90, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(ring1, with: .color(Color(hex: "2a3a5a")), lineWidth: 1)

            var ring2 = Path()
            ring2.addArc(center: center, radius: 50, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(ring2, with: .color(Color(hex: "2a3a5a")), lineWidth: 1)

            // Rim lights - Blue (at cardinal directions)
            let blueAngles: [Double] = [90, 0, 270, 180] // top, right, bottom, left
            for angleDeg in blueAngles {
                let angleRad = angleDeg * .pi / 180
                let x = center.x + cos(angleRad) * radius
                let y = center.y - sin(angleRad) * radius

                // Glow
                context.fill(
                    Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 10)),
                    with: .color(Color(hex: "86A6FF").opacity(0.4))
                )
                // Light
                context.fill(
                    Path(ellipseIn: CGRect(x: x - 3, y: y - 3, width: 6, height: 6)),
                    with: .color(Color(hex: "86A6FF").opacity(0.9))
                )
            }

            // Rim lights - Purple (at diagonal directions)
            let purpleAngles: [Double] = [135, 45, 315, 225]
            for angleDeg in purpleAngles {
                let angleRad = angleDeg * .pi / 180
                let x = center.x + cos(angleRad) * radius
                let y = center.y - sin(angleRad) * radius

                // Glow
                context.fill(
                    Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 10)),
                    with: .color(Color(hex: "C6A6FF").opacity(0.35))
                )
                // Light
                context.fill(
                    Path(ellipseIn: CGRect(x: x - 3, y: y - 3, width: 6, height: 6)),
                    with: .color(Color(hex: "C6A6FF").opacity(0.85))
                )
            }

            // Rim lights - Lighter accent (between main lights)
            let accentAngles: [Double] = [112.5, 67.5, 22.5, 337.5, 292.5, 247.5, 202.5, 157.5]
            for angleDeg in accentAngles {
                let angleRad = angleDeg * .pi / 180
                let x = center.x + cos(angleRad) * radius
                let y = center.y - sin(angleRad) * radius

                // Glow
                context.fill(
                    Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8)),
                    with: .color(Color(hex: "a8c8ff").opacity(0.3))
                )
                // Light
                context.fill(
                    Path(ellipseIn: CGRect(x: x - 2.5, y: y - 2.5, width: 5, height: 5)),
                    with: .color(Color(hex: "a8c8ff").opacity(0.8))
                )
            }

            // Hub - outer
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 15, y: center.y - 15, width: 30, height: 30)),
                with: .color(Color(hex: "2a3a5a"))
            )
            // Hub - inner
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16)),
                with: .color(Color(hex: "1a2a4a"))
            )
            // Hub - light
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)),
                with: .color(Color(hex: "86A6FF").opacity(0.6))
            )

            // A-frame support - left leg
            var leftLeg = Path()
            leftLeg.move(to: center)
            leftLeg.addLine(to: CGPoint(x: center.x - 45, y: size.height))
            leftLeg.addLine(to: CGPoint(x: center.x - 35, y: size.height))
            leftLeg.closeSubpath()
            context.fill(leftLeg, with: .color(Color(hex: "2a3a5a")))

            // A-frame support - right leg
            var rightLeg = Path()
            rightLeg.move(to: center)
            rightLeg.addLine(to: CGPoint(x: center.x + 35, y: size.height))
            rightLeg.addLine(to: CGPoint(x: center.x + 45, y: size.height))
            rightLeg.closeSubpath()
            context.fill(rightLeg, with: .color(Color(hex: "2a3a5a")))

            // Cross beam
            let beamRect = CGRect(x: center.x - 50, y: size.height - 50, width: 100, height: 6)
            context.fill(Path(roundedRect: beamRect, cornerRadius: 2), with: .color(Color(hex: "3a4a6a")))
        }
    }
}

// MARK: - Capsule Animated View

struct FerrisCapsuleAnimatedView: View {
    let cycleProgress: CGFloat
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    private let wheelRadius: CGFloat = 130
    private var wheelCenterX: CGFloat { screenWidth / 2 }
    private var wheelCenterY: CGFloat { screenHeight * 0.60 }

    // Easing function matching HTML
    private func easeInOutSine(_ t: CGFloat) -> CGFloat {
        return -(cos(.pi * t) - 1) / 2
    }

    // Calculate capsule angle based on breathing cycle
    // Inhale: bottom (90 degrees) to top (270 degrees)
    // Exhale: top (270 degrees) back to bottom (450 = 90 degrees)
    private var capsuleAngleDegrees: CGFloat {
        let isInhale = cycleProgress < 0.5

        if isInhale {
            // 0 -> 0.5 progress maps to 90 -> 270 degrees
            let inhaleProgress = easeInOutSine(cycleProgress * 2)
            return 90 + (inhaleProgress * 180)
        } else {
            // 0.5 -> 1.0 progress maps to 270 -> 450 (= 90) degrees
            let exhaleProgress = easeInOutSine((cycleProgress - 0.5) * 2)
            return 270 + (exhaleProgress * 180)
        }
    }

    var body: some View {
        let angleRad = capsuleAngleDegrees * .pi / 180
        // In SwiftUI coordinate system, Y increases downward
        // cos for X, sin for Y (but we need to negate sin because our angles are standard math angles)
        let capsuleX = wheelCenterX + cos(angleRad) * wheelRadius
        let capsuleY = wheelCenterY + sin(angleRad) * wheelRadius

        // Reflection in water
        let waterTop = screenHeight * 0.82
        let reflectionScale: CGFloat = 0.4
        let reflectionY = waterTop + (waterTop - capsuleY) * reflectionScale

        ZStack {
            // Capsule reflection in water
            FerrisCapsuleShape()
                .frame(width: 28, height: 40)
                .scaleEffect(y: -1)
                .opacity(0.12)
                .blur(radius: 2)
                .position(x: capsuleX, y: reflectionY)

            // Main capsule
            FerrisCapsuleShape()
                .frame(width: 28, height: 40)
                .position(x: capsuleX, y: capsuleY)
        }
    }
}

// MARK: - Capsule Shape

struct FerrisCapsuleShape: View {
    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2

            // Connector circle at top
            context.fill(
                Path(ellipseIn: CGRect(x: centerX - 4, y: 0, width: 8, height: 8)),
                with: .color(Color(hex: "4a5a7a"))
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: centerX - 4, y: 0, width: 8, height: 8)),
                with: .color(Color(hex: "3a4a6a")),
                lineWidth: 1.5
            )

            // Rod connecting to wheel
            context.fill(
                Path(CGRect(x: centerX - 2, y: 6, width: 4, height: 8)),
                with: .color(Color(hex: "3a4a6a"))
            )

            // Main capsule body (ellipse)
            context.fill(
                Path(ellipseIn: CGRect(x: 2, y: 13, width: 24, height: 26)),
                with: .color(Color(hex: "f0f4ff"))
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: 2, y: 13, width: 24, height: 26)),
                with: .color(Color(hex: "3a4a6a")),
                lineWidth: 1.5
            )

            // Window
            context.fill(
                Path(ellipseIn: CGRect(x: 4, y: 16, width: 20, height: 16)),
                with: .color(Color(hex: "a8c8f0"))
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: 4, y: 16, width: 20, height: 16)),
                with: .color(Color(hex: "5a6a8a")),
                lineWidth: 1
            )

            // Window reflection/highlight
            context.fill(
                Path(ellipseIn: CGRect(x: 6, y: 17, width: 8, height: 6)),
                with: .color(Color.white.opacity(0.4))
            )

            // Bottom rim of capsule
            context.fill(
                Path(ellipseIn: CGRect(x: 6, y: 30, width: 16, height: 8)),
                with: .color(Color(hex: "d8dce8"))
            )
        }
    }
}

#Preview {
    BreatheFerriswheelView(duration: 3, onComplete: {}, onBack: {})
}
