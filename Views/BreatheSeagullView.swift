//
//  BreatheSeagullView.swift
//  Dioboo
//
//  Seagull breathing experience - matches breatheseagull.html exactly
//

import SwiftUI

struct BreatheSeagullView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var cycleProgress: CGFloat = 0
    @State private var elapsedTime: TimeInterval = 0
    @State private var animationTimer: Timer?
    @State private var startTime: Date?
    @State private var timestamp: TimeInterval = 0
    @State private var isSceneVisible: Bool = false

    // Movement parameters from HTML
    private let skyHeight: CGFloat = 180
    private let waterDepth: CGFloat = 60
    private let cycleDuration: TimeInterval = 10.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                Color(hex: "1a4a6a")
                    .ignoresSafeArea()

                // Scene container with fade in
                ZStack {
                    // Sky gradient - exact from HTML (top 60%)
                    // #1a4a6a 0%, #2a6a8a 25%, #4a9aba 55%, #7ac4e4 80%, #a8e0f8 100%
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex: "1a4a6a"), location: 0.0),
                            .init(color: Color(hex: "2a6a8a"), location: 0.25),
                            .init(color: Color(hex: "4a9aba"), location: 0.55),
                            .init(color: Color(hex: "7ac4e4"), location: 0.80),
                            .init(color: Color(hex: "a8e0f8"), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geo.size.height * 0.6)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.3)

                    // Clouds
                    SeagullCloudsLayer()
                        .frame(width: geo.size.width, height: geo.size.height * 0.6)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.3)

                    // Ocean (bottom 48%)
                    SeagullOceanView(
                        cycleProgress: cycleProgress,
                        skyHeight: skyHeight,
                        waterDepth: waterDepth
                    )
                    .frame(width: geo.size.width * 1.2, height: geo.size.height * 0.48 * 1.2)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.76)

                    // Horizon elements (island) - at 52% from top, right side (8% from right)
                    SeagullIslandView()
                        .position(x: geo.size.width * 0.92, y: geo.size.height * 0.52 - 5)

                    // Sailboats layer (z-index: 15 in HTML)
                    SeagullSailboatsLayer(screenWidth: geo.size.width, screenHeight: geo.size.height)

                    // Seagull (z-index: 10 in HTML) - centered at 52% from top
                    SeagullBirdView(
                        cycleProgress: cycleProgress,
                        timestamp: timestamp,
                        skyHeight: skyHeight,
                        waterDepth: waterDepth
                    )
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.52)

                    // UI Overlay (z-index: 90 in HTML)
                    VStack {
                        // Back button - glass effect matching HTML exactly
                        HStack {
                            Button(action: onBack) {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .blur(radius: 10)
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
                        // font-size: 22px, letter-spacing: 6px, color: #F5F7FF
                        // text-shadow: 0 2px 15px rgba(0, 50, 100, 0.4)
                        Text(isInhaling ? "INHALE" : "EXHALE")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(Color(hex: "F5F7FF"))
                            .tracking(6)
                            .shadow(color: Color(red: 0, green: 50/255, blue: 100/255).opacity(0.4), radius: 15, x: 0, y: 2)
                            .padding(.bottom, 32)

                        // Timer text - font-size: 15px, font-weight: 300, color: rgba(255,255,255,0.8)
                        Text(formatTime(remaining: max(0, Double(duration * 60) - elapsedTime)))
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(.bottom, 38)

                        // Progress bar - height: 3px, background: rgba(255,255,255,0.2)
                        GeometryReader { progressGeo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 3)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: progressGeo.size.width * CGFloat(elapsedTime / Double(duration * 60)), height: 3)
                            }
                        }
                        .frame(height: 3)
                        .padding(.horizontal, 45)
                        .padding(.bottom, 50)
                    }
                }
                .opacity(isSceneVisible ? 1 : 0)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            // Fade in animation matching HTML (0.3s delay, 1s fade)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 1.0)) {
                    isSceneVisible = true
                }
            }
            // Start animation after 1.2s (matching HTML setTimeout)
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
            elapsedTime = elapsed
            timestamp = elapsed * 1000 // Convert to milliseconds like HTML

            // Check if complete
            if elapsed >= Double(duration * 60) {
                animationTimer?.invalidate()
                onComplete()
                return
            }

            // Calculate cycle progress (0 to 1)
            let progress = (elapsed.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration
            cycleProgress = progress

            // Update phase
            isInhaling = progress < 0.5
        }
    }
}

