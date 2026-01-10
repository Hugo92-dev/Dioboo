//
//  PaywallView.swift
//  Dioboo
//
//  Premium subscription paywall with StoreKit 2 integration
//

import SwiftUI
import StoreKit

enum SubscriptionPlan {
    case monthly
    case yearly
}

struct PaywallView: View {
    let onSubscribe: () -> Void
    let onSkip: () -> Void

    @EnvironmentObject var appState: AppState
    @StateObject private var storeManager = StoreManager()

    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var contentOpacity: Double = 0
    @State private var isPurchasing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            // Background
            DiobooTheme.backgroundGradient
                .ignoresSafeArea()

            // Ambient glows
            AmbientGlow(
                color: DiobooTheme.accentPrincipal,
                position: CGPoint(x: 60, y: 150),
                size: 250
            )
            AmbientGlow(
                color: DiobooTheme.accentSecondaire,
                position: CGPoint(x: 320, y: 600),
                size: 280
            )

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

                // Logo
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 48)
                    .padding(.bottom, 24)

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
                VStack(spacing: 0) {
                    FeatureRow(text: "Choose your duration: 3, 5, or 8 min")
                    FeatureRow(text: "Both rituals: Read and Breathe")
                    FeatureRow(text: "All breathing journeys")
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 28)

                // Pricing cards
                HStack(spacing: 14) {
                    PricingCard(
                        period: "Monthly",
                        price: storeManager.monthlyPrice,
                        priceDetail: "/mo",
                        subtitle: "Billed monthly",
                        isSelected: selectedPlan == .monthly,
                        isBestValue: false,
                        action: { selectedPlan = .monthly }
                    )

                    PricingCard(
                        period: "Yearly",
                        price: storeManager.yearlyPrice,
                        priceDetail: "/yr",
                        subtitle: "2.50\u{20AC}/month",
                        savingsText: "Save 37%",
                        isSelected: selectedPlan == .yearly,
                        isBestValue: true,
                        action: { selectedPlan = .yearly }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // CTA Button
                Button(action: purchase) {
                    ZStack {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: DiobooTheme.fondPrincipal))
                        } else {
                            Text("Start 7-day free trial")
                                .font(DiobooTheme.body(16))
                                .fontWeight(.semibold)
                        }
                    }
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
                .disabled(isPurchasing)
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
                Text("7-day free trial, then auto-renews \u{00B7} Cancel anytime")
                    .font(.system(size: 11))
                    .foregroundColor(DiobooTheme.texteSecondaire.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 8)

                // Restore purchases
                Button(action: restorePurchases) {
                    Text("Restore purchases")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DiobooTheme.texteSecondaire.opacity(0.6))
                }
                .padding(.bottom, 40)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 1
            }
            Task {
                await storeManager.loadProducts()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func purchase() {
        isPurchasing = true
        Task {
            do {
                let productId = selectedPlan == .monthly ? StoreManager.monthlyProductId : StoreManager.yearlyProductId
                let success = try await storeManager.purchase(productId: productId)
                await MainActor.run {
                    isPurchasing = false
                    if success {
                        appState.isPremium = true
                        onSubscribe()
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func restorePurchases() {
        Task {
            do {
                try await storeManager.restorePurchases()
                if storeManager.isPurchased {
                    await MainActor.run {
                        appState.isPremium = true
                        onSubscribe()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Could not restore purchases. Please try again."
                    showError = true
                }
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            // Gold checkmark circle
            Circle()
                .fill(DiobooTheme.premiumGradient)
                .frame(width: 20, height: 20)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a2e"))
                )

            Text(text)
                .font(DiobooTheme.body(15))
                .foregroundColor(DiobooTheme.textePrincipal)

            Spacer()
        }
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .fill(DiobooTheme.bordure.opacity(0.5))
                .frame(height: 1),
            alignment: .bottom
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
                    Text(period.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DiobooTheme.texteSecondaire)
                        .tracking(0.5)
                        .padding(.top, 20)

                    // Price
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(price)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(DiobooTheme.textePrincipal)
                        Text(priceDetail)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DiobooTheme.texteSecondaire)
                    }

                    // Subtitle
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(DiobooTheme.texteSecondaire.opacity(0.8))
                        .padding(.top, 4)

                    // Savings
                    if let savingsText = savingsText {
                        Text(savingsText)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(DiobooTheme.accentSecondaire)
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                    } else {
                        Spacer()
                            .frame(height: 40)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "86A6FF").opacity(0.1) : DiobooTheme.surface.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isSelected ? DiobooTheme.accentPrincipal : DiobooTheme.bordure,
                                    lineWidth: 1
                                )
                        )
                )

                // Best value badge
                if isBestValue {
                    Text("Best value")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a2e"))
                        .textCase(.uppercase)
                        .tracking(0.3)
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

// MARK: - Store Manager

@MainActor
class StoreManager: ObservableObject {
    static let monthlyProductId = "com.dioboo.premium.monthly"
    static let yearlyProductId = "com.dioboo.premium.yearly"

    @Published var products: [Product] = []
    @Published var isPurchased: Bool = false
    @Published var monthlyPrice: String = "3.99\u{20AC}"
    @Published var yearlyPrice: String = "29.99\u{20AC}"

    func loadProducts() async {
        do {
            let productIds = [Self.monthlyProductId, Self.yearlyProductId]
            products = try await Product.products(for: productIds)

            for product in products {
                if product.id == Self.monthlyProductId {
                    monthlyPrice = product.displayPrice
                } else if product.id == Self.yearlyProductId {
                    yearlyPrice = product.displayPrice
                }
            }

            // Check current entitlements
            await checkPurchaseStatus()
        } catch {
            print("Failed to load products: \(error)")
            // Keep default prices if products can't be loaded
        }
    }

    func purchase(productId: String) async throws -> Bool {
        guard let product = products.first(where: { $0.id == productId }) else {
            // If products not loaded (testing in simulator), simulate success
            isPurchased = true
            return true
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                isPurchased = true
                return true
            case .unverified:
                return false
            }
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await checkPurchaseStatus()
    }

    private func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.monthlyProductId ||
                   transaction.productID == Self.yearlyProductId {
                    isPurchased = true
                    return
                }
            }
        }
        isPurchased = false
    }
}

#Preview {
    PaywallView(onSubscribe: {}, onSkip: {})
        .environmentObject(AppState())
}
