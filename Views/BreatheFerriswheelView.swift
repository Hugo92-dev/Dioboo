//
//  BreatheFerriswheelView.swift
//  Dioboo
//
//  Ferris Wheel (London Eye) breathing experience - matches breatheferriswheel.html exactly
//

import SwiftUI
import Combine

struct BreatheFerriswheelView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var cycleProgress: CGFloat = 0
    @State private var animationTimer: Timer?
    @State private var startTime: Date?

    private let cycleDuration: TimeInterval = 10.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Night sky gradient - exact from HTML
                LinearGradient(
                    colors: [
                        Color(hex: "070A14"),
                        Color(hex: "0a0e1a"),
                        Color(hex: "0d1322"),
                        Color(hex: "101828"),
                        Color(hex: "141e32"),
                        Color(hex: "182440"),
                        Color(hex: "1a2844")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Stars
                FerrisStarsLayer()

                // Moon
                FerrisMoonView()
                    .position(x: geo.size.width - 60, y: 95)

                // Clouds
                FerrisCloudsLayer()

                // City skyline layers
                FerrisCityLayers(screenWidth: geo.size.width, screenHeight: geo.size.height)

                // Mist
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color(hex: "0f1630").opacity(0.3),
                                Color(hex: "0f1630").opacity(0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geo.size.height * 0.25)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.72)

                // Water (Thames)
                FerrisWaterView(screenWidth: geo.size.width, screenHeight: geo.size.height)

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
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.55)

                // London Eye wheel
                FerrisWheelView()
                    .frame(width: 280, height: 280)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.55)

                // Capsule
                FerrisCapsuleView(cycleProgress: cycleProgress, screenWidth: geo.size.width, screenHeight: geo.size.height)

                // Boats
                FerrisBoatsLayer(screenWidth: geo.size.width, screenHeight: geo.size.height)

                // UI Overlay
                VStack {
                    // Back button - glass effect from HTML
                    HStack {
                        Button(action: onBack) {
                            Circle()
                                .fill(Color(hex: "0f1630").opacity(0.8))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "1A2552"), lineWidth: 1)
                                )
                                .overlay(
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(Color(hex: "B8C0E6"))
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
                        .opacity(0.9)
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

            let progress = (elapsed.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            cycleProgress = progress
            isInhaling = progress < 0.5
        }
    }
}

// MARK: - Stars Layer

struct FerrisStarsLayer: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<45, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "F5F7FF").opacity(i < 40 ? Double.random(in: 0.2...0.5) : 0.7))
                    .frame(width: i < 40 ? CGFloat.random(in: 1...2.5) : 2.5)
                    .shadow(color: i >= 40 ? Color(hex: "F5F7FF").opacity(0.6) : .clear, radius: 2)
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height * 0.55)
                    )
            }
        }
    }
}

// MARK: - Moon View

struct FerrisMoonView: View {
    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Moon glow
            Circle()
                .fill(Color(hex: "f5f5f0").opacity(0.15))
                .frame(width: 55, height: 55)
                .blur(radius: 15)

            // Moon body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "f5f5f0"),
                            Color(hex: "e8e8e0"),
                            Color(hex: "d0d0c8")
                        ],
                        center: .init(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 17
                    )
                )
                .frame(width: 35, height: 35)
                .shadow(color: Color(hex: "f5f5f0").opacity(0.3), radius: 10)
                .shadow(color: Color(hex: "f5f5f0").opacity(0.15), radius: 20)

            // Moon crater
            Circle()
                .fill(Color(hex: "b4b4aa").opacity(0.3))
                .frame(width: 8, height: 8)
                .offset(x: -3, y: -8)
        }
    }
}

// MARK: - Clouds Layer

struct FerrisCloudsLayer: View {
    @State private var cloudOffsets: [CGFloat] = [-200, -200, -200]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<3, id: \.self) { i in
                Ellipse()
                    .fill(Color(hex: "86A6FF").opacity(0.03))
                    .frame(width: [150, 180, 120][i], height: [50, 60, 45][i])
                    .blur(radius: 25)
                    .offset(x: cloudOffsets[i])
                    .position(x: 0, y: CGFloat([60, 120, 90][i]))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 120).repeatForever(autoreverses: false)) {
                cloudOffsets[0] = 400
            }
            withAnimation(.linear(duration: 150).repeatForever(autoreverses: false).delay(40)) {
                cloudOffsets[1] = 400
            }
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false).delay(70)) {
                cloudOffsets[2] = 400
            }
        }
    }
}

