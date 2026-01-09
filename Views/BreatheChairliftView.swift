//
//  BreatheChairliftView.swift
//  Dioboo
//
//  Chairlift breathing experience - matches breathechairlift.html exactly
//

import SwiftUI
import Combine

struct BreatheChairliftView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var breatheProgress: CGFloat = 0.5 // 0 = pylon, 0.5 = sag, 1 = next pylon
    @State private var forestOffset: CGFloat = 0
    @State private var pylonOffset: CGFloat = 0
    @State private var timer: Timer?

    // Breathing rhythm: 5s inhale, 5s exhale (matches HTML)
    private let breatheDuration: Double = 5.0
    private let cableSag: CGFloat = 55 // matches HTML CABLE_SAG

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sky gradient - exact from HTML
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
                ChairliftMountainsLayer()

                // Dense forest (scrolls)
                ChairliftForestLayer(offset: forestOffset)

                // Pylons (scroll)
                ChairliftPylonsLayer(offset: pylonOffset, screenHeight: geo.size.height)

                // Cable
                ChairliftCableView(pylonOffset: pylonOffset, screenWidth: geo.size.width)

                // Snowflakes
                ChairliftSnowLayer()

                // Yellow cabin
                ChairliftCabinView(
                    breatheProgress: breatheProgress,
                    cableSag: cableSag,
                    screenHeight: geo.size.height,
                    screenWidth: geo.size.width
                )

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
                    Text(isInhaling ? "INHALE" : "EXHALE")
                        .font(.custom("Nunito", size: 22).weight(.medium))
                        .foregroundColor(.white)
                        .tracking(6)
                        .shadow(color: .black.opacity(0.6), radius: 8, y: 2)
                        .padding(.bottom, 8)

                    // Timer
                    BreathingTimer(duration: duration, onComplete: onComplete)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            startBreathingCycle()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        // Start at the sag point (t=0.5, lowest position)
        // First animation: inhale - cabin goes UP (from 0.5 to 1.0)
        withAnimation(.easeInOut(duration: breatheDuration)) {
            breatheProgress = 1.0
            pylonOffset += 150
            forestOffset += 120
        }

        timer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()

            if isInhaling {
                // Inhale: cabin goes UP (from 0.5 to 1.0, sag 55→0)
                // First jump to 0.5 without animation, then animate to 1.0
                breatheProgress = 0.5
                withAnimation(.easeInOut(duration: breatheDuration)) {
                    breatheProgress = 1.0
                    pylonOffset += 150
                    forestOffset += 120
                }
            } else {
                // Exhale: cabin goes DOWN (from 0.0 to 0.5, sag 0→55)
                // First jump to 0.0 without animation, then animate to 0.5
                breatheProgress = 0.0
                withAnimation(.easeInOut(duration: breatheDuration)) {
                    breatheProgress = 0.5
                    pylonOffset += 150
                    forestOffset += 120
                }
            }
        }
    }
}

// MARK: - Clouds Layer

struct ChairliftCloudsLayer: View {
    @State private var cloudOffsets: [CGFloat] = [-150, -80, -200, -50, -120]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<5, id: \.self) { i in
                ChairliftCloud(size: [1.0, 0.7, 1.2, 0.5, 0.8][i])
                    .offset(
                        x: cloudOffsets[i],
                        y: CGFloat([60, 100, 140, 85, 120][i])
                    )
            }
        }
        .onAppear {
            // Animate clouds drifting
            withAnimation(.linear(duration: 50).repeatForever(autoreverses: false)) {
                for i in cloudOffsets.indices {
                    cloudOffsets[i] = 500
                }
            }
        }
    }
}

struct ChairliftCloud: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width: 50 * size, height: 25 * size)
                .blur(radius: 2)

            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width: 35 * size, height: 20 * size)
                .offset(x: 8 * size, y: -8 * size)
                .blur(radius: 2)

            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width: 30 * size, height: 18 * size)
                .offset(x: 25 * size, y: -5 * size)
                .blur(radius: 2)
        }
    }
}

// MARK: - Mountains Layer

struct ChairliftMountainsLayer: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background mountains
                ChairliftMountain(baseWidth: 192, baseHeight: 240, color: Color(hex: "7A94A8"))
                    .offset(x: -100, y: geo.size.height * 0.35)

                ChairliftMountain(baseWidth: 160, baseHeight: 200, color: Color(hex: "8BA4B8"))
                    .offset(x: 75, y: geo.size.height * 0.38)

                ChairliftMountain(baseWidth: 208, baseHeight: 260, color: Color(hex: "7090A5"))
                    .offset(x: 175, y: geo.size.height * 0.33)

                ChairliftMountain(baseWidth: 144, baseHeight: 180, color: Color(hex: "9DB5C7"))
                    .offset(x: 275, y: geo.size.height * 0.40)
            }
        }
    }
}

