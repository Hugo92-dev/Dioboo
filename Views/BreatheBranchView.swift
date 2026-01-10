import SwiftUI

struct BreatheBranchView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var startTime: Date?
    @State private var sceneOpacity: Double = 0
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
                    // Background with gradient (matches HTML exactly)
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
                                        .blur(radius: 0.5) // backdrop-filter simulation
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
                            .shadow(color: Color(red: 0, green: 50.0/255.0, blue: 30.0/255.0).opacity(0.5), radius: 15, y: 2)
                            .padding(.bottom, 32)

                        // Timer
                        let remaining = max(0, totalDuration - elapsedTime)
                        let minutes = Int(remaining) / 60
                        let seconds = Int(remaining) % 60

                        Text(String(format: "%d:%02d", minutes, seconds))
                            .font(.custom("Nunito", size: 15).weight(.light))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: Color(red: 0, green: 50.0/255.0, blue: 30.0/255.0).opacity(0.3), radius: 5, y: 1)
                            .padding(.bottom, 38)

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
                .opacity(sceneOpacity)
            }
            .onChange(of: elapsedTime >= totalDuration) { _, completed in
                if completed && !hasCompleted {
                    hasCompleted = true
                    onComplete()
                }
            }
        }
        .onAppear {
            // Fade in animation matching HTML (1s ease with 0.3s delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    sceneOpacity = 1
                }
            }
            // Start breath animation after 1.2s
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                startTime = Date()
            }
        }
    }
}

// MARK: - Forest Background