// MARK: - City Layers

struct FerrisCityLayers: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    var body: some View {
        ZStack {
            // Far city layer
            FerrisCityLayer(
                buildings: [
                    (x: -10, y: 100, w: 30, h: 60),
                    (x: 25, y: 80, w: 25, h: 80),
                    (x: 55, y: 110, w: 20, h: 50),
                    (x: 80, y: 70, w: 22, h: 90),
                    (x: 110, y: 95, w: 35, h: 65),
                    (x: 150, y: 60, w: 18, h: 100),
                    (x: 175, y: 85, w: 28, h: 75),
                    (x: 210, y: 105, w: 22, h: 55),
                    (x: 238, y: 75, w: 20, h: 85),
                    (x: 265, y: 90, w: 30, h: 70),
                    (x: 300, y: 100, w: 25, h: 60),
                    (x: 330, y: 85, w: 30, h: 75)
                ],
                color: Color(hex: "0c1018"),
                scale: screenWidth / 351
            )
            .opacity(0.4)
            .position(x: screenWidth / 2, y: screenHeight * 0.67)

            // Mid city layer with Big Ben
            FerrisMidCityLayer(screenWidth: screenWidth)
                .opacity(0.7)
                .position(x: screenWidth / 2, y: screenHeight * 0.69)

            // Front city layer
            FerrisCityLayer(
                buildings: [
                    (x: -5, y: 100, w: 35, h: 45),
                    (x: 35, y: 85, w: 28, h: 60),
                    (x: 68, y: 105, w: 20, h: 40),
                    (x: 280, y: 90, w: 25, h: 55),
                    (x: 310, y: 100, w: 22, h: 45),
                    (x: 337, y: 80, w: 20, h: 65)
                ],
                color: Color(hex: "080c12"),
                scale: screenWidth / 351
            )
            .position(x: screenWidth / 2, y: screenHeight * 0.72)

            // Bridge
            FerrisBridgeView(screenWidth: screenWidth)
                .position(x: screenWidth / 2, y: screenHeight * 0.77)

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
            FerrisLamppostsView(screenWidth: screenWidth, screenHeight: screenHeight)
        }
    }
}

struct FerrisCityLayer: View {
    let buildings: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)]
    let color: Color
    let scale: CGFloat

    var body: some View {
        Canvas { context, size in
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
        .frame(width: 351 * scale, height: 175 * scale)
    }
}

struct FerrisMidCityLayer: View {
    let screenWidth: CGFloat

    var body: some View {
        let scale = screenWidth / 351

        Canvas { context, size in
            let color = Color(hex: "0a0e16")

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
                context.fill(Path(rect), with: .color(color))
            }

            // Big Ben
            context.fill(Path(CGRect(x: 98 * scale, y: 40 * scale, width: 18 * scale, height: 135 * scale)), with: .color(color))
            context.fill(Path(CGRect(x: 94 * scale, y: 35 * scale, width: 26 * scale, height: 10 * scale)), with: .color(color))

            // Big Ben spire
            var spire = Path()
            spire.move(to: CGPoint(x: 107 * scale, y: 35 * scale))
            spire.addLine(to: CGPoint(x: 100 * scale, y: 20 * scale))
            spire.addLine(to: CGPoint(x: 114 * scale, y: 20 * scale))
            spire.closeSubpath()
            context.fill(spire, with: .color(color))

            // Parliament
            context.fill(Path(CGRect(x: 165 * scale, y: 85 * scale, width: 55 * scale, height: 90 * scale)), with: .color(color))
            context.fill(Path(CGRect(x: 170 * scale, y: 80 * scale, width: 8 * scale, height: 10 * scale)), with: .color(color))
            context.fill(Path(CGRect(x: 190 * scale, y: 75 * scale, width: 8 * scale, height: 15 * scale)), with: .color(color))
            context.fill(Path(CGRect(x: 207 * scale, y: 80 * scale, width: 8 * scale, height: 10 * scale)), with: .color(color))

            // Window lights
            let lightColor = Color(hex: "ffd54f")
            let windowPositions: [(x: CGFloat, y: CGFloat)] = [
                (40, 105), (50, 120), (103, 60), (103, 80), (130, 115),
                (145, 130), (180, 100), (195, 110), (235, 120), (300, 115)
            ]

            for pos in windowPositions {
                let rect = CGRect(x: pos.x * scale, y: pos.y * scale, width: 2 * scale, height: 3 * scale)
                context.fill(Path(rect), with: .color(lightColor.opacity(0.6)))
            }
        }
        .frame(width: 351 * scale, height: 175 * scale)
    }
}

