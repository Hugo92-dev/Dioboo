//
//  BreatheAstronautView.swift
//  Dioboo
//
//  Astronaut breathing experience - matches breatheastronaut.html exactly
//  Floating in space, viewing Earth from orbit
//

import SwiftUI
import Combine

struct BreatheAstronautView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var cycleProgress: CGFloat = 0
    @State private var animationTimer: Timer?
    @State private var startTime: Date?

    private let cycleDuration: TimeInterval = 10.0
    private let floatDistance: CGFloat = 35

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep space background
                RadialGradient(
                    colors: [
                        Color(hex: "0a1228"),
                        Color(hex: "050a14"),
                        Color(hex: "020408"),
                        Color.black
                    ],
                    center: .init(x: 0.5, y: 1.0),
                    startRadius: 0,
                    endRadius: geo.size.height
                )
                .ignoresSafeArea()

                // Stars
                AstronautStarsLayer()

                // Satellites
                AstronautSatellitesLayer(screenWidth: geo.size.width)

                // Shooting stars
                AstronautShootingStarsLayer()

                // Floating view (moves with breath)
                AstronautFloatingView(
                    cycleProgress: cycleProgress,
                    floatDistance: floatDistance,
                    screenWidth: geo.size.width,
                    screenHeight: geo.size.height
                )

                // UI Overlay
                VStack {
                    // Back button
                    HStack {
                        Button(action: onBack) {
                            Circle()
                                .fill(Color(hex: "0a1228").opacity(0.7))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "6496FF").opacity(0.2), lineWidth: 1)
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
                        .opacity(0.95)
                        .shadow(color: Color(hex: "64A0FF").opacity(0.4), radius: 12)
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

struct AstronautStarsLayer: View {
    @State private var twinklePhases: [CGFloat] = Array(repeating: 0, count: 10)

    var body: some View {
        GeometryReader { geo in
            // Regular stars
            ForEach(0..<100, id: \.self) { i in
                let size = 0.5 + CGFloat.random(in: 0...1.2)
                Circle()
                    .fill(Color.white.opacity(0.3 + Double.random(in: 0...0.5)))
                    .frame(width: size, height: size)
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height * 0.5)
                    )
            }

            // Twinkling stars
            ForEach(0..<10, id: \.self) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: 2, height: 2)
                    .shadow(color: .white.opacity(0.6), radius: 2)
                    .opacity(0.4 + twinklePhases[i] * 0.6)
                    .position(
                        x: CGFloat(5 + (i * 9)) / 100 * geo.size.width,
                        y: CGFloat(5 + (i * 4)) / 100 * geo.size.height
                    )
            }

            // Colored stars
            Circle()
                .fill(Color(hex: "FFB496").opacity(0.9))
                .frame(width: 2.5, height: 2.5)
                .shadow(color: Color(hex: "FFB496"), radius: 3)
                .position(x: geo.size.width * 0.12, y: geo.size.height * 0.10)

            Circle()
                .fill(Color(hex: "96B4FF").opacity(0.9))
                .frame(width: 2.5, height: 2.5)
                .shadow(color: Color(hex: "96B4FF"), radius: 3)
                .position(x: geo.size.width * 0.78, y: geo.size.height * 0.22)

            Circle()
                .fill(Color(hex: "FFC896").opacity(0.85))
                .frame(width: 2.5, height: 2.5)
                .shadow(color: Color(hex: "FFC896"), radius: 3)
                .position(x: geo.size.width * 0.45, y: geo.size.height * 0.05)
        }
        .onAppear {
            for i in 0..<10 {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(Double.random(in: 0...3))) {
                    twinklePhases[i] = 1
                }
            }
        }
    }
}

// MARK: - Satellites Layer

struct AstronautSatellitesLayer: View {
    let screenWidth: CGFloat

    @State private var sat1X: CGFloat = -0.03
    @State private var sat2X: CGFloat = 1.03

    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
                .opacity(0.8)
                .position(x: sat1X * screenWidth, y: geo.size.height * 0.10)

            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
                .opacity(0.6)
                .position(x: sat2X * screenWidth, y: geo.size.height * 0.20)
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                sat1X = 1.03
            }
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                sat2X = -0.03
            }
        }
    }
}

// MARK: - Shooting Stars Layer

