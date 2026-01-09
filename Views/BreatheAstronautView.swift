//
//  BreatheAstronautView.swift
//  Dioboo
//
//  Astronaut breathing experience - matches breatheastronaut.html exactly
//  Floating in space, viewing Earth from orbit
//

import SwiftUI

struct BreatheAstronautView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var cycleProgress: CGFloat = 0
    @State private var totalProgress: CGFloat = 0
    @State private var remainingSeconds: Int = 0
    @State private var animationTimer: Timer?
    @State private var startTime: Date?
    @State private var hasAppeared: Bool = false

    private let cycleDuration: TimeInterval = 10.0
    private let floatDistance: CGFloat = 35

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep space background - radial gradient from bottom center
                RadialGradient(
                    colors: [
                        Color(hex: "0a1228"),
                        Color(hex: "050a14"),
                        Color(hex: "020408"),
                        Color.black
                    ],
                    center: UnitPoint(x: 0.5, y: 1.0),
                    startRadius: 0,
                    endRadius: geo.size.height
                )
                .ignoresSafeArea()

                // Stars layer
                AstronautStarsLayer(screenSize: geo.size)

                // Satellites
                AstronautSatellitesLayer(screenSize: geo.size)

                // Shooting stars
                AstronautShootingStarsLayer(screenSize: geo.size)

                // Floating view (moon + earth) - moves with breath
                AstronautFloatingView(
                    cycleProgress: cycleProgress,
                    floatDistance: floatDistance,
                    screenSize: geo.size
                )

                // UI Overlay
                VStack(spacing: 0) {
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
                        .blur(radius: 0)
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
                        .opacity(0.95)
                        .shadow(color: Color(hex: "64A0FF").opacity(0.4), radius: 12)
                        .padding(.bottom, 32)

                    // Timer text
                    Text(formatTime(remainingSeconds))
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(Color(hex: "B8C0E6"))
                        .padding(.bottom, 38)

                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "283C64").opacity(0.4))
                            .frame(height: 3)

                        GeometryReader { progressGeo in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "5090ff"), Color(hex: "70b0ff")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: progressGeo.size.width * totalProgress, height: 3)
                        }
                        .frame(height: 3)
                    }
                    .padding(.horizontal, 45)
                    .padding(.bottom, 50)
                }
            }
            .opacity(hasAppeared ? 1 : 0)
            .animation(.easeIn(duration: 1).delay(0.3), value: hasAppeared)
        }
        .onAppear {
            hasAppeared = true
            remainingSeconds = duration * 60
            startAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return "\(mins):\(String(format: "%02d", secs))"
    }

    private func startAnimation() {
        startTime = Date()
        let totalDuration = Double(duration) * 60.0

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            guard let start = startTime else { return }
            let elapsed = Date().timeIntervalSince(start)

            // Check completion
            if elapsed >= totalDuration {
                animationTimer?.invalidate()
                onComplete()
                return
            }

            // Update remaining time
            remainingSeconds = Int(ceil(totalDuration - elapsed))

            // Update total progress
            totalProgress = min(1.0, elapsed / totalDuration)

            // Update cycle progress (10 second cycle)
            let progress = (elapsed.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            cycleProgress = progress
            isInhaling = progress < 0.5
        }
    }
}

// MARK: - Ease Function

private func easeInOutSine(_ t: CGFloat) -> CGFloat {
    return -(cos(.pi * t) - 1) / 2
}

// MARK: - Stars Layer

struct AstronautStarsLayer: View {
    let screenSize: CGSize

    // Pre-generate star data to avoid regenerating on every render
    @State private var regularStars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []
    @State private var twinklingStars: [(x: CGFloat, y: CGFloat, delay: Double)] = []
    @State private var twinklePhases: [CGFloat] = Array(repeating: 0.4, count: 10)

    var body: some View {
        Canvas { context, size in
            // Draw regular stars
            for star in regularStars {
                let rect = CGRect(
                    x: star.x * size.width - star.size / 2,
                    y: star.y * size.height * 0.5 - star.size / 2,
                    width: star.size,
                    height: star.size
                )
                context.fill(
                    Circle().path(in: rect),
                    with: .color(Color.white.opacity(star.opacity))
                )
            }
        }

        // Twinkling stars with glow
        ForEach(0..<10, id: \.self) { i in
            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
                .shadow(color: Color.white.opacity(0.6), radius: 2)
                .opacity(Double(twinklePhases[i]))
                .position(
                    x: twinklingStars.isEmpty ? 0 : twinklingStars[i].x * screenSize.width,
                    y: twinklingStars.isEmpty ? 0 : twinklingStars[i].y * screenSize.height
                )
        }

        // Colored stars
        // Orange star at 12%, 10%
        Circle()
            .fill(Color(red: 1, green: 0.71, blue: 0.59).opacity(0.9))
            .frame(width: 2.5, height: 2.5)
            .shadow(color: Color(red: 1, green: 0.71, blue: 0.59), radius: 3)
            .modifier(TwinkleModifier())
            .position(x: screenSize.width * 0.12, y: screenSize.height * 0.10)

        // Blue star at 78%, 22%
        Circle()
            .fill(Color(red: 0.59, green: 0.71, blue: 1).opacity(0.9))
            .frame(width: 2.5, height: 2.5)
            .shadow(color: Color(red: 0.59, green: 0.71, blue: 1), radius: 3)
            .modifier(TwinkleModifier())
            .position(x: screenSize.width * 0.78, y: screenSize.height * 0.22)

        // Amber star at 45%, 5%
        Circle()
            .fill(Color(red: 1, green: 0.78, blue: 0.59).opacity(0.85))
            .frame(width: 2.5, height: 2.5)
            .shadow(color: Color(red: 1, green: 0.78, blue: 0.59), radius: 3)
            .modifier(TwinkleModifier())
            .position(x: screenSize.width * 0.45, y: screenSize.height * 0.05)

        .onAppear {
            generateStars()
            startTwinkling()
        }
    }