struct ForestBackground: View {
    var body: some View {
        // Exact gradient from HTML: linear-gradient(160deg, #1a3a2a, #2a4a3a, #3a5a4a, #2a4838, #1a3828)
        LinearGradient(
            stops: [
                .init(color: Color(red: 0x1a/255.0, green: 0x3a/255.0, blue: 0x2a/255.0), location: 0.0),
                .init(color: Color(red: 0x2a/255.0, green: 0x4a/255.0, blue: 0x3a/255.0), location: 0.25),
                .init(color: Color(red: 0x3a/255.0, green: 0x5a/255.0, blue: 0x4a/255.0), location: 0.50),
                .init(color: Color(red: 0x2a/255.0, green: 0x48/255.0, blue: 0x38/255.0), location: 0.75),
                .init(color: Color(red: 0x1a/255.0, green: 0x38/255.0, blue: 0x28/255.0), location: 1.0)
            ],
            startPoint: UnitPoint(x: 0.2, y: 0.0),  // 160deg approximation
            endPoint: UnitPoint(x: 0.8, y: 1.0)
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

    // Exact bokeh data from HTML
    private struct BokehData {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let color: Color
        let period: Double
        let offsetX: CGFloat
        let offsetY: CGFloat
        let scaleMax: CGFloat
        let opacityBase: CGFloat
        let opacityPeak: CGFloat
    }

    private let bokehItems: [BokehData] = [
        // bokeh-1: 80px, top: 10%, left: 15%, rgba(180,220,160,0.6), 8s
        BokehData(x: 0.15, y: 0.10, size: 80, color: Color(red: 180/255.0, green: 220/255.0, blue: 160/255.0), period: 8, offsetX: 10, offsetY: -15, scaleMax: 1.1, opacityBase: 0.4, opacityPeak: 0.5),
        // bokeh-2: 120px, top: 25%, right: 10% (so left: 90%), rgba(200,240,180,0.5), 10s
        BokehData(x: 0.90, y: 0.25, size: 120, color: Color(red: 200/255.0, green: 240/255.0, blue: 180/255.0), period: 10, offsetX: -15, offsetY: 10, scaleMax: 1.15, opacityBase: 0.35, opacityPeak: 0.45),
        // bokeh-3: 60px, top: 60%, left: 8%, rgba(160,200,140,0.5), 7s
        BokehData(x: 0.08, y: 0.60, size: 60, color: Color(red: 160/255.0, green: 200/255.0, blue: 140/255.0), period: 7, offsetX: 8, offsetY: 12, scaleMax: 0.95, opacityBase: 0.4, opacityPeak: 0.5),
        // bokeh-4: 100px, bottom: 25% (top: 75%), right: 15% (left: 85%), rgba(190,230,170,0.4), 9s
        BokehData(x: 0.85, y: 0.75, size: 100, color: Color(red: 190/255.0, green: 230/255.0, blue: 170/255.0), period: 9, offsetX: -10, offsetY: -8, scaleMax: 1.08, opacityBase: 0.35, opacityPeak: 0.45),
        // bokeh-5: 50px, top: 45%, left: 25%, rgba(220,255,200,0.5), 6s
        BokehData(x: 0.25, y: 0.45, size: 50, color: Color(red: 220/255.0, green: 255/255.0, blue: 200/255.0), period: 6, offsetX: 5, offsetY: -10, scaleMax: 1.12, opacityBase: 0.45, opacityPeak: 0.55),
        // bokeh-6: 70px, top: 15%, right: 25% (left: 75%), rgba(170,210,150,0.45), 11s
        BokehData(x: 0.75, y: 0.15, size: 70, color: Color(red: 170/255.0, green: 210/255.0, blue: 150/255.0), period: 11, offsetX: -8, offsetY: 5, scaleMax: 1.05, opacityBase: 0.4, opacityPeak: 0.5)
    ]

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let windPhase = cos(cycleProgress * .pi * 2)
        let breathPhase = (1 - windPhase) / 2
        let bokehIntensity = 0.3 + breathPhase * 0.25

        Canvas { context, size in
            for bokeh in bokehItems {
                let phase = elapsedTime / bokeh.period
                let t = (1 - cos(phase * .pi * 2)) / 2 // easeInOutSine equivalent

                let offsetX = bokeh.offsetX * t
                let offsetY = bokeh.offsetY * t
                let scaleVariation = 1 + (bokeh.scaleMax - 1) * t
                let opacity = bokeh.opacityBase + (bokeh.opacityPeak - bokeh.opacityBase) * t

                let centerX = size.width * bokeh.x + offsetX
                let centerY = size.height * bokeh.y + offsetY
                let radius = bokeh.size * scaleVariation / 2

                // Base opacity 0.4 from CSS, plus breath variation
                let finalOpacity = opacity * (bokehIntensity + 0.4)

                context.fill(
                    Path(ellipseIn: CGRect(
                        x: centerX - radius,
                        y: centerY - radius,
                        width: radius * 2,
                        height: radius * 2
                    )),
                    with: .radialGradient(
                        Gradient(colors: [bokeh.color.opacity(0.6 * finalOpacity), .clear]),
                        center: CGPoint(x: centerX, y: centerY),
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
        }
        .blur(radius: 8) // filter: blur(8px) from CSS
    }
}

// MARK: - Birds Layer

struct BirdsLayer: View {
    let elapsedTime: Double
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            // Bird 1 - flying left to right, 18s animation
            let bird1Cycle = elapsedTime.truncatingRemainder(dividingBy: 18)
            let bird1Progress = bird1Cycle / 18
            // translateX: 0 -> 200px -> 400px, translateY: 0 -> -30px -> -50px
            let bird1X = -0.1 + bird1Progress * 1.2
            let bird1Y = 0.18 - bird1Progress * 0.06
            // Opacity: 0 -> 0.6 (5%) -> 0.6 (95%) -> 0 (100%)
            let bird1Opacity: Double = {
                if bird1Progress < 0.05 { return bird1Progress / 0.05 * 0.6 }
                else if bird1Progress > 0.95 { return (1 - bird1Progress) / 0.05 * 0.6 }
                else { return 0.6 }
            }()

            BlueBirdView(elapsedTime: elapsedTime)
                .frame(width: 32, height: 20)
                .position(x: width * bird1X, y: height * bird1Y)
                .opacity(bird1Opacity)

            // Bird 2 - flying right to left (mirrored), 20s animation with -6s delay
            let bird2Cycle = (elapsedTime + 6).truncatingRemainder(dividingBy: 20)
            let bird2Progress = bird2Cycle / 20
            // translateX: 0 -> -200px -> -420px
            let bird2X = 1.1 - bird2Progress * 1.2
            let bird2Y = 0.55 - bird2Progress * 0.05
            let bird2Opacity: Double = {
                if bird2Progress < 0.05 { return bird2Progress / 0.05 * 0.6 }
                else if bird2Progress > 0.95 { return (1 - bird2Progress) / 0.05 * 0.6 }
                else { return 0.6 }
            }()

            BlueBirdView(elapsedTime: elapsedTime)
                .frame(width: 30, height: 18)
                .scaleEffect(x: -1, y: 1)
                .position(x: width * bird2X, y: height * bird2Y)
                .opacity(bird2Opacity)
        }
        .blur(radius: 0.5) // filter: blur(0.5px) from CSS
    }
}

// MARK: - Blue Bird View

struct BlueBirdView: View {
    let elapsedTime: Double

    var body: some View {
        // Wing flap: 0.2s ease-in-out infinite
        let wingPhase = elapsedTime.truncatingRemainder(dividingBy: 0.2) / 0.2
        let wingT = (1 - cos(wingPhase * .pi * 2)) / 2 // ease-in-out
        let wingY = -3 * wingT // translateY: 0 -> -3px -> 0
        let wingScaleY = 1 - 0.4 * wingT // scaleY: 1 -> 0.6 -> 1

        Canvas { context, size in
            let scale = size.width / 40

            // Body - ellipse cx="20" cy="14" rx="10" ry="6" fill="#5090c0"
            let bodyPath = Path(ellipseIn: CGRect(
                x: 10 * scale, y: 8 * scale, width: 20 * scale, height: 12 * scale
            ))
            context.fill(bodyPath, with: .color(Color(red: 0x50/255.0, green: 0x90/255.0, blue: 0xc0/255.0)))

            // Head - circle cx="30" cy="11" r="5" fill="#60a0d0"
            let headPath = Path(ellipseIn: CGRect(
                x: 25 * scale, y: 6 * scale, width: 10 * scale, height: 10 * scale
            ))
            context.fill(headPath, with: .color(Color(red: 0x60/255.0, green: 0xa0/255.0, blue: 0xd0/255.0)))

            // Beak - path d="M35,11 L40,12 L35,13" fill="#e0a050"
            var beakPath = Path()
            beakPath.move(to: CGPoint(x: 35 * scale, y: 11 * scale))
            beakPath.addLine(to: CGPoint(x: 40 * scale, y: 12 * scale))
            beakPath.addLine(to: CGPoint(x: 35 * scale, y: 13 * scale))
            beakPath.closeSubpath()
            context.fill(beakPath, with: .color(Color(red: 0xe0/255.0, green: 0xa0/255.0, blue: 0x50/255.0)))

            // Eye - circle cx="32" cy="10" r="1.2" fill="#1a2a3a"
            let eyePath = Path(ellipseIn: CGRect(
                x: 30.8 * scale, y: 8.8 * scale, width: 2.4 * scale, height: 2.4 * scale
            ))
            context.fill(eyePath, with: .color(Color(red: 0x1a/255.0, green: 0x2a/255.0, blue: 0x3a/255.0)))

            // Wing with flap animation - ellipse cx="18" cy="12" rx="8" ry="5" fill="#4080b0"
            let wingCenterY = (12 + wingY) * scale
            let wingHeight = 10 * scale * wingScaleY
            let wingPath = Path(ellipseIn: CGRect(
                x: 10 * scale, y: wingCenterY - wingHeight / 2, width: 16 * scale, height: wingHeight
            ))
            context.fill(wingPath, with: .color(Color(red: 0x40/255.0, green: 0x80/255.0, blue: 0xb0/255.0)))

            // Tail - path d="M10,12 L2,8 L4,14 L2,18 L10,16" fill="#4080b0"
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: 10 * scale, y: 12 * scale))
            tailPath.addLine(to: CGPoint(x: 2 * scale, y: 8 * scale))
            tailPath.addLine(to: CGPoint(x: 4 * scale, y: 14 * scale))
            tailPath.addLine(to: CGPoint(x: 2 * scale, y: 18 * scale))
            tailPath.addLine(to: CGPoint(x: 10 * scale, y: 16 * scale))
            tailPath.closeSubpath()
            context.fill(tailPath, with: .color(Color(red: 0x40/255.0, green: 0x80/255.0, blue: 0xb0/255.0)))
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
            // Light ray 1: 30x150, top: 20%, left: 30%, rotate(-15deg), shimmer 4s
            let ray1Phase = elapsedTime.truncatingRemainder(dividingBy: 4) / 4
            let ray1T = (1 - cos(ray1Phase * .pi * 2)) / 2
            let ray1Opacity = 0.2 + 0.3 * ray1T

            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1, green: 1, blue: 200/255.0).opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 30, height: 150)
                .blur(radius: 10)
                .rotationEffect(.degrees(-15))
                .position(x: width * 0.30, y: height * 0.20 + 75)
                .opacity(ray1Opacity)