struct FerrisBridgeView: View {
    let screenWidth: CGFloat

    var body: some View {
        let scale = screenWidth / 351

        Canvas { context, size in
            let bridgeColor = Color(hex: "0c1018")

            // Main deck
            context.fill(
                Path(CGRect(x: 0, y: 70 * scale, width: 351 * scale, height: 25 * scale)),
                with: .color(bridgeColor)
            )

            // Pillars
            context.fill(Path(CGRect(x: 83 * scale, y: 55 * scale, width: 10 * scale, height: 40 * scale)), with: .color(bridgeColor))
            context.fill(Path(CGRect(x: 171 * scale, y: 55 * scale, width: 10 * scale, height: 40 * scale)), with: .color(bridgeColor))
            context.fill(Path(CGRect(x: 259 * scale, y: 55 * scale, width: 10 * scale, height: 40 * scale)), with: .color(bridgeColor))

            // Arches
            let archPositions: [(start: CGFloat, end: CGFloat)] = [
                (0, 88), (88, 176), (176, 264), (264, 351)
            ]

            for arch in archPositions {
                var archPath = Path()
                archPath.move(to: CGPoint(x: arch.start * scale, y: 70 * scale))
                archPath.addQuadCurve(
                    to: CGPoint(x: arch.end * scale, y: 70 * scale),
                    control: CGPoint(x: (arch.start + arch.end) / 2 * scale, y: 45 * scale)
                )
                context.stroke(archPath, with: .color(bridgeColor), lineWidth: 8 * scale)
            }

            // Bridge lights
            let lightColor = Color(hex: "ffeecc")
            let lightPositions: [CGFloat] = [44, 132, 220, 308]
            for x in lightPositions {
                let lightPath = Path(ellipseIn: CGRect(x: (x - 2) * scale, y: 66 * scale, width: 4 * scale, height: 4 * scale))
                context.fill(lightPath, with: .color(lightColor.opacity(0.7)))
            }
        }
        .frame(width: 351 * scale, height: 95 * scale)
    }
}

struct FerrisLamppostsView: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    var body: some View {
        let scale = screenWidth / 351
        let positions: [CGFloat] = [35, 95, 255, 315]

        ForEach(positions.indices, id: \.self) { i in
            VStack(spacing: 0) {
                // Light
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "ffeecc"), Color(hex: "ffdd99"), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 3
                        )
                    )
                    .frame(width: 6, height: 6)
                    .shadow(color: Color(hex: "ffeecc").opacity(0.5), radius: 4)

                // Pole
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "3a4050"), Color(hex: "2a3040")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2, height: 25)
            }
            .position(x: positions[i] * scale, y: screenHeight * 0.77)
        }
    }
}

// MARK: - Water View

struct FerrisWaterView: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Water gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "0a1018"),
                            Color(hex: "0c1420"),
                            Color(hex: "0a1018"),
                            Color(hex: "081015"),
                            Color(hex: "060c12"),
                            Color(hex: "050a10")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: screenWidth, height: screenHeight * 0.18)

            // Water surface line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(hex: "86A6FF").opacity(0.15),
                            Color(hex: "86A6FF").opacity(0.25),
                            Color(hex: "86A6FF").opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: screenWidth, height: 3)
                .offset(y: -screenHeight * 0.09)

            // Moon reflection
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "f5f5f0").opacity(0.25),
                            Color(hex: "f5f5f0").opacity(0.15),
                            Color(hex: "f5f5f0").opacity(0.08),
                            Color(hex: "f5f5f0").opacity(0.03),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 20, height: screenHeight * 0.15)
                .scaleEffect(x: 1 + shimmerPhase * 0.2)
                .opacity(0.8 + shimmerPhase * 0.2)
                .position(x: screenWidth - 60, y: screenHeight * 0.085)
        }
        .position(x: screenWidth / 2, y: screenHeight * 0.91)
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                shimmerPhase = 1
            }
        }
    }
}

