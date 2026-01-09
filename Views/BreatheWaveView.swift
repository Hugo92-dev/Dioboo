import SwiftUI

struct BreatheWaveView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var elapsedTime: Double = 0
    @State private var isAnimating = false
    @State private var crab1Position: CGFloat = -0.1
    @State private var crab2Position: CGFloat = 1.1
    @State private var crab1Direction: CGFloat = 1
    @State private var crab2Direction: CGFloat = -1

    private let cycleDuration: Double = 10.0

    private var totalDuration: Double {
        Double(duration) * 60.0
    }

    var body: some View {
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

                // Crabs layer
                CrabsLayer(
                    width: width,
                    height: height,
                    crab1Position: crab1Position,
                    crab2Position: crab2Position,
                    crab1Direction: crab1Direction,
                    elapsedTime: elapsedTime
                )

                // Starfish
                StarfishView()
                    .frame(width: 38, height: 38)
                    .rotationEffect(.degrees(15))
                    .position(x: width * 0.65, y: height * 0.23)

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
                        .shadow(color: Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.5), radius: 15, y: 2)
                        .padding(.bottom, 8)

                    // Timer
                    let remaining = max(0, totalDuration - elapsedTime)
                    let minutes = Int(remaining) / 60
                    let seconds = Int(remaining) % 60

                    Text(String(format: "%d:%02d", minutes, seconds))
                        .font(.custom("Nunito", size: 15).weight(.light))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.3), radius: 5, y: 1)
                        .padding(.bottom, 20)

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

            // Crab 1 animation (18s cycle)
            let crab1Cycle = elapsedTime.truncatingRemainder(dividingBy: 18)
            if crab1Cycle < 9 {
                crab1Position = -0.1 + (crab1Cycle / 9) * 1.2
                crab1Direction = 1
            } else {
                crab1Position = 1.1 - ((crab1Cycle - 9) / 9) * 1.2
                crab1Direction = -1
            }

            // Crab 2 animation (22s cycle)
            let crab2Cycle = elapsedTime.truncatingRemainder(dividingBy: 22)
            if crab2Cycle < 11 {
                crab2Position = 1.1 - (crab2Cycle / 11) * 1.2
                crab2Direction = -1
            } else {
                crab2Position = -0.1 + ((crab2Cycle - 11) / 11) * 1.2
                crab2Direction = 1
            }

            if elapsedTime >= totalDuration {
                timer.invalidate()
                onComplete()
            }
        }
    }
}

// MARK: - Sand Background

struct SandBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.83, green: 0.72, blue: 0.59),
                Color(red: 0.86, green: 0.75, blue: 0.61),
                Color(red: 0.88, green: 0.77, blue: 0.63),
                Color(red: 0.89, green: 0.78, blue: 0.64),
                Color(red: 0.91, green: 0.80, blue: 0.66),
                Color(red: 0.93, green: 0.82, blue: 0.67)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Wave Layer

struct WaveLayer: View {
    let width: CGFloat
    let height: CGFloat
    let elapsedTime: Double
    let cycleDuration: Double

    private let waveYRetreated: CGFloat = 0.20
    private let waveYExtended: CGFloat = 0.75

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let wavePhase = cos(cycleProgress * .pi * 2)
        let waveMid = (waveYRetreated + waveYExtended) / 2
        let waveRange = (waveYExtended - waveYRetreated) / 2
        let waveY = waveMid + waveRange * wavePhase

        Canvas { context, size in
            let waveYPos = size.height * waveY

            // Generate wave curves
            let curve1 = sin(elapsedTime / 3) * 15
            let curve2 = cos(elapsedTime / 2.5) * 12
            let curve3 = sin(elapsedTime / 2.8) * 18
            let curve4 = cos(elapsedTime / 3.2) * 10

            // Water body path
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

            // Water gradient
            let waterGradient = Gradient(colors: [
                Color(red: 0.16, green: 0.50, blue: 0.60),
                Color(red: 0.23, green: 0.60, blue: 0.69),
                Color(red: 0.29, green: 0.69, blue: 0.78),
                Color(red: 0.38, green: 0.77, blue: 0.85),
                Color(red: 0.50, green: 0.85, blue: 0.91)
            ])

            context.fill(
                waterPath,
                with: .linearGradient(
                    waterGradient,
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: waveYPos + 50)
                )
            )

            // Foam area
            let foamTop = waveYPos - 10
            let foamBottom = waveYPos + 60

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