// MARK: - Clouds Layer
// From HTML:
// cloud-1: top: 6%, left: 5%, width: 100px, height: 35px, opacity: 0.25, animation: 45s, +40px
// cloud-2: top: 18%, left: 55%, width: 120px, height: 40px, opacity: 0.2, animation: 60s, -50px
// cloud-3: top: 30%, left: 20%, width: 80px, height: 25px, opacity: 0.15, animation: 50s, +30px
// cloud-4: top: 12%, left: -20%, width: 140px, height: 45px, opacity: 0.18, animation: 70s linear, +450px
// cloud-5: top: 38%, left: 70%, width: 90px, height: 30px, opacity: 0.12, animation: 55s, -35px

struct SeagullCloudsLayer: View {
    @State private var cloud1Offset: CGFloat = 0
    @State private var cloud2Offset: CGFloat = 0
    @State private var cloud3Offset: CGFloat = 0
    @State private var cloud4Offset: CGFloat = 0
    @State private var cloud5Offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Cloud 1: top: 6%, left: 5%, 100x35, opacity: 0.25
                Ellipse()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 100, height: 35)
                    .blur(radius: 20)
                    .offset(x: cloud1Offset)
                    .position(x: geo.size.width * 0.05 + 50, y: geo.size.height * 0.06 / 0.6)

                // Cloud 2: top: 18%, left: 55%, 120x40, opacity: 0.2
                Ellipse()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 40)
                    .blur(radius: 20)
                    .offset(x: cloud2Offset)
                    .position(x: geo.size.width * 0.55 + 60, y: geo.size.height * 0.18 / 0.6)

                // Cloud 3: top: 30%, left: 20%, 80x25, opacity: 0.15
                Ellipse()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 80, height: 25)
                    .blur(radius: 20)
                    .offset(x: cloud3Offset)
                    .position(x: geo.size.width * 0.20 + 40, y: geo.size.height * 0.30 / 0.6)

                // Cloud 4: top: 12%, left: -20%, 140x45, opacity: 0.18 (linear continuous)
                Ellipse()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 140, height: 45)
                    .blur(radius: 20)
                    .offset(x: cloud4Offset)
                    .position(x: geo.size.width * -0.20 + 70, y: geo.size.height * 0.12 / 0.6)

                // Cloud 5: top: 38%, left: 70%, 90x30, opacity: 0.12
                Ellipse()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 90, height: 30)
                    .blur(radius: 20)
                    .offset(x: cloud5Offset)
                    .position(x: geo.size.width * 0.70 + 45, y: geo.size.height * 0.38 / 0.6)
            }
        }
        .onAppear {
            // Cloud drift animations matching HTML exactly
            withAnimation(.easeInOut(duration: 45).repeatForever(autoreverses: true)) {
                cloud1Offset = 40
            }
            withAnimation(.easeInOut(duration: 60).repeatForever(autoreverses: true)) {
                cloud2Offset = -50
            }
            withAnimation(.easeInOut(duration: 50).repeatForever(autoreverses: true)) {
                cloud3Offset = 30
            }
            // Cloud 4 is linear, goes from 0 to 450px continuously
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
// From HTML:
// Ocean gradient: #4a9aba 0%, #3a7a9a 30%, #2a5a7a 60%, #1a3a5a 100%
// Horizon glow: rgba(255, 230, 200, 0.2) 0%, rgba(255, 210, 170, 0.1) 40%, transparent 100%
// Sun path: 8px wide, gradient with rgba(255, 240, 200, 0.35) etc.
// Wave paths with animated d attribute
// Foam patches with animated cx

struct SeagullOceanView: View {
    let cycleProgress: CGFloat
    let skyHeight: CGFloat
    let waterDepth: CGFloat

    @State private var foamOffset1: CGFloat = 0
    @State private var foamOffset2: CGFloat = 0
    @State private var foamOffset3: CGFloat = 0
    @State private var foamOffset4: CGFloat = 0

    var body: some View {
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = verticalWave * (skyHeight + waterDepth) / 2 - (skyHeight - waterDepth) / 2
        let normalizedPos = (verticalPos + skyHeight) / (skyHeight + waterDepth)
        let oceanScale = 0.9 + normalizedPos * 0.2
        let oceanY = normalizedPos * 20

        GeometryReader { geo in
            ZStack {
                // Ocean gradient - exact from HTML
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "4a9aba"), location: 0.0),
                        .init(color: Color(hex: "3a7a9a"), location: 0.30),
                        .init(color: Color(hex: "2a5a7a"), location: 0.60),
                        .init(color: Color(hex: "1a3a5a"), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Horizon glow - exact from HTML
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 255/255, green: 230/255, blue: 200/255).opacity(0.2), location: 0.0),
                        .init(color: Color(red: 255/255, green: 210/255, blue: 170/255).opacity(0.1), location: 0.40),
                        .init(color: Color.clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 50)
                .position(x: geo.size.width / 2, y: 25)

                // Sun reflection path - exact from HTML (8px wide, 80% height)
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 255/255, green: 240/255, blue: 200/255).opacity(0.35), location: 0.0),
                                .init(color: Color(red: 255/255, green: 230/255, blue: 180/255).opacity(0.2), location: 0.20),
                                .init(color: Color(red: 255/255, green: 220/255, blue: 160/255).opacity(0.1), location: 0.50),
                                .init(color: Color.clear, location: 1.0)
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

                // Foam patches - exact from HTML
                // Foam 1: cx=80, cy=45, rx=15, ry=4, opacity=0.2, animation: 12s, 80->100->80
                Ellipse()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 30, height: 8)
                    .offset(x: foamOffset1)
                    .position(x: geo.size.width * 0.2, y: 45)

                // Foam 2: cx=280, cy=90, rx=20, ry=5, opacity=0.15, animation: 14s, 280->260->280
                Ellipse()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 40, height: 10)
                    .offset(x: foamOffset2)
                    .position(x: geo.size.width * 0.7, y: 90)

                // Foam 3: cx=150, cy=150, rx=12, ry=3, opacity=0.12, animation: 11s, 150->170->150
                Ellipse()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 24, height: 6)
                    .offset(x: foamOffset3)
                    .position(x: geo.size.width * 0.375, y: 150)

                // Foam 4: cx=320, cy=200, rx=18, ry=4, opacity=0.1, animation: 13s, 320->300->320
                Ellipse()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 36, height: 8)
                    .offset(x: foamOffset4)
                    .position(x: geo.size.width * 0.8, y: 200)
            }
            .scaleEffect(oceanScale)
            .offset(y: -oceanY)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                foamOffset1 = 20
            }
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                foamOffset2 = -20
            }
            withAnimation(.easeInOut(duration: 11).repeatForever(autoreverses: true)) {
                foamOffset3 = 20
            }
            withAnimation(.easeInOut(duration: 13).repeatForever(autoreverses: true)) {
                foamOffset4 = -20
            }
        }
    }
}

