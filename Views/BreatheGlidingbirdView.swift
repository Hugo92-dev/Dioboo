import SwiftUI

struct BreatheGlidingbirdView: View {
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
                // Sky gradient
                DesertSkyView()

                // Sun
                SunView()
                    .frame(width: 50, height: 50)
                    .position(x: width * 0.85, y: height * 0.12)

                // Desert floor
                DesertFloorView()
                    .position(x: width / 2, y: height * 0.91)

                // Horses running
                HorsesLayer(width: width, height: height, elapsedTime: elapsedTime)

                // Canyon formations
                CanyonLayer(width: width, height: height, elapsedTime: elapsedTime)

                // Cactus layer
                CactusLayer(width: width, height: height, elapsedTime: elapsedTime)

                // Gliding bird
                GlidingBirdView(elapsedTime: elapsedTime, cycleDuration: cycleDuration)
                    .frame(width: 80, height: 50)
                    .position(x: width * 0.30, y: height * 0.50)

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

// MARK: - Desert Sky View

struct DesertSkyView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.56, blue: 0.78),
                Color(red: 0.25, green: 0.66, blue: 0.88),
                Color(red: 0.38, green: 0.72, blue: 0.91),
                Color(red: 0.50, green: 0.78, blue: 0.94),
                Color(red: 0.63, green: 0.85, blue: 0.97),
                Color(red: 0.78, green: 0.91, blue: 0.99)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Sun View

struct SunView: View {
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1, green: 0.87, blue: 0.39).opacity(0.6),
                            Color(red: 1, green: 0.78, blue: 0.20).opacity(0.3),
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)

            // Sun
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1, green: 0.97, blue: 0.88),
                            Color(red: 1, green: 0.88, blue: 0.50),
                            Color(red: 1, green: 0.80, blue: 0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
        }
    }
}

// MARK: - Desert Floor View

struct DesertFloorView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main floor
                LinearGradient(
                    colors: [
                        Color(red: 0.85, green: 0.56, blue: 0.38),
                        Color(red: 0.78, green: 0.50, blue: 0.31),
                        Color(red: 0.72, green: 0.44, blue: 0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Texture
                Canvas { context, size in
                    let texturePoints: [(CGFloat, CGFloat)] = [
                        (0.2, 0.8), (0.6, 0.7), (0.8, 0.9),
                        (0.15, 0.5), (0.45, 0.6), (0.75, 0.4)
                    ]

                    for (x, y) in texturePoints {
                        let circlePath = Path(ellipseIn: CGRect(
                            x: size.width * x - 3,
                            y: size.height * y - 3,
                            width: 6,
                            height: 6
                        ))
                        context.fill(circlePath, with: .color(Color(red: 0.7, green: 0.39, blue: 0.24).opacity(0.25)))
                    }
                }
            }
        }
        .frame(height: 150)
    }
}

// MARK: - Horses Layer

struct HorsesLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    var body: some View {
        let group1Progress = elapsedTime.truncatingRemainder(dividingBy: 20) / 20
        let group2Progress = (elapsedTime + 5).truncatingRemainder(dividingBy: 25) / 25

        ZStack {
            // Group 1 - closer
            HStack(spacing: 15) {
                HorseView(color: Color(red: 0.29, green: 0.19, blue: 0.13), legOffset: elapsedTime)
                    .frame(width: 25, height: 18)
                HorseView(color: Color(red: 0.35, green: 0.25, blue: 0.19), legOffset: elapsedTime + 0.1)
                    .frame(width: 25, height: 18)
                HorseView(color: Color(red: 0.23, green: 0.15, blue: 0.09), legOffset: elapsedTime + 0.2)
                    .frame(width: 25, height: 18)
            }
            .position(x: width * (-0.3 + group1Progress * 1.5), y: height * 0.82)
            .opacity(0.7)

            // Group 2 - farther
            HStack(spacing: 12) {
                HorseView(color: Color(red: 0.42, green: 0.31, blue: 0.25), legOffset: elapsedTime)
                    .frame(width: 20, height: 14)
                HorseView(color: Color(red: 0.29, green: 0.21, blue: 0.15), legOffset: elapsedTime + 0.15)
                    .frame(width: 20, height: 14)
            }
            .position(x: width * (-0.4 + group2Progress * 1.6), y: height * 0.80)
            .opacity(0.35)
        }
    }
}

// MARK: - Horse View

struct HorseView: View {
    let color: Color
    let legOffset: Double