struct AstronautShootingStarsLayer: View {
    @State private var shoot1Opacity: Double = 0
    @State private var shoot1Offset: CGFloat = 0
    @State private var shoot2Opacity: Double = 0
    @State private var shoot2Offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            // Shooting star 1
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.9), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 50, height: 1)
                .rotationEffect(.degrees(-35))
                .opacity(shoot1Opacity)
                .offset(x: shoot1Offset)
                .position(x: geo.size.width * 0.20, y: geo.size.height * 0.06)

            // Shooting star 2
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 40, height: 1)
                .rotationEffect(.degrees(-40))
                .opacity(shoot2Opacity)
                .offset(x: shoot2Offset)
                .position(x: geo.size.width * 0.55, y: geo.size.height * 0.14)
        }
        .onAppear {
            // Shooting star 1 animation
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                shoot1Opacity = 1
                shoot1Offset = 0
                withAnimation(.easeOut(duration: 0.7)) {
                    shoot1Offset = 90
                    shoot1Opacity = 0
                }
            }

            // Shooting star 2 animation (delayed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                Timer.scheduledTimer(withTimeInterval: 14, repeats: true) { _ in
                    shoot2Opacity = 0.8
                    shoot2Offset = 0
                    withAnimation(.easeOut(duration: 0.6)) {
                        shoot2Offset = 70
                        shoot2Opacity = 0
                    }
                }
            }
        }
    }
}

// MARK: - Floating View (Earth + Moon)

struct AstronautFloatingView: View {
    let cycleProgress: CGFloat
    let floatDistance: CGFloat
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    private func easeInOutSine(_ t: CGFloat) -> CGFloat {
        return -(cos(.pi * t) - 1) / 2
    }

    private var floatOffset: CGFloat {
        let isInhale = cycleProgress < 0.5
        if isInhale {
            return -easeInOutSine(cycleProgress * 2) * floatDistance
        } else {
            return -floatDistance + easeInOutSine((cycleProgress - 0.5) * 2) * floatDistance
        }
    }

    var body: some View {
        ZStack {
            // Moon
            AstronautMoonView()
                .position(x: screenWidth - 50, y: 85)

            // Earth
            AstronautEarthView()
                .frame(width: 560, height: 560)
                .position(x: screenWidth / 2, y: screenHeight + 230)
        }
        .offset(y: floatOffset)
    }
}

// MARK: - Moon View

struct AstronautMoonView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "f0f0ec"),
                            Color(hex: "d0d0cc"),
                            Color(hex: "a0a098")
                        ],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: 11
                    )
                )
                .frame(width: 22, height: 22)
                .shadow(color: Color(hex: "c8c8c8").opacity(0.2), radius: 6)

            // Craters
            Circle()
                .fill(Color(hex: "64645f").opacity(0.3))
                .frame(width: 4, height: 4)
                .offset(x: -3, y: -3)

            Ellipse()
                .fill(Color(hex: "64645f").opacity(0.25))
                .frame(width: 5, height: 4)
                .offset(x: -5, y: 2)
        }
    }
}

// MARK: - Earth View

struct AstronautEarthView: View {
    var body: some View {
        ZStack {
            // Atmosphere glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "64B4FF").opacity(0.1),
                            Color(hex: "5096FF").opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 250,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)

            // Earth
            ZStack {
                // Ocean base
                Circle()
                    .fill(Color(hex: "1a6090"))
                    .shadow(color: Color(hex: "4696FF").opacity(0.2), radius: 30)
                    .shadow(color: Color(hex: "3278FF").opacity(0.1), radius: 60)

                // Ocean gradient overlay
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "2285b8"),
                                Color(hex: "1a70a0"),
                                Color(hex: "155a88"),
                                Color(hex: "0d4060")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Ocean highlights
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "2890c8"), Color.clear],
                            center: .init(x: 0.25, y: 0.25),
                            startRadius: 0,
                            endRadius: 100
                        )
                    )

                // Continents
                AstronautContinentsView()

                // Clouds
                AstronautCloudsView()

                // Sun light (left side)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color(hex: "C8E6FF").opacity(0.18),
                                Color(hex: "96C8FF").opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .offset(x: -150, y: -80)

                // Sphere shading
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            center: .init(x: 0.3, y: 0.25),
                            startRadius: 0,
                            endRadius: 100
                        )
                    )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.black.opacity(0.5), Color.clear],
                            center: .init(x: 0.75, y: 0.75),
                            startRadius: 0,
                            endRadius: 130
                        )
                    )

                // Night side overlay
                HalfCircle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color(hex: "000819").opacity(0.25),
                                Color(hex: "000819").opacity(0.5),
                                Color(hex: "000819").opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // City lights on night side
                AstronautCityLightsView()
            }
            .frame(width: 560, height: 560)
            .clipShape(Circle())
        }
    }
}

struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: .degrees(90),
                    endAngle: .degrees(-90),
                    clockwise: true)
        return path
    }
}

// MARK: - Continents View

