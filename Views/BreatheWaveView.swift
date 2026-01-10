import SwiftUI

struct BreatheWaveView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var startTime: Date?
    @State private var hasCompleted: Bool = false

    private let cycleDuration: Double = 10.0

    private var totalDuration: Double {
        Double(duration) * 60.0
    }

    // Calculate crab positions from elapsed time
    private func crabPositions(elapsedTime: Double) -> (crab1Pos: CGFloat, crab1Dir: CGFloat, crab2Pos: CGFloat, crab2Dir: CGFloat) {
        // Crab 1 animation (18s cycle) - walks left to right then back
        let crab1Cycle = elapsedTime.truncatingRemainder(dividingBy: 18)
        let crab1Position: CGFloat
        let crab1Direction: CGFloat
        if crab1Cycle < 9 {
            crab1Position = -0.1 + (crab1Cycle / 9) * 1.2
            crab1Direction = 1
        } else {
            crab1Position = 1.1 - ((crab1Cycle - 9) / 9) * 1.2
            crab1Direction = -1
        }

        // Crab 2 animation (22s cycle) - walks right to left then back
        let crab2Cycle = elapsedTime.truncatingRemainder(dividingBy: 22)
        let crab2Position: CGFloat
        let crab2Direction: CGFloat
        if crab2Cycle < 11 {
            crab2Position = 1.1 - (crab2Cycle / 11) * 1.2
            crab2Direction = -1
        } else {
            crab2Position = -0.1 + ((crab2Cycle - 11) / 11) * 1.2
            crab2Direction = 1
        }

        return (crab1Position, crab1Direction, crab2Position, crab2Direction)
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = startTime.map { timeline.date.timeIntervalSince($0) } ?? 0
            let crabs = crabPositions(elapsedTime: elapsedTime)

            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    // Sand background
                    SandBackground()

                    // Wave with water
                    WaveLayer(
                        width: width,
                        height: height,
                        elapsedTime: elapsedTime,
                        cycleDuration: cycleDuration
                    )

                    // Crabs layer (z-index 15 in HTML - above sand, can be covered by wave)
                    CrabsLayer(
                        width: width,
                        height: height,
                        crab1Position: crabs.crab1Pos,
                        crab2Position: crabs.crab2Pos,
                        crab1Direction: crabs.crab1Dir,
                        crab2Direction: crabs.crab2Dir,
                        elapsedTime: elapsedTime
                    )

                    // Starfish - positioned at bottom: 70%, left: 65% (in crabs-layer which is bottom 25%)
                    // So starfish is at height * (1 - 0.25 * 0.70) = height * 0.825 from top
                    StarfishView()
                        .frame(width: 38, height: 38)
                        .rotationEffect(.degrees(15))
                        .position(x: width * 0.65, y: height * 0.825)

                    // UI Layer
                    VStack {
                        HStack {
                            Button(action: onBack) {
                                ZStack {
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                        .frame(width: 42, height: 42)
                                        .background(
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                                .opacity(0.5)
                                        )
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
                            .shadow(color: Color(red: 0.39, green: 0.31, blue: 0.24).opacity(0.5), radius: 15, y: 2)
                            .padding(.bottom, 32)

                        // Timer
                        let remaining = max(0, totalDuration - elapsedTime)
                        let minutes = Int(remaining) / 60
                        let seconds = Int(remaining) % 60

                        Text(String(format: "%d:%02d", minutes, seconds))
                            .font(.custom("Nunito", size: 15).weight(.light))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: Color(red: 0.39, green: 0.31, blue: 0.24).opacity(0.3), radius: 5, y: 1)
                            .padding(.bottom, 38)

                        // Progress bar
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.25))
                                .frame(height: 3)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.85))
                                .frame(width: max(0, (geometry.size.width - 90) * CGFloat(elapsedTime / totalDuration)), height: 3)
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

// MARK: - Sand Background

