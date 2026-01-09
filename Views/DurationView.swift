//
//  DurationView.swift
//  Dioboo
//
//  Choose session duration (3, 5, or 8 minutes)
//

import SwiftUI

struct DurationView: View {
    let ritual: Ritual
    let onSelectDuration: (Int) -> Void
    let onSelectPremiumDuration: () -> Void
    let onBack: () -> Void

    @EnvironmentObject var appState: AppState

    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonsOpacity: [Double] = [0, 0, 0]

    private let durations = [3, 5, 8]

    var body: some View {
        ZStack {
            // Ambient glows
            AmbientGlow(
                color: DiobooTheme.accentPrincipal,
                position: CGPoint(x: 80, y: 250),
                size: 300
            )
            AmbientGlow(
                color: DiobooTheme.accentSecondaire,
                position: CGPoint(x: 300, y: 500),
                size: 280
            )

            VStack(spacing: 0) {
                // Back button
                HStack {
                    BackButton(action: onBack)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()

                // Title
                Text("How long?")
                    .font(DiobooTheme.title(26))
                    .foregroundColor(DiobooTheme.textePrincipal)
                    .opacity(titleOpacity)
                    .padding(.bottom, 8)

                // Subtitle
                Text("A few minutes for yourself.")
                    .font(DiobooTheme.subtitle(15))
                    .foregroundColor(DiobooTheme.texteSecondaire)
                    .opacity(subtitleOpacity)
                    .padding(.bottom, 50)

                // Duration buttons
                HStack(spacing: 16) {
                    ForEach(Array(durations.enumerated()), id: \.offset) { index, duration in
                        DurationButton(
                            minutes: duration,
                            isPremium: appState.isDurationPremium(duration),
                            action: {
                                if appState.isDurationPremium(duration) {
                                    onSelectPremiumDuration()
                                } else {
                                    onSelectDuration(duration)
                                }
                            }
                        )
                        .opacity(buttonsOpacity[index])
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) {
            titleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            subtitleOpacity = 1
        }
        for i in 0..<durations.count {
            withAnimation(.easeOut(duration: 0.5).delay(0.2 + Double(i) * 0.1)) {
                buttonsOpacity[i] = 1
            }
        }
    }
}

// MARK: - Duration Button

struct DurationButton: View {
    let minutes: Int
    let isPremium: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    Text("\(minutes)")
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .foregroundColor(DiobooTheme.textePrincipal)

                    Text("min")
                        .font(DiobooTheme.caption(14))
                        .foregroundColor(DiobooTheme.texteSecondaire)
                }
                .frame(width: 90, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(DiobooTheme.surface.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(DiobooTheme.bordure, lineWidth: 1)
                        )
                )

                // Premium badge
                if isPremium {
                    PremiumBadge()
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    ZStack {
        DiobooTheme.backgroundGradient
            .ignoresSafeArea()
        DurationView(
            ritual: .read,
            onSelectDuration: { _ in },
            onSelectPremiumDuration: {},
            onBack: {}
        )
        .environmentObject(AppState())
    }
}
