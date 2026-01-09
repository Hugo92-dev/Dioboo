//
//  HomeView.swift
//  Dioboo
//
//  Welcome screen - "You can close the day here"
//

import SwiftUI

struct HomeView: View {
    let onBegin: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    var body: some View {
        ZStack {
            // Ambient glows
            AmbientGlow(
                color: DiobooTheme.accentPrincipal,
                position: CGPoint(x: 80, y: 200),
                size: 300
            )
            AmbientGlow(
                color: DiobooTheme.accentSecondaire,
                position: CGPoint(x: 320, y: 600),
                size: 350
            )

            VStack(spacing: 0) {
                Spacer()

                // Logo
                DiobooLogo()
                    .frame(width: 70, height: 70)
                    .opacity(logoOpacity)
                    .padding(.bottom, 40)

                // Title
                Text("You can close\nthe day here.")
                    .font(DiobooTheme.title(28))
                    .foregroundColor(DiobooTheme.textePrincipal)
                    .multilineTextAlignment(.center)
                    .opacity(titleOpacity)
                    .padding(.bottom, 16)

                // Subtitle
                Text("A moment of quiet before sleep.")
                    .font(DiobooTheme.subtitle(16))
                    .foregroundColor(DiobooTheme.texteSecondaire)
                    .opacity(subtitleOpacity)

                Spacer()

                // Begin button
                Button(action: onBegin) {
                    Text("Begin")
                        .font(DiobooTheme.body(16))
                        .fontWeight(.medium)
                        .foregroundColor(DiobooTheme.fondPrincipal)
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [
                                    DiobooTheme.accentPrincipal,
                                    DiobooTheme.accentSecondaire
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: DiobooTheme.accentPrincipal.opacity(0.4), radius: 15, y: 5)
                }
                .opacity(buttonOpacity)
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.6)) {
            logoOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            titleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            subtitleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            buttonOpacity = 1
        }
    }
}

#Preview {
    ZStack {
        DiobooTheme.backgroundGradient
            .ignoresSafeArea()
        HomeView(onBegin: {})
    }
}