struct AstronautContinentsView: View {
    var body: some View {
        Canvas { context, size in
            let scale = size.width / 100

            // Colors
            let forestColor = Color(hex: "3d9960")
            let desertColor = Color(hex: "d4b896")
            let iceColor = Color(hex: "f0f4f8")

            // North America (simplified)
            var northAmerica = Path()
            northAmerica.move(to: CGPoint(x: 5 * scale, y: 8 * scale))
            northAmerica.addCurve(
                to: CGPoint(x: 34 * scale, y: 12 * scale),
                control1: CGPoint(x: 15 * scale, y: 5 * scale),
                control2: CGPoint(x: 28 * scale, y: 7 * scale)
            )
            northAmerica.addCurve(
                to: CGPoint(x: 28 * scale, y: 28 * scale),
                control1: CGPoint(x: 35 * scale, y: 18 * scale),
                control2: CGPoint(x: 31 * scale, y: 24 * scale)
            )
            northAmerica.addCurve(
                to: CGPoint(x: 14 * scale, y: 43 * scale),
                control1: CGPoint(x: 21 * scale, y: 32 * scale),
                control2: CGPoint(x: 17 * scale, y: 40 * scale)
            )
            northAmerica.addCurve(
                to: CGPoint(x: 5 * scale, y: 8 * scale),
                control1: CGPoint(x: 8 * scale, y: 32 * scale),
                control2: CGPoint(x: 4 * scale, y: 18 * scale)
            )
            context.fill(northAmerica, with: .color(forestColor))

            // South America
            var southAmerica = Path()
            southAmerica.move(to: CGPoint(x: 18 * scale, y: 52 * scale))
            southAmerica.addCurve(
                to: CGPoint(x: 30 * scale, y: 70 * scale),
                control1: CGPoint(x: 27 * scale, y: 51 * scale),
                control2: CGPoint(x: 32 * scale, y: 58 * scale)
            )
            southAmerica.addCurve(
                to: CGPoint(x: 17 * scale, y: 68 * scale),
                control1: CGPoint(x: 25 * scale, y: 82 * scale),
                control2: CGPoint(x: 16 * scale, y: 80 * scale)
            )
            southAmerica.closeSubpath()
            context.fill(southAmerica, with: .color(forestColor))

            // Africa
            var africa = Path()
            africa.move(to: CGPoint(x: 40 * scale, y: 30 * scale))
            africa.addCurve(
                to: CGPoint(x: 66 * scale, y: 38 * scale),
                control1: CGPoint(x: 52 * scale, y: 28 * scale),
                control2: CGPoint(x: 60 * scale, y: 32 * scale)
            )
            africa.addCurve(
                to: CGPoint(x: 54 * scale, y: 70 * scale),
                control1: CGPoint(x: 67 * scale, y: 48 * scale),
                control2: CGPoint(x: 62 * scale, y: 60 * scale)
            )
            africa.addCurve(
                to: CGPoint(x: 40 * scale, y: 30 * scale),
                control1: CGPoint(x: 42 * scale, y: 60 * scale),
                control2: CGPoint(x: 38 * scale, y: 40 * scale)
            )
            context.fill(africa, with: .color(forestColor))

            // Sahara desert
            var sahara = Path()
            sahara.move(to: CGPoint(x: 42 * scale, y: 32 * scale))
            sahara.addCurve(
                to: CGPoint(x: 44 * scale, y: 40 * scale),
                control1: CGPoint(x: 56 * scale, y: 32 * scale),
                control2: CGPoint(x: 50 * scale, y: 38 * scale)
            )
            sahara.closeSubpath()
            context.fill(sahara, with: .color(desertColor))

            // Europe
            var europe = Path()
            europe.move(to: CGPoint(x: 44 * scale, y: 10 * scale))
            europe.addCurve(
                to: CGPoint(x: 54 * scale, y: 19 * scale),
                control1: CGPoint(x: 52 * scale, y: 10 * scale),
                control2: CGPoint(x: 56 * scale, y: 14 * scale)
            )
            europe.addCurve(
                to: CGPoint(x: 43 * scale, y: 33 * scale),
                control1: CGPoint(x: 50 * scale, y: 26 * scale),
                control2: CGPoint(x: 46 * scale, y: 29 * scale)
            )
            europe.addCurve(
                to: CGPoint(x: 44 * scale, y: 10 * scale),
                control1: CGPoint(x: 39 * scale, y: 24 * scale),
                control2: CGPoint(x: 40 * scale, y: 15 * scale)
            )
            context.fill(europe, with: .color(forestColor))

            // Asia
            var asia = Path()
            asia.move(to: CGPoint(x: 56 * scale, y: 6 * scale))
            asia.addCurve(
                to: CGPoint(x: 96 * scale, y: 22 * scale),
                control1: CGPoint(x: 75 * scale, y: 5 * scale),
                control2: CGPoint(x: 92 * scale, y: 11 * scale)
            )
            asia.addCurve(
                to: CGPoint(x: 80 * scale, y: 27 * scale),
                control1: CGPoint(x: 94 * scale, y: 26 * scale),
                control2: CGPoint(x: 88 * scale, y: 28 * scale)
            )
            asia.addCurve(
                to: CGPoint(x: 56 * scale, y: 6 * scale),
                control1: CGPoint(x: 64 * scale, y: 24 * scale),
                control2: CGPoint(x: 54 * scale, y: 12 * scale)
            )
            context.fill(asia, with: .color(forestColor))

            // India
            var india = Path()
            india.addEllipse(in: CGRect(x: 68 * scale, y: 34 * scale, width: 12 * scale, height: 18 * scale))
            context.fill(india, with: .color(forestColor))

            // Australia
            var australia = Path()
            australia.move(to: CGPoint(x: 82 * scale, y: 60 * scale))
            australia.addCurve(
                to: CGPoint(x: 98 * scale, y: 68 * scale),
                control1: CGPoint(x: 90 * scale, y: 58 * scale),
                control2: CGPoint(x: 96 * scale, y: 62 * scale)
            )
            australia.addCurve(
                to: CGPoint(x: 82 * scale, y: 60 * scale),
                control1: CGPoint(x: 94 * scale, y: 80 * scale),
                control2: CGPoint(x: 78 * scale, y: 74 * scale)
            )
            context.fill(australia, with: .color(desertColor))

            // Greenland
            var greenland = Path()
            greenland.addEllipse(in: CGRect(x: 29 * scale, y: 2 * scale, width: 15 * scale, height: 15 * scale))
            context.fill(greenland, with: .color(iceColor))

            // Antarctica hint
            var antarctica = Path()
            antarctica.move(to: CGPoint(x: 20 * scale, y: 96 * scale))
            antarctica.addCurve(
                to: CGPoint(x: 80 * scale, y: 96 * scale),
                control1: CGPoint(x: 40 * scale, y: 92 * scale),
                control2: CGPoint(x: 60 * scale, y: 92 * scale)
            )
            antarctica.addLine(to: CGPoint(x: 80 * scale, y: 100 * scale))
            antarctica.addLine(to: CGPoint(x: 20 * scale, y: 100 * scale))
            antarctica.closeSubpath()
            context.fill(antarctica, with: .color(iceColor.opacity(0.8)))
        }
    }
}