// Wave paths matching HTML exactly
// Wave 1: y=30, stroke: rgba(255,255,255,0.25), stroke-width: 3, dur: 6s
// Wave 2: y=70, stroke: rgba(255,255,255,0.2), stroke-width: 2, dur: 7s
// Wave 3: y=120, stroke: rgba(255,255,255,0.15), stroke-width: 2, dur: 8s
// Wave 4: y=180, stroke: rgba(255,255,255,0.1), stroke-width: 2, dur: 9s
// Wave 5: y=250, stroke: rgba(255,255,255,0.08), stroke-width: 1.5, dur: 10s

struct SeagullWavesView: View {
    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var phase3: CGFloat = 0
    @State private var phase4: CGFloat = 0
    @State private var phase5: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Wave 1: y=30
                WavePath(amplitude: 15, wavelength: 100, phase: phase1)
                    .stroke(Color.white.opacity(0.25), lineWidth: 3)
                    .offset(y: 30)

                // Wave 2: y=70
                WavePath(amplitude: 15, wavelength: 100, phase: phase2)
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .offset(y: 70)

                // Wave 3: y=120
                WavePath(amplitude: 15, wavelength: 100, phase: phase3)
                    .stroke(Color.white.opacity(0.15), lineWidth: 2)
                    .offset(y: 120)