            // Foam gradient
            let foamIntensity = 0.6 + (1 + wavePhase) * 0.15
            context.fill(
                foamPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.white.opacity(0.2 * foamIntensity),
                        Color.white.opacity(0.6 * foamIntensity),
                        Color.white.opacity(0.85 * foamIntensity),
                        Color.white.opacity(0.95 * foamIntensity)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: foamTop),
                    endPoint: CGPoint(x: size.width / 2, y: foamBottom)
                )
            )

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
                lineWidth: 5
            )

            // Wet sand trace
            let wetSandTop = foamBottom + 5
            let wetSandBottom = foamBottom + 50

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

            // Foam bubbles
            let bubblePositions: [(CGFloat, CGFloat, CGFloat)] = [
                (0.1, 0.3, 4), (0.25, 0.15, 3), (0.18, 0.5, 3.5),
                (0.35, 0.25, 2.5), (0.08, 0.7, 3), (0.22, 0.8, 4),
                (0.4, 0.6, 2), (0.55, 0.2, 3.5), (0.65, 0.45, 3),
                (0.75, 0.3, 4), (0.85, 0.55, 2.5), (0.92, 0.4, 3)
            ]

            for (xRatio, yRatio, radius) in bubblePositions {
                let bubbleX = size.width * xRatio
                let bubbleY = foamTop + (foamBottom - foamTop) * yRatio

                let circlePath = Path(ellipseIn: CGRect(
                    x: bubbleX - radius,
                    y: bubbleY - radius,
                    width: radius * 2,
                    height: radius * 2
                ))

                context.fill(
                    circlePath,
                    with: .color(.white.opacity(0.6 * foamIntensity))
                )
            }
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
    let elapsedTime: Double

    var body: some View {
        ZStack {
            // Crab 1 - larger
            CrabView(
                color1: Color(red: 0.77, green: 0.25, blue: 0.19),
                color2: Color(red: 0.83, green: 0.31, blue: 0.25),
                elapsedTime: elapsedTime
            )
            .frame(width: 35, height: 25)
            .scaleEffect(x: crab1Direction, y: 1)
            .position(x: width * crab1Position, y: height * 0.82)

            // Crab 2 - smaller
            CrabView(
                color1: Color(red: 0.72, green: 0.21, blue: 0.15),
                color2: Color(red: 0.78, green: 0.27, blue: 0.21),
                elapsedTime: elapsedTime
            )
            .frame(width: 28, height: 20)
            .scaleEffect(x: crab2Position > 0.5 ? -1 : 1, y: 1)
            .position(x: width * crab2Position, y: height * 0.94)
        }
    }
}

// MARK: - Crab View

struct CrabView: View {
    let color1: Color
    let color2: Color
    let elapsedTime: Double

    var body: some View {
        let legRotation = sin(elapsedTime * 20) * 5

        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height * 0.57

            // Body
            let bodyPath = Path(ellipseIn: CGRect(x: cx - 12, y: cy - 8, width: 24, height: 16))
            context.fill(bodyPath, with: .color(color1))

            let bodyTop = Path(ellipseIn: CGRect(x: cx - 10, y: cy - 10, width: 20, height: 12))
            context.fill(bodyTop, with: .color(color2))

            // Eyes
            let leftEyeStalk = Path(ellipseIn: CGRect(x: cx - 8, y: cy - 14, width: 4, height: 6))
            let rightEyeStalk = Path(ellipseIn: CGRect(x: cx + 4, y: cy - 14, width: 4, height: 6))
            context.fill(leftEyeStalk, with: .color(color1))
            context.fill(rightEyeStalk, with: .color(color1))

            let leftEye = Path(ellipseIn: CGRect(x: cx - 7.5, y: cy - 16, width: 3, height: 3))
            let rightEye = Path(ellipseIn: CGRect(x: cx + 4.5, y: cy - 16, width: 3, height: 3))
            context.fill(leftEye, with: .color(Color(red: 0.1, green: 0.1, blue: 0.1)))
            context.fill(rightEye, with: .color(Color(red: 0.1, green: 0.1, blue: 0.1)))

            // Claws
            let leftClaw = Path(ellipseIn: CGRect(x: cx - 19, y: cy - 6, width: 8, height: 6))
            let rightClaw = Path(ellipseIn: CGRect(x: cx + 11, y: cy - 6, width: 8, height: 6))
            context.fill(leftClaw, with: .color(color2))
            context.fill(rightClaw, with: .color(color2))

            let leftClawTip = Path(ellipseIn: CGRect(x: cx - 21, y: cy - 10, width: 4, height: 4))
            let rightClawTip = Path(ellipseIn: CGRect(x: cx + 17, y: cy - 10, width: 4, height: 4))
            context.fill(leftClawTip, with: .color(color1))
            context.fill(rightClawTip, with: .color(color1))

            // Legs with animation
            let legColor = color1.opacity(0.85)

            // Left legs
            for i in 0..<3 {
                var legPath = Path()
                let startX = cx - 10 + CGFloat(i) * 4
                let startY = cy + 4 + CGFloat(i) * 2
                let endX = startX - 8
                let endY = startY + 8 + legRotation
                legPath.move(to: CGPoint(x: startX, y: startY))
                legPath.addLine(to: CGPoint(x: endX, y: endY))
                context.stroke(legPath, with: .color(legColor), lineWidth: 2)
            }

            // Right legs
            for i in 0..<3 {
                var legPath = Path()
                let startX = cx + 10 - CGFloat(i) * 4
                let startY = cy + 4 + CGFloat(i) * 2
                let endX = startX + 8
                let endY = startY + 8 - legRotation
                legPath.move(to: CGPoint(x: startX, y: startY))
                legPath.addLine(to: CGPoint(x: endX, y: endY))
                context.stroke(legPath, with: .color(legColor), lineWidth: 2)
            }
        }
    }
}

