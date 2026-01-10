import SwiftUI

struct BreatheGlidingbirdView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var startTime: Date?
    @State private var hasCompleted: Bool = false

    private let cycleDuration: Double = 10.0

    private var totalDuration: Double {
        Double(duration) * 60.0
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = startTime.map { timeline.date.timeIntervalSince($0) } ?? 0

            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    // Sky gradient - matches HTML exactly
                    DesertSkyView()

                    // Sun - positioned at top 12%, right 15%
                    SunView()
                        .position(x: width * 0.85, y: height * 0.12)

                    // Desert floor - 18% height from bottom
                    DesertFloorView(width: width, height: height)

                    // Horses running in distance
                    HorsesLayerView(width: width, height: height, elapsedTime: elapsedTime)

                    // Canyon rock formations
                    CanyonLayerView(width: width, height: height, elapsedTime: elapsedTime)

                    // Cactus layer
                    CactusLayerView(width: width, height: height, elapsedTime: elapsedTime)

                    // Gliding bird - positioned at left 30%, animated vertically
                    // Bird rises during inhale, descends during exhale
                    let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
                    let flightPhase = cos(cycleProgress * .pi * 2)
                    let birdYOffset = flightPhase * height * 0.18

                    GlidingBirdView(elapsedTime: elapsedTime, cycleDuration: cycleDuration)
                        .frame(width: 80, height: 50)
                        .position(x: width * 0.30, y: height * 0.35 + birdYOffset)

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
                                        .blur(radius: 0.5)
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
                            .shadow(color: Color(red: 0, green: 0.196, blue: 0.314).opacity(0.5), radius: 15, y: 2)
                            .padding(.bottom, 8)

                        // Timer
                        let remaining = max(0, totalDuration - elapsedTime)
                        let minutes = Int(remaining) / 60
                        let seconds = Int(remaining) % 60

                        Text(String(format: "%d:%02d", minutes, seconds))
                            .font(.custom("Nunito", size: 15).weight(.light))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: Color(red: 0, green: 0.196, blue: 0.314).opacity(0.3), radius: 5, y: 1)
                            .padding(.bottom, 20)

                        // Progress bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.2))
                                .frame(height: 3)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.8))
                                .frame(width: max(0, (width - 90) * CGFloat(elapsedTime / totalDuration)), height: 3)
                        }
                        .padding(.horizontal, 45)
                        .padding(.bottom, 50)
                    }
                }
                .ignoresSafeArea()
            }
            .onChange(of: elapsedTime >= totalDuration) { _, completed in
                if completed && !hasCompleted {
                    hasCompleted = true
                    onComplete()
                }
            }
        }
        .onAppear {
            startTime = Date()
        }
    }
}

// MARK: - Desert Sky View
// Matches HTML: #1e90c8 -> #40a8e0 -> #60b8e8 -> #80c8f0 -> #a0d8f8 -> #c8e8fc

struct DesertSkyView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.118, green: 0.565, blue: 0.784),  // #1e90c8
                Color(red: 0.251, green: 0.659, blue: 0.878),  // #40a8e0
                Color(red: 0.376, green: 0.722, blue: 0.910),  // #60b8e8
                Color(red: 0.502, green: 0.784, blue: 0.941),  // #80c8f0
                Color(red: 0.627, green: 0.847, blue: 0.973),  // #a0d8f8
                Color(red: 0.784, green: 0.910, blue: 0.988)   // #c8e8fc
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Sun View
// Matches HTML: radial gradient #fff8e0 -> #ffe080 -> #ffcc00