// MARK: - Clouds View

struct AstronautCloudsView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<7, id: \.self) { i in
                let positions: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
                    (0.18, 0.06, 55, 12),
                    (0.52, 0.14, 45, 10),
                    (0.10, 0.26, 40, 9),
                    (0.62, 0.32, 50, 11),
                    (0.28, 0.44, 45, 10),
                    (0.78, 0.20, 35, 8),
                    (0.70, 0.50, 40, 9)
                ]
                let p = positions[i]

                Ellipse()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: p.w, height: p.h)
                    .blur(radius: 3)
                    .position(x: geo.size.width * p.x, y: geo.size.height * p.y)
            }
        }
    }
}

// MARK: - City Lights View

struct AstronautCityLightsView: View {
    var body: some View {
        GeometryReader { geo in
            // City glows (larger areas)
            let glows: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
                (0.84, 0.12, 14, 9),
                (0.90, 0.20, 12, 8),
                (0.94, 0.30, 16, 10),
                (0.96, 0.42, 12, 8)
            ]

            ForEach(glows.indices, id: \.self) { i in
                let g = glows[i]
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "FFDC82").opacity(0.7),
                                Color(hex: "FFC864").opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: g.w / 2
                        )
                    )
                    .frame(width: g.w, height: g.h)
                    .position(x: geo.size.width * g.x, y: geo.size.height * g.y)
            }

            // Individual city lights
            let cities: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
                (0.80, 0.14, 3),
                (0.86, 0.11, 3),
                (0.87, 0.22, 3),
                (0.92, 0.18, 4),
                (0.90, 0.32, 3),
                (0.95, 0.28, 4),
                (0.88, 0.36, 3)
            ]

            ForEach(cities.indices, id: \.self) { i in
                let c = cities[i]
                Circle()
                    .fill(Color(hex: "ffdc7d"))
                    .frame(width: c.size, height: c.size)
                    .shadow(color: Color(hex: "ffdca0").opacity(0.9), radius: 3)
                    .shadow(color: Color(hex: "ffc864").opacity(0.5), radius: 5)
                    .position(x: geo.size.width * c.x, y: geo.size.height * c.y)
            }
        }
    }
}

#Preview {
    BreatheAstronautView(duration: 3, onComplete: {}, onBack: {})
}