// MARK: - Starfish View

struct StarfishView: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let scale = size.width / 60

            // Main starfish body path
            var starPath = Path()
            starPath.move(to: CGPoint(x: cx, y: cy - 27 * scale))

            // Top arm
            starPath.addQuadCurve(
                to: CGPoint(x: cx + 4 * scale, y: cy - 8 * scale),
                control: CGPoint(x: cx + 3 * scale, y: cy - 12 * scale)
            )

            // Top right arm
            starPath.addQuadCurve(
                to: CGPoint(x: cx + 27 * scale, y: cy - 2 * scale),
                control: CGPoint(x: cx + 22 * scale, y: cy - 7 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: cx + 6 * scale, y: cy + 1 * scale),
                control: CGPoint(x: cx + 14 * scale, y: cy + 1 * scale)
            )

            // Bottom right arm
            starPath.addQuadCurve(
                to: CGPoint(x: cx + 6 * scale, y: cy + 24 * scale),
                control: CGPoint(x: cx + 5 * scale, y: cy + 16 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: cx - 2 * scale, y: cy + 6 * scale),
                control: CGPoint(x: cx - 2 * scale, y: cy + 14 * scale)
            )

            // Bottom left arm
            starPath.addQuadCurve(
                to: CGPoint(x: cx - 16 * scale, y: cy + 21 * scale),
                control: CGPoint(x: cx - 8 * scale, y: cy + 14 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: cx - 4 * scale, y: cy + 2 * scale),
                control: CGPoint(x: cx - 8 * scale, y: cy + 6 * scale)
            )

            // Top left arm
            starPath.addQuadCurve(
                to: CGPoint(x: cx - 27 * scale, y: cy - 4 * scale),
                control: CGPoint(x: cx - 14 * scale, y: cy - 4 * scale)
            )
            starPath.addQuadCurve(
                to: CGPoint(x: cx - 2 * scale, y: cy - 6 * scale),
                control: CGPoint(x: cx - 10 * scale, y: cy - 5 * scale)
            )

            starPath.addQuadCurve(
                to: CGPoint(x: cx, y: cy - 27 * scale),
                control: CGPoint(x: cx - 2 * scale, y: cy - 18 * scale)
            )

            starPath.closeSubpath()

            // Fill main body
            context.fill(starPath, with: .color(Color(red: 0.91, green: 0.60, blue: 0.66)))

            // Stroke outline
            context.stroke(starPath, with: .color(.white), lineWidth: 1.5)

            // Center
            let centerPath = Path(ellipseIn: CGRect(
                x: cx - 7 * scale,
                y: cy - 7 * scale,
                width: 14 * scale,
                height: 14 * scale
            ))
            context.fill(centerPath, with: .color(Color(red: 0.86, green: 0.52, blue: 0.58)))
            context.stroke(centerPath, with: .color(.white), lineWidth: 1)

            // Texture dots on arms
            let dotPositions: [(CGFloat, CGFloat, CGFloat)] = [
                (0, -14, 3), (0, -22, 2),
                (15, -2, 4), (22, -2, 2.5),
                (5, 15, 3), (4, 22, 2),
                (-14, 12, 3), (-19, 18, 2),
                (-15, -2, 4), (-22, -2, 2)
            ]

            for (dx, dy, r) in dotPositions {
                let dotPath = Path(ellipseIn: CGRect(
                    x: cx + dx * scale - r * scale / 2,
                    y: cy + dy * scale - r * scale / 2,
                    width: r * scale,
                    height: r * scale * 1.2
                ))
                context.fill(dotPath, with: .color(Color(red: 0.86, green: 0.52, blue: 0.58)))
                context.stroke(dotPath, with: .color(Color(red: 0.96, green: 0.77, blue: 0.81)), lineWidth: 0.6)
            }
        }
    }
}

#Preview {
    BreatheWaveView(duration: 3, onComplete: {}, onBack: {})
}
