import SwiftUI

struct BreatheBranchView: View {
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
                // Forest background
                ForestBackground()

                // Bokeh lights
                BokehLayer(elapsedTime: elapsedTime, cycleDuration: cycleDuration, width: width, height: height)

                // Birds flying
                BirdsLayer(elapsedTime: elapsedTime, width: width, height: height)

                // Light rays
                LightRaysLayer(elapsedTime: elapsedTime, cycleDuration: cycleDuration, width: width, height: height)

                // Branch with leaves
                BranchWithLeaves(
                    elapsedTime: elapsedTime,
                    cycleDuration: cycleDuration,
                    width: width,
                    height: height
                )

                // UI Layer
                VStack {
                    HStack {
                        Button(action: onBack) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.15))
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
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
                        .shadow(color: Color(red: 0, green: 0.2, blue: 0.1).opacity(0.5), radius: 15, y: 2)
                        .padding(.bottom, 8)

                    // Timer
                    let remaining = max(0, totalDuration - elapsedTime)
                    let minutes = Int(remaining) / 60
                    let seconds = Int(remaining) % 60

                    Text(String(format: "%d:%02d", minutes, seconds))
                        .font(.custom("Nunito", size: 15).weight(.light))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: Color(red: 0, green: 0.2, blue: 0.1).opacity(0.3), radius: 5, y: 1)
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

// MARK: - Forest Background

struct ForestBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.23, blue: 0.16),
                Color(red: 0.16, green: 0.29, blue: 0.23),
                Color(red: 0.23, green: 0.35, blue: 0.29),
                Color(red: 0.16, green: 0.28, blue: 0.22),
                Color(red: 0.10, green: 0.22, blue: 0.16)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Bokeh Layer

struct BokehLayer: View {
    let elapsedTime: Double
    let cycleDuration: Double
    let width: CGFloat
    let height: CGFloat

    private let bokehData: [(x: CGFloat, y: CGFloat, size: CGFloat, color: Color, period: Double)] = [
        (0.15, 0.10, 80, Color(red: 0.70, green: 0.86, blue: 0.63), 8),
        (0.90, 0.25, 120, Color(red: 0.78, green: 0.94, blue: 0.70), 10),
        (0.08, 0.60, 60, Color(red: 0.63, green: 0.78, blue: 0.55), 7),
        (0.85, 0.75, 100, Color(red: 0.74, green: 0.90, blue: 0.67), 9),
        (0.25, 0.45, 50, Color(red: 0.86, green: 1.0, blue: 0.78), 6),
        (0.75, 0.15, 70, Color(red: 0.67, green: 0.82, blue: 0.59), 11)
    ]

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let windPhase = cos(cycleProgress * .pi * 2)
        let breathPhase = (1 - windPhase) / 2
        let bokehIntensity = 0.3 + breathPhase * 0.25

        Canvas { context, size in
            for bokeh in bokehData {
                let phase = elapsedTime / bokeh.period
                let offsetX = sin(phase) * 10 + cos(phase * 0.7) * 5
                let offsetY = cos(phase) * 15 - sin(phase * 0.5) * 8
                let scaleVariation = 1 + sin(phase) * 0.1

                let centerX = size.width * bokeh.x + offsetX
                let centerY = size.height * bokeh.y + offsetY
                let radius = bokeh.size * scaleVariation / 2

                context.fill(
                    Path(ellipseIn: CGRect(
                        x: centerX - radius,
                        y: centerY - radius,
                        width: radius * 2,
                        height: radius * 2
                    )),
                    with: .radialGradient(
                        Gradient(colors: [bokeh.color.opacity(0.5 * (bokehIntensity + 0.4)), .clear]),
                        center: CGPoint(x: centerX, y: centerY),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
        }
        .blur(radius: 8)
    }
}

// MARK: - Birds Layer

struct BirdsLayer: View {
    let elapsedTime: Double
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        // Bird 1 - flying left to right
        let bird1Cycle = elapsedTime.truncatingRemainder(dividingBy: 18)
        let bird1X = -0.1 + (bird1Cycle / 18) * 1.2
        let bird1Y = 0.18 - (bird1Cycle / 18) * 0.06

        SmallBirdView(elapsedTime: elapsedTime)
            .frame(width: 32, height: 20)
            .position(x: width * bird1X, y: height * bird1Y)
            .opacity(bird1X > 0 && bird1X < 1 ? 0.6 : 0)

        // Bird 2 - flying right to left
        let bird2Cycle = (elapsedTime + 6).truncatingRemainder(dividingBy: 20)
        let bird2X = 1.1 - (bird2Cycle / 20) * 1.2
        let bird2Y = 0.55 - (bird2Cycle / 20) * 0.05

        SmallBirdView(elapsedTime: elapsedTime)
            .frame(width: 30, height: 18)
            .scaleEffect(x: -1, y: 1)
            .position(x: width * bird2X, y: height * bird2Y)
            .opacity(bird2X > 0 && bird2X < 1 ? 0.6 : 0)
    }
}

// MARK: - Small Bird View

struct SmallBirdView: View {
    let elapsedTime: Double

