//
//  SplashView.swift
//  Dioboo
//
//  Splash screen with animated logo
//

import SwiftUI

struct SplashView: View {
    let onComplete: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var logoScale: Double = 0.8
    @State private var titleOpacity: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo
            DiobooLogo()
                .frame(width: 80, height: 80)
                .opacity(logoOpacity)
                .scaleEffect(logoScale)

            // Title
            Text("Dioboo")
                .font(DiobooTheme.title(32))
                .foregroundColor(DiobooTheme.textePrincipal)
                .opacity(titleOpacity)

            Spacer()
        }
        .onAppear {
            // Logo fade in
            withAnimation(.easeOut(duration: 0.8)) {
                logoOpacity = 1
                logoScale = 1
            }

            // Title fade in (delayed)
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                titleOpacity = 1
            }

            // Auto-navigate after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete()
            }
        }
    }
}

// MARK: - Dioboo Logo

struct DiobooLogo: View {
    var body: some View {
        ZStack {
            // Abstract curved shape representing calm/transition
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            DiobooTheme.accentPrincipal,
                            DiobooTheme.accentSecondaire
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 60, height: 60)

            // Inner soft glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DiobooTheme.accentPrincipal.opacity(0.3),
                            DiobooTheme.accentPrincipal.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 50, height: 50)
        }
    }
}

#Preview {
    ZStack {
        DiobooTheme.backgroundGradient
            .ignoresSafeArea()
        SplashView(onComplete: {})
    }
}
