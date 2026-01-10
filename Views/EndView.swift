//
//  EndView.swift
//  Dioboo
//
//  End of session - "That's it for today"
//

import SwiftUI
import Combine

struct EndView: View {
    let onAnotherRitual: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var overlayOpacity: Double = 0

    var body: some View {
        ZStack {
            // Content
            VStack(spacing: 0) {
                Spacer()

                // Logo
                DiobooLogo()
                    .frame(width: 60, height: 60)
                    .opacity(logoOpacity)
                    .padding(.bottom, 40)

                // Title
                Text("That's it for today.")
                    .font(DiobooTheme.title(26))
                    .foregroundColor(DiobooTheme.textePrincipal)
                    .opacity(titleOpacity)
                    .padding(.bottom, 16)

                // Subtitle
                VStack(spacing: 8) {
                    Text("You made space for rest.")
                        .font(DiobooTheme.subtitle(15))
                        .foregroundColor(DiobooTheme.texteSecondaire)

                    Text("You can put your phone down now.")
                        .font(DiobooTheme.subtitle(15))
                        .foregroundColor(DiobooTheme.texteSecondaire)
                }
                .multilineTextAlignment(.center)
                .opacity(subtitleOpacity)

                Spacer()

                // Another ritual button
                Button(action: onAnotherRitual) {
                    Text("Another ritual")
                        .font(DiobooTheme.body(15))
                        .foregroundColor(DiobooTheme.texteSecondaire)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(DiobooTheme.bordure, lineWidth: 1)
                        )
                }
                .opacity(buttonOpacity)
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 40)

            // Darkening overlay (gradually appears after delay)
            Color.black
                .opacity(overlayOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onAppear {
            animateIn()
            startDarkeningEffect()
        }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.8)) {
            logoOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            titleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            subtitleOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
            buttonOpacity = 1
        }
    }

    private func startDarkeningEffect() {
        // Start darkening after 6 seconds, complete over 10 seconds
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 6_000_000_000)
            withAnimation(.easeIn(duration: 10)) {
                overlayOpacity = 0.7
            }
        }
    }
}

#Preview {
    ZStack {
        DiobooTheme.backgroundGradient
            .ignoresSafeArea()
        EndView(onAnotherRitual: {})
    }
}
