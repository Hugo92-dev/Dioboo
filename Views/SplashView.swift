//
//  SplashView.swift
//  Dioboo
//
//  Splash screen - matches ouverture.html exactly
//

import SwiftUI
import Combine

struct SplashView: View {
    let onComplete: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var logoScale: Double = 0.9
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 8
    @State private var containerOpacity: Double = 1

    var body: some View {
        ZStack {
            // Background - exact color from HTML: #070A14
            Color(hex: "070A14")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Logo image - Formelogo.png (add to Assets as "Logo")
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)

                // Title image - titrelogo.png (add to Assets as "LogoText")
                Image("LogoText")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
            }
            .opacity(containerOpacity)
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        // Logo appears: 0 → 1.4s (matches HTML @keyframes logoAppear)
        withAnimation(.easeOut(duration: 1.4)) {
            logoOpacity = 1
            logoScale = 1
        }

        // Title appears: 0.8s → 1.8s (matches HTML @keyframes nameAppear)
        withAnimation(.easeOut(duration: 1.0).delay(0.8)) {
            titleOpacity = 1
            titleOffset = 0
        }

        // Fade out container: 2.6s → 3.4s
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            withAnimation(.easeIn(duration: 0.8)) {
                containerOpacity = 0
            }
        }

        // Navigate to next screen: 3.4s
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_400_000_000)
            onComplete()
        }
    }
}

// MARK: - Dioboo Logo (Fallback if image not found)
// This is only used if the Logo image is not in Assets
// The real logo should be added as an image asset

struct DiobooLogo: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    SplashView(onComplete: {})
}