struct SandBackground: View {
    var body: some View {
        ZStack {
            // Main sand gradient - exact HTML colors
            LinearGradient(
                colors: [
                    Color(hex: "d4b896"),  // 0%
                    Color(hex: "dcbf9c"),  // 20%
                    Color(hex: "e0c4a0"),  // 40%
                    Color(hex: "e4c8a4"),  // 60%
                    Color(hex: "e8cca8"),  // 80%
                    Color(hex: "ecd0ac")   // 100%
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Sand texture overlay
            SandTextureView()
        }
    }
}

// MARK: - Sand Texture View

struct SandTextureView: View {
    var body: some View {
        Canvas { context, size in
            // Sand texture pattern matching HTML
            let sandGrainColor = Color(red: 0.78, green: 0.67, blue: 0.51) // rgba(200,170,130)

            // Pattern 1: 30x30 at 20%, 30%
            for x in stride(from: 0, to: size.width, by: 30) {
                for y in stride(from: 0, to: size.height, by: 30) {
                    let dot = Path(ellipseIn: CGRect(x: x + 6, y: y + 9, width: 2, height: 2))
                    context.fill(dot, with: .color(sandGrainColor.opacity(0.3)))
                }
            }

            // Pattern 2: 45x45 at 60%, 50%
            for x in stride(from: 0, to: size.width, by: 45) {
                for y in stride(from: 0, to: size.height, by: 45) {
                    let dot = Path(ellipseIn: CGRect(x: x + 27, y: y + 22.5, width: 2, height: 2))
                    context.fill(dot, with: .color(sandGrainColor.opacity(0.25)))
                }
            }

            // Pattern 3: 55x55 at 80%, 20%
            for x in stride(from: 0, to: size.width, by: 55) {
                for y in stride(from: 0, to: size.height, by: 55) {
                    let dot = Path(ellipseIn: CGRect(x: x + 44, y: y + 11, width: 2, height: 2))
                    context.fill(dot, with: .color(sandGrainColor.opacity(0.2)))
                }
            }

            // Pattern 4: 35x35 at 40%, 70%
            for x in stride(from: 0, to: size.width, by: 35) {
                for y in stride(from: 0, to: size.height, by: 35) {
                    let dot = Path(ellipseIn: CGRect(x: x + 14, y: y + 24.5, width: 2, height: 2))
                    context.fill(dot, with: .color(sandGrainColor.opacity(0.3)))
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Wave Layer

struct WaveLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double
    let cycleDuration: Double

    // Wave Y positions as percentages (matching HTML: 180/900 = 0.20, 680/900 = 0.756)
    private let waveYRetreated: CGFloat = 0.20   // Y position when fully retreated (exhale)
    private let waveYExtended: CGFloat = 0.756   // Y position when fully extended (inhale)

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        // cos(0) = 1 -> extended position (inhale - wave covers sand)
        // cos(pi) = -1 -> retreated position (exhale - wave uncovers sand)
        let wavePhase = cos(cycleProgress * .pi * 2)
        let waveMid = (waveYRetreated + waveYExtended) / 2
        let waveRange = (waveYExtended - waveYRetreated) / 2
        let waveY = waveMid + waveRange * wavePhase

        Canvas { context, size in
            let waveYPos = size.height * waveY

            // Generate wave curves with time-based animation
            let t = elapsedTime * 1000 // Convert to milliseconds like HTML
            let curve1 = sin(t / 3000) * 15
            let curve2 = cos(t / 2500) * 12
            let curve3 = sin(t / 2800) * 18
            let curve4 = cos(t / 3200) * 10

            // Foam dimensions
            let foamHeight: CGFloat = 60
            let foamTop = waveYPos - 10
            let foamBottom = waveYPos + foamHeight
            let wetSandTop = foamBottom + 5
            let wetSandBottom = foamBottom + 50

            // Water body path - covers from top of screen to waveY with wavy bottom edge
            var waterPath = Path()
            waterPath.move(to: CGPoint(x: -20, y: 0))
            waterPath.addLine(to: CGPoint(x: size.width + 20, y: 0))
            waterPath.addLine(to: CGPoint(x: size.width + 20, y: waveYPos - 20))
            waterPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.8, y: waveYPos + 25 + curve2),
                control: CGPoint(x: size.width * 0.95, y: waveYPos + curve1)
            )
            waterPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.4, y: waveYPos + 20 + curve4),
                control: CGPoint(x: size.width * 0.6, y: waveYPos + 40 + curve3)
            )
            waterPath.addQuadCurve(
                to: CGPoint(x: 0, y: waveYPos + 30 + curve1),
                control: CGPoint(x: size.width * 0.2, y: waveYPos + curve2)
            )
            waterPath.addLine(to: CGPoint(x: -20, y: waveYPos + 30))
            waterPath.closeSubpath()

            // Water gradient - exact HTML colors
            let waterGradient = Gradient(colors: [
                Color(hex: "2a8098"),  // 0%
                Color(hex: "3a9ab0"),  // 20%
                Color(hex: "4ab0c8"),  // 50%
                Color(hex: "60c4d8"),  // 80%
                Color(hex: "80d8e8")   // 100%
            ])

            context.fill(
                waterPath,
                with: .linearGradient(
                    waterGradient,
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: waveYPos + 50)
                )
            )

            // Water texture overlay - subtle circles
            let waterTexturePositions: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (0.25, 0.25, 12, 0.06),
                (0.75, 0.56, 10, 0.05),
                (0.44, 0.81, 8, 0.04)
            ]
            for (xRatio, yRatio, radius, opacity) in waterTexturePositions {
                for xOff in stride(from: 0, to: size.width, by: 80) {
                    for yOff in stride(from: 0, to: waveYPos, by: 80) {
                        let circleX = xOff + 80 * xRatio
                        let circleY = yOff + 80 * yRatio
                        if circleY < waveYPos {
                            let circlePath = Path(ellipseIn: CGRect(
                                x: circleX - radius,
                                y: circleY - radius,
                                width: radius * 2,
                                height: radius * 2
                            ))
                            context.fill(circlePath, with: .color(.white.opacity(opacity)))
                        }
                    }
                }
            }

            // Foam area path
            var foamPath = Path()
            foamPath.move(to: CGPoint(x: -20, y: foamTop + 30 + curve1))
            foamPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.4, y: foamTop + 20 + curve4),
                control: CGPoint(x: size.width * 0.2, y: foamTop + curve2)
            )
            foamPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.8, y: foamTop + 25 + curve2),
                control: CGPoint(x: size.width * 0.6, y: foamTop + 40 + curve3)
            )
            foamPath.addQuadCurve(
                to: CGPoint(x: size.width + 20, y: foamTop - 20),
                control: CGPoint(x: size.width * 0.95, y: foamTop + curve1)
            )
            foamPath.addLine(to: CGPoint(x: size.width + 20, y: foamBottom - 10))
            foamPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.8, y: foamBottom + 30 + curve2),
                control: CGPoint(x: size.width * 0.95, y: foamBottom + 15 + curve1)
            )
            foamPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.4, y: foamBottom + 25 + curve4),
                control: CGPoint(x: size.width * 0.6, y: foamBottom + 45 + curve3)
            )
            foamPath.addQuadCurve(
                to: CGPoint(x: -20, y: foamBottom + 35 + curve1),
                control: CGPoint(x: size.width * 0.2, y: foamBottom + 10 + curve2)
            )
            foamPath.closeSubpath()

            // Foam gradient - exact HTML values
            let foamIntensity = 0.6 + (1 + wavePhase) * 0.15
            context.fill(
                foamPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.6),
                        Color.white.opacity(0.85),
                        Color.white.opacity(0.95)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: foamTop),
                    endPoint: CGPoint(x: size.width / 2, y: foamBottom)
                )
            )
            context.opacity = foamIntensity

            // Foam bubbles pattern overlay
            let foamBubblePositions: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (0.24, 0.24, 4, 0.75),
                (0.60, 0.20, 3, 0.65),
                (0.44, 0.50, 3.5, 0.7),
                (0.80, 0.56, 2.5, 0.55),
                (0.20, 0.76, 3, 0.6),
                (0.56, 0.84, 4, 0.65),
                (0.90, 0.80, 2, 0.5)
            ]
            context.opacity = 1.0
            for xOff in stride(from: 0, to: size.width, by: 50) {
                for yOff in stride(from: foamTop, to: foamBottom, by: 50) {
                    for (xRatio, yRatio, radius, opacity) in foamBubblePositions {
                        let bubbleX = xOff + 50 * xRatio
                        let bubbleY = yOff + 50 * yRatio
                        if bubbleY >= foamTop && bubbleY <= foamBottom + 20 {
                            let bubblePath = Path(ellipseIn: CGRect(
                                x: bubbleX - radius,
                                y: bubbleY - radius,
                                width: radius * 2,
                                height: radius * 2
                            ))
                            context.fill(bubblePath, with: .color(.white.opacity(opacity * 0.85 * foamIntensity)))
                        }
                    }
                }
            }

            // Foam edge line
            var edgePath = Path()
            edgePath.move(to: CGPoint(x: -20, y: foamBottom + 35 + curve1))
            edgePath.addQuadCurve(
                to: CGPoint(x: size.width * 0.4, y: foamBottom + 25 + curve4),
                control: CGPoint(x: size.width * 0.2, y: foamBottom + 10 + curve2)
            )
            edgePath.addQuadCurve(
                to: CGPoint(x: size.width * 0.8, y: foamBottom + 30 + curve2),
                control: CGPoint(x: size.width * 0.6, y: foamBottom + 45 + curve3)
            )
            edgePath.addQuadCurve(
                to: CGPoint(x: size.width + 20, y: foamBottom - 10),
                control: CGPoint(x: size.width * 0.95, y: foamBottom + 15 + curve1)
            )

            context.stroke(
                edgePath,
                with: .color(.white.opacity(0.9)),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )

            // Wet sand trace
            var wetSandPath = Path()
            wetSandPath.move(to: CGPoint(x: -20, y: wetSandTop + 35 + curve1))
            wetSandPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.4, y: wetSandTop + 25 + curve4),
                control: CGPoint(x: size.width * 0.2, y: wetSandTop + 10 + curve2)
            )
            wetSandPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.8, y: wetSandTop + 30 + curve2),
                control: CGPoint(x: size.width * 0.6, y: wetSandTop + 45 + curve3)
            )
            wetSandPath.addQuadCurve(
                to: CGPoint(x: size.width + 20, y: wetSandTop - 10),
                control: CGPoint(x: size.width * 0.95, y: wetSandTop + 15 + curve1)
            )
            wetSandPath.addLine(to: CGPoint(x: size.width + 20, y: wetSandBottom))
            wetSandPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.7, y: wetSandBottom + 5 + curve2),
                control: CGPoint(x: size.width * 0.875, y: wetSandBottom - 10 + curve1)
            )
            wetSandPath.addQuadCurve(
                to: CGPoint(x: size.width * 0.3, y: wetSandBottom + curve4),
                control: CGPoint(x: size.width * 0.5, y: wetSandBottom + 15 + curve3)
            )
            wetSandPath.addQuadCurve(
                to: CGPoint(x: -20, y: wetSandBottom + 10),
                control: CGPoint(x: size.width * 0.15, y: wetSandBottom - 10 + curve2)
            )
            wetSandPath.closeSubpath()

            // Wet sand gradient - rgba(170,150,120,0.7) to transparent
            context.fill(
                wetSandPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.67, green: 0.59, blue: 0.47).opacity(0.7),
                        Color(red: 0.67, green: 0.59, blue: 0.47).opacity(0)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: wetSandTop),
                    endPoint: CGPoint(x: size.width / 2, y: wetSandBottom)
                )
            )
        }
    }
}