struct SunView: View {
    var body: some View {
        ZStack {
            // Outer glow - matches box-shadow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1, green: 0.863, blue: 0.392).opacity(0.6),  // rgba(255, 220, 100, 0.6)
                            Color(red: 1, green: 0.784, blue: 0.196).opacity(0.3),  // rgba(255, 200, 50, 0.3)
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)

            // Sun body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1, green: 0.973, blue: 0.878),  // #fff8e0
                            Color(red: 1, green: 0.878, blue: 0.502),  // #ffe080
                            Color(red: 1, green: 0.800, blue: 0)       // #ffcc00
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
// Desert ground that extends to absolute bottom of screen (including safe area)

struct DesertFloorView: View {
    let width: CGFloat
    let height: CGFloat

    // Desert starts at 70% from top
    private var desertTopY: CGFloat { height * 0.70 }
    // Desert height extended to cover safe area (add extra 15% to ensure full coverage)
    private var desertHeight: CGFloat { height * 0.45 }

    var body: some View {
        ZStack {
            // Main desert floor - covers from 70% to beyond bottom (including safe area)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.847, green: 0.565, blue: 0.376),  // #d89060
                            Color(red: 0.784, green: 0.502, blue: 0.314),  // #c88050
                            Color(red: 0.722, green: 0.439, blue: 0.251)   // #b87040
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 1.1, height: desertHeight)
                .position(x: width / 2, y: desertTopY + desertHeight / 2)

            // Desert texture dots
            Canvas { context, size in
                let texturePoints: [(CGFloat, CGFloat, CGFloat)] = [
                    (0.2, 0.73, 2), (0.6, 0.75, 3), (0.8, 0.78, 2),
                    (0.15, 0.76, 2), (0.45, 0.80, 3), (0.75, 0.74, 2),
                    (0.35, 0.82, 2), (0.55, 0.77, 2), (0.9, 0.79, 3)
                ]

                let textureColor = Color(red: 0.706, green: 0.392, blue: 0.235).opacity(0.25)

                for (x, y, radius) in texturePoints {
                    let circlePath = Path(ellipseIn: CGRect(
                        x: size.width * x - radius,
                        y: size.height * y - radius,
                        width: radius * 2,
                        height: radius * 2
                    ))
                    context.fill(circlePath, with: .color(textureColor))
                }
            }
            .frame(width: width, height: height)
        }
    }
}

// MARK: - Horses Layer View
// Matches HTML horses with gallop animation

struct HorsesLayerView: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    // Horses run on the desert floor (at 70% from top)
    private var desertTopY: CGFloat { height * 0.70 }

    var body: some View {
        // Group 1 - closer horses (animation: 20s)
        let group1Progress = elapsedTime.truncatingRemainder(dividingBy: 20) / 20
        // Group 2 - farther horses (animation: 25s, delayed by 5s)
        let group2Progress = (elapsedTime + 5).truncatingRemainder(dividingBy: 25) / 25

        ZStack {
            // Group 1 - 3 horses, closer (on desert floor)
            HStack(spacing: 15) {
                HorseShape(bodyColor: Color(red: 0.290, green: 0.188, blue: 0.125), legColor: Color(red: 0.227, green: 0.145, blue: 0.082), tailColor: Color(red: 0.165, green: 0.102, blue: 0.039), elapsedTime: elapsedTime, legDelay: 0)
                    .frame(width: 25, height: 18)
                HorseShape(bodyColor: Color(red: 0.353, green: 0.251, blue: 0.188), legColor: Color(red: 0.290, green: 0.188, blue: 0.125), tailColor: Color(red: 0.227, green: 0.145, blue: 0.082), elapsedTime: elapsedTime, legDelay: 0.1)
                    .frame(width: 25, height: 18)
                HorseShape(bodyColor: Color(red: 0.227, green: 0.145, blue: 0.082), legColor: Color(red: 0.165, green: 0.102, blue: 0.039), tailColor: Color(red: 0.102, green: 0.039, blue: 0), elapsedTime: elapsedTime, legDelay: 0.2)
                    .frame(width: 25, height: 18)
            }
            .opacity(0.7)
            .position(x: -150 + (width + 150) * group1Progress * 1.1, y: desertTopY + 5)

            // Group 2 - 2 horses, farther (smaller, more transparent)
            HStack(spacing: 12) {
                HorseShape(bodyColor: Color(red: 0.416, green: 0.314, blue: 0.251), legColor: Color(red: 0.353, green: 0.251, blue: 0.188), tailColor: Color(red: 0.290, green: 0.188, blue: 0.125), elapsedTime: elapsedTime, legDelay: 0)
                    .frame(width: 20, height: 14)
                HorseShape(bodyColor: Color(red: 0.290, green: 0.208, blue: 0.145), legColor: Color(red: 0.227, green: 0.145, blue: 0.082), tailColor: Color(red: 0.165, green: 0.102, blue: 0.039), elapsedTime: elapsedTime, legDelay: 0.1)
                    .frame(width: 20, height: 14)
            }
            .opacity(0.35)
            .scaleEffect(0.7)
            .position(x: -250 + (width + 250) * group2Progress * 1.2, y: desertTopY - 5)
        }
    }
}