    var body: some View {
        let wingFlap = sin(elapsedTime * 30) * 0.4

        Canvas { context, size in
            let scale = size.width / 40

            // Body
            let bodyPath = Path(ellipseIn: CGRect(
                x: 10 * scale, y: 8 * scale, width: 20 * scale, height: 12 * scale
            ))
            context.fill(bodyPath, with: .color(Color(red: 0.31, green: 0.56, blue: 0.75)))

            // Head
            let headPath = Path(ellipseIn: CGRect(
                x: 25 * scale, y: 6 * scale, width: 10 * scale, height: 10 * scale
            ))
            context.fill(headPath, with: .color(Color(red: 0.38, green: 0.63, blue: 0.82)))

            // Beak
            var beakPath = Path()
            beakPath.move(to: CGPoint(x: 35 * scale, y: 11 * scale))
            beakPath.addLine(to: CGPoint(x: 40 * scale, y: 12 * scale))
            beakPath.addLine(to: CGPoint(x: 35 * scale, y: 13 * scale))
            beakPath.closeSubpath()
            context.fill(beakPath, with: .color(Color(red: 0.88, green: 0.63, blue: 0.31)))

            // Eye
            let eyePath = Path(ellipseIn: CGRect(
                x: 31 * scale, y: 9 * scale, width: 2.4 * scale, height: 2.4 * scale
            ))
            context.fill(eyePath, with: .color(Color(red: 0.1, green: 0.16, blue: 0.23)))

            // Wing with flap
            let wingY = 6 * scale + wingFlap * 10
            let wingPath = Path(ellipseIn: CGRect(
                x: 10 * scale, y: wingY, width: 16 * scale, height: 10 * scale
            ))
            context.fill(wingPath, with: .color(Color(red: 0.25, green: 0.50, blue: 0.69)))

            // Tail
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: 10 * scale, y: 12 * scale))
            tailPath.addLine(to: CGPoint(x: 2 * scale, y: 8 * scale))
            tailPath.addLine(to: CGPoint(x: 4 * scale, y: 14 * scale))
            tailPath.addLine(to: CGPoint(x: 2 * scale, y: 18 * scale))
            tailPath.addLine(to: CGPoint(x: 10 * scale, y: 16 * scale))
            tailPath.closeSubpath()
            context.fill(tailPath, with: .color(Color(red: 0.25, green: 0.50, blue: 0.69)))
        }
    }
}

// MARK: - Light Rays Layer

struct LightRaysLayer: View {
    let elapsedTime: Double
    let cycleDuration: Double
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let windPhase = cos(cycleProgress * .pi * 2)
        let breathPhase = (1 - windPhase) / 2
        let rayIntensity = 0.2 + breathPhase * 0.3

