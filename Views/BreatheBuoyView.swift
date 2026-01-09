import SwiftUI

struct BreatheBuoyView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var elapsedTime: Double = 0
    @State private var isAnimating = false

    private let cycleDuration: Double = 10.0

    private var totalDuration: Double {
        Double(duration) * 60.0
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                // Sky
                SkyLayer(height: height)

                // Horizon line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                Color(red: 0.78, green: 0.86, blue: 0.90).opacity(0.5),
                                Color(red: 0.78, green: 0.86, blue: 0.90).opacity(0.6),
                                Color(red: 0.78, green: 0.86, blue: 0.90).opacity(0.5),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .position(x: width / 2, y: height * 0.45)

                // Sea
                SeaLayer(height: height)

                // Water shimmer
                WaterShimmer(width: width, height: height, elapsedTime: elapsedTime)

                // Ships on horizon
                ShipsLayer(width: width, height: height, elapsedTime: elapsedTime)

                // Waves
                WavesLayer(width: width, height: height, elapsedTime: elapsedTime)

                // Fish swimming
                FishLayer(width: width, height: height, elapsedTime: elapsedTime)

                // Ripples around buoy
                RipplesLayer(width: width, height: height, elapsedTime: elapsedTime, cycleDuration: cycleDuration)

                // Buoy
                BuoyView(elapsedTime: elapsedTime, cycleDuration: cycleDuration)
                    .frame(width: 120, height: 200)
                    .position(x: width / 2, y: height * 0.50)

                // Clouds
                CloudsLayer(width: width, height: height, elapsedTime: elapsedTime)

                // UI Layer
                VStack {
                    HStack {
                        Button(action: onBack) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.25), lineWidth: 1)
                                    )
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()

                    // Phase text
                    let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
                    let isInhale = cycleProgress < 0.5

                    Text(isInhale ? "INHALE" : "EXHALE")
                        .font(.custom("Nunito", size: 22).weight(.regular))
                        .tracking(6)
                        .foregroundColor(.white)
                        .shadow(color: Color(red: 0, green: 0.2, blue: 0.3).opacity(0.5), radius: 15, y: 2)
                        .padding(.bottom, 8)

                    // Timer
                    let remaining = max(0, totalDuration - elapsedTime)
                    let minutes = Int(remaining) / 60
                    let seconds = Int(remaining) % 60

                    Text(String(format: "%d:%02d", minutes, seconds))
                        .font(.custom("Nunito", size: 15).weight(.light))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: Color(red: 0, green: 0.2, blue: 0.3).opacity(0.3), radius: 5, y: 1)
                        .padding(.bottom, 20)

                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.2))
                            .frame(height: 3)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.8))
                            .frame(width: max(0, (geometry.size.width - 90) * CGFloat(elapsedTime / totalDuration)), height: 3)
                    }
                    .padding(.horizontal, 45)
                    .padding(.bottom, 50)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            isAnimating = false
        }
    }

    private func startAnimation() {
        isAnimating = true
        let startTime = Date()

        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            guard isAnimating else {
                timer.invalidate()
                return
            }

            elapsedTime = Date().timeIntervalSince(startTime)

            if elapsedTime >= totalDuration {
                timer.invalidate()
                onComplete()
            }
        }
    }
}

// MARK: - Sky Layer

struct SkyLayer: View {
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color(red: 0.29, green: 0.44, blue: 0.56),
                    Color(red: 0.42, green: 0.56, blue: 0.69),
                    Color(red: 0.54, green: 0.69, blue: 0.78),
                    Color(red: 0.66, green: 0.78, blue: 0.85),
                    Color(red: 0.75, green: 0.85, blue: 0.89)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height * 0.45)

            Spacer()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Sea Layer

struct SeaLayer: View {
    let height: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: height * 0.45)

            LinearGradient(
                colors: [
                    Color(red: 0.23, green: 0.42, blue: 0.54),
                    Color(red: 0.16, green: 0.35, blue: 0.48),
                    Color(red: 0.10, green: 0.29, blue: 0.42),
                    Color(red: 0.04, green: 0.23, blue: 0.35),
                    Color(red: 0.04, green: 0.16, blue: 0.29)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Water Shimmer

struct WaterShimmer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    var body: some View {
        let shimmerOpacity = 0.5 + sin(elapsedTime / 2) * 0.15

        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        Color(red: 0.59, green: 0.78, blue: 0.86).opacity(0.15),
                        Color(red: 0.71, green: 0.86, blue: 0.94).opacity(0.2),
                        Color(red: 0.59, green: 0.78, blue: 0.86).opacity(0.15),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height * 0.20)
            .position(x: width / 2, y: height * 0.56)
            .opacity(shimmerOpacity)
    }
}