struct ChairliftMountain: View {
    let baseWidth: CGFloat
    let baseHeight: CGFloat
    let color: Color

    var body: some View {
        ZStack(alignment: .top) {
            // Mountain body
            Triangle()
                .fill(color)
                .frame(width: baseWidth, height: baseHeight)

            // Snow cap with drips (Fuji style)
            VStack(spacing: 0) {
                // Main snow triangle
                Triangle()
                    .fill(Color.white)
                    .frame(width: baseWidth * 0.42, height: baseHeight * 0.38)

                // Snow drips
                HStack(spacing: 8) {
                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 14, height: 22)
                        .offset(y: -5)
                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 18, height: 28)
                        .offset(y: -2)
                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 14, height: 20)
                        .offset(y: -8)
                }
                .offset(y: -baseHeight * 0.15)
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

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Multiple rows of trees at different depths
                ChairliftTreeRow(
                    treeCount: 40,
                    scale: 0.6,
                    colors: [Color(hex: "3CB371"), Color(hex: "2E8B57")],
                    yPosition: geo.size.height * 0.55,
                    offset: offset * 0.6
                )

                ChairliftTreeRow(
                    treeCount: 35,
                    scale: 0.75,
                    colors: [Color(hex: "228B22"), Color(hex: "32CD32")],
                    yPosition: geo.size.height * 0.62,
                    offset: offset * 0.75
                )

                ChairliftTreeRow(
                    treeCount: 30,
                    scale: 0.9,
                    colors: [Color(hex: "006400"), Color(hex: "008000")],
                    yPosition: geo.size.height * 0.70,
                    offset: offset * 0.9
                )

                ChairliftTreeRow(
                    treeCount: 25,
                    scale: 1.1,
                    colors: [Color(hex: "006400"), Color(hex: "1A6B1A")],
                    yPosition: geo.size.height * 0.80,
                    offset: offset
                )
            }
        }
    }
}

struct ChairliftTreeRow: View {
    let treeCount: Int
    let scale: CGFloat
    let colors: [Color]
    let yPosition: CGFloat
    let offset: CGFloat

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 12 * scale) {
                ForEach(0..<treeCount, id: \.self) { i in
                    ChairliftTree(
                        height: CGFloat.random(in: 40...60) * scale,
                        color: colors[i % colors.count]
                    )
                }
            }
            .offset(x: -offset.truncatingRemainder(dividingBy: geo.size.width * 2))
            .position(x: geo.size.width / 2, y: yPosition)
        }
    }
}

struct ChairliftTree: View {
    let height: CGFloat
    let color: Color

    var body: some View {
        VStack(spacing: -height * 0.15) {
            // Three triangular layers
            ForEach(0..<3, id: \.self) { i in
                Triangle()
                    .fill(color)
                    .frame(width: height * 0.6 * (1 - CGFloat(i) * 0.1), height: height * 0.45)
            }
        }
    }
}

// MARK: - Pylons Layer

struct ChairliftPylonsLayer: View {
    let offset: CGFloat
    let screenHeight: CGFloat

    private let pylonSpacing: CGFloat = 300
    private let pylonBaseY: CGFloat = 0.48 // 48% from top

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<6, id: \.self) { i in
                ChairliftPylon(poleHeight: screenHeight * 0.55)
                    .position(
                        x: CGFloat(i) * pylonSpacing - offset.truncatingRemainder(dividingBy: pylonSpacing * 3) + 150,
                        y: geo.size.height * pylonBaseY
                    )
            }
        }
    }
}

struct ChairliftPylon: View {
    let poleHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            // Wheel at top
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "9ABBCF"), Color(hex: "6A8AA8"), Color(hex: "4A6A88")],
                        center: .init(x: 0.3, y: 0.3),
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

            // Arm
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "8AABBF"), Color(hex: "6A8BA8"), Color(hex: "4A6B8A")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 90, height: 16)
                .offset(y: -14)
                .shadow(color: .black.opacity(0.4), radius: 5, y: 4)

            // Pole
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "5A7A9A"), Color(hex: "9ABBCF"), Color(hex: "7A9AB8"), Color(hex: "5A7A9A")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 16, height: poleHeight)
                .shadow(color: .black.opacity(0.3), radius: 6, x: 4)
        }
    }
}