            // Light ray 2: 25x120, top: 25%, left: 55%, rotate(10deg), shimmer 5s
            let ray2Phase = elapsedTime.truncatingRemainder(dividingBy: 5) / 5
            let ray2T = (1 - cos(ray2Phase * .pi * 2)) / 2
            let ray2Opacity = 0.25 + 0.2 * ray2T

            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1, green: 1, blue: 200/255.0).opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 25, height: 120)
                .blur(radius: 10)
                .rotationEffect(.degrees(10))
                .position(x: width * 0.55, y: height * 0.25 + 60)
                .opacity(ray2Opacity)

            // Light ray 3: 20x100, top: 30%, left: 70%, rotate(5deg), shimmer 3.5s
            let ray3Phase = elapsedTime.truncatingRemainder(dividingBy: 3.5) / 3.5
            let ray3T = (1 - cos(ray3Phase * .pi * 2)) / 2
            let ray3Opacity = 0.15 + 0.25 * ray3T

            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1, green: 1, blue: 200/255.0).opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 20, height: 100)
                .blur(radius: 10)
                .rotationEffect(.degrees(5))
                .position(x: width * 0.70, y: height * 0.30 + 50)
                .opacity(ray3Opacity)
        }
        .opacity(rayIntensity) // Overall ray intensity based on breath
    }
}