// MARK: - Clouds Layer

struct CloudsLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    var body: some View {
        let cloudOffset1 = (elapsedTime.truncatingRemainder(dividingBy: 60) / 60) * (width + 200) - 100
        let cloudOffset2 = ((elapsedTime + 20).truncatingRemainder(dividingBy: 80) / 80) * (width + 180) - 80
        let cloudOffset3 = ((elapsedTime + 40).truncatingRemainder(dividingBy: 70) / 70) * (width + 220) - 120

        ZStack {
            Ellipse()
                .fill(.white.opacity(0.24))
                .frame(width: 100, height: 30)
                .blur(radius: 15)
                .position(x: cloudOffset1, y: height * 0.08)

            Ellipse()
                .fill(.white.opacity(0.24))
                .frame(width: 80, height: 25)
                .blur(radius: 15)
                .position(x: cloudOffset2, y: height * 0.16)

            Ellipse()
                .fill(.white.opacity(0.24))
                .frame(width: 120, height: 35)
                .blur(radius: 15)
                .position(x: cloudOffset3, y: height * 0.06)
        }
        .opacity(0.4)
    }
}

// MARK: - Ships Layer

struct ShipsLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    var body: some View {
        let bobY1 = sin(elapsedTime / 2) * 2
        let bobX1 = sin(elapsedTime / 4) * 2
        let bobY2 = sin(elapsedTime / 2.25 + 1) * 1.5
        let bobX2 = sin(elapsedTime / 3) * 1.5

        ZStack {
            // Ship 1 - left
            ShipView(variant: 1)
                .frame(width: 50, height: 25)
                .position(x: width * 0.08 + bobX1, y: height * 0.435 + bobY1)

            // Ship 2 - right
            ShipView(variant: 2)
                .frame(width: 40, height: 20)
                .position(x: width * 0.88 + bobX2, y: height * 0.44 + bobY2)
        }
    }
}

// MARK: - Ship View

struct ShipView: View {
    let variant: Int

    var body: some View {
        Canvas { context, size in
            let scale = size.width / 60

            // Hull
            var hullPath = Path()
            hullPath.move(to: CGPoint(x: 5 * scale, y: 20 * scale))
            hullPath.addLine(to: CGPoint(x: 10 * scale, y: 26 * scale))
            hullPath.addLine(to: CGPoint(x: 50 * scale, y: 26 * scale))
            hullPath.addLine(to: CGPoint(x: 55 * scale, y: 20 * scale))
            hullPath.addLine(to: CGPoint(x: 50 * scale, y: 16 * scale))
            hullPath.addLine(to: CGPoint(x: 10 * scale, y: 16 * scale))
            hullPath.closeSubpath()
            context.fill(hullPath, with: .color(variant == 1 ? Color(red: 0.1, green: 0.1, blue: 0.16) : Color(red: 0.13, green: 0.13, blue: 0.19)))

            // Cabin
            let cabinRect = CGRect(x: 15 * scale, y: 10 * scale, width: 25 * scale, height: 9 * scale)
            context.fill(Path(roundedRect: cabinRect, cornerRadius: 0), with: .color(Color(red: 0.94, green: 0.94, blue: 0.94)))

            // Windows
            let windowColor = Color(red: 0.44, green: 0.63, blue: 0.75)
            for i in 0..<3 {
                let windowRect = CGRect(x: (18 + CGFloat(i) * 6) * scale, y: 12 * scale, width: 3 * scale, height: 4 * scale)
                context.fill(Path(roundedRect: windowRect, cornerRadius: 0), with: .color(windowColor))
            }

            if variant == 1 {
                // Chimney
                let chimneyRect = CGRect(x: 36 * scale, y: 3 * scale, width: 6 * scale, height: 9 * scale)
                context.fill(Path(roundedRect: chimneyRect, cornerRadius: 0), with: .color(Color(red: 0.88, green: 0.88, blue: 0.88)))

                let topRect = CGRect(x: 35 * scale, y: 1 * scale, width: 8 * scale, height: 3 * scale)
                context.fill(Path(roundedRect: topRect, cornerRadius: 0), with: .color(Color(red: 0.82, green: 0.25, blue: 0.25)))

                // Smoke
                let smokePath = Path(ellipseIn: CGRect(x: 38 * scale, y: -2 * scale, width: 8 * scale, height: 4 * scale))
                context.fill(smokePath, with: .color(Color.gray.opacity(0.5)))
            } else {
                // Upper deck
                let deckRect = CGRect(x: 18 * scale, y: 3 * scale, width: 20 * scale, height: 6 * scale)
                context.fill(Path(roundedRect: deckRect, cornerRadius: 0), with: .color(Color(red: 0.96, green: 0.96, blue: 0.96)))

                // Small chimney
                let smallChimney = CGRect(x: 32 * scale, y: 0 * scale, width: 5 * scale, height: 4 * scale)
                context.fill(Path(roundedRect: smallChimney, cornerRadius: 0), with: .color(Color(red: 0.25, green: 0.25, blue: 0.31)))
            }
        }
    }
}