    var body: some View {
        let gallopY = sin(legOffset * 20) * 2

        Canvas { context, size in
            let scale = size.width / 30

            // Body
            let bodyPath = Path(ellipseIn: CGRect(x: 5 * scale, y: 3 * scale, width: 20 * scale, height: 10 * scale))
            context.fill(bodyPath, with: .color(color))

            // Neck
            var neckPath = Path()
            neckPath.move(to: CGPoint(x: 23 * scale, y: 6 * scale))
            neckPath.addQuadCurve(
                to: CGPoint(x: 26 * scale, y: 0),
                control: CGPoint(x: 28 * scale, y: 2 * scale)
            )
            neckPath.addLine(to: CGPoint(x: 24 * scale, y: 0))
            neckPath.addQuadCurve(
                to: CGPoint(x: 22 * scale, y: 7 * scale),
                control: CGPoint(x: 22 * scale, y: 3 * scale)
            )
            neckPath.closeSubpath()
            context.fill(neckPath, with: .color(color))

            // Head
            let headPath = Path(ellipseIn: CGRect(x: 23 * scale, y: -1 * scale, width: 6 * scale, height: 4 * scale))
            context.fill(headPath, with: .color(color))

            // Legs (with animation offset)
            let legColor = color.opacity(0.85)
            let legPositions: [CGFloat] = [8, 12, 18, 22]
            for (index, xPos) in legPositions.enumerated() {
                let legY = gallopY * (index % 2 == 0 ? 1 : -1)
                let legRect = CGRect(x: xPos * scale, y: (12 + legY) * scale, width: 2 * scale, height: 7 * scale)
                context.fill(Path(roundedRect: legRect, cornerRadius: 0), with: .color(legColor))
            }

            // Tail
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: 5 * scale, y: 7 * scale))
            tailPath.addQuadCurve(
                to: CGPoint(x: 2 * scale, y: 14 * scale),
                control: CGPoint(x: 0, y: 10 * scale)
            )
            context.stroke(tailPath, with: .color(color.opacity(0.7)), style: StrokeStyle(lineWidth: 2 * scale, lineCap: .round))
        }
    }
}

// MARK: - Canyon Layer

struct CanyonLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    var body: some View {
        let scrollOffset = elapsedTime.truncatingRemainder(dividingBy: 50) / 50

        Canvas { context, size in
            let canyonColor = Color(red: 0.75, green: 0.41, blue: 0.19)
            let canyonColorLight = Color(red: 0.82, green: 0.47, blue: 0.25)
            let canyonColorDark = Color(red: 0.88, green: 0.53, blue: 0.31)

            // Canyon formations
            let formations: [(x: CGFloat, width: CGFloat, heightRatio: CGFloat, clipPath: [(CGFloat, CGFloat)])] = [
                (
                    x: 0.08 - scrollOffset,
                    width: 0.5,
                    heightRatio: 0.25,
                    clipPath: [(0, 1), (0, 0.5), (0.15, 0.35), (0.35, 0.45), (0.5, 0.2), (0.65, 0.4), (0.85, 0.25), (1, 0.35), (1, 1)]
                ),
                (
                    x: 0.68 - scrollOffset,
                    width: 0.45,
                    heightRatio: 0.22,
                    clipPath: [(0, 1), (0, 0.4), (0.25, 0.25), (0.45, 0.35), (0.6, 0.15), (0.8, 0.3), (1, 0.2), (1, 1)]
                ),
                (
                    x: 1.28 - scrollOffset,
                    width: 0.55,
                    heightRatio: 0.28,
                    clipPath: [(0, 1), (0, 0.35), (0.2, 0.45), (0.4, 0.2), (0.55, 0.35), (0.75, 0.15), (0.9, 0.3), (1, 0.25), (1, 1)]
                ),
                (
                    x: 1.95 - scrollOffset,
                    width: 0.48,
                    heightRatio: 0.24,
                    clipPath: [(0, 1), (0, 0.3), (0.3, 0.4), (0.5, 0.15), (0.7, 0.35), (1, 0.2), (1, 1)]
                )
            ]

            for formation in formations {
                let formationX = size.width * formation.x
                let formationWidth = size.width * formation.width
                let formationHeight = size.height * formation.heightRatio

                var path = Path()
                for (index, point) in formation.clipPath.enumerated() {
                    let px = formationX + formationWidth * point.0
                    let py = size.height - formationHeight + formationHeight * point.1

                    if index == 0 {
                        path.move(to: CGPoint(x: px, y: py))
                    } else {
                        path.addLine(to: CGPoint(x: px, y: py))
                    }
                }
                path.closeSubpath()

                context.fill(path, with: .linearGradient(
                    Gradient(colors: [canyonColorDark, canyonColorLight, canyonColor]),
                    startPoint: CGPoint(x: formationX, y: size.height - formationHeight),
                    endPoint: CGPoint(x: formationX, y: size.height)
                ))
            }
        }
        .frame(width: width * 2, height: height)
    }
}

