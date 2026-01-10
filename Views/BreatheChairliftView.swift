//
//  BreatheChairliftView.swift
//  Dioboo
//
//  Chairlift breathing experience - matches breathechairlift.html exactly
//

import SwiftUI

// MARK: - Main View

struct BreatheChairliftView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    // State
    @State private var isInhaling: Bool = true
    @State private var elapsedTime: Double = 0
    @State private var displayLink: Timer?
    @State private var startTime: Date?
    @State private var isAnimating: Bool = false

    // Constants matching HTML exactly
    private let inhaleDuration: Double = 5.0
    private let exhaleDuration: Double = 5.0
    private var cycleDuration: Double { inhaleDuration + exhaleDuration }
    private let cableSag: CGFloat = 55
    private let pylonBaseY: CGFloat = 380
    private let pylonSpacing: CGFloat = 300
    private let cabinScreenXRatio: CGFloat = 0.4

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            // Calculate animation state
            let totalDuration = Double(duration * 60)
            let cycleProgress = (elapsedTime.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            let currentIsInhale = cycleProgress < 0.5
            let cycleNumber = Int(elapsedTime / cycleDuration)

            // Calculate continuousT for cable position (matches HTML exactly)
            let continuousT: Double = {
                if currentIsInhale {
                    // Inhale: moving UP from sag (t=0.5) to pylon (t=1.0)
                    let inhaleProgress = easeInOutSine(cycleProgress * 2)
                    return Double(cycleNumber) + 0.5 + inhaleProgress * 0.5
                } else {
                    // Exhale: moving DOWN from pylon (t=0.0) to sag (t=0.5)
                    let exhaleProgress = easeInOutSine((cycleProgress - 0.5) * 2)
                    return Double(cycleNumber) + 1.0 + exhaleProgress * 0.5
                }
            }()

            let tInSegment = continuousT.truncatingRemainder(dividingBy: 1.0)

            // Calculate cabin Y on cable: pylonY + 4*t*(1-t)*CABLE_SAG
            let cabinCableY = pylonBaseY + cableSag * 4 * CGFloat(tInSegment) * CGFloat(1 - tInSegment)

            // Forest scroll offset
            let forestScroll = CGFloat(continuousT) * pylonSpacing * 0.8

            // Progress
            let progress = min(elapsedTime / totalDuration, 1.0)
            let remainingSeconds = max(0, Int(totalDuration - elapsedTime))

            ZStack {
                // Sky gradient - exact from HTML (top to bottom)
                LinearGradient(
                    colors: [
                        Color(hex: "5BA3C6"),
                        Color(hex: "7EC8E3"),
                        Color(hex: "98D4EA"),
                        Color(hex: "B8E6F0"),
                        Color(hex: "D0EDE8"),
                        Color(hex: "E8F4E8")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Clouds layer
                ChairliftCloudsLayer()

                // Mountains with snow caps
                ChairliftMountainsLayer(screenHeight: screenHeight)

                // Dense forest (scrolls with parallax)
                ChairliftForestLayer(offset: forestScroll, screenHeight: screenHeight)

                // Pylons (scroll)
                ChairliftPylonsLayer(
                    continuousT: continuousT,
                    pylonSpacing: pylonSpacing,
                    pylonBaseY: pylonBaseY,
                    cabinScreenX: screenWidth * cabinScreenXRatio,
                    screenHeight: screenHeight
                )

                // Cable (curved path between pylons)
                ChairliftCableView(
                    continuousT: continuousT,
                    pylonSpacing: pylonSpacing,
                    pylonBaseY: pylonBaseY,
                    cableSag: cableSag,
                    cabinScreenX: screenWidth * cabinScreenXRatio,
                    screenWidth: screenWidth
                )

                // Snowflakes
                ChairliftSnowLayer()

                // Yellow cabin - connector center must be exactly ON the cable
                // Cabin total height: connector(16) + rod(22) + body(62) = 100
                // Connector center is 8px from top
                // To position connector center at cabinCableY, offset cabin down by:
                // (totalHeight/2 - connectorRadius) = (100/2 - 8) = 42
                ChairliftCabinView()
                    .position(x: screenWidth * cabinScreenXRatio, y: cabinCableY + 42)

                // UI Overlay
                VStack {
                    // Back button - white circle (matches HTML)
                    HStack {
                        Button(action: onBack) {
                            Circle()
                                .fill(Color.white.opacity(0.95))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(Color(hex: "444444"))
                                        .font(.system(size: 18, weight: .medium))
                                )
                                .shadow(color: .black.opacity(0.25), radius: 7, y: 4)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()

                    // Phase text - exact styling from HTML
                    Text(currentIsInhale ? "INHALE" : "EXHALE")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .tracking(6)
                        .shadow(color: .black.opacity(0.6), radius: 8, y: 2)

                    // Timer display
                    Text(formatTime(remainingSeconds))
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.5), radius: 5, y: 2)
                        .padding(.top, 4)

                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.4))
                            .frame(height: 5)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white)
                            .frame(width: (screenWidth - 90) * CGFloat(progress), height: 5)
                    }
                    .frame(width: screenWidth - 90)
                    .padding(.top, 20)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }

    // Easing function matching HTML
    private func easeInOutSine(_ t: Double) -> Double {
        return -(cos(Double.pi * t) - 1) / 2
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func startAnimation() {
        startTime = Date()
        isAnimating = true

        // Use a timer to update at ~60fps
        displayLink = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            guard let start = startTime else { return }
            elapsedTime = Date().timeIntervalSince(start)

            // Check completion
            let totalDuration = Double(duration * 60)
            if elapsedTime >= totalDuration {
                stopAnimation()
                onComplete()
            }
        }
    }

    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        isAnimating = false
    }
}