// MARK: - London Eye Wheel

struct FerrisWheelView: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 130

            // Main wheel rim
            var rimPath = Path()
            rimPath.addArc(center: center, radius: radius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(rimPath, with: .color(Color(hex: "4a5a7a")), lineWidth: 5)

            var innerRimPath = Path()
            innerRimPath.addArc(center: center, radius: 125, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            context.stroke(innerRimPath, with: .color(Color(hex: "3a4a6a")), lineWidth: 2)

            // Spokes
            for i in 0..<16 {
                let angle = Double(i) * 22.5 * .pi / 180
                var spokePath = Path()
                spokePath.move(to: center)
                spokePath.addLine(to: CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
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

            // Rim lights
            let bluePositions: [Double] = [90, 0, 270, 180] // degrees
            let purplePositions: [Double] = [45, 135, 225, 315]
            let accentPositions: [Double] = [22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5]

            for angle in bluePositions {
                let rad = angle * .pi / 180
                let x = center.x + cos(rad) * radius
                let y = center.y + sin(rad) * radius
                context.fill(Path(ellipseIn: CGRect(x: x - 3, y: y - 3, width: 6, height: 6)), with: .color(Color(hex: "86A6FF").opacity(0.9)))
            }

            for angle in purplePositions {
                let rad = angle * .pi / 180
                let x = center.x + cos(rad) * radius
                let y = center.y + sin(rad) * radius
                context.fill(Path(ellipseIn: CGRect(x: x - 3, y: y - 3, width: 6, height: 6)), with: .color(Color(hex: "C6A6FF").opacity(0.85)))
            }

            for angle in accentPositions {
                let rad = angle * .pi / 180
                let x = center.x + cos(rad) * radius
                let y = center.y + sin(rad) * radius
                context.fill(Path(ellipseIn: CGRect(x: x - 2.5, y: y - 2.5, width: 5, height: 5)), with: .color(Color(hex: "a8c8ff").opacity(0.8)))
            }

            // Hub
            context.fill(Path(ellipseIn: CGRect(x: center.x - 15, y: center.y - 15, width: 30, height: 30)), with: .color(Color(hex: "2a3a5a")))
            context.fill(Path(ellipseIn: CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16)), with: .color(Color(hex: "1a2a4a")))
            context.fill(Path(ellipseIn: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)), with: .color(Color(hex: "86A6FF").opacity(0.6)))

            // A-frame support
            var leftLeg = Path()
            leftLeg.move(to: center)
            leftLeg.addLine(to: CGPoint(x: center.x - 45, y: size.height))
            leftLeg.addLine(to: CGPoint(x: center.x - 35, y: size.height))
            leftLeg.closeSubpath()
            context.fill(leftLeg, with: .color(Color(hex: "2a3a5a")))

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

// MARK: - Capsule View

struct FerrisCapsuleView: View {
    let cycleProgress: CGFloat
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    private let wheelRadius: CGFloat = 130
    private var wheelCenterX: CGFloat { screenWidth / 2 }
    private var wheelCenterY: CGFloat { screenHeight * 0.55 }

    private func easeInOutSine(_ t: CGFloat) -> CGFloat {
        return -(cos(.pi * t) - 1) / 2
    }

    var body: some View {
        // Calculate angle based on breath cycle
        // Inhale: 90 -> 270 (bottom to top)
        // Exhale: 270 -> 450 (top to bottom, wraps to 90)
        let isInhale = cycleProgress < 0.5
        let angle: CGFloat
        if isInhale {
            let inhaleProgress = easeInOutSine(cycleProgress * 2)
            angle = 90 + (inhaleProgress * 180)
        } else {
            let exhaleProgress = easeInOutSine((cycleProgress - 0.5) * 2)
            angle = 270 + (exhaleProgress * 180)
        }

        let angleRad = angle * .pi / 180
        let capsuleX = wheelCenterX + cos(angleRad) * wheelRadius
        let capsuleY = wheelCenterY + sin(angleRad) * wheelRadius

        // Capsule reflection
        let waterTop = screenHeight * 0.82
        let reflectionY = waterTop + (waterTop - capsuleY) * 0.4

        ZStack {
            // Reflection in water
            CapsuleShape()
                .frame(width: 28, height: 40)
                .scaleEffect(y: -1)
                .opacity(0.12)
                .blur(radius: 2)
                .position(x: capsuleX, y: reflectionY)

            // Actual capsule
            CapsuleShape()
                .frame(width: 28, height: 40)
                .position(x: capsuleX, y: capsuleY)
        }
    }
}

struct CapsuleShape: View {
    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let centerY = size.height / 2

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

            // Rod
            context.fill(
                Path(CGRect(x: centerX - 2, y: 6, width: 4, height: 8)),
                with: .color(Color(hex: "3a4a6a"))
            )

            // Capsule body
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

            // Window reflection
            context.fill(
                Path(ellipseIn: CGRect(x: 6, y: 17, width: 8, height: 6)),
                with: .color(Color.white.opacity(0.4))
            )

            // Bottom rim
            context.fill(
                Path(ellipseIn: CGRect(x: 6, y: 30, width: 16, height: 8)),
                with: .color(Color(hex: "d8dce8"))
            )
        }
    }
}