// MARK: - Waves Layer

struct WavesLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    var body: some View {
        let wave1Offset = sin(elapsedTime / 3) * (width * 0.05)
        let wave2Offset = sin(elapsedTime / 3.5 - 2) * (width * 0.05)
        let wave3Offset = sin(elapsedTime / 2.5 - 4) * (width * 0.05)

        ZStack {
            WaveLineView()
                .frame(width: width * 1.2, height: 8)
                .position(x: width / 2 + wave1Offset, y: height * 0.46)
                .opacity(1)

            WaveLineView()
                .frame(width: width * 1.2, height: 8)
                .position(x: width / 2 + wave2Offset, y: height * 0.48)
                .opacity(0.7)

            WaveLineView()
                .frame(width: width * 1.2, height: 8)
                .position(x: width / 2 + wave3Offset, y: height * 0.50)
                .opacity(0.5)
        }
    }
}

// MARK: - Wave Line View

struct WaveLineView: View {
    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        Color(red: 0.39, green: 0.63, blue: 0.75).opacity(0.3),
                        Color(red: 0.47, green: 0.71, blue: 0.82).opacity(0.4),
                        Color(red: 0.39, green: 0.63, blue: 0.75).opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

// MARK: - Fish Layer

struct FishLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    var body: some View {
        let fish1Progress = elapsedTime.truncatingRemainder(dividingBy: 12) / 12
        let fish2Progress = (elapsedTime + 5).truncatingRemainder(dividingBy: 15) / 15
        let fish3Progress = (elapsedTime + 3).truncatingRemainder(dividingBy: 10) / 10
        let fish4Progress = (elapsedTime + 8).truncatingRemainder(dividingBy: 14) / 14

        ZStack {
            FishView(color: Color(red: 0.29, green: 0.44, blue: 0.56).opacity(0.6))
                .frame(width: 32, height: 16)
                .position(
                    x: width * (-0.1 + fish1Progress * 1.2),
                    y: height * 0.67 + sin(fish1Progress * .pi * 4) * 8
                )

            FishView(color: Color(red: 0.35, green: 0.50, blue: 0.56).opacity(0.5))
                .frame(width: 28, height: 14)
                .position(
                    x: width * (-0.1 + fish2Progress * 1.2),
                    y: height * 0.72 + sin(fish2Progress * .pi * 3) * 10
                )

            FishView(color: Color(red: 0.38, green: 0.56, blue: 0.63).opacity(0.5))
                .frame(width: 22, height: 11)
                .position(
                    x: width * (-0.08 + fish3Progress * 1.18),
                    y: height * 0.78 + sin(fish3Progress * .pi * 3.5) * 6
                )

            FishView(color: Color(red: 0.29, green: 0.50, blue: 0.56).opacity(0.55))
                .frame(width: 26, height: 13)
                .scaleEffect(x: -1, y: 1)
                .position(
                    x: width * (1.1 - fish4Progress * 1.2),
                    y: height * 0.70 + sin(fish4Progress * .pi * 3.2) * 7
                )
        }
    }
}

// MARK: - Fish View