                // Wave 4: y=180
                WavePath(amplitude: 15, wavelength: 100, phase: phase4)
                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    .offset(y: 180)

                // Wave 5: y=250
                WavePath(amplitude: 15, wavelength: 100, phase: phase5)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1.5)
                    .offset(y: 250)
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
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                phase5 = .pi
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
        path.move(to: CGPoint(x: -50, y: rect.midY))

        for x in stride(from: -50, through: rect.width + 200, by: 5) {
            let y = rect.midY + amplitude * sin((x / wavelength) * 2 * .pi + phase)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

// MARK: - Island View
// From HTML SVG:
// Sand mound: ellipse cx=28 cy=38 rx=26 ry=8 fill=#d4b896
//             ellipse cx=28 cy=36 rx=22 ry=6 fill=#e0c9a6
// Palm trunk: path M28,36 Q26,28 28,18 stroke=#8b6914 stroke-width=3
// Palm leaves with various rotations and colors

struct SeagullIslandView: View {
    var body: some View {
        Canvas { context, size in
            // Sand mound - bottom ellipse
            let sandPath1 = Path(ellipseIn: CGRect(x: 2, y: 30, width: 52, height: 16))
            context.fill(sandPath1, with: .color(Color(hex: "d4b896")))

            // Sand mound - top ellipse
            let sandPath2 = Path(ellipseIn: CGRect(x: 6, y: 30, width: 44, height: 12))
            context.fill(sandPath2, with: .color(Color(hex: "e0c9a6")))

            // Palm trunk
            var trunkPath = Path()
            trunkPath.move(to: CGPoint(x: 28, y: 36))
            trunkPath.addQuadCurve(to: CGPoint(x: 28, y: 18), control: CGPoint(x: 26, y: 28))
            context.stroke(trunkPath, with: .color(Color(hex: "8b6914")), style: StrokeStyle(lineWidth: 3, lineCap: .round))

            // Palm leaves - approximate rotations with positions
            // Leaf 1: cx=20, cy=16, rx=10, ry=4, fill=#5a9a4a, rotate -25
            context.drawLayer { ctx in
                ctx.translateBy(x: 20, y: 16)
                ctx.rotate(by: .degrees(-25))
                let leaf1 = Path(ellipseIn: CGRect(x: -10, y: -4, width: 20, height: 8))
                ctx.fill(leaf1, with: .color(Color(hex: "5a9a4a")))
            }

            // Leaf 2: cx=36, cy=16, rx=10, ry=4, fill=#4a8a3a, rotate 25
            context.drawLayer { ctx in
                ctx.translateBy(x: 36, y: 16)
                ctx.rotate(by: .degrees(25))
                let leaf2 = Path(ellipseIn: CGRect(x: -10, y: -4, width: 20, height: 8))
                ctx.fill(leaf2, with: .color(Color(hex: "4a8a3a")))
            }

            // Leaf 3: cx=28, cy=12, rx=8, ry=4, fill=#6aaa5a, rotate -5
            context.drawLayer { ctx in
                ctx.translateBy(x: 28, y: 12)
                ctx.rotate(by: .degrees(-5))
                let leaf3 = Path(ellipseIn: CGRect(x: -8, y: -4, width: 16, height: 8))
                ctx.fill(leaf3, with: .color(Color(hex: "6aaa5a")))
            }

            // Leaf 4: cx=24, cy=14, rx=9, ry=3.5, fill=#5a9a4a, rotate -40
            context.drawLayer { ctx in
                ctx.translateBy(x: 24, y: 14)
                ctx.rotate(by: .degrees(-40))
                let leaf4 = Path(ellipseIn: CGRect(x: -9, y: -3.5, width: 18, height: 7))
                ctx.fill(leaf4, with: .color(Color(hex: "5a9a4a")))
            }

            // Leaf 5: cx=32, cy=14, rx=9, ry=3.5, fill=#4a8a3a, rotate 40
            context.drawLayer { ctx in
                ctx.translateBy(x: 32, y: 14)
                ctx.rotate(by: .degrees(40))
                let leaf5 = Path(ellipseIn: CGRect(x: -9, y: -3.5, width: 18, height: 7))
                ctx.fill(leaf5, with: .color(Color(hex: "4a8a3a")))
            }
        }
        .frame(width: 55, height: 45)
    }
}

// MARK: - Sailboats Layer
// From HTML:
// Sailboat 1: bottom: 12%, width: 45px, height: 60px, bob: 3.5s, move: 50s left:-15% -> 110%
// Sailboat 2: bottom: 28%, width: 32px, height: 45px, bob: 4.5s, move: 65s left:110% -> -15% (flipped)
// Bob animation: translateY(0) rotate(-1deg) -> translateY(3px) rotate(1deg)

struct SeagullSailboatsLayer: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    @State private var boat1X: CGFloat = -0.15
    @State private var boat2X: CGFloat = 1.10
    @State private var bobOffset1: CGFloat = 0
    @State private var bobOffset2: CGFloat = 0
    @State private var bobRotation1: Double = -1
    @State private var bobRotation2: Double = -1

    var body: some View {
        ZStack {
            // Sailboat 1 - large, goes right (bottom: 12% = 88% from top)
            SeagullSailboat(size: 45, flipped: false)
                .offset(y: bobOffset1)
                .rotationEffect(.degrees(bobRotation1))
                .position(x: screenWidth * boat1X, y: screenHeight * 0.88)

            // Sailboat 2 - medium, goes left (bottom: 28% = 72% from top)
            SeagullSailboat(size: 32, flipped: true)
                .offset(y: bobOffset2)
                .rotationEffect(.degrees(bobRotation2))
                .position(x: screenWidth * boat2X, y: screenHeight * 0.72)
        }
        .onAppear {
            // Boat 1 movement: -15% to 110% over 50s
            withAnimation(.linear(duration: 50).repeatForever(autoreverses: false)) {
                boat1X = 1.10
            }
            // Boat 2 movement: 110% to -15% over 65s
            withAnimation(.linear(duration: 65).repeatForever(autoreverses: false)) {
                boat2X = -0.15
            }
            // Bob animation for boat 1
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                bobOffset1 = 3
                bobRotation1 = 1
            }
            // Bob animation for boat 2
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                bobOffset2 = 3
                bobRotation2 = 1
            }
        }
    }
}