// MARK: - Branch with Leaves

struct BranchWithLeaves: View {
    let elapsedTime: Double
    let cycleDuration: Double
    let width: CGFloat
    let height: CGFloat

    // Leaf data structure matching HTML exactly
    private struct LeafData {
        let stemStart: CGPoint
        let stemEnd: CGPoint
        let stemWidth: CGFloat
        let isLight: Bool
        let leafPath: String // SVG path data
        let veinPath: String // SVG vein path data
    }

    // Exact leaf data from HTML
    private let leavesData: [LeafData] = [
        // Leaf 1 - pivot at (82,282)
        LeafData(stemStart: CGPoint(x: 100, y: 300), stemEnd: CGPoint(x: 82, y: 282), stemWidth: 2.5, isLight: false,
                 leafPath: "M82,282 Q62,268 68,248 Q82,255 92,270 Q90,282 82,282",
                 veinPath: "M82,280 Q74,266 72,255"),
        // Leaf 2 - pivot at (128,268)
        LeafData(stemStart: CGPoint(x: 110, y: 285), stemEnd: CGPoint(x: 128, y: 268), stemWidth: 2.5, isLight: true,
                 leafPath: "M128,268 Q148,254 152,270 Q144,284 132,285 Q126,280 128,268",
                 veinPath: "M130,270 Q144,260 150,272"),
        // Leaf 3 - pivot at (122,235)
        LeafData(stemStart: CGPoint(x: 140, y: 250), stemEnd: CGPoint(x: 122, y: 235), stemWidth: 2.5, isLight: false,
                 leafPath: "M122,235 Q102,220 110,200 Q124,210 130,228 Q127,238 122,235",
                 veinPath: "M123,232 Q114,218 114,205"),
        // Leaf 4 - pivot at (168,218)
        LeafData(stemStart: CGPoint(x: 150, y: 235), stemEnd: CGPoint(x: 168, y: 218), stemWidth: 2.5, isLight: true,
                 leafPath: "M168,218 Q188,204 193,220 Q185,235 172,235 Q166,228 168,218",
                 veinPath: "M170,220 Q184,210 190,222"),
        // Leaf 5 - pivot at (142,182)
        LeafData(stemStart: CGPoint(x: 160, y: 200), stemEnd: CGPoint(x: 142, y: 182), stemWidth: 2, isLight: false,
                 leafPath: "M142,182 Q122,166 132,148 Q148,160 152,178 Q148,186 142,182",
                 veinPath: "M143,180 Q134,166 138,153"),
        // Leaf 6 - pivot at (195,158)
        LeafData(stemStart: CGPoint(x: 175, y: 175), stemEnd: CGPoint(x: 195, y: 158), stemWidth: 2, isLight: true,
                 leafPath: "M195,158 Q215,144 220,160 Q212,175 198,174 Q192,168 195,158",
                 veinPath: "M197,160 Q212,150 218,162"),
        // Leaf 7 - pivot at (182,122)
        LeafData(stemStart: CGPoint(x: 200, y: 140), stemEnd: CGPoint(x: 182, y: 122), stemWidth: 2, isLight: false,
                 leafPath: "M182,122 Q164,106 174,90 Q190,102 192,118 Q188,126 182,122",
                 veinPath: "M183,120 Q174,106 178,95"),
        // Leaf 8 - pivot at (240,104)
        LeafData(stemStart: CGPoint(x: 220, y: 120), stemEnd: CGPoint(x: 240, y: 104), stemWidth: 2, isLight: true,
                 leafPath: "M240,104 Q260,90 265,106 Q256,120 244,118 Q238,112 240,104",
                 veinPath: "M242,106 Q256,96 263,108"),
        // Leaf 9 - pivot at (240,78)
        LeafData(stemStart: CGPoint(x: 255, y: 95), stemEnd: CGPoint(x: 240, y: 78), stemWidth: 2, isLight: false,
                 leafPath: "M240,78 Q224,62 234,48 Q250,60 252,76 Q247,82 240,78",
                 veinPath: "M241,76 Q232,64 238,53"),
        // Leaf 10 - pivot at (298,65)
        LeafData(stemStart: CGPoint(x: 280, y: 80), stemEnd: CGPoint(x: 298, y: 65), stemWidth: 2, isLight: true,
                 leafPath: "M298,65 Q316,52 320,68 Q310,82 298,80 Q293,74 298,65",
                 veinPath: "M300,67 Q313,58 318,70")
    ]