    private func generateStars() {
        // Generate 100 regular stars
        var stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []
        for _ in 0..<100 {
            let size = 0.5 + CGFloat.random(in: 0...1.2)
            let opacity = 0.3 + Double.random(in: 0...0.5)
            stars.append((
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: size,
                opacity: opacity
            ))
        }
        regularStars = stars

        // Generate 10 twinkling star positions
        var twinkling: [(x: CGFloat, y: CGFloat, delay: Double)] = []
        for _ in 0..<10 {
            twinkling.append((
                x: CGFloat.random(in: 0.05...0.95),
                y: CGFloat.random(in: 0.05...0.45),
                delay: Double.random(in: 0...3)
            ))
        }
        twinklingStars = twinkling
    }

    private func startTwinkling() {
        for i in 0..<10 {
            let delay = twinklingStars.isEmpty ? Double.random(in: 0...3) : twinklingStars[i].delay
            withAnimation(
                .easeInOut(duration: 3)
                .repeatForever(autoreverses: true)
                .delay(delay)
            ) {
                twinklePhases[i] = 1.0
            }
        }
    }
}

struct TwinkleModifier: ViewModifier {
    @State private var opacity: Double = 0.4

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...3))
                ) {
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Satellites Layer

struct AstronautSatellitesLayer: View {
    let screenSize: CGSize

    @State private var sat1X: CGFloat = -0.03
    @State private var sat2X: CGFloat = 1.03
    @State private var sat1Opacity: Double = 0
    @State private var sat2Opacity: Double = 0

    var body: some View {
        // Satellite 1 - moves left to right at 10% height
        Circle()
            .fill(Color.white)
            .frame(width: 2, height: 2)
            .opacity(sat1Opacity)
            .position(x: sat1X * screenSize.width, y: screenSize.height * 0.10)

        // Satellite 2 - moves right to left at 20% height
        Circle()
            .fill(Color.white)
            .frame(width: 2, height: 2)
            .opacity(sat2Opacity)
            .position(x: sat2X * screenSize.width, y: screenSize.height * 0.20)

        .onAppear {
            // Satellite 1: left to right, 30s
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                sat1X = 1.03
            }
            // Fade in at 5%, fade out at 95%
            withAnimation(.linear(duration: 1.5)) {
                sat1Opacity = 0.8
            }

            // Satellite 2: right to left, 40s, starts mid-animation
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                sat2X = -0.03
            }
            withAnimation(.linear(duration: 2)) {
                sat2Opacity = 0.6
            }
        }
    }
}

// MARK: - Shooting Stars Layer

struct AstronautShootingStarsLayer: View {
    let screenSize: CGSize

    @State private var shoot1Visible: Bool = false
    @State private var shoot1Offset: CGFloat = 0
    @State private var shoot2Visible: Bool = false
    @State private var shoot2Offset: CGFloat = 0

    var body: some View {
        // Shooting star 1 at 20%, 6%
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
            .opacity(shoot1Visible ? 1 : 0)
            .offset(x: shoot1Offset)
            .position(x: screenSize.width * 0.20, y: screenSize.height * 0.06)

        // Shooting star 2 at 55%, 14%
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
            .opacity(shoot2Visible ? 0.8 : 0)
            .offset(x: shoot2Offset)
            .position(x: screenSize.width * 0.55, y: screenSize.height * 0.14)

        .onAppear {
            // Shooting star 1: every 10 seconds, 2s initial delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                triggerShoot1()
            }
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                triggerShoot1()
            }

            // Shooting star 2: every 14 seconds, 7s initial delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                triggerShoot2()
            }
            Timer.scheduledTimer(withTimeInterval: 14, repeats: true) { _ in
                triggerShoot2()
            }
        }
    }

    private func triggerShoot1() {
        shoot1Offset = 0
        shoot1Visible = true
        withAnimation(.easeOut(duration: 0.5)) {
            shoot1Offset = 90
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            shoot1Visible = false
        }
    }

    private func triggerShoot2() {
        shoot2Offset = 0
        shoot2Visible = true
        withAnimation(.easeOut(duration: 0.4)) {
            shoot2Offset = 70
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            shoot2Visible = false
        }
    }
}

// MARK: - Floating View (Moon + Earth)

struct AstronautFloatingView: View {
    let cycleProgress: CGFloat
    let floatDistance: CGFloat
    let screenSize: CGSize