// MARK: - Boats Layer

struct FerrisBoatsLayer: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var boat1X: CGFloat = -50
    @State private var boat2X: CGFloat = 400

    var body: some View {
        ZStack {
            // Boat 1
            FerrisBoatView(size: 80)
                .position(x: boat1X, y: screenHeight * 0.92)

            // Boat 2
            FerrisBoatView(size: 65)
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
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 80

            // Light trail on water
            context.fill(
                Path(ellipseIn: CGRect(x: 3 * scale, y: 17 * scale, width: 24 * scale, height: 6 * scale)),
                with: .color(Color(hex: "ffeecc").opacity(0.15))
            )

            // Hull
            var hullPath = Path()
            hullPath.move(to: CGPoint(x: 40 * scale, y: 12 * scale))
            hullPath.addLine(to: CGPoint(x: 45 * scale, y: 18 * scale))
            hullPath.addLine(to: CGPoint(x: 70 * scale, y: 18 * scale))
            hullPath.addLine(to: CGPoint(x: 75 * scale, y: 12 * scale))
            hullPath.closeSubpath()
            context.fill(hullPath, with: .color(Color(hex: "1a1a2a")))

            // Cabin
            context.fill(
                Path(roundedRect: CGRect(x: 50 * scale, y: 5 * scale, width: 15 * scale, height: 8 * scale), cornerRadius: 1),
                with: .color(Color(hex: "1a1a2a"))
            )

            // Windows
            context.fill(
                Path(CGRect(x: 52 * scale, y: 7 * scale, width: 4 * scale, height: 4 * scale)),
                with: .color(Color(hex: "ffdd99").opacity(0.8))
            )
            context.fill(
                Path(CGRect(x: 59 * scale, y: 7 * scale, width: 4 * scale, height: 4 * scale)),
                with: .color(Color(hex: "ffeeaa").opacity(0.7))
            )

            // Front light
            context.fill(
                Path(ellipseIn: CGRect(x: 71 * scale, y: 8 * scale, width: 4 * scale, height: 4 * scale)),
                with: .color(Color(hex: "ffeecc").opacity(0.9))
            )

            // Back light
            context.fill(
                Path(ellipseIn: CGRect(x: 41.5 * scale, y: 8.5 * scale, width: 3 * scale, height: 3 * scale)),
                with: .color(Color(hex: "ff6666").opacity(0.7))
            )

            // Light reflection on water
            context.fill(
                Path(ellipseIn: CGRect(x: 67 * scale, y: 20 * scale, width: 12 * scale, height: 4 * scale)),
                with: .color(Color(hex: "ffeecc").opacity(0.25))
            )
        }
        .frame(width: size, height: size * 25 / 80)
    }
}

#Preview {
    BreatheFerriswheelView(duration: 3, onComplete: {}, onBack: {})
}