// MARK: - Clouds Layer

struct ChairliftCloudsLayer: View {
    // Cloud data matching HTML exactly
    private let cloudData: [(top: CGFloat, size: CGFloat, duration: Double, delay: Double)] = [
        (60, 1.0, 45, 0),
        (100, 0.7, 60, 15),
        (140, 1.2, 50, 30),
        (85, 0.5, 70, 45),
        (120, 0.8, 55, 20)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<cloudData.count, id: \.self) { i in
                ChairliftCloud(size: cloudData[i].size, duration: cloudData[i].duration, delay: cloudData[i].delay)
                    .offset(y: cloudData[i].top)
            }
        }
    }
}

struct ChairliftCloud: View {
    let size: CGFloat
    let duration: Double
    let delay: Double

    @State private var xOffset: CGFloat = -150

    var body: some View {
        ZStack {
            // Main cloud body
            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width: 50 * size, height: 25 * size)
                .blur(radius: 2)

            // Puff 1
            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width: 35 * size, height: 20 * size)
                .offset(x: 8 * size, y: -8 * size)
                .blur(radius: 2)

            // Puff 2
            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width: 30 * size, height: 18 * size)
                .offset(x: 25 * size, y: -5 * size)
                .blur(radius: 2)
        }
        .offset(x: xOffset)
        .onAppear {
            // Start at position based on delay
            xOffset = -150 + (650 * CGFloat(delay) / CGFloat(duration))

            // Animate drift from -150 to 500 (matching HTML)
            withAnimation(
                .linear(duration: duration)
                .repeatForever(autoreverses: false)
                .delay(duration - (duration * delay / duration))
            ) {
                xOffset = 500
            }
        }
    }
}

// MARK: - Mountains Layer

struct ChairliftMountainsLayer: View {
    let screenHeight: CGFloat

    // Mountain data matching HTML exactly
    private let mountainData: [(left: CGFloat, size: CGFloat, color: String)] = [
        (-100, 1.2, "7A94A8"),
        (150, 1.0, "8BA4B8"),
        (350, 1.3, "7090A5"),
        (550, 0.9, "9DB5C7"),
        (750, 1.1, "8BA4B8")
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                ForEach(0..<mountainData.count, id: \.self) { i in
                    let m = mountainData[i]
                    let baseW = 160 * m.size
                    let baseH = 200 * m.size

                    ChairliftMountain(baseWidth: baseW * 2, baseHeight: baseH, color: Color(hex: m.color), scale: m.size)
                        .position(x: m.left + baseW, y: geo.size.height * 0.7 - baseH / 2)
                }
            }
        }
    }
}

struct ChairliftMountain: View {
    let baseWidth: CGFloat
    let baseHeight: CGFloat
    let color: Color
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            // Mountain body
            Triangle()
                .fill(color)
                .frame(width: baseWidth, height: baseHeight)