// MARK: - Crabs Layer

struct CrabsLayer: View {
    let width: CGFloat
    let height: CGFloat
    let crab1Position: CGFloat
    let crab2Position: CGFloat
    let crab1Direction: CGFloat
    let crab2Direction: CGFloat
    let elapsedTime: Double

    var body: some View {
        // Crabs layer is bottom 25% of screen (like HTML crabs-layer)
        let crabsLayerTop = height * 0.75

        ZStack {
            // Crab 1 - larger, at bottom: 45% of crabs-layer
            // 45% from bottom of crabs-layer = crabsLayerTop + height * 0.25 * (1 - 0.45)
            CrabView(
                bodyColor: Color(hex: "c44030"),
                highlightColor: Color(hex: "d45040"),
                legColor: Color(hex: "b03828"),
                elapsedTime: elapsedTime
            )
            .frame(width: 35, height: 25)
            .scaleEffect(x: crab1Direction, y: 1)
            .position(x: width * crab1Position, y: crabsLayerTop + height * 0.25 * 0.55)

            // Crab 2 - smaller, at bottom: 12% of crabs-layer
            CrabView(
                bodyColor: Color(hex: "b83525"),
                highlightColor: Color(hex: "c84535"),
                legColor: Color(hex: "a02818"),
                elapsedTime: elapsedTime,
                legAnimationDelay: 0.1
            )
            .frame(width: 28, height: 20)
            .scaleEffect(x: crab2Direction, y: 1)
            .position(x: width * crab2Position, y: crabsLayerTop + height * 0.25 * 0.88)
        }
    }
}