// Sailboat SVG from HTML:
// Hull: path d="M4,28 Q12,31 20,28 L18,24 L6,24 Z" fill="#6a4a3a"
// Mast: line x1=12 y1=24 x2=12 y2=6 stroke=#5a3a2a stroke-width=1.5
// Main sail: path d="M12,7 L12,22 L21,22 Q16,14 12,7" fill=#fff opacity=0.9
// Small sail: path d="M12,9 L12,18 L5,18 Q8,13 12,9" fill=#fff opacity=0.75

struct SeagullSailboat: View {
    let size: CGFloat
    let flipped: Bool

    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 24

            if flipped {
                context.translateBy(x: canvasSize.width, y: 0)
                context.scaleBy(x: -scale, y: scale)
            } else {
                context.scaleBy(x: scale, y: scale)
            }

            // Hull - darker for flipped boat
            var hullPath = Path()
            hullPath.move(to: CGPoint(x: 4, y: 28))
            hullPath.addQuadCurve(to: CGPoint(x: 20, y: 28), control: CGPoint(x: 12, y: 31))
            hullPath.addLine(to: CGPoint(x: 18, y: 24))
            hullPath.addLine(to: CGPoint(x: 6, y: 24))
            hullPath.closeSubpath()
            context.fill(hullPath, with: .color(Color(hex: flipped ? "5a3a2a" : "6a4a3a")))

            // Mast
            var mastPath = Path()
            mastPath.move(to: CGPoint(x: 12, y: 24))
            mastPath.addLine(to: CGPoint(x: 12, y: 6))
            context.stroke(mastPath, with: .color(Color(hex: flipped ? "4a2a1a" : "5a3a2a")), lineWidth: 1.5)

            // Main sail
            var sailPath = Path()
            sailPath.move(to: CGPoint(x: 12, y: 7))
            sailPath.addLine(to: CGPoint(x: 12, y: 22))
            sailPath.addLine(to: CGPoint(x: 21, y: 22))
            sailPath.addQuadCurve(to: CGPoint(x: 12, y: 7), control: CGPoint(x: 16, y: 14))
            context.fill(sailPath, with: .color(Color.white.opacity(flipped ? 0.85 : 0.9)))