    private var floatOffset: CGFloat {
        let isInhale = cycleProgress < 0.5
        if isInhale {
            // Inhale: move UP (negative Y)
            return -easeInOutSine(cycleProgress * 2) * floatDistance
        } else {
            // Exhale: move DOWN (back to original)
            return -floatDistance + easeInOutSine((cycleProgress - 0.5) * 2) * floatDistance
        }
    }

    var body: some View {
        ZStack {
            // Moon - positioned at top: 70px, right: 35px
            AstronautMoonView()
                .position(x: screenSize.width - 35 - 11, y: 70 + 11) // -11 because moon is 22x22

            // Earth - positioned at bottom: -50px, centered, 560x560
            AstronautEarthView()
                .frame(width: 560, height: 560)
                .position(x: screenSize.width / 2, y: screenSize.height + 50 + 280 - 50) // -50 bottom offset, +280 half height
        }
        .offset(y: floatOffset)
    }
}

// MARK: - Moon View

struct AstronautMoonView: View {
    var body: some View {
        ZStack {
            // Moon base with gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "f0f0ec"),
                            Color(hex: "d0d0cc"),
                            Color(hex: "a0a098")
                        ],
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: 11
                    )
                )
                .frame(width: 22, height: 22)
                .shadow(color: Color(hex: "c8c8c8").opacity(0.2), radius: 6)

            // Crater 1: top: 5px, left: 6px, 4x4
            Circle()
                .fill(Color(hex: "64645f").opacity(0.3))
                .frame(width: 4, height: 4)
                .offset(x: 6 - 11, y: 5 - 11) // offset from center

            // Crater 2: top: 11px, left: 4px, 5x4 ellipse
            Ellipse()
                .fill(Color(hex: "64645f").opacity(0.25))
                .frame(width: 5, height: 4)
                .offset(x: 4 - 11 + 2.5, y: 11 - 11 + 2) // offset from center
        }
    }
}

// MARK: - Earth View

struct AstronautEarthView: View {
    var body: some View {
        ZStack {
            // Atmosphere glow - extends 20px beyond earth
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.clear,
                            Color(hex: "64B4FF").opacity(0.1),
                            Color(hex: "5096FF").opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 260,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)

            // Earth sphere
            ZStack {
                // Ocean base color
                Circle()
                    .fill(Color(hex: "1a6090"))

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

                // Ocean radial highlights
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "2890c8"), Color.clear],
                            center: UnitPoint(x: 0.25, y: 0.25),
                            startRadius: 0,
                            endRadius: 112
                        )
                    )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1a70a0"), Color.clear],
                            center: UnitPoint(x: 0.70, y: 0.60),
                            startRadius: 0,
                            endRadius: 98
                        )
                    )

                // Continents SVG paths
                AstronautContinentsView()

                // Clouds
                AstronautCloudsView()

                // Sun light effect (top-left)
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
                    .offset(x: -280 * 0.12 - 140, y: 280 * 0.05 - 140) // left: -12%, top: 5%

                // Sphere shading - highlight
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            center: UnitPoint(x: 0.30, y: 0.25),
                            startRadius: 0,
                            endRadius: 98
                        )
                    )

                // Sphere shading - shadow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.black.opacity(0.5), Color.clear],
                            center: UnitPoint(x: 0.75, y: 0.75),
                            startRadius: 0,
                            endRadius: 126
                        )
                    )

                // Night overlay (right half)
                AstronautNightOverlay()

                // City lights on night side
                AstronautCityLightsView()
            }
            .frame(width: 560, height: 560)
            .clipShape(Circle())
            .shadow(color: Color(hex: "4696FF").opacity(0.2), radius: 30)
            .shadow(color: Color(hex: "3278FF").opacity(0.1), radius: 60)
        }
    }
}

// MARK: - Night Overlay

struct AstronautNightOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Right half with curved left edge
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: true
        )
        return path
    }
}

extension AstronautNightOverlay: View {
    var body: some View {
        self
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
    }
}

// MARK: - Continents View (SVG Paths)