// MARK: - Crab View

struct CrabView: View {
    let bodyColor: Color
    let highlightColor: Color
    let legColor: Color
    let elapsedTime: Double
    var legAnimationDelay: Double = 0

    var body: some View {
        // Legs animate with steps - matching HTML animation
        let legRotation = ((Int(elapsedTime * 6.67 + legAnimationDelay * 6.67) % 2) == 0) ? -5.0 : 5.0

        Canvas { context, size in
            let scaleX = size.width / 40
            let scaleY = size.height / 28

            // Body - main ellipse
            let bodyPath = Path(ellipseIn: CGRect(
                x: 8 * scaleX,
                y: 8 * scaleY,
                width: 24 * scaleX,
                height: 16 * scaleY
            ))
            context.fill(bodyPath, with: .color(bodyColor))

            // Body - top highlight ellipse
            let bodyTopPath = Path(ellipseIn: CGRect(
                x: 10 * scaleX,
                y: 8 * scaleY,
                width: 20 * scaleX,
                height: 12 * scaleY
            ))
            context.fill(bodyTopPath, with: .color(highlightColor))

            // Left eye stalk
            let leftEyeStalk = Path(ellipseIn: CGRect(
                x: 12 * scaleX,
                y: 7 * scaleY,
                width: 4 * scaleX,
                height: 6 * scaleY
            ))
            context.fill(leftEyeStalk, with: .color(bodyColor))

            // Right eye stalk
            let rightEyeStalk = Path(ellipseIn: CGRect(
                x: 24 * scaleX,
                y: 7 * scaleY,
                width: 4 * scaleX,
                height: 6 * scaleY
            ))
            context.fill(rightEyeStalk, with: .color(bodyColor))

            // Left eye
            let leftEye = Path(ellipseIn: CGRect(
                x: 12.5 * scaleX,
                y: 6.5 * scaleY,
                width: 3 * scaleX,
                height: 3 * scaleY
            ))
            context.fill(leftEye, with: .color(Color(hex: "1a1a1a")))

            // Right eye
            let rightEye = Path(ellipseIn: CGRect(
                x: 24.5 * scaleX,
                y: 6.5 * scaleY,
                width: 3 * scaleX,
                height: 3 * scaleY
            ))
            context.fill(rightEye, with: .color(Color(hex: "1a1a1a")))

            // Left claw
            let leftClaw = Path(ellipseIn: CGRect(
                x: 1 * scaleX,
                y: 11 * scaleY,
                width: 8 * scaleX,
                height: 6 * scaleY
            ))
            context.fill(leftClaw, with: .color(highlightColor))

            // Right claw
            let rightClaw = Path(ellipseIn: CGRect(
                x: 31 * scaleX,
                y: 11 * scaleY,
                width: 8 * scaleX,
                height: 6 * scaleY
            ))
            context.fill(rightClaw, with: .color(highlightColor))

            // Left claw tip
            let leftClawTip = Path(ellipseIn: CGRect(
                x: 1 * scaleX,
                y: 10 * scaleY,
                width: 4 * scaleX,
                height: 4 * scaleY
            ))
            context.fill(leftClawTip, with: .color(bodyColor))

            // Right claw tip
            let rightClawTip = Path(ellipseIn: CGRect(
                x: 35 * scaleX,
                y: 10 * scaleY,
                width: 4 * scaleX,
                height: 4 * scaleY
            ))
            context.fill(rightClawTip, with: .color(bodyColor))

            // Left legs with rotation animation
            let leftLegData: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (10, 18, 4, 24),
                (12, 20, 6, 26),
                (14, 21, 10, 27)
            ]
            for (x1, y1, x2, y2) in leftLegData {
                var legPath = Path()
                legPath.move(to: CGPoint(x: x1 * scaleX, y: y1 * scaleY))
                let rotatedY2 = y2 + CGFloat(legRotation) * 0.3
                legPath.addLine(to: CGPoint(x: x2 * scaleX, y: rotatedY2 * scaleY))
                context.stroke(
                    legPath,
                    with: .color(legColor),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
            }

            // Right legs with rotation animation (opposite phase)
            let rightLegData: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (30, 18, 36, 24),
                (28, 20, 34, 26),
                (26, 21, 30, 27)
            ]
            for (x1, y1, x2, y2) in rightLegData {
                var legPath = Path()
                legPath.move(to: CGPoint(x: x1 * scaleX, y: y1 * scaleY))
                let rotatedY2 = y2 - CGFloat(legRotation) * 0.3
                legPath.addLine(to: CGPoint(x: x2 * scaleX, y: rotatedY2 * scaleY))
                context.stroke(
                    legPath,
                    with: .color(legColor),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
            }
        }
    }
}