// MARK: - Horse Shape
// Matches HTML SVG horse exactly

struct HorseShape: View {
    let bodyColor: Color
    let legColor: Color
    let tailColor: Color
    let elapsedTime: Double
    let legDelay: Double

    var body: some View {
        let gallopOffset = sin((elapsedTime + legDelay) * 20) * 2

        Canvas { context, size in
            let scaleX = size.width / 30
            let scaleY = size.height / 20

            // Body - ellipse at cx="15" cy="8" rx="10" ry="5"
            let bodyPath = Path(ellipseIn: CGRect(
                x: 5 * scaleX,
                y: 3 * scaleY,
                width: 20 * scaleX,
                height: 10 * scaleY
            ))
            context.fill(bodyPath, with: .color(bodyColor))

            // Neck - path d="M23,6 Q28,2 26,0 L24,0 Q22,3 22,7 Z"
            var neckPath = Path()
            neckPath.move(to: CGPoint(x: 23 * scaleX, y: 6 * scaleY))
            neckPath.addQuadCurve(
                to: CGPoint(x: 26 * scaleX, y: 0),
                control: CGPoint(x: 28 * scaleX, y: 2 * scaleY)
            )
            neckPath.addLine(to: CGPoint(x: 24 * scaleX, y: 0))
            neckPath.addQuadCurve(
                to: CGPoint(x: 22 * scaleX, y: 7 * scaleY),
                control: CGPoint(x: 22 * scaleX, y: 3 * scaleY)
            )
            neckPath.closeSubpath()
            context.fill(neckPath, with: .color(bodyColor))

            // Head - ellipse at cx="26" cy="1" rx="3" ry="2"
            let headPath = Path(ellipseIn: CGRect(
                x: 23 * scaleX,
                y: -1 * scaleY,
                width: 6 * scaleX,
                height: 4 * scaleY
            ))
            context.fill(headPath, with: .color(bodyColor))

            // Legs with gallop animation
            let legPositions: [(CGFloat, CGFloat)] = [(8, 12), (12, 12), (18, 12), (22, 12)]
            for (index, (x, y)) in legPositions.enumerated() {
                let legYOffset = gallopOffset * (index % 2 == 0 ? 1 : -1)
                let legRect = CGRect(
                    x: x * scaleX,
                    y: (y + legYOffset) * scaleY,
                    width: 2 * scaleX,
                    height: 7 * scaleY
                )
                context.fill(Path(legRect), with: .color(legColor))
            }

            // Tail - path d="M5,7 Q0,10 2,14"
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: 5 * scaleX, y: 7 * scaleY))
            tailPath.addQuadCurve(
                to: CGPoint(x: 2 * scaleX, y: 14 * scaleY),
                control: CGPoint(x: 0, y: 10 * scaleY)
            )
            context.stroke(tailPath, with: .color(tailColor), style: StrokeStyle(lineWidth: 2 * scaleX, lineCap: .round))
        }
    }
}

// MARK: - Canyon Layer View
// Matches HTML canyon formations with scrolling animation (50s)
// Formations sit ON the desert floor at the horizon line