            // Snow cap - Fuji style with irregular edges
            VStack(spacing: 0) {
                // Main snow triangle (top ~38%)
                let snowHeight = baseHeight * 0.38
                let snowWidth = baseWidth * 0.42

                ZStack {
                    // Main snow cap
                    Triangle()
                        .fill(Color.white)
                        .frame(width: snowWidth, height: snowHeight)

                    // Snow shadow
                    Triangle()
                        .fill(Color(hex: "C8D7E6").opacity(0.4))
                        .frame(width: snowWidth * 0.3, height: snowHeight * 0.55)
                        .offset(x: snowWidth * 0.1, y: snowHeight * 0.15)
                }

                // Snow drips (ellipses below main cap)
                HStack(spacing: 4) {
                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 12 * scale, height: 18 * scale)
                        .offset(y: -8 * scale)

                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 15 * scale, height: 22 * scale)
                        .offset(y: -2 * scale)

                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 18 * scale, height: 28 * scale)
                        .offset(y: 5 * scale)

                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 14 * scale, height: 20 * scale)
                        .offset(y: -3 * scale)

                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 10 * scale, height: 15 * scale)
                        .offset(y: -10 * scale)
                }
                .offset(y: -snowHeight * 0.4)
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Forest Layer

struct ChairliftForestLayer: View {
    let offset: CGFloat
    let screenHeight: CGFloat

    // Row configs - forest only in bottom 45% of screen (below mountains)
    // In HTML: mountains end around 55% from top, forest starts there
    // Row Y positions are from BOTTOM of screen
    // We clip the forest to only show below mountains
    private let rowConfigs: [(bottomRatio: CGFloat, scale: CGFloat, colors: [String], count: Int, spacing: CGFloat, parallax: CGFloat)] = [
        (0.36, 0.6, ["3CB371", "2E8B57", "228B22", "32CD32"], 80, 16, 0.5),
        (0.27, 0.72, ["3CB371", "2E8B57", "228B22", "32CD32"], 75, 18, 0.6),
        (0.18, 0.85, ["006400", "008000", "1A6B1A", "228B22"], 70, 20, 0.75),
        (0.08, 1.0, ["006400", "008000", "1A6B1A", "228B22"], 65, 22, 0.9),
        (-0.03, 1.15, ["006400", "008000", "1A6B1A", "228B22"], 60, 25, 1.0)
    ]

    var body: some View {
        GeometryReader { geo in
            // Forest is clipped to only show in bottom 50% of screen
            // This prevents trees from appearing on the mountains
            let forestTopY = geo.size.height * 0.55 // Mountains end around 55%

            ZStack {
                ForEach(0..<rowConfigs.count, id: \.self) { i in
                    let config = rowConfigs[i]
                    // Calculate Y position: bottomRatio is from bottom
                    // y = height * (1 - bottomRatio)
                    let rowY = geo.size.height * (1 - config.bottomRatio)

                    ChairliftTreeRow(
                        treeCount: config.count,
                        scale: config.scale,
                        colors: config.colors.map { Color(hex: $0) },
                        spacing: config.spacing,
                        offset: offset * config.parallax,
                        screenWidth: geo.size.width
                    )
                    .position(x: geo.size.width / 2, y: rowY)
                }
            }
            .clipShape(
                Rectangle()
                    .offset(y: forestTopY)
            )
            .mask(
                VStack(spacing: 0) {
                    Color.clear.frame(height: forestTopY)
                    Color.white
                }
            )
        }
    }
}

struct ChairliftTreeRow: View {
    let treeCount: Int
    let scale: CGFloat
    let colors: [Color]
    let spacing: CGFloat
    let offset: CGFloat
    let screenWidth: CGFloat

    @State private var treeSeeds: [UInt64] = []