// MARK: - Cable View

struct ChairliftCableView: View {
    let pylonOffset: CGFloat
    let screenWidth: CGFloat

    private let pylonSpacing: CGFloat = 300
    private let cableSag: CGFloat = 55
    private let pylonY: CGFloat = 380

    var body: some View {
        Canvas { context, size in
            var path = Path()
            let startX: CGFloat = -100
            let endX = size.width + 100

            // Draw curved cable segments
            var x = startX - pylonOffset.truncatingRemainder(dividingBy: pylonSpacing)
            path.move(to: CGPoint(x: x, y: pylonY))

            while x < endX {
                let nextX = x + pylonSpacing
                let controlX = (x + nextX) / 2
                let controlY = pylonY + 2 * cableSag

                path.addQuadCurve(
                    to: CGPoint(x: nextX, y: pylonY),
                    control: CGPoint(x: controlX, y: controlY)
                )
                x = nextX
            }

            context.stroke(
                path,
                with: .color(Color(hex: "3D5A6A")),
                lineWidth: 5
            )
        }
    }
}

// MARK: - Yellow Cabin

struct ChairliftCabinView: View {
    let breatheProgress: CGFloat
    let cableSag: CGFloat
    let screenHeight: CGFloat
    let screenWidth: CGFloat

    private let pylonY: CGFloat = 380

    // Total cabin height: connector(16) + rod(22) + body(62) = 100
    // Connector center is at 8px from top of group
    private let connectorOffset: CGFloat = 8

    var body: some View {
        // Calculate Y position based on cable curve (connector should be ON the cable)
        let sagAmount = cableSag * 4 * breatheProgress * (1 - breatheProgress)
        let cableY = pylonY + sagAmount
        // Position so connector (top of group + 8px) is at cable Y
        let cabinY = cableY + 50 - connectorOffset // 50 = half of total height

        VStack(spacing: 0) {
            // Connector (circle at top)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "B0C8D8"), Color(hex: "7A9AB8")],
                        center: .init(x: 0.3, y: 0.3),
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

            // Rod
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "6A8AA8"), Color(hex: "9ABBCF"), Color(hex: "6A8AA8")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 4, height: 22)

            // Yellow cabin body
            ZStack {
                // Main body
                RoundedRectangle(cornerRadius: 10)
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
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "E65100"), lineWidth: 4)
                    )
                    .shadow(color: .black.opacity(0.45), radius: 10, y: 8)

                // Window
                VStack(spacing: 0) {
                    ZStack {
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

                        // Divider
                        Rectangle()
                            .fill(Color(hex: "E65100"))
                            .frame(width: 3, height: 28)

                        // Window reflection
                        VStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 43, height: 10)
                            Spacer()
                        }
                        .frame(height: 24)
                    }
                    .offset(y: -10)

                    Spacer()

                    // Bottom stripe
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FF9500"), Color(hex: "E65100")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 49, height: 12)
                        .offset(y: -8)
                }
                .frame(height: 62)
            }
        }
        .position(x: screenWidth * 0.4, y: cabinY)
    }
}

// MARK: - Snow Layer

struct ChairliftSnowLayer: View {
    @State private var snowflakes: [Snowflake] = (0..<50).map { _ in Snowflake() }

    var body: some View {
        GeometryReader { geo in
            ForEach(snowflakes.indices, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(snowflakes[i].opacity))
                    .frame(width: snowflakes[i].size, height: snowflakes[i].size)
                    .position(
                        x: snowflakes[i].x * geo.size.width,
                        y: snowflakes[i].y * geo.size.height
                    )
            }
        }
        .onAppear {
            animateSnow()
        }
    }

    private func animateSnow() {
        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            for i in snowflakes.indices {
                snowflakes[i].y += snowflakes[i].speed
                snowflakes[i].x += CGFloat.random(in: -0.001...0.002)

                if snowflakes[i].y > 1.05 {
                    snowflakes[i].y = -0.05
                    snowflakes[i].x = CGFloat.random(in: 0...1)
                }
            }
        }
    }
}

struct Snowflake: Identifiable {
    let id = UUID()
    var x: CGFloat = CGFloat.random(in: 0...1)
    var y: CGFloat = CGFloat.random(in: 0...1)
    var size: CGFloat = CGFloat.random(in: 2...5)
    var speed: CGFloat = CGFloat.random(in: 0.002...0.006)
    var opacity: Double = Double.random(in: 0.3...0.8)
}

#Preview {
    BreatheChairliftView(duration: 3, onComplete: {}, onBack: {})
}