struct AstronautContinentsView: View {
    var body: some View {
        Canvas { context, size in
            let scale = size.width / 100

            // Define gradient colors
            let forestGreen1 = Color(hex: "3d9960")
            let forestGreen2 = Color(hex: "2d7a48")
            let forestGreen3 = Color(hex: "1d5a30")

            let desertTan1 = Color(hex: "d4b896")
            let desertTan2 = Color(hex: "c4a878")
            let desertTan3 = Color(hex: "a08858")

            let iceWhite1 = Color(hex: "f0f4f8")
            let iceWhite2 = Color(hex: "d0dce8")

            // Helper to draw with forest gradient
            func drawForest(_ path: Path) {
                // Use middle forest color for Canvas (gradients not supported in Canvas fill)
                context.fill(path, with: .color(forestGreen2))
            }

            func drawDesert(_ path: Path) {
                context.fill(path, with: .color(desertTan2))
            }

            func drawIce(_ path: Path, opacity: Double = 1.0) {
                context.fill(path, with: .color(iceWhite1.opacity(opacity)))
            }

            func drawOcean(_ path: Path) {
                context.fill(path, with: .color(Color(hex: "1a70a0")))
            }

            // ========== NORTH AMERICA ==========
            var northAmerica = Path()
            northAmerica.move(to: CGPoint(x: 5 * scale, y: 8 * scale))
            northAmerica.addQuadCurve(
                to: CGPoint(x: 22 * scale, y: 6 * scale),
                control: CGPoint(x: 15 * scale, y: 5 * scale)
            )
            northAmerica.addQuadCurve(
                to: CGPoint(x: 34 * scale, y: 12 * scale),
                control: CGPoint(x: 28 * scale, y: 7 * scale)
            )
            northAmerica.addQuadCurve(
                to: CGPoint(x: 32 * scale, y: 20 * scale),
                control: CGPoint(x: 35 * scale, y: 15 * scale)
            )
            northAmerica.addLine(to: CGPoint(x: 30 * scale, y: 22 * scale))
            northAmerica.addQuadCurve(
                to: CGPoint(x: 28 * scale, y: 28 * scale),
                control: CGPoint(x: 31 * scale, y: 24 * scale)
            )
            northAmerica.addQuadCurve(
                to: CGPoint(x: 22 * scale, y: 28 * scale),
                control: CGPoint(x: 24 * scale, y: 29 * scale)
            )
            northAmerica.addLine(to: CGPoint(x: 20 * scale, y: 30 * scale))
            northAmerica.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 35 * scale),
                control: CGPoint(x: 21 * scale, y: 32 * scale)
            )
            northAmerica.addLine(to: CGPoint(x: 16 * scale, y: 38 * scale))
            northAmerica.addQuadCurve(
                to: CGPoint(x: 14 * scale, y: 43 * scale),
                control: CGPoint(x: 17 * scale, y: 40 * scale)
            )
            northAmerica.addQuadCurve(
                to: CGPoint(x: 12 * scale, y: 38 * scale),
                control: CGPoint(x: 11 * scale, y: 40 * scale)
            )
            northAmerica.addQuadCurve(
                to: CGPoint(x: 7 * scale, y: 28 * scale),
                control: CGPoint(x: 8 * scale, y: 32 * scale)
            )
            northAmerica.addQuadCurve(
                to: CGPoint(x: 4 * scale, y: 14 * scale),
                control: CGPoint(x: 4 * scale, y: 18 * scale)
            )
            northAmerica.addQuadCurve(
                to: CGPoint(x: 5 * scale, y: 8 * scale),
                control: CGPoint(x: 4 * scale, y: 10 * scale)
            )
            northAmerica.closeSubpath()
            drawForest(northAmerica)

