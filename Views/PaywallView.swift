//
//  PaywallView.swift
//  Dioboo
//
//  Premium subscription paywall
//

import SwiftUI
import Combine

enum SubscriptionPlan {
    case monthly
    case yearly
}

struct PaywallView: View {
    let onSubscribe: () -> Void
    let onSkip: () -> Void

    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background
            DiobooTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onSkip) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DiobooTheme.texteSecondaire)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(DiobooTheme.surface.opacity(0.6))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Title
                Text("More time for yourself")
                    .font(DiobooTheme.title(26))
                    .foregroundColor(DiobooTheme.textePrincipal)
                    .padding(.bottom, 8)

                // Subtitle
                Text("Unlock your full evening ritual.")
                    .font(DiobooTheme.subtitle(15))
                    .foregroundColor(DiobooTheme.texteSecondaire)
                    .padding(.bottom, 30)

                // Features
                VStack(spacing: 16) {
                    FeatureRow(text: "Choose your duration: 3, 5, or 8 min")
                    FeatureRow(text: "Both rituals: Read and Breathe")
                    FeatureRow(text: "All breathing journeys")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)

                // Pricing cards
                HStack(spacing: 14) {
                    PricingCard(
                        period: "Monthly",
                        price: "3.99€",
                        priceDetail: "/mo",
                        subtitle: "Billed monthly",
                        isSelected: selectedPlan == .monthly,
                        isBestValue: false,
                        action: { selectedPlan = .monthly }
                    )

                    PricingCard(
                        period: "Yearly",
                        price: "29.99€",
                        priceDetail: "/yr",
                        subtitle: "2.50€/month",
                        savingsText: "Save 37%",
                        isSelected: selectedPlan == .yearly,
                        isBestValue: true,
                        action: { selectedPlan = .yearly }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)

                // CTA Button
                Button(action: onSubscribe) {
                    Text("Start 7-day free trial")
                        .font(DiobooTheme.body(16))
                        .fontWeight(.semibold)
                        .foregroundColor(DiobooTheme.fondPrincipal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [DiobooTheme.accentPrincipal, DiobooTheme.accentSecondaire],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(26)
                        .shadow(color: DiobooTheme.accentPrincipal.opacity(0.4), radius: 15, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                // Skip button
                Button(action: onSkip) {
                    Text("Not now")
                        .font(DiobooTheme.body(14))
                        .foregroundColor(DiobooTheme.texteSecondaire)
                }
                .padding(.bottom, 16)

                // Footer
                Text("7-day free trial, then auto-renews · Cancel anytime · Restore purchases")
                    .font(.system(size: 11))
                    .foregroundColor(DiobooTheme.texteSecondaire.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 1
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            Text(text)
                .font(DiobooTheme.body(15))
                .foregroundColor(DiobooTheme.textePrincipal)
            Spacer()
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DiobooTheme.surface.opacity(0.4))
        )
    }
}

// MARK: - Pricing Card

struct PricingCard: View {
    let period: String
    let price: String
    let priceDetail: String
    let subtitle: String
    var savingsText: String? = nil
    let isSelected: Bool
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    // Period
                    Text(period)
                        .font(DiobooTheme.caption(12))
                        .foregroundColor(DiobooTheme.texteSecondaire)
                        .padding(.top, 16)

                    // Price
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(price)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(DiobooTheme.textePrincipal)
                        Text(priceDetail)
                            .font(DiobooTheme.caption(12))
                            .foregroundColor(DiobooTheme.texteSecondaire)
                    }

                    // Subtitle
                    Text(subtitle)
                        .font(DiobooTheme.caption(11))
                        .foregroundColor(DiobooTheme.texteSecondaire)

                    // Savings
                    if let savingsText = savingsText {
                        Text(savingsText)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(DiobooTheme.accentPrincipal)
                            .padding(.bottom, 16)
                    } else {
                        Spacer()
                            .frame(height: 30)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DiobooTheme.surface.opacity(isSelected ? 0.8 : 0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? DiobooTheme.accentPrincipal : DiobooTheme.bordure,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )

                // Best value badge
                if isBestValue {
                    Text("Best value")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a2e"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(DiobooTheme.premiumGradient)
                        .cornerRadius(8)
                        .shadow(color: DiobooTheme.premiumGold.opacity(0.4), radius: 4, y: 2)
                        .offset(x: 8, y: -8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    PaywallView(onSubscribe: {}, onSkip: {})
}