// MARK: - Cactus Layer

struct CactusLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    var body: some View {
        let scrollOffset = elapsedTime.truncatingRemainder(dividingBy: 50) / 50

        ZStack {
            CactusView(variant: 1)
                .frame(width: 35, height: 70)
                .position(x: width * (0.08 - scrollOffset * 2).truncatingRemainder(dividingBy: 1.2) + width * 0.1, y: height * 0.78)

            CactusView(variant: 2)
                .frame(width: 30, height: 60)
                .position(x: width * (0.25 - scrollOffset * 2).truncatingRemainder(dividingBy: 1.2) + width * 0.1, y: height * 0.76)

            CactusView(variant: 3)
                .frame(width: 38, height: 75)
                .position(x: width * (0.45 - scrollOffset * 2).truncatingRemainder(dividingBy: 1.2) + width * 0.1, y: height * 0.79)

            CactusView(variant: 1)
                .frame(width: 28, height: 55)
                .position(x: width * (0.62 - scrollOffset * 2).truncatingRemainder(dividingBy: 1.2) + width * 0.1, y: height * 0.74)

            CactusView(variant: 2)
                .frame(width: 32, height: 65)
                .position(x: width * (0.80 - scrollOffset * 2).truncatingRemainder(dividingBy: 1.2) + width * 0.1, y: height * 0.77)
        }
    }
}

// MARK: - Cactus View

struct CactusView: View {
    let variant: Int

    var body: some View {
        Canvas { context, size in
            let scale = size.width / 40
            let cactusGreen = Color(red: 0.18, green: 0.35, blue: 0.18)
            let cactusHighlight = Color(red: 0.29, green: 0.54, blue: 0.29)

            // Main stem
            var stemPath = Path()
            stemPath.move(to: CGPoint(x: 18 * scale, y: 80 * scale))
            stemPath.addLine(to: CGPoint(x: 18 * scale, y: 25 * scale))
            stemPath.addQuadCurve(
                to: CGPoint(x: 22 * scale, y: 25 * scale),
                control: CGPoint(x: 20 * scale, y: 10 * scale)
            )
            stemPath.addLine(to: CGPoint(x: 22 * scale, y: 80 * scale))
            stemPath.closeSubpath()
            context.fill(stemPath, with: .color(cactusGreen))

            // Left arm
            var leftArmPath = Path()
            if variant == 1 || variant == 3 {
                leftArmPath.move(to: CGPoint(x: 18 * scale, y: 50 * scale))
                leftArmPath.addLine(to: CGPoint(x: 10 * scale, y: 50 * scale))
                leftArmPath.addQuadCurve(
                    to: CGPoint(x: 8 * scale, y: 35 * scale),
                    control: CGPoint(x: 5 * scale, y: 45 * scale)
                )
                leftArmPath.addQuadCurve(
                    to: CGPoint(x: 12 * scale, y: 30 * scale),
                    control: CGPoint(x: 8 * scale, y: 30 * scale)
                )
                leftArmPath.addLine(to: CGPoint(x: 12 * scale, y: 45 * scale))
                leftArmPath.addLine(to: CGPoint(x: 18 * scale, y: 45 * scale))
                leftArmPath.closeSubpath()
                context.fill(leftArmPath, with: .color(cactusGreen))
            }

            // Right arm
            var rightArmPath = Path()
            if variant == 1 || variant == 2 {
                let armY: CGFloat = variant == 1 ? 40 : 45
                rightArmPath.move(to: CGPoint(x: 22 * scale, y: armY * scale))
                rightArmPath.addLine(to: CGPoint(x: 30 * scale, y: armY * scale))
                rightArmPath.addQuadCurve(
                    to: CGPoint(x: 32 * scale, y: (armY - 15) * scale),
                    control: CGPoint(x: 35 * scale, y: (armY - 5) * scale)
                )
                rightArmPath.addQuadCurve(
                    to: CGPoint(x: 28 * scale, y: (armY - 20) * scale),
                    control: CGPoint(x: 32 * scale, y: (armY - 20) * scale)
                )
                rightArmPath.addLine(to: CGPoint(x: 28 * scale, y: (armY - 5) * scale))
                rightArmPath.addLine(to: CGPoint(x: 22 * scale, y: (armY - 5) * scale))
                rightArmPath.closeSubpath()
                context.fill(rightArmPath, with: .color(cactusGreen))
            }

            // Highlight
            var highlightPath = Path()
            highlightPath.move(to: CGPoint(x: 19 * scale, y: 75 * scale))
            highlightPath.addLine(to: CGPoint(x: 19 * scale, y: 30 * scale))
            context.stroke(highlightPath, with: .color(cactusHighlight.opacity(0.5)), style: StrokeStyle(lineWidth: 2 * scale))
        }
    }
}