    var body: some View {
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let windPhase = cos(cycleProgress * .pi * 2)
        let breathPhase = (1 - windPhase) / 2

        // Add subtle wind gusts variation (matching HTML exactly)
        let gustVariation = sin(elapsedTime / 0.8) * 0.08 + sin(elapsedTime / 1.2) * 0.05
        let finalPhase = breathPhase + gustVariation * breathPhase

        // Branch movement - whole branch rises and curves with wind
        let branchRotation = finalPhase * 12 // Gentle rotation in degrees
        let branchLift = finalPhase * 25 // Vertical movement

        Canvas { context, size in
            // Scale to fit screen - branch should span from bottom-left to upper-right
            // Original SVG viewBox is roughly 320x400, branch goes from (-20,380) to (290,75)
            let scale = min(size.width / 280, size.height / 380) * 1.1

            // Position branch to start from bottom-left corner (off-screen)
            // The branch path starts at M-20,380 which should be at the bottom-left of the screen
            let offsetX: CGFloat = -40 * scale  // Push left so branch starts off-screen
            let offsetY: CGFloat = size.height - 420 * scale  // Align bottom of branch coords with bottom of screen

            context.translateBy(x: offsetX, y: offsetY)

            // Apply branch group transform: rotate around bottom-left origin (0%, 100%)
            // transformOrigin: '0% 100%' means (0, 380) in SVG coordinates
            let rotationAngle = -branchRotation * .pi / 180
            context.translateBy(x: 0, y: 380 * scale)
            context.rotate(by: Angle(radians: rotationAngle))
            context.translateBy(x: 0, y: -380 * scale - branchLift)

            // Branch gradient colors (exact from HTML)
            let branchDark = Color(red: 0x4a/255.0, green: 0x35/255.0, blue: 0x25/255.0)
            let branchMid = Color(red: 0x5d/255.0, green: 0x46/255.0, blue: 0x32/255.0)
            let branchTexture = Color(red: 0x3d/255.0, green: 0x2a/255.0, blue: 0x1a/255.0)

            // Main branch path: d="M-20,380 Q60,350 100,300 Q140,250 160,200 Q180,150 220,120 Q260,90 290,75"
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

            // Branch texture lines
            var texture1 = Path()
            texture1.move(to: CGPoint(x: 30 * scale, y: 350 * scale))
            texture1.addQuadCurve(
                to: CGPoint(x: 110 * scale, y: 280 * scale),
                control: CGPoint(x: 80 * scale, y: 320 * scale)
            )
            context.stroke(texture1, with: .color(branchTexture.opacity(0.3)), style: StrokeStyle(lineWidth: 1 * scale))

            var texture2 = Path()
            texture2.move(to: CGPoint(x: 130 * scale, y: 240 * scale))
            texture2.addQuadCurve(
                to: CGPoint(x: 190 * scale, y: 165 * scale),
                control: CGPoint(x: 160 * scale, y: 200 * scale)
            )
            context.stroke(texture2, with: .color(branchTexture.opacity(0.25)), style: StrokeStyle(lineWidth: 1 * scale))

            // Draw stems
            for leaf in leavesData {
                var stemPath = Path()
                stemPath.move(to: CGPoint(x: leaf.stemStart.x * scale, y: leaf.stemStart.y * scale))
                stemPath.addLine(to: CGPoint(x: leaf.stemEnd.x * scale, y: leaf.stemEnd.y * scale))
                context.stroke(stemPath, with: .color(branchMid), style: StrokeStyle(lineWidth: leaf.stemWidth * scale, lineCap: .round))
            }

            // Leaf gradient colors (exact from HTML)
            // leafGradient: #5a8a50 -> #4a7a40 -> #3a6a30
            // leafGradientLight: #6a9a60 -> #5a8a50 -> #4a7a40
            let leafGreen = Color(red: 0x4a/255.0, green: 0x7a/255.0, blue: 0x40/255.0)
            let leafGreenLight = Color(red: 0x5a/255.0, green: 0x8a/255.0, blue: 0x50/255.0)
            let veinDark = Color(red: 0x3a/255.0, green: 0x5a/255.0, blue: 0x30/255.0)
            let veinLight = Color(red: 0x4a/255.0, green: 0x6a/255.0, blue: 0x40/255.0)

            // Draw leaves with individual animation
            for (index, leaf) in leavesData.enumerated() {
                let pivotX = leaf.stemEnd.x
                let pivotY = leaf.stemEnd.y

                // Calculate leaf rotation (matching HTML JS exactly)
                let windStrength = breathPhase * 8 // Max rotation in degrees
                let flutter = sin(elapsedTime / 0.4 + Double(index) * 1.5) * (2 + windStrength * 0.5)
                let sway = sin(elapsedTime / 0.6 + Double(index) * 0.8) * windStrength * 0.3
                let totalRotation = flutter + sway

                // Apply rotation around pivot point
                context.translateBy(x: pivotX * scale, y: pivotY * scale)
                context.rotate(by: Angle(degrees: totalRotation))
                context.translateBy(x: -pivotX * scale, y: -pivotY * scale)

                // Parse and draw leaf path
                let leafPath = parseSVGPath(leaf.leafPath, scale: scale)
                let leafColor = leaf.isLight ? leafGreenLight : leafGreen
                context.fill(leafPath, with: .color(leafColor))

                // Parse and draw vein path
                let veinPath = parseSVGPath(leaf.veinPath, scale: scale)
                let veinColor = leaf.isLight ? veinLight : veinDark
                context.stroke(veinPath, with: .color(veinColor.opacity(0.5)), style: StrokeStyle(lineWidth: 0.8 * scale))

                // Restore rotation
                context.translateBy(x: pivotX * scale, y: pivotY * scale)
                context.rotate(by: Angle(degrees: -totalRotation))
                context.translateBy(x: -pivotX * scale, y: -pivotY * scale)
            }
        }
        // Use full screen size to prevent clipping when branch rises/rotates
        .frame(width: width, height: height)
    }