struct CanyonLayerView: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    // Canyon positioned at the horizon line (70% from top)
    // Formations rise UP from the desert floor, not down
    private var horizonY: CGFloat { height * 0.70 }
    // Visible desert area for formation height calculations
    private var visibleDesertHeight: CGFloat { height * 0.25 }

    var body: some View {
        let scrollProgress = elapsedTime.truncatingRemainder(dividingBy: 50) / 50
        let scrollOffset = scrollProgress * width

        Canvas { context, size in
            // Canyon gradient colors: #c06830 -> #d07840 -> #e08850
            let canyonGradient = Gradient(colors: [
                Color(red: 0.753, green: 0.408, blue: 0.188),  // #c06830
                Color(red: 0.816, green: 0.471, blue: 0.251),  // #d07840
                Color(red: 0.878, green: 0.533, blue: 0.314)   // #e08850
            ])

            // Canyon formations - triangular shapes sitting on the desert
            // heightPercent is relative to visible desert area
            let formations: [(left: CGFloat, formationWidth: CGFloat, heightPercent: CGFloat, clipPath: [(CGFloat, CGFloat)])] = [
                (left: 30, formationWidth: 200, heightPercent: 0.40,
                 clipPath: [(0, 1), (0, 0.5), (0.15, 0.35), (0.35, 0.45), (0.5, 0.2), (0.65, 0.4), (0.85, 0.25), (1, 0.35), (1, 1)]),
                (left: 280, formationWidth: 180, heightPercent: 0.35,
                 clipPath: [(0, 1), (0, 0.4), (0.25, 0.25), (0.45, 0.35), (0.6, 0.15), (0.8, 0.3), (1, 0.2), (1, 1)]),
                (left: 510, formationWidth: 220, heightPercent: 0.45,
                 clipPath: [(0, 1), (0, 0.35), (0.2, 0.45), (0.4, 0.2), (0.55, 0.35), (0.75, 0.15), (0.9, 0.3), (1, 0.25), (1, 1)]),
                (left: 780, formationWidth: 190, heightPercent: 0.38,
                 clipPath: [(0, 1), (0, 0.3), (0.3, 0.4), (0.5, 0.15), (0.7, 0.35), (1, 0.2), (1, 1)])
            ]

            let htmlScreenWidth: CGFloat = 351
            let scaleFactor = width / htmlScreenWidth

            // Draw formations sitting on the desert at the horizon line
            for offset in [0, width] {
                for formation in formations {
                    let formationX = formation.left * scaleFactor - scrollOffset + offset
                    let formationW = formation.formationWidth * scaleFactor
                    // Formation height based on visible desert area
                    let formationH = visibleDesertHeight * formation.heightPercent

                    var path = Path()
                    for (index, point) in formation.clipPath.enumerated() {
                        let px = formationX + formationW * point.0
                        // Formations sit on horizon line, peaks point UP (lower Y)
                        // point.1 = 1 is base (at horizon), point.1 = 0 is peak (above horizon)
                        let py = horizonY + formationH * point.1

                        if index == 0 {
                            path.move(to: CGPoint(x: px, y: py))
                        } else {
                            path.addLine(to: CGPoint(x: px, y: py))
                        }
                    }
                    path.closeSubpath()

                    context.fill(path, with: .linearGradient(
                        canyonGradient,
                        startPoint: CGPoint(x: formationX, y: horizonY),
                        endPoint: CGPoint(x: formationX, y: horizonY + formationH)
                    ))
                }
            }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Cactus Layer View
// Matches HTML cactus layer with scrolling animation (50s)

struct CactusLayerView: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double

    // Cactuses on the desert floor (starting at 70% from top)
    private var desertTopY: CGFloat { height * 0.70 }

    var body: some View {
        let scrollProgress = elapsedTime.truncatingRemainder(dividingBy: 50) / 50
        let scrollOffset = scrollProgress * width

        ZStack {
            // Cactus 1: on desert, rooted at horizon
            CactusShape(variant: 1)
                .frame(width: 35, height: 70)
                .position(
                    x: calculateCactusX(basePercent: 0.08, scrollOffset: scrollOffset, width: width),
                    y: desertTopY - 5
                )

            // Cactus 2
            CactusShape(variant: 2)
                .frame(width: 30, height: 60)
                .position(
                    x: calculateCactusX(basePercent: 0.25, scrollOffset: scrollOffset, width: width),
                    y: desertTopY - 2
                )

            // Cactus 3
            CactusShape(variant: 3)
                .frame(width: 38, height: 75)
                .position(
                    x: calculateCactusX(basePercent: 0.45, scrollOffset: scrollOffset, width: width),
                    y: desertTopY - 8
                )

            // Cactus 4
            CactusShape(variant: 4)
                .frame(width: 28, height: 55)
                .position(
                    x: calculateCactusX(basePercent: 0.62, scrollOffset: scrollOffset, width: width),
                    y: desertTopY
                )

            // Cactus 5
            CactusShape(variant: 5)
                .frame(width: 32, height: 65)
                .position(
                    x: calculateCactusX(basePercent: 0.80, scrollOffset: scrollOffset, width: width),
                    y: desertTopY - 3
                )
        }
    }

    private func calculateCactusX(basePercent: CGFloat, scrollOffset: CGFloat, width: CGFloat) -> CGFloat {
        var x = width * basePercent - scrollOffset
        // Wrap around for seamless scrolling
        while x < -50 {
            x += width * 2
        }
        return x
    }
}

// MARK: - Cactus Shape
// Matches HTML SVG cacti exactly with different arm configurations

struct CactusShape: View {
    let variant: Int

    var body: some View {
        Canvas { context, size in
            let scale = size.width / 40

            // Cactus colors from HTML: #2d5a2d, #2a5528, #286028
            let mainGreen: Color
            let highlightGreen: Color

            switch variant {
            case 1, 3, 5:
                mainGreen = Color(red: 0.176, green: 0.353, blue: 0.176)      // #2d5a2d
                highlightGreen = Color(red: 0.290, green: 0.541, blue: 0.290) // #4a8a4a
            case 2:
                mainGreen = Color(red: 0.165, green: 0.333, blue: 0.157)      // #2a5528
                highlightGreen = Color(red: 0.251, green: 0.502, blue: 0.251) // #408040
            default:
                mainGreen = Color(red: 0.157, green: 0.376, blue: 0.157)      // #286028
                highlightGreen = Color(red: 0.227, green: 0.478, blue: 0.227) // #3a7a3a
            }

            // Main stem - all cacti have this
            var stemPath = Path()
            stemPath.move(to: CGPoint(x: 18 * scale, y: 80 * scale))
            stemPath.addLine(to: CGPoint(x: 18 * scale, y: 25 * scale))
            stemPath.addQuadCurve(
                to: CGPoint(x: 20 * scale, y: 10 * scale),
                control: CGPoint(x: 18 * scale, y: 15 * scale)
            )
            stemPath.addQuadCurve(
                to: CGPoint(x: 22 * scale, y: 25 * scale),
                control: CGPoint(x: 22 * scale, y: 15 * scale)
            )
            stemPath.addLine(to: CGPoint(x: 22 * scale, y: 80 * scale))
            stemPath.closeSubpath()
            context.fill(stemPath, with: .color(mainGreen))

            // Left arm - variants 1, 2, 3, 5 have left arms
            if variant == 1 || variant == 2 || variant == 3 || variant == 5 {
                var leftArmPath = Path()
                let armY: CGFloat = variant == 3 ? 55 : (variant == 5 ? 48 : 50)
                let armTopY: CGFloat = variant == 3 ? 38 : (variant == 5 ? 32 : 35)
                let armEndY: CGFloat = variant == 3 ? 33 : (variant == 5 ? 28 : 30)

                leftArmPath.move(to: CGPoint(x: 18 * scale, y: armY * scale))
                leftArmPath.addLine(to: CGPoint(x: 10 * scale, y: armY * scale))
                leftArmPath.addQuadCurve(
                    to: CGPoint(x: 5 * scale, y: (armY - 5) * scale),
                    control: CGPoint(x: 5 * scale, y: armY * scale)
                )
                leftArmPath.addLine(to: CGPoint(x: 5 * scale, y: armTopY * scale))
                leftArmPath.addQuadCurve(
                    to: CGPoint(x: 8 * scale, y: armEndY * scale),
                    control: CGPoint(x: 5 * scale, y: armEndY * scale)
                )
                leftArmPath.addLine(to: CGPoint(x: 10 * scale, y: armEndY * scale))
                leftArmPath.addQuadCurve(
                    to: CGPoint(x: 12 * scale, y: armTopY * scale),
                    control: CGPoint(x: 12 * scale, y: armEndY * scale)
                )
                leftArmPath.addLine(to: CGPoint(x: 12 * scale, y: (armY - 5) * scale))
                leftArmPath.addLine(to: CGPoint(x: 18 * scale, y: (armY - 5) * scale))
                leftArmPath.closeSubpath()
                context.fill(leftArmPath, with: .color(mainGreen))
            }

            // Right arm - variants 1, 3, 4, 5 have right arms
            if variant == 1 || variant == 3 || variant == 4 || variant == 5 {
                var rightArmPath = Path()
                let armY: CGFloat = variant == 3 ? 42 : (variant == 5 ? 38 : (variant == 4 ? 50 : 40))
                let armTopY: CGFloat = variant == 3 ? 25 : (variant == 5 ? 28 : (variant == 4 ? 35 : 20))
                let armEndY: CGFloat = variant == 3 ? 20 : (variant == 5 ? 25 : (variant == 4 ? 31 : 15))

                rightArmPath.move(to: CGPoint(x: 22 * scale, y: armY * scale))
                rightArmPath.addLine(to: CGPoint(x: 30 * scale, y: armY * scale))
                rightArmPath.addQuadCurve(
                    to: CGPoint(x: 35 * scale, y: (armY - 5) * scale),
                    control: CGPoint(x: 35 * scale, y: armY * scale)
                )
                rightArmPath.addLine(to: CGPoint(x: 35 * scale, y: armTopY * scale))
                rightArmPath.addQuadCurve(
                    to: CGPoint(x: 32 * scale, y: armEndY * scale),
                    control: CGPoint(x: 35 * scale, y: armEndY * scale)
                )
                rightArmPath.addLine(to: CGPoint(x: 30 * scale, y: armEndY * scale))
                rightArmPath.addQuadCurve(
                    to: CGPoint(x: 28 * scale, y: armTopY * scale),
                    control: CGPoint(x: 28 * scale, y: armEndY * scale)
                )
                rightArmPath.addLine(to: CGPoint(x: 28 * scale, y: (armY - 5) * scale))
                rightArmPath.addLine(to: CGPoint(x: 22 * scale, y: (armY - 5) * scale))
                rightArmPath.closeSubpath()
                context.fill(rightArmPath, with: .color(mainGreen))
            }

            // Highlight line on stem
            var highlightPath = Path()
            highlightPath.move(to: CGPoint(x: 19 * scale, y: 75 * scale))
            highlightPath.addLine(to: CGPoint(x: 19 * scale, y: 30 * scale))
            context.stroke(highlightPath, with: .color(highlightGreen.opacity(0.5)), style: StrokeStyle(lineWidth: 2 * scale))
        }
    }
}

// MARK: - Gliding Bird View
// Matches HTML bird SVG exactly with breathing animation

struct GlidingBirdView: View {
    let elapsedTime: Double
    let cycleDuration: Double

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration

        // Flight phase: cos for smooth motion
        let flightPhase = cos(cycleProgress * .pi * 2)

        // Subtle tilt - nose up when rising, nose down when descending
        let birdTilt = -flightPhase * 8

        // Gentle horizontal sway
        let sway = sin(elapsedTime / 1.5) * 3

        // Wing animation - subtle gliding motion
        let wingAngle = sin(elapsedTime / 0.8) * 3
        let wingStretch = 1 + sin(elapsedTime / 1.2) * 0.05

        Canvas { context, size in
            // Apply tilt and sway transformations
            context.translateBy(x: size.width / 2, y: size.height / 2)
            context.rotate(by: Angle(degrees: birdTilt))
            context.translateBy(x: -size.width / 2 + sway, y: -size.height / 2)

            let scale = size.width / 80

            // Body - ellipse cx="35" cy="25" rx="18" ry="8" fill="#ffffff"
            let bodyPath = Path(ellipseIn: CGRect(
                x: 17 * scale,
                y: 17 * scale,
                width: 36 * scale,
                height: 16 * scale
            ))
            context.fill(bodyPath, with: .color(.white))

            // Head - circle cx="52" cy="23" r="6" fill="#ffffff"
            let headPath = Path(ellipseIn: CGRect(
                x: 46 * scale,
                y: 17 * scale,
                width: 12 * scale,
                height: 12 * scale
            ))
            context.fill(headPath, with: .color(.white))

            // Beak - path d="M58,23 L65,24 L58,25 Z" fill="#f0a030"
            var beakPath = Path()
            beakPath.move(to: CGPoint(x: 58 * scale, y: 23 * scale))
            beakPath.addLine(to: CGPoint(x: 65 * scale, y: 24 * scale))
            beakPath.addLine(to: CGPoint(x: 58 * scale, y: 25 * scale))
            beakPath.closeSubpath()
            context.fill(beakPath, with: .color(Color(red: 0.941, green: 0.627, blue: 0.188)))  // #f0a030

            // Tail - path d="M17,22 L5,18 L8,25 L5,32 L17,28 Z" fill="#f5f5f5"
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: 17 * scale, y: 22 * scale))
            tailPath.addLine(to: CGPoint(x: 5 * scale, y: 18 * scale))
            tailPath.addLine(to: CGPoint(x: 8 * scale, y: 25 * scale))
            tailPath.addLine(to: CGPoint(x: 5 * scale, y: 32 * scale))
            tailPath.addLine(to: CGPoint(x: 17 * scale, y: 28 * scale))
            tailPath.closeSubpath()
            context.fill(tailPath, with: .color(Color(red: 0.961, green: 0.961, blue: 0.961)))  // #f5f5f5

            // Top wing with animation
            // path d="M30,20 Q20,5 40,8 Q50,10 45,20 Z" fill="#e8e8e8"
            context.translateBy(x: 35 * scale, y: 20 * scale)
            context.rotate(by: Angle(degrees: wingAngle))
            context.scaleBy(x: 1, y: wingStretch)
            context.translateBy(x: -35 * scale, y: -20 * scale)

            var topWingPath = Path()
            topWingPath.move(to: CGPoint(x: 30 * scale, y: 20 * scale))
            topWingPath.addQuadCurve(
                to: CGPoint(x: 40 * scale, y: 8 * scale),
                control: CGPoint(x: 20 * scale, y: 5 * scale)
            )
            topWingPath.addQuadCurve(
                to: CGPoint(x: 45 * scale, y: 20 * scale),
                control: CGPoint(x: 50 * scale, y: 10 * scale)
            )
            topWingPath.closeSubpath()
            context.fill(topWingPath, with: .color(Color(red: 0.910, green: 0.910, blue: 0.910)))  // #e8e8e8

            // Reset transform for bottom wing
            context.translateBy(x: 35 * scale, y: 20 * scale)
            context.scaleBy(x: 1, y: 1 / wingStretch)
            context.rotate(by: Angle(degrees: -wingAngle))
            context.translateBy(x: -35 * scale, y: -20 * scale)

            // Bottom wing with animation
            // path d="M30,30 Q20,45 40,42 Q50,40 45,30 Z" fill="#e8e8e8"
            context.translateBy(x: 35 * scale, y: 30 * scale)
            context.rotate(by: Angle(degrees: -wingAngle))
            context.scaleBy(x: 1, y: wingStretch)
            context.translateBy(x: -35 * scale, y: -30 * scale)

            var bottomWingPath = Path()
            bottomWingPath.move(to: CGPoint(x: 30 * scale, y: 30 * scale))
            bottomWingPath.addQuadCurve(
                to: CGPoint(x: 40 * scale, y: 42 * scale),
                control: CGPoint(x: 20 * scale, y: 45 * scale)
            )
            bottomWingPath.addQuadCurve(
                to: CGPoint(x: 45 * scale, y: 30 * scale),
                control: CGPoint(x: 50 * scale, y: 40 * scale)
            )
            bottomWingPath.closeSubpath()
            context.fill(bottomWingPath, with: .color(Color(red: 0.910, green: 0.910, blue: 0.910)))  // #e8e8e8

            // Reset transform for eye
            context.translateBy(x: 35 * scale, y: 30 * scale)
            context.scaleBy(x: 1, y: 1 / wingStretch)
            context.rotate(by: Angle(degrees: wingAngle))
            context.translateBy(x: -35 * scale, y: -30 * scale)

            // Eye - circle cx="54" cy="22" r="1.5" fill="#1a1a1a"
            let eyePath = Path(ellipseIn: CGRect(
                x: 52.5 * scale,
                y: 20.5 * scale,
                width: 3 * scale,
                height: 3 * scale
            ))
            context.fill(eyePath, with: .color(Color(red: 0.102, green: 0.102, blue: 0.102)))  // #1a1a1a
        }
    }
}

#Preview {
    BreatheGlidingbirdView(duration: 3, onComplete: {}, onBack: {})
}