            // Florida
            var florida = Path()
            florida.move(to: CGPoint(x: 20 * scale, y: 30 * scale))
            florida.addQuadCurve(
                to: CGPoint(x: 22 * scale, y: 37 * scale),
                control: CGPoint(x: 23 * scale, y: 34 * scale)
            )
            florida.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 35 * scale),
                control: CGPoint(x: 19 * scale, y: 37 * scale)
            )
            florida.closeSubpath()
            drawForest(florida)

            // Great Lakes (indent/water)
            var greatLakes = Path()
            greatLakes.addEllipse(in: CGRect(x: 19 * scale, y: 18 * scale, width: 6 * scale, height: 4 * scale))
            drawOcean(greatLakes)

            // ========== CENTRAL AMERICA ==========
            var centralAmerica = Path()
            centralAmerica.move(to: CGPoint(x: 14 * scale, y: 43 * scale))
            centralAmerica.addQuadCurve(
                to: CGPoint(x: 16 * scale, y: 48 * scale),
                control: CGPoint(x: 17 * scale, y: 46 * scale)
            )
            centralAmerica.addQuadCurve(
                to: CGPoint(x: 12 * scale, y: 50 * scale),
                control: CGPoint(x: 13 * scale, y: 51 * scale)
            )
            centralAmerica.addQuadCurve(
                to: CGPoint(x: 14 * scale, y: 43 * scale),
                control: CGPoint(x: 12 * scale, y: 45 * scale)
            )
            centralAmerica.closeSubpath()
            drawForest(centralAmerica)

            // ========== SOUTH AMERICA ==========
            var southAmerica = Path()
            southAmerica.move(to: CGPoint(x: 18 * scale, y: 52 * scale))
            southAmerica.addQuadCurve(
                to: CGPoint(x: 30 * scale, y: 54 * scale),
                control: CGPoint(x: 27 * scale, y: 51 * scale)
            )
            southAmerica.addQuadCurve(
                to: CGPoint(x: 30 * scale, y: 70 * scale),
                control: CGPoint(x: 32 * scale, y: 64 * scale)
            )
            southAmerica.addQuadCurve(
                to: CGPoint(x: 22 * scale, y: 86 * scale),
                control: CGPoint(x: 25 * scale, y: 82 * scale)
            )
            southAmerica.addQuadCurve(
                to: CGPoint(x: 17 * scale, y: 84 * scale),
                control: CGPoint(x: 18 * scale, y: 87 * scale)
            )
            southAmerica.addQuadCurve(
                to: CGPoint(x: 17 * scale, y: 68 * scale),
                control: CGPoint(x: 16 * scale, y: 74 * scale)
            )
            southAmerica.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 52 * scale),
                control: CGPoint(x: 16 * scale, y: 56 * scale)
            )
            southAmerica.closeSubpath()
            drawForest(southAmerica)

            // Amazon basin highlight
            var amazon = Path()
            amazon.addEllipse(in: CGRect(x: 20 * scale, y: 55 * scale, width: 8 * scale, height: 6 * scale))
            context.fill(amazon, with: .color(Color(hex: "4aaa68").opacity(0.5)))

            // ========== GREENLAND ==========
            var greenland = Path()
            greenland.move(to: CGPoint(x: 30 * scale, y: 2 * scale))
            greenland.addQuadCurve(
                to: CGPoint(x: 44 * scale, y: 7 * scale),
                control: CGPoint(x: 42 * scale, y: 3 * scale)
            )
            greenland.addQuadCurve(
                to: CGPoint(x: 39 * scale, y: 17 * scale),
                control: CGPoint(x: 43 * scale, y: 15 * scale)
            )
            greenland.addQuadCurve(
                to: CGPoint(x: 29 * scale, y: 12 * scale),
                control: CGPoint(x: 31 * scale, y: 16 * scale)
            )
            greenland.addQuadCurve(
                to: CGPoint(x: 30 * scale, y: 2 * scale),
                control: CGPoint(x: 28 * scale, y: 4 * scale)
            )
            greenland.closeSubpath()
            drawIce(greenland)

            // ========== EUROPE ==========
            var europe = Path()
            europe.move(to: CGPoint(x: 44 * scale, y: 10 * scale))
            europe.addQuadCurve(
                to: CGPoint(x: 54 * scale, y: 12 * scale),
                control: CGPoint(x: 52 * scale, y: 10 * scale)
            )
            europe.addQuadCurve(
                to: CGPoint(x: 54 * scale, y: 19 * scale),
                control: CGPoint(x: 56 * scale, y: 17 * scale)
            )
            europe.addQuadCurve(
                to: CGPoint(x: 52 * scale, y: 25 * scale),
                control: CGPoint(x: 55 * scale, y: 24 * scale)
            )
            europe.addQuadCurve(
                to: CGPoint(x: 46 * scale, y: 24 * scale),
                control: CGPoint(x: 48 * scale, y: 25 * scale)
            )
            europe.addLine(to: CGPoint(x: 45 * scale, y: 27 * scale))
            europe.addQuadCurve(
                to: CGPoint(x: 43 * scale, y: 33 * scale),
                control: CGPoint(x: 46 * scale, y: 32 * scale)
            )
            europe.addQuadCurve(
                to: CGPoint(x: 41 * scale, y: 26 * scale),
                control: CGPoint(x: 40 * scale, y: 29 * scale)
            )
            europe.addQuadCurve(
                to: CGPoint(x: 39 * scale, y: 18 * scale),
                control: CGPoint(x: 38 * scale, y: 21 * scale)
            )
            europe.addQuadCurve(
                to: CGPoint(x: 44 * scale, y: 10 * scale),
                control: CGPoint(x: 42 * scale, y: 12 * scale)
            )
            europe.closeSubpath()
            drawForest(europe)

            // Scandinavian Peninsula
            var scandinavia = Path()
            scandinavia.move(to: CGPoint(x: 48 * scale, y: 4 * scale))
            scandinavia.addQuadCurve(
                to: CGPoint(x: 55 * scale, y: 8 * scale),
                control: CGPoint(x: 54 * scale, y: 5 * scale)
            )
            scandinavia.addQuadCurve(
                to: CGPoint(x: 50 * scale, y: 16 * scale),
                control: CGPoint(x: 53 * scale, y: 15 * scale)
            )
            scandinavia.addQuadCurve(
                to: CGPoint(x: 47 * scale, y: 9 * scale),
                control: CGPoint(x: 47 * scale, y: 12 * scale)
            )
            scandinavia.addQuadCurve(
                to: CGPoint(x: 48 * scale, y: 4 * scale),
                control: CGPoint(x: 47 * scale, y: 6 * scale)
            )
            scandinavia.closeSubpath()
            drawForest(scandinavia)

            // UK
            var uk = Path()
            uk.move(to: CGPoint(x: 40 * scale, y: 14 * scale))
            uk.addQuadCurve(
                to: CGPoint(x: 44 * scale, y: 17 * scale),
                control: CGPoint(x: 44 * scale, y: 14 * scale)
            )
            uk.addQuadCurve(
                to: CGPoint(x: 39 * scale, y: 19 * scale),
                control: CGPoint(x: 41 * scale, y: 20 * scale)
            )
            uk.addQuadCurve(
                to: CGPoint(x: 40 * scale, y: 14 * scale),
                control: CGPoint(x: 38 * scale, y: 15 * scale)
            )
            uk.closeSubpath()
            drawForest(uk)

            // Ireland
            var ireland = Path()
            ireland.addEllipse(in: CGRect(x: 35 * scale, y: 14.5 * scale, width: 4 * scale, height: 5 * scale))
            drawForest(ireland)

            // Italy boot
            var italy = Path()
            italy.move(to: CGPoint(x: 47 * scale, y: 26 * scale))
            italy.addQuadCurve(
                to: CGPoint(x: 48 * scale, y: 33 * scale),
                control: CGPoint(x: 49 * scale, y: 30 * scale)
            )
            italy.addQuadCurve(
                to: CGPoint(x: 45 * scale, y: 32 * scale),
                control: CGPoint(x: 45 * scale, y: 34 * scale)
            )
            italy.addQuadCurve(
                to: CGPoint(x: 47 * scale, y: 26 * scale),
                control: CGPoint(x: 44 * scale, y: 27 * scale)
            )
            italy.closeSubpath()
            drawForest(italy)

            // Iberian Peninsula (desert color)
            var iberia = Path()
            iberia.move(to: CGPoint(x: 38 * scale, y: 22 * scale))
            iberia.addQuadCurve(
                to: CGPoint(x: 42 * scale, y: 26 * scale),
                control: CGPoint(x: 43 * scale, y: 23 * scale)
            )
            iberia.addQuadCurve(
                to: CGPoint(x: 36 * scale, y: 27 * scale),
                control: CGPoint(x: 38 * scale, y: 29 * scale)
            )
            iberia.addQuadCurve(
                to: CGPoint(x: 38 * scale, y: 22 * scale),
                control: CGPoint(x: 35 * scale, y: 23 * scale)
            )
            iberia.closeSubpath()
            drawDesert(iberia)

            // ========== AFRICA ==========
            var africa = Path()
            africa.move(to: CGPoint(x: 40 * scale, y: 30 * scale))
            africa.addQuadCurve(
                to: CGPoint(x: 56 * scale, y: 34 * scale),
                control: CGPoint(x: 52 * scale, y: 30 * scale)
            )
            africa.addQuadCurve(
                to: CGPoint(x: 66 * scale, y: 38 * scale),
                control: CGPoint(x: 64 * scale, y: 34 * scale)
            )
            africa.addQuadCurve(
                to: CGPoint(x: 64 * scale, y: 54 * scale),
                control: CGPoint(x: 66 * scale, y: 48 * scale)
            )
            africa.addQuadCurve(
                to: CGPoint(x: 54 * scale, y: 70 * scale),
                control: CGPoint(x: 58 * scale, y: 66 * scale)
            )
            africa.addQuadCurve(
                to: CGPoint(x: 44 * scale, y: 66 * scale),
                control: CGPoint(x: 46 * scale, y: 70 * scale)
            )
            africa.addQuadCurve(
                to: CGPoint(x: 40 * scale, y: 46 * scale),
                control: CGPoint(x: 40 * scale, y: 52 * scale)
            )
            africa.addQuadCurve(
                to: CGPoint(x: 40 * scale, y: 30 * scale),
                control: CGPoint(x: 38 * scale, y: 34 * scale)
            )
            africa.closeSubpath()
            drawForest(africa)

            // Sahara desert overlay
            var sahara = Path()
            sahara.move(to: CGPoint(x: 42 * scale, y: 32 * scale))
            sahara.addQuadCurve(
                to: CGPoint(x: 58 * scale, y: 36 * scale),
                control: CGPoint(x: 56 * scale, y: 32 * scale)
            )
            sahara.addQuadCurve(
                to: CGPoint(x: 44 * scale, y: 40 * scale),
                control: CGPoint(x: 50 * scale, y: 42 * scale)
            )
            sahara.addQuadCurve(
                to: CGPoint(x: 42 * scale, y: 32 * scale),
                control: CGPoint(x: 40 * scale, y: 34 * scale)
            )
            sahara.closeSubpath()
            drawDesert(sahara)

            // Madagascar
            var madagascar = Path()
            madagascar.move(to: CGPoint(x: 66 * scale, y: 58 * scale))
            madagascar.addQuadCurve(
                to: CGPoint(x: 70 * scale, y: 62 * scale),
                control: CGPoint(x: 70 * scale, y: 58 * scale)
            )
            madagascar.addQuadCurve(
                to: CGPoint(x: 65 * scale, y: 66 * scale),
                control: CGPoint(x: 67 * scale, y: 68 * scale)
            )
            madagascar.addQuadCurve(
                to: CGPoint(x: 66 * scale, y: 58 * scale),
                control: CGPoint(x: 64 * scale, y: 60 * scale)
            )
            madagascar.closeSubpath()
            drawForest(madagascar)

            // ========== MIDDLE EAST / ARABIAN PENINSULA ==========
            var arabia = Path()
            arabia.move(to: CGPoint(x: 58 * scale, y: 28 * scale))
            arabia.addQuadCurve(
                to: CGPoint(x: 70 * scale, y: 32 * scale),
                control: CGPoint(x: 68 * scale, y: 28 * scale)
            )
            arabia.addQuadCurve(
                to: CGPoint(x: 64 * scale, y: 42 * scale),
                control: CGPoint(x: 68 * scale, y: 40 * scale)
            )
            arabia.addQuadCurve(
                to: CGPoint(x: 56 * scale, y: 36 * scale),
                control: CGPoint(x: 56 * scale, y: 40 * scale)
            )
            arabia.addQuadCurve(
                to: CGPoint(x: 58 * scale, y: 28 * scale),
                control: CGPoint(x: 56 * scale, y: 29 * scale)
            )
            arabia.closeSubpath()
            drawDesert(arabia)

            // ========== RUSSIA / NORTHERN ASIA ==========
            var russia = Path()
            russia.move(to: CGPoint(x: 56 * scale, y: 6 * scale))
            russia.addQuadCurve(
                to: CGPoint(x: 84 * scale, y: 8 * scale),
                control: CGPoint(x: 75 * scale, y: 5 * scale)
            )
            russia.addQuadCurve(
                to: CGPoint(x: 96 * scale, y: 22 * scale),
                control: CGPoint(x: 97 * scale, y: 16 * scale)
            )
            russia.addQuadCurve(
                to: CGPoint(x: 80 * scale, y: 27 * scale),
                control: CGPoint(x: 88 * scale, y: 28 * scale)
            )
            russia.addQuadCurve(
                to: CGPoint(x: 58 * scale, y: 20 * scale),
                control: CGPoint(x: 64 * scale, y: 24 * scale)
            )
            russia.addQuadCurve(
                to: CGPoint(x: 56 * scale, y: 6 * scale),
                control: CGPoint(x: 54 * scale, y: 12 * scale)
            )
            russia.closeSubpath()
            drawForest(russia)

            // ========== INDIA ==========
            var india = Path()
            india.move(to: CGPoint(x: 70 * scale, y: 34 * scale))
            india.addQuadCurve(
                to: CGPoint(x: 80 * scale, y: 38 * scale),
                control: CGPoint(x: 78 * scale, y: 34 * scale)
            )
            india.addQuadCurve(
                to: CGPoint(x: 74 * scale, y: 52 * scale),
                control: CGPoint(x: 78 * scale, y: 50 * scale)
            )
            india.addQuadCurve(
                to: CGPoint(x: 68 * scale, y: 46 * scale),
                control: CGPoint(x: 68 * scale, y: 50 * scale)
            )
            india.addQuadCurve(
                to: CGPoint(x: 70 * scale, y: 34 * scale),
                control: CGPoint(x: 68 * scale, y: 36 * scale)
            )
            india.closeSubpath()
            drawForest(india)

            // ========== SOUTHEAST ASIA MAINLAND ==========
            var seAsia = Path()
            seAsia.move(to: CGPoint(x: 80 * scale, y: 36 * scale))
            seAsia.addQuadCurve(
                to: CGPoint(x: 89 * scale, y: 40 * scale),
                control: CGPoint(x: 88 * scale, y: 36 * scale)
            )
            seAsia.addQuadCurve(
                to: CGPoint(x: 80 * scale, y: 50 * scale),
                control: CGPoint(x: 84 * scale, y: 50 * scale)
            )
            seAsia.addQuadCurve(
                to: CGPoint(x: 80 * scale, y: 36 * scale),
                control: CGPoint(x: 78 * scale, y: 42 * scale)
            )
            seAsia.closeSubpath()
            drawForest(seAsia)

            // ========== CHINA / EAST ASIA ==========
            var china = Path()
            china.move(to: CGPoint(x: 78 * scale, y: 22 * scale))
            china.addQuadCurve(
                to: CGPoint(x: 94 * scale, y: 30 * scale),
                control: CGPoint(x: 92 * scale, y: 24 * scale)
            )
            china.addQuadCurve(
                to: CGPoint(x: 82 * scale, y: 40 * scale),
                control: CGPoint(x: 88 * scale, y: 40 * scale)
            )
            china.addQuadCurve(
                to: CGPoint(x: 76 * scale, y: 28 * scale),
                control: CGPoint(x: 74 * scale, y: 34 * scale)
            )
            china.addQuadCurve(
                to: CGPoint(x: 78 * scale, y: 22 * scale),
                control: CGPoint(x: 76 * scale, y: 24 * scale)
            )
            china.closeSubpath()
            drawForest(china)

            // ========== JAPAN ==========
            var japan = Path()
            japan.move(to: CGPoint(x: 92 * scale, y: 26 * scale))
            japan.addQuadCurve(
                to: CGPoint(x: 96 * scale, y: 30 * scale),
                control: CGPoint(x: 96 * scale, y: 26 * scale)
            )
            japan.addQuadCurve(
                to: CGPoint(x: 91 * scale, y: 34 * scale),
                control: CGPoint(x: 93 * scale, y: 36 * scale)
            )
            japan.addQuadCurve(
                to: CGPoint(x: 92 * scale, y: 26 * scale),
                control: CGPoint(x: 90 * scale, y: 28 * scale)
            )
            japan.closeSubpath()
            drawForest(japan)

            // ========== INDONESIA / PHILIPPINES ==========
            var indo1 = Path()
            indo1.addEllipse(in: CGRect(x: 81 * scale, y: 48.5 * scale, width: 10 * scale, height: 3 * scale))
            drawForest(indo1)

            var indo2 = Path()
            indo2.addEllipse(in: CGRect(x: 86 * scale, y: 52.8 * scale, width: 8 * scale, height: 2.4 * scale))
            drawForest(indo2)

            var indo3 = Path()
            indo3.addEllipse(in: CGRect(x: 81 * scale, y: 55 * scale, width: 6 * scale, height: 2 * scale))
            drawForest(indo3)

            // Philippines
            var philippines = Path()
            philippines.addEllipse(in: CGRect(x: 90 * scale, y: 41 * scale, width: 4 * scale, height: 6 * scale))
            drawForest(philippines)

            // ========== AUSTRALIA ==========
            var australia = Path()
            australia.move(to: CGPoint(x: 82 * scale, y: 60 * scale))
            australia.addQuadCurve(
                to: CGPoint(x: 98 * scale, y: 68 * scale),
                control: CGPoint(x: 96 * scale, y: 62 * scale)
            )
            australia.addQuadCurve(
                to: CGPoint(x: 88 * scale, y: 82 * scale),
                control: CGPoint(x: 94 * scale, y: 80 * scale)
            )
            australia.addQuadCurve(
                to: CGPoint(x: 78 * scale, y: 74 * scale),
                control: CGPoint(x: 78 * scale, y: 80 * scale)
            )
            australia.addQuadCurve(
                to: CGPoint(x: 82 * scale, y: 60 * scale),
                control: CGPoint(x: 78 * scale, y: 62 * scale)
            )
            australia.closeSubpath()
            drawDesert(australia)

            // Australian coasts (greener)
            var ausCoast = Path()
            ausCoast.move(to: CGPoint(x: 84 * scale, y: 62 * scale))
            ausCoast.addQuadCurve(
                to: CGPoint(x: 92 * scale, y: 68 * scale),
                control: CGPoint(x: 92 * scale, y: 64 * scale)
            )
            ausCoast.addQuadCurve(
                to: CGPoint(x: 84 * scale, y: 62 * scale),
                control: CGPoint(x: 86 * scale, y: 64 * scale)
            )
            ausCoast.closeSubpath()
            context.fill(ausCoast, with: .color(forestGreen2.opacity(0.6)))

            // ========== NEW ZEALAND ==========
            var nz1 = Path()
            nz1.addEllipse(in: CGRect(x: 96.5 * scale, y: 79 * scale, width: 3 * scale, height: 6 * scale))
            drawForest(nz1)

            var nz2 = Path()
            nz2.addEllipse(in: CGRect(x: 96 * scale, y: 84 * scale, width: 2 * scale, height: 4 * scale))
            drawForest(nz2)

            // ========== ANTARCTICA ==========
            var antarctica = Path()
            antarctica.move(to: CGPoint(x: 20 * scale, y: 96 * scale))
            antarctica.addQuadCurve(
                to: CGPoint(x: 80 * scale, y: 96 * scale),
                control: CGPoint(x: 50 * scale, y: 92 * scale)
            )
            antarctica.addLine(to: CGPoint(x: 80 * scale, y: 100 * scale))
            antarctica.addLine(to: CGPoint(x: 20 * scale, y: 100 * scale))
            antarctica.closeSubpath()
            drawIce(antarctica, opacity: 0.8)
        }
    }
}