// MARK: - Gliding Bird View

struct GlidingBirdView: View {
    let elapsedTime: Double
    let cycleDuration: Double

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let flightPhase = cos(cycleProgress * .pi * 2)

        // Vertical position
        let birdY = flightPhase * 18

        // Tilt
        let birdTilt = -flightPhase * 8

        // Sway
        let sway = sin(elapsedTime / 1.5) * 3

        // Wing animation
        let wingAngle = sin(elapsedTime / 0.8) * 3
        let wingStretch = 1 + sin(elapsedTime / 1.2) * 0.05

        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2 + birdY

            // Apply rotation
            context.translateBy(x: cx, y: cy)
            context.rotate(by: Angle(degrees: birdTilt))
            context.translateBy(x: -cx + sway, y: -cy)

            // Body
            let bodyPath = Path(ellipseIn: CGRect(x: 17, y: 17, width: 36, height: 16))
            context.fill(bodyPath, with: .color(.white))

            // Head
            let headPath = Path(ellipseIn: CGRect(x: 46, y: 17, width: 12, height: 12))
            context.fill(headPath, with: .color(.white))

            // Beak
            var beakPath = Path()
            beakPath.move(to: CGPoint(x: 58, y: 23))
            beakPath.addLine(to: CGPoint(x: 65, y: 24))
            beakPath.addLine(to: CGPoint(x: 58, y: 25))
            beakPath.closeSubpath()
            context.fill(beakPath, with: .color(Color(red: 0.94, green: 0.63, blue: 0.19)))

            // Tail
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: 17, y: 22))
            tailPath.addLine(to: CGPoint(x: 5, y: 18))
            tailPath.addLine(to: CGPoint(x: 8, y: 25))
            tailPath.addLine(to: CGPoint(x: 5, y: 32))
            tailPath.addLine(to: CGPoint(x: 17, y: 28))
            tailPath.closeSubpath()
            context.fill(tailPath, with: .color(Color(red: 0.96, green: 0.96, blue: 0.96)))

            // Top wing
            context.translateBy(x: 35, y: 20)
            context.rotate(by: Angle(degrees: wingAngle))
            context.scaleBy(x: 1, y: wingStretch)
            context.translateBy(x: -35, y: -20)

            var topWingPath = Path()
            topWingPath.move(to: CGPoint(x: 30, y: 20))
            topWingPath.addQuadCurve(
                to: CGPoint(x: 40, y: 8),
                control: CGPoint(x: 20, y: 5)
            )
            topWingPath.addQuadCurve(
                to: CGPoint(x: 45, y: 20),
                control: CGPoint(x: 50, y: 10)
            )
            topWingPath.closeSubpath()
            context.fill(topWingPath, with: .color(Color(red: 0.91, green: 0.91, blue: 0.91)))

            // Reset transform for bottom wing
            context.translateBy(x: 35, y: 20)
            context.scaleBy(x: 1, y: 1/wingStretch)
            context.rotate(by: Angle(degrees: -wingAngle))
            context.translateBy(x: -35, y: -20)

            // Bottom wing
            context.translateBy(x: 35, y: 30)
            context.rotate(by: Angle(degrees: -wingAngle))
            context.scaleBy(x: 1, y: wingStretch)
            context.translateBy(x: -35, y: -30)

            var bottomWingPath = Path()
            bottomWingPath.move(to: CGPoint(x: 30, y: 30))
            bottomWingPath.addQuadCurve(
                to: CGPoint(x: 40, y: 42),
                control: CGPoint(x: 20, y: 45)
            )
            bottomWingPath.addQuadCurve(
                to: CGPoint(x: 45, y: 30),
                control: CGPoint(x: 50, y: 40)
            )
            bottomWingPath.closeSubpath()
            context.fill(bottomWingPath, with: .color(Color(red: 0.91, green: 0.91, blue: 0.91)))

            // Reset transform for eye
            context.translateBy(x: 35, y: 30)
            context.scaleBy(x: 1, y: 1/wingStretch)
            context.rotate(by: Angle(degrees: wingAngle))
            context.translateBy(x: -35, y: -30)

            // Eye
            let eyePath = Path(ellipseIn: CGRect(x: 52.5, y: 20.5, width: 3, height: 3))
            context.fill(eyePath, with: .color(Color(red: 0.1, green: 0.1, blue: 0.1)))
        }
    }
}

#Preview {
    BreatheGlidingbirdView(duration: 3, onComplete: {}, onBack: {})
}