// MARK: - Starfish View

struct StarfishView: View {
    var body: some View {
        Canvas { context, size in
            let scale = size.width / 60

            // Main starfish body path - exact HTML SVG path
            var starPath = Path()

            // Starting point
            starPath.move(to: CGPoint(x: 30 * scale, y: 3 * scale))

            // Top arm going down
            starPath.addQuadCurve(
                to: CGPoint(x: 34 * scale, y: 12 * scale),
                control: CGPoint(x: 33 * scale, y: 8 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 33 * scale, y: 20 * scale),
                control: CGPoint(x: 35 * scale, y: 16 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 30 * scale, y: 26 * scale),
                control: CGPoint(x: 31 * scale, y: 24 * scale)
            )

            // Right arm
            starPath.addQuadCurve(
                to: CGPoint(x: 36 * scale, y: 26 * scale),
                control: CGPoint(x: 32 * scale, y: 25 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 44 * scale, y: 25 * scale),
                control: CGPoint(x: 40 * scale, y: 27 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 52 * scale, y: 24 * scale),
                control: CGPoint(x: 48 * scale, y: 23 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 57 * scale, y: 28 * scale),
                control: CGPoint(x: 55 * scale, y: 25 * scale)
            )

            // Right arm coming back
            starPath.addQuadCurve(
                to: CGPoint(x: 52 * scale, y: 32 * scale),
                control: CGPoint(x: 55 * scale, y: 31 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 44 * scale, y: 32 * scale),
                control: CGPoint(x: 48 * scale, y: 33 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 36 * scale, y: 31 * scale),
                control: CGPoint(x: 40 * scale, y: 31 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 30 * scale, y: 32 * scale),
                control: CGPoint(x: 32 * scale, y: 31 * scale)
            )

            // Bottom right arm
            starPath.addQuadCurve(
                to: CGPoint(x: 34 * scale, y: 38 * scale),
                control: CGPoint(x: 32 * scale, y: 34 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 35 * scale, y: 46 * scale),
                control: CGPoint(x: 36 * scale, y: 42 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 36 * scale, y: 54 * scale),
                control: CGPoint(x: 34 * scale, y: 50 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 32 * scale, y: 58 * scale),
                control: CGPoint(x: 35 * scale, y: 57 * scale)
            )

            // Bottom right arm coming back
            starPath.addQuadCurve(
                to: CGPoint(x: 28 * scale, y: 52 * scale),
                control: CGPoint(x: 29 * scale, y: 56 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 28 * scale, y: 44 * scale),
                control: CGPoint(x: 27 * scale, y: 48 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 28 * scale, y: 36 * scale),
                control: CGPoint(x: 29 * scale, y: 40 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 26 * scale, y: 32 * scale),
                control: CGPoint(x: 27 * scale, y: 33 * scale)
            )

            // Bottom left arm
            starPath.addQuadCurve(
                to: CGPoint(x: 22 * scale, y: 36 * scale),
                control: CGPoint(x: 24 * scale, y: 33 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 44 * scale),
                control: CGPoint(x: 20 * scale, y: 40 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 14 * scale, y: 51 * scale),
                control: CGPoint(x: 16 * scale, y: 48 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 9 * scale, y: 53 * scale),
                control: CGPoint(x: 12 * scale, y: 54 * scale)
            )

            // Bottom left arm coming back
            starPath.addQuadCurve(
                to: CGPoint(x: 10 * scale, y: 46 * scale),
                control: CGPoint(x: 8 * scale, y: 50 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 15 * scale, y: 38 * scale),
                control: CGPoint(x: 12 * scale, y: 42 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 31 * scale),
                control: CGPoint(x: 18 * scale, y: 34 * scale)
            )

            // Left arm
            starPath.addQuadCurve(
                to: CGPoint(x: 10 * scale, y: 33 * scale),
                control: CGPoint(x: 14 * scale, y: 32 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 3 * scale, y: 32 * scale),
                control: CGPoint(x: 6 * scale, y: 34 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 3 * scale, y: 26 * scale),
                control: CGPoint(x: 1 * scale, y: 29 * scale)
            )

            // Left arm coming back
            starPath.addQuadCurve(
                to: CGPoint(x: 10 * scale, y: 25 * scale),
                control: CGPoint(x: 6 * scale, y: 24 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 18 * scale, y: 26 * scale),
                control: CGPoint(x: 14 * scale, y: 26 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 26 * scale, y: 25 * scale),
                control: CGPoint(x: 22 * scale, y: 26 * scale)
            )

            // Back to top
            starPath.addQuadCurve(
                to: CGPoint(x: 28 * scale, y: 20 * scale),
                control: CGPoint(x: 28 * scale, y: 24 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 27 * scale, y: 12 * scale),
                control: CGPoint(x: 28 * scale, y: 16 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: 30 * scale, y: 3 * scale),
                control: CGPoint(x: 26 * scale, y: 8 * scale)
            )

            starPath.closeSubpath()

            // Fill main body - #e89aa8
            context.fill(starPath, with: .color(Color(hex: "e89aa8")))

            // Stroke outline - white
            context.stroke(starPath, with: .color(.white), lineWidth: 1.5)

            // Center area - #db8595
            let centerPath = Path(ellipseIn: CGRect(
                x: 23 * scale,
                y: 23 * scale,
                width: 14 * scale,
                height: 14 * scale
            ))
            context.fill(centerPath, with: .color(Color(hex: "db8595")))
            context.stroke(centerPath, with: .color(.white), lineWidth: 1)

            // Texture cells on arms - matching HTML exactly
            let textureEllipses: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                // Top arm
                (30, 14, 3, 4),
                (30, 8, 2, 2.5),
                // Right arm
                (45, 28, 4, 3),
                (52, 28, 2.5, 2),
                // Bottom right arm
                (35, 45, 3, 4),
                (34, 52, 2, 2.5),
                // Bottom left arm
                (16, 42, 3, 3.5),
                (11, 48, 2, 2),
                // Left arm
                (12, 28, 4, 3),
                (5, 28, 2, 2)
            ]

            for (cx, cy, rx, ry) in textureEllipses {
                let ellipsePath = Path(ellipseIn: CGRect(
                    x: (cx - rx) * scale,
                    y: (cy - ry) * scale,
                    width: rx * 2 * scale,
                    height: ry * 2 * scale
                ))
                context.fill(ellipsePath, with: .color(Color(hex: "db8595")))
                context.stroke(ellipsePath, with: .color(Color(hex: "f5c5cf")), lineWidth: 0.8)
            }

            // Small dots texture - #d07585
            let dotPositions: [(CGFloat, CGFloat)] = [
                (30, 20),
                (38, 28),
                (34, 38),
                (24, 38),
                (22, 28)
            ]

            for (cx, cy) in dotPositions {
                let dotPath = Path(ellipseIn: CGRect(
                    x: (cx - 1.5) * scale,
                    y: (cy - 1.5) * scale,
                    width: 3 * scale,
                    height: 3 * scale
                ))
                context.fill(dotPath, with: .color(Color(hex: "d07585")))
                context.stroke(dotPath, with: .color(Color(hex: "f5c5cf")), lineWidth: 0.5)
            }
        }
    }
}

#Preview {
    BreatheWaveView(duration: 3, onComplete: {}, onBack: {})
}