            // Small sail
            var smallSailPath = Path()
            smallSailPath.move(to: CGPoint(x: 12, y: 9))
            smallSailPath.addLine(to: CGPoint(x: 12, y: 18))
            smallSailPath.addLine(to: CGPoint(x: 5, y: 18))
            smallSailPath.addQuadCurve(to: CGPoint(x: 12, y: 9), control: CGPoint(x: 8, y: 13))
            context.fill(smallSailPath, with: .color(Color.white.opacity(flipped ? 0.7 : 0.75)))
        }
        .frame(width: size, height: size * 35 / 24)
    }
}

// MARK: - Seagull Bird View
// From HTML:
// Position: top: 52%, centered
// Movement: figure-8 pattern using cos/sin
// verticalPos = cos(cycleProgress * 2PI) * (skyHeight + waterDepth) / 2 - (skyHeight - waterDepth) / 2
// horizontalPos = sin(cycleProgress * 2PI) * 40
// pitch = verticalVelocity * 25
// roll = horizontalVelocity * 10
// wingFold = max(0, verticalVelocity * 12)
// floatOffset = sin(timestamp / 1400) * 6
// floatSway = cos(timestamp / 1800) * 4
// wingGlide = sin(timestamp / 600) * 2

struct SeagullBirdView: View {
    let cycleProgress: CGFloat
    let timestamp: TimeInterval
    let skyHeight: CGFloat
    let waterDepth: CGFloat

    var body: some View {
        // Calculate position and rotation from HTML logic exactly
        let verticalWave = cos(cycleProgress * .pi * 2)
        let verticalPos = verticalWave * (skyHeight + waterDepth) / 2 - (skyHeight - waterDepth) / 2
        let horizontalPos = sin(cycleProgress * .pi * 2) * 40

        // Velocity for banking (derivative of position)
        let horizontalVelocity = cos(cycleProgress * .pi * 2)
        let verticalVelocity = -sin(cycleProgress * .pi * 2)

        // Pitch and roll
        let pitch = verticalVelocity * 25
        let roll = horizontalVelocity * 10

        // Wing fold during dive
        let wingFold = max(0, verticalVelocity * 12)

        // Floating oscillation (independent micro-movements)
        let floatOffset = sin(timestamp / 1400) * 6
        let floatSway = cos(timestamp / 1800) * 4

        // Wing glide
        let wingGlide = sin(timestamp / 600) * 2

        // Shadow calculations
        let distanceFromWater = abs(verticalPos)
        let shadowVisibility = max(0, 1 - distanceFromWater / 100)
        let shadowScale = 0.5 + shadowVisibility * 0.5

        ZStack {
            // Shadow on water - from HTML: rgba(0,40,60,0.25), blur: 5px
            Ellipse()
                .fill(Color(red: 0, green: 40/255, blue: 60/255).opacity(0.25))
                .frame(width: 80, height: 20)
                .blur(radius: 5)
                .scaleEffect(shadowScale)
                .opacity(shadowVisibility * 0.5)
                .offset(y: 80)

            // Seagull with rotation
            SeagullShape(wingFold: wingFold, wingGlide: wingGlide)
                .frame(width: 140, height: 60)
                .rotation3DEffect(.degrees(roll), axis: (x: 0, y: 1, z: 0))
                .rotationEffect(.degrees(pitch))
        }
        .offset(x: horizontalPos + floatSway, y: verticalPos + floatOffset)
    }
}

// Seagull SVG from HTML - detailed rendering with gradients
// Body gradient: #ffffff 0%, #f0f0f0 50%, #d8d8d8 100%
// Wing gradient: #f5f5f5 0%, #e0e0e0 40%, #c0c0c0 100%
// Wing tip gradient: #3a3a3a 0%, #1a1a1a 100%
// Body: ellipse cx=70 cy=32 rx=22 ry=10
// Head: ellipse cx=95 cy=28 rx=10 ry=8
// Eye: circle cx=98 cy=26 r=2 fill=#1a1a1a
// Eye highlight: circle cx=98.5 cy=25.5 r=0.5 fill=#fff
// Beak: path fill=#e8a030, line stroke=#c08020

struct SeagullShape: View {
    let wingFold: CGFloat
    let wingGlide: CGFloat

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2  // 70 in SVG
            let centerY = size.height / 2 // 30 in SVG

