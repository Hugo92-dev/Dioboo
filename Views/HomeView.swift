//
//  HomeView.swift
//  Dioboo
//
//  Welcome screen - matches accueil.html exactly
//

import SwiftUI
import Combine

struct HomeView: View {
    let onBegin: () -> Void

    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 10

    var body: some View {
        ZStack {
            // Background - exact color from HTML: #070A14
            Color(hex: "070A14")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo - Formelogo.png (90x54 in HTML)
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 54)
                    .padding(.bottom, 44)

                // Title - exact text and styling from HTML
                Text("You can close\nthe day here.")
                    .font(.custom("Nunito", size: 26).weight(.semibold))
                    .foregroundColor(Color(hex: "F5F7FF"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(26 * 0.35) // line-height 1.35

                // Subtitle - exact text from HTML
                Text("A quiet moment of transition.")
                    .font(.custom("Nunito", size: 15).weight(.regular))
                    .foregroundColor(Color(hex: "B8C0E6"))
                    .padding(.top, 14)

                Spacer()

                // Begin button - exact styling from HTML
                Button(action: onBegin) {
                    Text("Begin")
                        .font(.custom("Nunito", size: 17).weight(.semibold))
                        .foregroundColor(Color(hex: "070A14"))
                        .padding(.horizontal, 52)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "86A6FF"),
                                    Color(hex: "C6A6FF")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(30)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 28)
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .onAppear {
            // Animation matches HTML: fadeIn 0.8s ease
            withAnimation(.easeOut(duration: 0.8)) {
                contentOpacity = 1
                contentOffset = 0
            }
        }
    }
}

#Preview {
    HomeView(onBegin: {})
}