    // Parse simplified SVG path commands
    private func parseSVGPath(_ svgPath: String, scale: CGFloat) -> Path {
        var path = Path()
        let commands = svgPath.components(separatedBy: " ")

        var i = 0
        var currentPoint = CGPoint.zero

        while i < commands.count {
            let cmd = commands[i]

            if cmd.hasPrefix("M") {
                let coords = parseCoords(String(cmd.dropFirst()))
                currentPoint = CGPoint(x: coords.0 * scale, y: coords.1 * scale)
                path.move(to: currentPoint)
                i += 1
            } else if cmd.hasPrefix("Q") {
                let controlCoords = parseCoords(String(cmd.dropFirst()))
                i += 1
                if i < commands.count {
                    let endCoords = parseCoords(commands[i])
                    let control = CGPoint(x: controlCoords.0 * scale, y: controlCoords.1 * scale)
                    let end = CGPoint(x: endCoords.0 * scale, y: endCoords.1 * scale)
                    path.addQuadCurve(to: end, control: control)
                    currentPoint = end
                    i += 1
                }
            } else if cmd.hasPrefix("L") {
                let coords = parseCoords(String(cmd.dropFirst()))
                let point = CGPoint(x: coords.0 * scale, y: coords.1 * scale)
                path.addLine(to: point)
                currentPoint = point
                i += 1
            } else {
                // Try parsing as coordinates (implicit command continuation)
                let coords = parseCoords(cmd)
                if coords.0 != 0 || coords.1 != 0 {
                    let point = CGPoint(x: coords.0 * scale, y: coords.1 * scale)
                    path.addLine(to: point)
                    currentPoint = point
                }
                i += 1
            }
        }

        return path
    }

    private func parseCoords(_ str: String) -> (CGFloat, CGFloat) {
        let parts = str.components(separatedBy: ",")
        if parts.count >= 2 {
            let x = CGFloat(Double(parts[0]) ?? 0)
            let y = CGFloat(Double(parts[1]) ?? 0)
            return (x, y)
        }
        return (0, 0)
    }
}

#Preview {
    BreatheBranchView(duration: 3, onComplete: {}, onBack: {})
}