        ZStack {
            // Light ray 1
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1, green: 1, blue: 0.78).opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 30, height: 150)
                .blur(radius: 10)
                .rotationEffect(.degrees(-15))
                .position(x: width * 0.30, y: height * 0.25)
                .opacity(0.2 + sin(elapsedTime / 4) * 0.15)

            // Light ray 2
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1, green: 1, blue: 0.78).opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 25, height: 120)
                .blur(radius: 10)
                .rotationEffect(.degrees(10))
                .position(x: width * 0.55, y: height * 0.30)
                .opacity(0.25 + sin(elapsedTime / 5) * 0.10)

            // Light ray 3
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1, green: 1, blue: 0.78).opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 20, height: 100)
                .blur(radius: 10)
                .rotationEffect(.degrees(5))
                .position(x: width * 0.70, y: height * 0.35)
                .opacity(0.15 + sin(elapsedTime / 3.5) * 0.125)
        }
        .opacity(rayIntensity + 0.3)
    }
}

// MARK: - Branch with Leaves

struct BranchWithLeaves: View {
    let elapsedTime: Double
    let cycleDuration: Double
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let windPhase = cos(cycleProgress * .pi * 2)
        let breathPhase = (1 - windPhase) / 2

        let gustVariation = sin(elapsedTime / 0.8) * 0.08 + sin(elapsedTime / 1.2) * 0.05
        let finalPhase = breathPhase + gustVariation * breathPhase

        let branchRotation = finalPhase * 12
        let branchLift = finalPhase * 25