struct FishView: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let scale = size.width / 40

            // Body
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: 35 * scale, y: 10 * scale))
            bodyPath.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 6 * scale),
                control: CGPoint(x: 28 * scale, y: 4 * scale)
            )
            bodyPath.addQuadCurve(
                to: CGPoint(x: 2 * scale, y: 10 * scale),
                control: CGPoint(x: 8 * scale, y: 8 * scale)
            )
            bodyPath.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 14 * scale),
                control: CGPoint(x: 8 * scale, y: 12 * scale)
            )
            bodyPath.addQuadCurve(
                to: CGPoint(x: 35 * scale, y: 10 * scale),
                control: CGPoint(x: 28 * scale, y: 16 * scale)
            )
            bodyPath.closeSubpath()
            context.fill(bodyPath, with: .color(color))

            // Tail
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: 2 * scale, y: 10 * scale))
            tailPath.addLine(to: CGPoint(x: -5 * scale, y: 5 * scale))
            tailPath.addLine(to: CGPoint(x: -3 * scale, y: 10 * scale))
            tailPath.addLine(to: CGPoint(x: -5 * scale, y: 15 * scale))
            tailPath.closeSubpath()
            context.fill(tailPath, with: .color(color.opacity(0.85)))

            // Eye
            let eyePath = Path(ellipseIn: CGRect(x: 28 * scale, y: 8 * scale, width: 3 * scale, height: 3 * scale))
            context.fill(eyePath, with: .color(Color(red: 0.1, green: 0.23, blue: 0.35)))
        }
    }
}

// MARK: - Ripples Layer

struct RipplesLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double
    let cycleDuration: Double

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let wavePhase = cos(cycleProgress * .pi * 2)
        let buoyLift = wavePhase * -20
        let swayPhase = sin(cycleProgress * .pi * 4 + elapsedTime / 2)
        let buoySway = swayPhase * 3

        let ripple1Progress = elapsedTime.truncatingRemainder(dividingBy: 4) / 4
        let ripple2Progress = (elapsedTime + 1.3).truncatingRemainder(dividingBy: 4) / 4
        let ripple3Progress = (elapsedTime + 2.6).truncatingRemainder(dividingBy: 4) / 4

        ZStack {
            RippleView(progress: ripple1Progress)
                .position(x: width / 2 + buoySway, y: height * 0.58 + buoyLift * 0.5)

            RippleView(progress: ripple2Progress)
                .position(x: width / 2 + buoySway, y: height * 0.58 + buoyLift * 0.5)

            RippleView(progress: ripple3Progress)
                .position(x: width / 2 + buoySway, y: height * 0.58 + buoyLift * 0.5)
        }
    }
}

// MARK: - Ripple View

struct RippleView: View {
    let progress: Double

    var body: some View {
        let rippleWidth = 60 + progress * 120
        let rippleHeight = 20 + progress * 30
        let opacity = 0.6 * (1 - progress)

        Ellipse()
            .stroke(Color(red: 0.59, green: 0.78, blue: 0.86).opacity(opacity), lineWidth: 2)
            .frame(width: rippleWidth, height: rippleHeight)
    }
}

// MARK: - Buoy View

struct BuoyView: View {
    let elapsedTime: Double
    let cycleDuration: Double

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let wavePhase = cos(cycleProgress * .pi * 2)
        let buoyLift = wavePhase * -20
        let tiltPhase = sin(cycleProgress * .pi * 2)
        let buoyTilt = tiltPhase * 2
        let swayPhase = sin(cycleProgress * .pi * 4 + elapsedTime / 2)
        let buoySway = swayPhase * 3

        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2 + buoyLift

            // Buoy reflection
            let reflectionPath = Path(ellipseIn: CGRect(x: cx - 25, y: cy + 55, width: 50, height: 16))
            context.fill(reflectionPath, with: .color(Color(red: 0.24, green: 0.39, blue: 0.51).opacity(0.24)))

            // Underwater part
            let underwaterPath = Path(ellipseIn: CGRect(x: cx - 28, y: cy + 45, width: 56, height: 20))
            context.fill(underwaterPath, with: .color(Color(red: 0.10, green: 0.29, blue: 0.42).opacity(0.6)))

            // Lower red band
            var lowerRedPath = Path()
            lowerRedPath.move(to: CGPoint(x: cx - 28, y: cy + 20))
            lowerRedPath.addQuadCurve(
                to: CGPoint(x: cx, y: cy + 45),
                control: CGPoint(x: cx - 28, y: cy + 45)
            )
            lowerRedPath.addQuadCurve(
                to: CGPoint(x: cx + 28, y: cy + 20),
                control: CGPoint(x: cx + 28, y: cy + 45)
            )
            lowerRedPath.addLine(to: CGPoint(x: cx + 28, y: cy + 10))
            lowerRedPath.addQuadCurve(
                to: CGPoint(x: cx, y: cy + 25),
                control: CGPoint(x: cx + 28, y: cy + 25)
            )
            lowerRedPath.addQuadCurve(
                to: CGPoint(x: cx - 28, y: cy + 10),
                control: CGPoint(x: cx - 28, y: cy + 25)
            )
            lowerRedPath.closeSubpath()

