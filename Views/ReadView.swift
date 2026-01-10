//
//  ReadView.swift
//  Dioboo
//
//  Reading experience with horizontal carousel of anecdotes
//

import SwiftUI
import Combine

struct ReadView: View {
    let duration: Int
    let onComplete: () -> Void
    let onBack: () -> Void

    @State private var currentIndex: Int = 0
    @State private var shuffledAnecdotes: [String] = []
    @State private var progress: Double = 0
    @State private var isTimeUp: Bool = false
    @State private var timer: Timer?

    private var durationInSeconds: Int {
        duration * 60
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Back button
                HStack {
                    BackButton(action: onBack)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Main content - Horizontal scroll
                TabView(selection: $currentIndex) {
                    ForEach(Array(shuffledAnecdotes.enumerated()), id: \.offset) { index, anecdote in
                        AnecdoteSlide(text: anecdote)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .disabled(isTimeUp)
                .opacity(isTimeUp && currentIndex != shuffledAnecdotes.count - 1 ? 0.5 : 1)

                Spacer()

                // Close button
                Button(action: onComplete) {
                    Text("Close the day")
                        .font(DiobooTheme.body(15))
                        .foregroundColor(isTimeUp ? DiobooTheme.textePrincipal : DiobooTheme.texteSecondaire)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    isTimeUp ? DiobooTheme.accentPrincipal : DiobooTheme.bordure,
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isTimeUp ? DiobooTheme.accentPrincipal.opacity(0.3) : .clear,
                            radius: isTimeUp ? 10 : 0
                        )
                }
                .animation(.easeInOut(duration: 0.5), value: isTimeUp)
                .padding(.bottom, 20)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(DiobooTheme.accentPrincipal.opacity(0.1))
                            .frame(height: 2)

                        Rectangle()
                            .fill(DiobooTheme.accentPrincipal.opacity(0.5))
                            .frame(width: geo.size.width * progress, height: 2)
                    }
                }
                .frame(width: 80, height: 2)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            setupSession()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func setupSession() {
        shuffledAnecdotes = Anecdotes.all.shuffled()
    }

    private func startTimer() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(TimeInterval(durationInSeconds))

        Task { @MainActor in
            while Date() < endTime {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                let elapsed = Date().timeIntervalSince(startTime)
                let total = TimeInterval(durationInSeconds)

                withAnimation(.linear(duration: 1)) {
                    progress = min(elapsed / total, 1)
                }
            }
            withAnimation {
                isTimeUp = true
            }
        }
    }
}

// MARK: - Anecdote Slide

struct AnecdoteSlide: View {
    let text: String

    var body: some View {
        VStack {
            Spacer()

            Text(text)
                .font(.system(size: 18, weight: .light, design: .rounded))
                .foregroundColor(DiobooTheme.textePrincipal)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        DiobooTheme.backgroundGradient
            .ignoresSafeArea()
        ReadView(
            duration: 3,
            onComplete: {},
            onBack: {}
        )
    }
}