        Canvas { context, size in
            let centerX = size.width / 2
            let centerY = size.height / 2
            let scale = min(size.width / 300, size.height / 400)

            // Apply branch group transform
            context.translateBy(x: centerX - 150 * scale, y: centerY - 200 * scale)

            // Simulate rotation around bottom left
            let rotationAngle = -branchRotation * .pi / 180
            context.translateBy(x: 0, y: 380 * scale)
            context.rotate(by: Angle(radians: rotationAngle))
            context.translateBy(x: 0, y: -380 * scale - branchLift)

            // Branch gradient colors
            let branchDark = Color(red: 0.29, green: 0.21, blue: 0.15)
            let branchMid = Color(red: 0.36, green: 0.27, blue: 0.20)

            // Main branch
            var branchPath = Path()
            branchPath.move(to: CGPoint(x: -20 * scale, y: 380 * scale))
            branchPath.addQuadCurve(
                to: CGPoint(x: 100 * scale, y: 300 * scale),
                control: CGPoint(x: 60 * scale, y: 350 * scale)
            )
            branchPath.addQuadCurve(
                to: CGPoint(x: 160 * scale, y: 200 * scale),
                control: CGPoint(x: 140 * scale, y: 250 * scale)
            )
            branchPath.addQuadCurve(
                to: CGPoint(x: 220 * scale, y: 120 * scale),
                control: CGPoint(x: 180 * scale, y: 150 * scale)
            )
            branchPath.addQuadCurve(
                to: CGPoint(x: 290 * scale, y: 75 * scale),
                control: CGPoint(x: 260 * scale, y: 90 * scale)
            )

            context.stroke(
                branchPath,
                with: .linearGradient(
                    Gradient(colors: [branchDark, branchMid, branchDark]),
                    startPoint: CGPoint(x: 0, y: 200 * scale),
                    endPoint: CGPoint(x: 300 * scale, y: 200 * scale)
                ),
                style: StrokeStyle(lineWidth: 10 * scale, lineCap: .round)
            )

            // Stems and leaves data
            let leavesData: [(stemStart: CGPoint, stemEnd: CGPoint, isLight: Bool, pivotX: CGFloat, pivotY: CGFloat)] = [
                (CGPoint(x: 100, y: 300), CGPoint(x: 82, y: 282), false, 82, 282),
                (CGPoint(x: 110, y: 285), CGPoint(x: 128, y: 268), true, 128, 268),
                (CGPoint(x: 140, y: 250), CGPoint(x: 122, y: 235), false, 122, 235),
                (CGPoint(x: 150, y: 235), CGPoint(x: 168, y: 218), true, 168, 218),
                (CGPoint(x: 160, y: 200), CGPoint(x: 142, y: 182), false, 142, 182),
                (CGPoint(x: 175, y: 175), CGPoint(x: 195, y: 158), true, 195, 158),
                (CGPoint(x: 200, y: 140), CGPoint(x: 182, y: 122), false, 182, 122),
                (CGPoint(x: 220, y: 120), CGPoint(x: 240, y: 104), true, 240, 104),
                (CGPoint(x: 255, y: 95), CGPoint(x: 240, y: 78), false, 240, 78),
                (CGPoint(x: 280, y: 80), CGPoint(x: 298, y: 65), true, 298, 65)
            ]

            // Draw stems
            for leaf in leavesData {
                var stemPath = Path()
                stemPath.move(to: CGPoint(x: leaf.stemStart.x * scale, y: leaf.stemStart.y * scale))
                stemPath.addLine(to: CGPoint(x: leaf.stemEnd.x * scale, y: leaf.stemEnd.y * scale))
                context.stroke(stemPath, with: .color(branchMid), style: StrokeStyle(lineWidth: 2.5 * scale, lineCap: .round))
            }

            // Draw leaves with animation
            let leafGreen = Color(red: 0.35, green: 0.54, blue: 0.31)
            let leafGreenLight = Color(red: 0.42, green: 0.60, blue: 0.38)

            for (index, leaf) in leavesData.enumerated() {
                let windStrength = breathPhase * 8
                let flutter = sin(elapsedTime / 0.4 + Double(index) * 1.5) * (2 + windStrength * 0.5)
                let sway = sin(elapsedTime / 0.6 + Double(index) * 0.8) * windStrength * 0.3
                let totalRotation = flutter + sway

                // Save context state
                context.translateBy(x: leaf.pivotX * scale, y: leaf.pivotY * scale)
                context.rotate(by: Angle(degrees: totalRotation))
                context.translateBy(x: -leaf.pivotX * scale, y: -leaf.pivotY * scale)

                let leafColor = leaf.isLight ? leafGreenLight : leafGreen
                let px = leaf.pivotX * scale
                let py = leaf.pivotY * scale

                // Draw leaf shape
                var leafPath = Path()

                if leaf.isLight {
                    // Right-side leaves
                    leafPath.move(to: CGPoint(x: px, y: py))
                    leafPath.addQuadCurve(
                        to: CGPoint(x: px + 24 * scale, y: py + 2 * scale),
                        control: CGPoint(x: px + 20 * scale, y: py - 14 * scale)
                    )
                    leafPath.addQuadCurve(
                        to: CGPoint(x: px + 4 * scale, y: py + 17 * scale),
                        control: CGPoint(x: px + 16 * scale, y: py + 17 * scale)
                    )
                    leafPath.addQuadCurve(
                        to: CGPoint(x: px, y: py),
                        control: CGPoint(x: px - 2 * scale, y: py + 10 * scale)
                    )
                } else {
                    // Left-side leaves
                    leafPath.move(to: CGPoint(x: px, y: py))
                    leafPath.addQuadCurve(
                        to: CGPoint(x: px - 10 * scale, y: py - 30 * scale),
                        control: CGPoint(x: px - 20 * scale, y: py - 15 * scale)
                    )
                    leafPath.addQuadCurve(
                        to: CGPoint(x: px + 10 * scale, y: py - 12 * scale),
                        control: CGPoint(x: px + 2 * scale, y: py - 25 * scale)
                    )
                    leafPath.addQuadCurve(
                        to: CGPoint(x: px, y: py),
                        control: CGPoint(x: px + 8 * scale, y: py - 2 * scale)
                    )
                }

                leafPath.closeSubpath()
                context.fill(leafPath, with: .color(leafColor))

                // Restore context
                context.translateBy(x: leaf.pivotX * scale, y: leaf.pivotY * scale)
                context.rotate(by: Angle(degrees: -totalRotation))
                context.translateBy(x: -leaf.pivotX * scale, y: -leaf.pivotY * scale)
            }
        }
        .frame(width: 300, height: 400)
        .position(x: width / 2, y: height / 2)
    }
}

#Preview {
    BreatheBranchView(duration: 3, onComplete: {}, onBack: {})
}