    var body: some View {
        Canvas { context, size in
            let totalWidth = CGFloat(treeCount) * (spacing + 20 * scale)
            let wrappedOffset = offset.truncatingRemainder(dividingBy: totalWidth)

            for i in 0..<treeCount {
                let seed = i < treeSeeds.count ? treeSeeds[i] : UInt64(i)
                var rng = SeededRandomNumberGenerator(seed: seed)

                let baseX = CGFloat(i) * (spacing * (0.6 + CGFloat.random(in: 0...0.8, using: &rng)))
                let x = baseX - wrappedOffset

                // Skip if off screen
                if x < -50 || x > screenWidth + 50 { continue }

                let baseH = (40 + CGFloat.random(in: 0...40, using: &rng)) * scale
                let treeWidth = baseH * 0.6
                let colorIndex = Int.random(in: 0..<colors.count, using: &rng)

                // Draw 3 triangle layers
                for j in 0..<3 {
                    let layerW = treeWidth * (1 - CGFloat(j) * 0.12)
                    let layerH = baseH * 0.45
                    let yOffset = CGFloat(j) * (-layerH * 0.35)

                    let path = Path { p in
                        p.move(to: CGPoint(x: x, y: size.height / 2 - yOffset - layerH))
                        p.addLine(to: CGPoint(x: x - layerW / 2, y: size.height / 2 - yOffset))
                        p.addLine(to: CGPoint(x: x + layerW / 2, y: size.height / 2 - yOffset))
                        p.closeSubpath()
                    }
                    context.fill(path, with: .color(colors[colorIndex]))
                }
            }
        }
        .onAppear {
            // Generate stable random seeds for each tree
            treeSeeds = (0..<treeCount).map { UInt64($0 * 12345 + 67890) }
        }
    }
}

// Seeded random number generator for stable tree generation
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - Pylons Layer

struct ChairliftPylonsLayer: View {
    let continuousT: Double
    let pylonSpacing: CGFloat
    let pylonBaseY: CGFloat
    let cabinScreenX: CGFloat
    let screenHeight: CGFloat

    private let numPylons = 8

    var body: some View {
        GeometryReader { geo in
            let tInSegment = continuousT.truncatingRemainder(dividingBy: 1.0)
            let cabinSegmentLeftPylonX = cabinScreenX - CGFloat(tInSegment) * pylonSpacing

            ForEach(-2..<numPylons, id: \.self) { i in
                let screenX = cabinSegmentLeftPylonX + CGFloat(i) * pylonSpacing

                // Only draw if on screen
                if screenX > -100 && screenX < geo.size.width + 100 {
                    ChairliftPylon(
                        pylonY: pylonBaseY,
                        screenHeight: screenHeight
                    )
                    .position(x: screenX, y: pylonBaseY)
                }
            }
        }
    }
}

struct ChairliftPylon: View {
    let pylonY: CGFloat
    let screenHeight: CGFloat

    // Pylon structure from HTML:
    // - Wheel at TOP (at pylonY, where cable passes)
    // - Arm below wheel
    // - Pole extends DOWN from arm to bottom of screen

    var body: some View {
        ZStack {
            // Pole - extends from below arm to bottom of screen
            // Positioned so it starts below the wheel/arm and goes down
            let poleHeight = screenHeight - pylonY + 100
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "5A7A9A"),
                            Color(hex: "9ABBCF"),
                            Color(hex: "7A9AB8"),
                            Color(hex: "5A7A9A")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 16, height: poleHeight)
                .offset(y: poleHeight / 2 + 8) // Position below wheel
                .shadow(color: .black.opacity(0.3), radius: 6, x: 4)

            // Arm - horizontal bar below wheel
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "8AABBF"),
                            Color(hex: "6A8BA8"),
                            Color(hex: "4A6B8A")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 90, height: 16)
                .offset(y: 8) // Below wheel center
                .shadow(color: .black.opacity(0.4), radius: 5, y: 4)

            // Wheel at TOP - this is where the cable passes through
            // Centered at pylonY (where cable Y = pylonBaseY)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "9ABBCF"),
                            Color(hex: "6A8AA8"),
                            Color(hex: "4A6A88")
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 14
                    )
                )
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "3D5A6A"), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.5), radius: 4, y: 3)
        }
    }
}

// MARK: - Cable View

struct ChairliftCableView: View {
    let continuousT: Double
    let pylonSpacing: CGFloat
    let pylonBaseY: CGFloat
    let cableSag: CGFloat
    let cabinScreenX: CGFloat
    let screenWidth: CGFloat

