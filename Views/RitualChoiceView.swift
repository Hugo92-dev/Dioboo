//
//  RitualChoiceView.swift
//  Dioboo
//
//  Choose between Read and Breathe rituals
//

import SwiftUI

struct RitualChoiceView: View {
    let onSelectRead: () -> Void
    let onSelectBreathe: () -> Void
    let onBack: () -> Void

    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var readCardOpacity: Double = 0
    @State private var breatheCardOpacity: Double = 0

    var body: some View {
        ZStack {
            // Ambient glows
            AmbientGlow(
                color: DiobooTheme.accentPrincipal,
                position: CGPoint(x: 60, y: 300),
                size: 280
            )
            AmbientGlow(
                color: DiobooTheme.accentSecondaire,
                position: CGPoint(x: 340, y: 550),
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

                Spacer()

                // Title
                Text("Your ritual tonight")
                    .font(DiobooTheme.title(26))
                    .foregroundColor(DiobooTheme.textePrincipal)
                    .opacity(titleOpacity)
                    .padding(.bottom, 8)

                // Subtitle
                Text("Choose one to close your day.")
                    .font(DiobooTheme.subtitle(15))
                    .foregroundColor(DiobooTheme.texteSecondaire)
                    .opacity(subtitleOpacity)
                    .padding(.bottom, 50)

                // Ritual cards
                VStack(spacing: 16) {
                    // Read card
                    RitualCard(
                        icon: "📖",
                        title: "Read",
                        description: "Quiet thoughts to let go",
                        action: onSelectRead
                    )
                    .opacity(readCardOpacity)

                    // Breathe card
                    RitualCard(
                        icon: "🌬️",
                        title: "Breathe",
                        description: "A visual breathing journey",
                        action: onSelectBreathe
                    )
                    .opacity(breatheCardOpacity)
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
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            readCardOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            breatheCardOpacity = 1
        }
    }
}

// MARK: - Ritual Card

struct RitualCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Text(icon)
                    .font(.system(size: 32))
                    .frame(width: 50)

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(DiobooTheme.body(17))
                        .fontWeight(.medium)
                        .foregroundColor(DiobooTheme.textePrincipal)

                    Text(description)
                        .font(DiobooTheme.caption(13))
                        .foregroundColor(DiobooTheme.texteSecondaire)
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DiobooTheme.texteSecondaire)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DiobooTheme.surface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DiobooTheme.bordure, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Back Button

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DiobooTheme.texteSecondaire)
        }
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        DiobooTheme.backgroundGradient
            .ignoresSafeArea()
        RitualChoiceView(
            onSelectRead: {},
            onSelectBreathe: {},
            onBack: {}
        )
    }
}