            // Wing gradient colors from HTML
            let wingGradient = Gradient(colors: [
                Color(hex: "f5f5f5"),
                Color(hex: "e0e0e0"),
                Color(hex: "c0c0c0")
            ])

            // Wing tip gradient from HTML
            let wingTipGradient = Gradient(colors: [
                Color(hex: "3a3a3a"),
                Color(hex: "1a1a1a")
            ])

            // Body gradient from HTML
            let bodyGradient = Gradient(colors: [
                Color.white,
                Color(hex: "f0f0f0"),
                Color(hex: "d8d8d8")
            ])

            // Calculate wing positions with fold and glide
            let leftWingFold = wingFold + wingGlide
            let rightWingFold = -wingFold - wingGlide

            // Left wing - from HTML SVG path
            // M70,28 Q50,26 30,30 Q15,32 5,28 L8,32 Q20,35 35,32 Q55,30 70,30 Z
            var leftWingPath = Path()
            leftWingPath.move(to: CGPoint(x: centerX, y: centerY - 2))
            leftWingPath.addQuadCurve(
                to: CGPoint(x: centerX - 40, y: centerY + leftWingFold),
                control: CGPoint(x: centerX - 20, y: centerY - 4)
            )
            leftWingPath.addQuadCurve(
                to: CGPoint(x: centerX - 65, y: centerY - 2 + leftWingFold),
                control: CGPoint(x: centerX - 55, y: centerY + 2 + leftWingFold)
            )
            leftWingPath.addLine(to: CGPoint(x: centerX - 62, y: centerY + 2 + leftWingFold))
            leftWingPath.addQuadCurve(
                to: CGPoint(x: centerX - 35, y: centerY + 2 + leftWingFold * 0.5),
                control: CGPoint(x: centerX - 50, y: centerY + 5 + leftWingFold)
            )
            leftWingPath.addQuadCurve(
                to: CGPoint(x: centerX, y: centerY),
                control: CGPoint(x: centerX - 15, y: centerY)
            )
            leftWingPath.closeSubpath()

            context.fill(leftWingPath, with: .linearGradient(
                wingGradient,
                startPoint: CGPoint(x: centerX, y: centerY - 10),
                endPoint: CGPoint(x: centerX, y: centerY + 10)
            ))

            // Left wing tip (dark) - from HTML
            // M15,29 Q8,28 2,25 L5,28 Q10,31 15,30 Z
            var leftTipPath = Path()
            leftTipPath.move(to: CGPoint(x: centerX - 55, y: centerY - 1 + leftWingFold))
            leftTipPath.addQuadCurve(
                to: CGPoint(x: centerX - 68, y: centerY - 5 + leftWingFold),
                control: CGPoint(x: centerX - 62, y: centerY - 2 + leftWingFold)
            )
            leftTipPath.addLine(to: CGPoint(x: centerX - 65, y: centerY - 2 + leftWingFold))
            leftTipPath.addQuadCurve(
                to: CGPoint(x: centerX - 55, y: centerY + leftWingFold),
                control: CGPoint(x: centerX - 60, y: centerY + 1 + leftWingFold)
            )
            leftTipPath.closeSubpath()

            context.fill(leftTipPath, with: .linearGradient(
                wingTipGradient,
                startPoint: CGPoint(x: centerX - 60, y: centerY - 5),
                endPoint: CGPoint(x: centerX - 60, y: centerY + 5)
            ))

            // Right wing - mirror of left
            var rightWingPath = Path()
            rightWingPath.move(to: CGPoint(x: centerX, y: centerY - 2))
            rightWingPath.addQuadCurve(
                to: CGPoint(x: centerX + 40, y: centerY - rightWingFold),
                control: CGPoint(x: centerX + 20, y: centerY - 4)
            )
            rightWingPath.addQuadCurve(
                to: CGPoint(x: centerX + 65, y: centerY - 2 - rightWingFold),
                control: CGPoint(x: centerX + 55, y: centerY + 2 - rightWingFold)
            )
            rightWingPath.addLine(to: CGPoint(x: centerX + 62, y: centerY + 2 - rightWingFold))
            rightWingPath.addQuadCurve(
                to: CGPoint(x: centerX + 35, y: centerY + 2 - rightWingFold * 0.5),
                control: CGPoint(x: centerX + 50, y: centerY + 5 - rightWingFold)
            )
            rightWingPath.addQuadCurve(
                to: CGPoint(x: centerX, y: centerY),
                control: CGPoint(x: centerX + 15, y: centerY)
            )
            rightWingPath.closeSubpath()