    var body: some View {
        Canvas { context, size in
            let tInSegment = continuousT.truncatingRemainder(dividingBy: 1.0)
            let cabinSegmentLeftPylonX = cabinScreenX - CGFloat(tInSegment) * pylonSpacing

            // Generate pylon positions extending left and right
            var pylonPositions: [CGFloat] = []
            for i in -3...8 {
                pylonPositions.append(cabinSegmentLeftPylonX + CGFloat(i) * pylonSpacing)
            }

            var path = Path()
            var started = false

            for i in 0..<(pylonPositions.count - 1) {
                let screenLeftX = pylonPositions[i]
                let screenRightX = pylonPositions[i + 1]

                // Control point for quadratic bezier
                let controlX = (screenLeftX + screenRightX) / 2
                let controlY = pylonBaseY + 2 * cableSag

                if !started {
                    path.move(to: CGPoint(x: screenLeftX, y: pylonBaseY))
                    started = true
                }

                path.addQuadCurve(
                    to: CGPoint(x: screenRightX, y: pylonBaseY),
                    control: CGPoint(x: controlX, y: controlY)
                )
            }

            context.stroke(
                path,
                with: .color(Color(hex: "3D5A6A")),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Yellow Cabin

struct ChairliftCabinView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Connector circle - sits ON the cable
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "B0C8D8"),
                            Color(hex: "7A9AB8")
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "4A6A88"), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.4), radius: 3, y: 2)

            // Rod connecting to cabin
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "6A8AA8"),
                            Color(hex: "9ABBCF"),
                            Color(hex: "6A8AA8")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 4, height: 22)

            // Yellow cabin body
            ZStack {
                // Main body with gradient
                UnevenRoundedRectangle(
                    topLeadingRadius: 10,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 10
                )
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FFE566"),
                            Color(hex: "FFDA40"),
                            Color(hex: "FFC800"),
                            Color(hex: "FFB000")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 65, height: 62)
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 10,
                        bottomLeadingRadius: 16,
                        bottomTrailingRadius: 16,
                        topTrailingRadius: 10
                    )
                    .stroke(Color(hex: "E65100"), lineWidth: 4)
                )
                // Inner highlights
                .overlay(
                    VStack {
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 20)
                        Spacer()
                    }
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 8,
                        bottomLeadingRadius: 14,
                        bottomTrailingRadius: 14,
                        topTrailingRadius: 8
                    ))
                    .padding(2)
                )
                .shadow(color: .black.opacity(0.45), radius: 10, y: 8)

                // Window area
                VStack(spacing: 0) {
                    ZStack {
                        // Window background
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "C5EFFF"),
                                        Color(hex: "90D8FA"),
                                        Color(hex: "60C5F7")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 49, height: 28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(hex: "E65100"), lineWidth: 3)
                            )

                        // Window divider
                        Rectangle()
                            .fill(Color(hex: "E65100"))
                            .frame(width: 3, height: 28)

                        // Window reflection
                        VStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.7), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 43, height: 10)
                                .padding(.top, 2)
                            Spacer()
                        }
                        .frame(height: 24)
                    }
                    .offset(y: 7)

                    Spacer()

                    // Bottom stripe (orange gradient)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF9500"),
                                    Color(hex: "E65100")
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 49, height: 12)
                        .padding(.bottom, 5)
                }
                .frame(height: 62)
            }
        }
    }
}

// MARK: - Snow Layer

struct ChairliftSnowLayer: View {
    @State private var snowflakes: [ChairliftSnowflake] = []
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geo in
            ForEach(snowflakes) { flake in
                Circle()
                    .fill(Color.white.opacity(flake.opacity))
                    .frame(width: flake.size, height: flake.size)
                    .position(
                        x: flake.x * geo.size.width,
                        y: flake.y * geo.size.height
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            // Create 50 snowflakes (matching HTML)
            snowflakes = (0..<50).map { _ in ChairliftSnowflake() }
            startSnowAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startSnowAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
            for i in snowflakes.indices {
                // Move down (matching HTML: translateY from -20 to 820)
                snowflakes[i].y += snowflakes[i].speed
                // Slight horizontal drift (matching HTML: translateX 0 to 30)
                snowflakes[i].x += 0.0004

                // Reset when off screen
                if snowflakes[i].y > 1.05 {
                    snowflakes[i].y = -0.025
                    snowflakes[i].x = CGFloat.random(in: 0...1)
                }
            }
        }
    }
}

struct ChairliftSnowflake: Identifiable {
    let id = UUID()
    var x: CGFloat = CGFloat.random(in: 0...1)
    var y: CGFloat = CGFloat.random(in: -0.025...1)
    let size: CGFloat = CGFloat.random(in: 2...5) // 2-5px matching HTML
    let speed: CGFloat = CGFloat.random(in: 0.001...0.003) // Fall speed
    let opacity: Double = Double.random(in: 0.3...0.8) // 0.3-0.8 matching HTML
}

// MARK: - Preview

#Preview {
    BreatheChairliftView(duration: 3, onComplete: {}, onBack: {})
}
