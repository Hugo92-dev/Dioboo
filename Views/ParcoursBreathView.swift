//
//  ParcoursBreathView.swift
//  Dioboo
//
//  Choose breathing journey/parcours
//

import SwiftUI
import Combine

struct ParcoursBreathView: View {
    let onSelectParcours: (BreatheParcours) -> Void
    let onSelectPremiumParcours: () -> Void
    let onBack: () -> Void

    @EnvironmentObject var appState: AppState

    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var cardsOpacity: [Double] = Array(repeating: 0, count: BreatheParcours.allCases.count)

    var body: some View {
        ZStack {
            // Ambient glows
            AmbientGlow(
                color: DiobooTheme.accentPrincipal,
                position: CGPoint(x: 60, y: 200),
                size: 280
            )
            AmbientGlow(
                color: DiobooTheme.accentSecondaire,
                position: CGPoint(x: 340, y: 700),
                size: 320
            )

            VStack(spacing: 0) {
                // Back button
                HStack {
                    BackButton(action: onBack)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Title
                Text("Choose your journey")
                    .font(DiobooTheme.title(26))
                    .foregroundColor(DiobooTheme.textePrincipal)
                    .opacity(titleOpacity)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                // Subtitle
                Text("A visual breathing experience.")
                    .font(DiobooTheme.subtitle(15))
                    .foregroundColor(DiobooTheme.texteSecondaire)
                    .opacity(subtitleOpacity)
                    .padding(.bottom, 24)

                // Scrollable list of parcours
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(BreatheParcours.allCases.enumerated()), id: \.element) { index, parcours in
                            ParcoursCard(
                                parcours: parcours,
                                isPremium: appState.isParcoursPremium(parcours),
                                action: {
                                    if appState.isParcoursPremium(parcours) {
                                        onSelectPremiumParcours()
                                    } else {
                                        onSelectParcours(parcours)
                                    }
                                }
                            )
                            .opacity(cardsOpacity[index])
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
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
        for i in 0..<BreatheParcours.allCases.count {
            withAnimation(.easeOut(duration: 0.4).delay(0.15 + Double(i) * 0.05)) {
                cardsOpacity[i] = 1
            }
        }
    }
}

// MARK: - Parcours Card

struct ParcoursCard: View {
    let parcours: BreatheParcours
    let isPremium: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with gradient background (matches HTML parcours-icon)
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [DiobooTheme.accentSecondaire, Color(hex: "A686FF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Text(parcours.icon)
                        .font(.system(size: 24))
                }

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(parcours.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DiobooTheme.textePrincipal)

                    Text(parcours.description)
                        .font(.system(size: 13))
                        .foregroundColor(DiobooTheme.texteSecondaire.opacity(0.85))
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DiobooTheme.surface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DiobooTheme.bordure, lineWidth: 1)
                    )
            )
            .overlay(alignment: .topTrailing) {
                // Premium badge - positioned like HTML (top: 10px, right: 12px)
                if isPremium {
                    PremiumBadge()
                        .offset(x: -12, y: 10)
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
        ParcoursBreathView(
            onSelectParcours: { _ in },
            onSelectPremiumParcours: {},
            onBack: {}
        )
        .environmentObject(AppState())
    }
}