// MARK: - Clouds View

struct AstronautCloudsView: View {
    var body: some View {
        GeometryReader { geo in
            let clouds: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
                (0.18, 0.06, 55, 12),
                (0.52, 0.14, 45, 10),
                (0.10, 0.26, 40, 9),
                (0.62, 0.32, 50, 11),
                (0.28, 0.44, 45, 10),
                (0.78, 0.20, 35, 8),
                (0.70, 0.50, 40, 9)
            ]

            ForEach(clouds.indices, id: \.self) { i in
                let c = clouds[i]
                Ellipse()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: c.w, height: c.h)
                    .blur(radius: 3)
                    .position(x: geo.size.width * c.x, y: geo.size.height * c.y)
            }
        }
    }
}

// MARK: - City Lights View

struct AstronautCityLightsView: View {
    var body: some View {
        GeometryReader { geo in
            // City glows (elliptical glow areas)
            let glows: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
                (0.84, 0.12, 14, 9),   // top: 12%, right: 16%
                (0.90, 0.20, 12, 8),   // top: 20%, right: 10%
                (0.94, 0.30, 16, 10),  // top: 30%, right: 6%
                (0.96, 0.42, 12, 8)    // top: 42%, right: 4%
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
                (0.80, 0.14, 3),  // top: 14%, right: 20%
                (0.86, 0.11, 3),  // top: 11%, right: 14%
                (0.87, 0.22, 3),  // top: 22%, right: 13%
                (0.92, 0.18, 4),  // top: 18%, right: 8%
                (0.90, 0.32, 3),  // top: 32%, right: 10%
                (0.95, 0.28, 4),  // top: 28%, right: 5%
                (0.88, 0.36, 3)   // top: 36%, right: 12%
            ]

            ForEach(cities.indices, id: \.self) { i in
                let c = cities[i]
                Circle()
                    .fill(Color(hex: "ffdc7d"))
                    .frame(width: c.size, height: c.size)
                    .shadow(color: Color(hex: "ffdc7d").opacity(0.9), radius: 3)
                    .shadow(color: Color(hex: "ffc864").opacity(0.5), radius: 5)
                    .position(x: geo.size.width * c.x, y: geo.size.height * c.y)
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    BreatheAstronautView(duration: 3, onComplete: {}, onBack: {})
}