            context.fill(lowerRedPath, with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.63, green: 0.13, blue: 0.13),
                    Color(red: 0.82, green: 0.19, blue: 0.19),
                    Color(red: 0.88, green: 0.25, blue: 0.25),
                    Color(red: 0.82, green: 0.19, blue: 0.19),
                    Color(red: 0.63, green: 0.13, blue: 0.13)
                ]),
                startPoint: CGPoint(x: cx - 30, y: cy),
                endPoint: CGPoint(x: cx + 30, y: cy)
            ))

            // White middle band
            var whiteMiddlePath = Path()
            whiteMiddlePath.move(to: CGPoint(x: cx - 28, y: cy + 10))
            whiteMiddlePath.addQuadCurve(
                to: CGPoint(x: cx, y: cy + 25),
                control: CGPoint(x: cx - 28, y: cy + 25)
            )
            whiteMiddlePath.addQuadCurve(
                to: CGPoint(x: cx + 28, y: cy + 10),
                control: CGPoint(x: cx + 28, y: cy + 25)
            )
            whiteMiddlePath.addLine(to: CGPoint(x: cx + 28, y: cy - 5))
            whiteMiddlePath.addQuadCurve(
                to: CGPoint(x: cx, y: cy + 10),
                control: CGPoint(x: cx + 28, y: cy + 10)
            )
            whiteMiddlePath.addQuadCurve(
                to: CGPoint(x: cx - 28, y: cy - 5),
                control: CGPoint(x: cx - 28, y: cy + 10)
            )
            whiteMiddlePath.closeSubpath()

            context.fill(whiteMiddlePath, with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.75, green: 0.75, blue: 0.75),
                    Color(red: 0.91, green: 0.91, blue: 0.91),
                    Color.white,
                    Color(red: 0.91, green: 0.91, blue: 0.91),
                    Color(red: 0.75, green: 0.75, blue: 0.75)
                ]),
                startPoint: CGPoint(x: cx - 30, y: cy),
                endPoint: CGPoint(x: cx + 30, y: cy)
            ))

            // Upper red band
            var upperRedPath = Path()
            upperRedPath.move(to: CGPoint(x: cx - 28, y: cy - 5))
            upperRedPath.addQuadCurve(
                to: CGPoint(x: cx, y: cy + 10),
                control: CGPoint(x: cx - 28, y: cy + 10)
            )
            upperRedPath.addQuadCurve(
                to: CGPoint(x: cx + 28, y: cy - 5),
                control: CGPoint(x: cx + 28, y: cy + 10)
            )
            upperRedPath.addLine(to: CGPoint(x: cx + 28, y: cy - 20))
            upperRedPath.addQuadCurve(
                to: CGPoint(x: cx, y: cy - 5),
                control: CGPoint(x: cx + 28, y: cy - 5)
            )
            upperRedPath.addQuadCurve(
                to: CGPoint(x: cx - 28, y: cy - 20),
                control: CGPoint(x: cx - 28, y: cy - 5)
            )
            upperRedPath.closeSubpath()

            context.fill(upperRedPath, with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.63, green: 0.13, blue: 0.13),
                    Color(red: 0.82, green: 0.19, blue: 0.19),
                    Color(red: 0.88, green: 0.25, blue: 0.25),
                    Color(red: 0.82, green: 0.19, blue: 0.19),
                    Color(red: 0.63, green: 0.13, blue: 0.13)
                ]),
                startPoint: CGPoint(x: cx - 30, y: cy),
                endPoint: CGPoint(x: cx + 30, y: cy)
            ))

            // Top white section
            var topWhitePath = Path()
            topWhitePath.move(to: CGPoint(x: cx - 22, y: cy - 20))
            topWhitePath.addQuadCurve(
                to: CGPoint(x: cx, y: cy - 5),
                control: CGPoint(x: cx - 22, y: cy - 5)
            )
            topWhitePath.addQuadCurve(
                to: CGPoint(x: cx + 22, y: cy - 20),
                control: CGPoint(x: cx + 22, y: cy - 5)
            )
            topWhitePath.addLine(to: CGPoint(x: cx + 22, y: cy - 30))
            topWhitePath.addQuadCurve(
                to: CGPoint(x: cx, y: cy - 20),
                control: CGPoint(x: cx + 22, y: cy - 20)
            )
            topWhitePath.addQuadCurve(
                to: CGPoint(x: cx - 22, y: cy - 30),
                control: CGPoint(x: cx - 22, y: cy - 20)
            )
            topWhitePath.closeSubpath()

            context.fill(topWhitePath, with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.75, green: 0.75, blue: 0.75),
                    Color(red: 0.91, green: 0.91, blue: 0.91),
                    Color.white,
                    Color(red: 0.91, green: 0.91, blue: 0.91),
                    Color(red: 0.75, green: 0.75, blue: 0.75)
                ]),
                startPoint: CGPoint(x: cx - 25, y: cy),
                endPoint: CGPoint(x: cx + 25, y: cy)
            ))

            // Top cap
            let topCapPath = Path(ellipseIn: CGRect(x: cx - 22, y: cy - 38, width: 44, height: 16))
            context.fill(topCapPath, with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.31, green: 0.31, blue: 0.31),
                    Color(red: 0.50, green: 0.50, blue: 0.50),
                    Color(red: 0.63, green: 0.63, blue: 0.63),
                    Color(red: 0.50, green: 0.50, blue: 0.50),
                    Color(red: 0.31, green: 0.31, blue: 0.31)
                ]),
                startPoint: CGPoint(x: cx - 25, y: cy - 30),
                endPoint: CGPoint(x: cx + 25, y: cy - 30)
            ))

            // Metal pole
            let polePath = Path(CGRect(x: cx - 4, y: cy - 60, width: 8, height: 32))
            context.fill(polePath, with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.31, green: 0.31, blue: 0.31),
                    Color(red: 0.50, green: 0.50, blue: 0.50),
                    Color(red: 0.63, green: 0.63, blue: 0.63),
                    Color(red: 0.50, green: 0.50, blue: 0.50),
                    Color(red: 0.31, green: 0.31, blue: 0.31)
                ]),
                startPoint: CGPoint(x: cx - 5, y: cy - 50),
                endPoint: CGPoint(x: cx + 5, y: cy - 50)
            ))

            // Light housing
            let housingPath = Path(ellipseIn: CGRect(x: cx - 10, y: cy - 64, width: 20, height: 12))
            context.fill(housingPath, with: .color(Color(red: 0.25, green: 0.25, blue: 0.25)))

            let housingTopPath = Path(ellipseIn: CGRect(x: cx - 8, y: cy - 66, width: 16, height: 8))
            context.fill(housingTopPath, with: .color(Color(red: 0.38, green: 0.38, blue: 0.38)))

            // Light
            let lightGlowPath = Path(ellipseIn: CGRect(x: cx - 6, y: cy - 71, width: 12, height: 12))
            context.fill(lightGlowPath, with: .color(Color(red: 1, green: 0.87, blue: 0.27).opacity(0.8)))

            let lightPath = Path(ellipseIn: CGRect(x: cx - 4, y: cy - 69, width: 8, height: 8))
            context.fill(lightPath, with: .color(Color(red: 1, green: 0.93, blue: 0.53)))

            // Highlight reflections
            let highlight1 = Path(ellipseIn: CGRect(x: cx - 20, y: cy - 18, width: 6, height: 16))
            context.fill(highlight1, with: .color(Color.white.opacity(0.3)))

            let highlight2 = Path(ellipseIn: CGRect(x: cx - 20, y: cy + 7, width: 6, height: 16))
            context.fill(highlight2, with: .color(Color.white.opacity(0.2)))

            // Water line around buoy
            let waterLineScale = 1 + (1 + wavePhase) * 0.15
            let waterLinePath = Path(ellipseIn: CGRect(
                x: cx - 35 * waterLineScale,
                y: cy + 40 - 12 * waterLineScale,
                width: 70 * waterLineScale,
                height: 24 * waterLineScale
            ))
            let waterLineOpacity = 0.3 + abs(wavePhase) * 0.3
            context.stroke(waterLinePath, with: .color(Color(red: 0.59, green: 0.78, blue: 0.86).opacity(waterLineOpacity)), lineWidth: 3)
        }
        .offset(x: buoySway, y: 0)
        .rotationEffect(.degrees(buoyTilt), anchor: .center)
    }
}

#Preview {
    BreatheBuoyView(duration: 3, onComplete: {}, onBack: {})
}