            context.fill(rightWingPath, with: .linearGradient(
                wingGradient,
                startPoint: CGPoint(x: centerX, y: centerY - 10),
                endPoint: CGPoint(x: centerX, y: centerY + 10)
            ))

            // Right wing tip (dark)
            var rightTipPath = Path()
            rightTipPath.move(to: CGPoint(x: centerX + 55, y: centerY - 1 - rightWingFold))
            rightTipPath.addQuadCurve(
                to: CGPoint(x: centerX + 68, y: centerY - 5 - rightWingFold),
                control: CGPoint(x: centerX + 62, y: centerY - 2 - rightWingFold)
            )
            rightTipPath.addLine(to: CGPoint(x: centerX + 65, y: centerY - 2 - rightWingFold))
            rightTipPath.addQuadCurve(
                to: CGPoint(x: centerX + 55, y: centerY - rightWingFold),
                control: CGPoint(x: centerX + 60, y: centerY + 1 - rightWingFold)
            )
            rightTipPath.closeSubpath()

            context.fill(rightTipPath, with: .linearGradient(
                wingTipGradient,
                startPoint: CGPoint(x: centerX + 60, y: centerY - 5),
                endPoint: CGPoint(x: centerX + 60, y: centerY + 5)
            ))

            // Body - ellipse cx=70 cy=32 rx=22 ry=10
            let bodyPath = Path(ellipseIn: CGRect(x: centerX - 22, y: centerY - 8, width: 44, height: 20))
            context.fill(bodyPath, with: .linearGradient(
                bodyGradient,
                startPoint: CGPoint(x: centerX, y: centerY - 10),
                endPoint: CGPoint(x: centerX, y: centerY + 10)
            ))

            // Tail - from HTML: M48,32 Q42,30 38,32 Q42,34 48,32
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

            // Head - ellipse cx=95 cy=28 rx=10 ry=8
            let headPath = Path(ellipseIn: CGRect(x: centerX + 15, y: centerY - 10, width: 20, height: 16))
            context.fill(headPath, with: .linearGradient(
                bodyGradient,
                startPoint: CGPoint(x: centerX + 25, y: centerY - 12),
                endPoint: CGPoint(x: centerX + 25, y: centerY + 4)
            ))

            // Eye - circle cx=98 cy=26 r=2 fill=#1a1a1a
            let eyePath = Path(ellipseIn: CGRect(x: centerX + 26, y: centerY - 6, width: 4, height: 4))
            context.fill(eyePath, with: .color(Color(hex: "1a1a1a")))

            // Eye highlight - circle cx=98.5 cy=25.5 r=0.5 fill=#fff
            let eyeHighlightPath = Path(ellipseIn: CGRect(x: centerX + 27, y: centerY - 5.5, width: 1, height: 1))
            context.fill(eyeHighlightPath, with: .color(.white))

            // Beak - from HTML: M105,28 L118,30 L105,32 Q107,30 105,28 fill=#e8a030
            var beakPath = Path()
            beakPath.move(to: CGPoint(x: centerX + 35, y: centerY - 2))
            beakPath.addLine(to: CGPoint(x: centerX + 48, y: centerY))
            beakPath.addLine(to: CGPoint(x: centerX + 35, y: centerY + 2))
            beakPath.addQuadCurve(
                to: CGPoint(x: centerX + 35, y: centerY - 2),
                control: CGPoint(x: centerX + 37, y: centerY)
            )
            context.fill(beakPath, with: .color(Color(hex: "e8a030")))

            // Beak line - stroke=#c08020 stroke-width=0.5
            var beakLinePath = Path()
            beakLinePath.move(to: CGPoint(x: centerX + 35, y: centerY))
            beakLinePath.addLine(to: CGPoint(x: centerX + 48, y: centerY))
            context.stroke(beakLinePath, with: .color(Color(hex: "c08020")), lineWidth: 0.5)
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
    BreatheSeagullView(duration: 3, onComplete: {}, onBack: {})
}
