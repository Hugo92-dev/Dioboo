//
//  BreatheChairliftView.swift
//  Dioboo
//
//  Chairlift breathing experience - Glide over the slopes
//

import SwiftUI
import Combine

struct BreatheChairliftView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var isInhaling: Bool = true
    @State private var breatheProgress: CGFloat = 0
    @State private var cabinOffset: CGFloat = 0
    @State private var cloudOffset: CGFloat = 0
    @State private var timer: Timer?
    @State private var breatheTimer: Timer?

    // Breathing rhythm: 5s inhale, 5s exhale
    private let breatheDuration: Double = 5.0

    var body: some View {
        ZStack {
            // Sky gradient
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
            CloudsLayer(offset: cloudOffset)

            // Mountains
            MountainsLayer()

            // Forest
            ForestLayer()

            // Cable and cabin
            ChairliftCable()
            ChairliftCabin(progress: breatheProgress)

            // Snow particles
            SnowParticles()

            // UI Overlay
            VStack {
                // Back button
                HStack {
                    Button(action: onBack) {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Breathing indicator
                BreathingIndicator(isInhaling: $isInhaling)
                    .padding(.bottom, 20)

                // Timer
                BreathingTimer(duration: duration, onComplete: onComplete)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            startBreathingCycle()
            startCloudAnimation()
        }
        .onDisappear {
            timer?.invalidate()
            breatheTimer?.invalidate()
        }
    }

    private func startBreathingCycle() {
        // Initial state
        withAnimation(.easeInOut(duration: breatheDuration)) {
            breatheProgress = 1
        }

        breatheTimer = Timer.scheduledTimer(withTimeInterval: breatheDuration, repeats: true) { _ in
            isInhaling.toggle()
            withAnimation(.easeInOut(duration: breatheDuration)) {
                breatheProgress = isInhaling ? 1 : 0
            }
        }
    }

    private func startCloudAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            cloudOffset -= 0.3
            if cloudOffset < -400 {
                cloudOffset = 0
            }
        }
    }
}

// MARK: - Clouds Layer

struct CloudsLayer: View {
    let offset: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<5) { i in
                    Cloud()
                        .offset(
                            x: (CGFloat(i) * 150 + offset).truncatingRemainder(dividingBy: geo.size.width + 200) - 100,
                            y: CGFloat(i * 40 + 80)
                        )
                }
            }
        }
    }
}

struct Cloud: View {
    var body: some View {
        Ellipse()
            .fill(Color.white.opacity(0.6))
            .frame(width: 120, height: 40)
            .blur(radius: 20)
    }
}

// MARK: - Mountains Layer

struct MountainsLayer: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Far mountains
                MountainShape(peaks: 5, height: 200)
                    .fill(Color(hex: "8BA5B5").opacity(0.6))
                    .offset(y: geo.size.height - 350)

                // Near mountains
                MountainShape(peaks: 4, height: 280)
                    .fill(Color(hex: "6B8B9A").opacity(0.8))
                    .offset(y: geo.size.height - 300)

                // Snow caps
                MountainShape(peaks: 4, height: 100)
                    .fill(Color.white.opacity(0.9))
                    .offset(y: geo.size.height - 380)
            }
        }
    }
}

struct MountainShape: Shape {
    let peaks: Int
    let height: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let peakWidth = rect.width / CGFloat(peaks)

        path.move(to: CGPoint(x: 0, y: rect.height))

        for i in 0..<peaks {
            let peakX = peakWidth * CGFloat(i) + peakWidth / 2
            let startX = peakWidth * CGFloat(i)
            let endX = peakWidth * CGFloat(i + 1)

            path.addLine(to: CGPoint(x: peakX, y: rect.height - height * CGFloat.random(in: 0.7...1.0)))
            path.addLine(to: CGPoint(x: endX, y: rect.height))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Forest Layer

struct ForestLayer: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Tree silhouettes
                ForEach(0..<20) { i in
                    TreeShape()
                        .fill(Color(hex: "2D5A4A").opacity(0.8))
                        .frame(width: 30, height: CGFloat.random(in: 60...100))
                        .offset(
                            x: CGFloat(i * 25) - 50,
                            y: geo.size.height - CGFloat.random(in: 150...200)
                        )
                }
            }
        }
    }
}

struct TreeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Simple triangle tree
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.midX + 5, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.midX + 5, y: rect.height))
        path.addLine(to: CGPoint(x: rect.midX - 5, y: rect.height))
        path.addLine(to: CGPoint(x: rect.midX - 5, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.7))
        path.closeSubpath()

        return path
    }
}

// MARK: - Chairlift Components

struct ChairliftCable: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: -50, y: geo.size.height * 0.6))
                path.addQuadCurve(
                    to: CGPoint(x: geo.size.width + 50, y: geo.size.height * 0.3),
                    control: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.35)
                )
            }
            .stroke(Color(hex: "333333"), lineWidth: 3)
        }
    }
}

struct ChairliftCabin: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            let startPoint = CGPoint(x: geo.size.width * 0.15, y: geo.size.height * 0.55)
            let endPoint = CGPoint(x: geo.size.width * 0.85, y: geo.size.height * 0.35)

            let currentX = startPoint.x + (endPoint.x - startPoint.x) * progress
            let currentY = startPoint.y + (endPoint.y - startPoint.y) * progress

            VStack(spacing: 0) {
                // Cable attachment
                Rectangle()
                    .fill(Color(hex: "555555"))
                    .frame(width: 4, height: 20)

                // Cabin
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "E74C3C"))
                    .frame(width: 40, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "87CEEB").opacity(0.5))
                            .frame(width: 30, height: 25)
                            .offset(y: -5)
                    )
            }
            .position(x: currentX, y: currentY)
        }
    }
}

// MARK: - Snow Particles

struct SnowParticles: View {
    @State private var particles: [SnowParticle] = (0..<30).map { _ in SnowParticle() }

    var body: some View {
        GeometryReader { geo in
            ForEach(particles.indices, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: particles[index].size, height: particles[index].size)
                    .position(
                        x: particles[index].x * geo.size.width,
                        y: particles[index].y * geo.size.height
                    )
            }
        }
        .onAppear {
            animateSnow()
        }
    }

    private func animateSnow() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y += particles[i].speed
                particles[i].x += CGFloat.random(in: -0.002...0.002)

                if particles[i].y > 1.1 {
                    particles[i].y = -0.1
                    particles[i].x = CGFloat.random(in: 0...1)
                }
            }
        }
    }
}

struct SnowParticle {
    var x: CGFloat = CGFloat.random(in: 0...1)
    var y: CGFloat = CGFloat.random(in: 0...1)
    var size: CGFloat = CGFloat.random(in: 2...5)
    var speed: CGFloat = CGFloat.random(in: 0.002...0.008)
}

#Preview {
    BreatheChairliftView(duration: 3, onComplete: {}, onBack: {})
}
