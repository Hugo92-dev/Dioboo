//
//  DiobooTheme.swift
//  Dioboo
//
//  Design system - Colors, fonts, and styles
//

import SwiftUI
import Combine

struct DiobooTheme {
    // MARK: - Colors (from Brand Book)

    // Backgrounds
    static let fondPrincipal = Color(hex: "070A14")
    static let surface = Color(hex: "0F1630")

    // Text
    static let textePrincipal = Color(hex: "F5F7FF")
    static let texteSecondaire = Color(hex: "B8C0E6")

    // Accents
    static let accentPrincipal = Color(hex: "86A6FF")
    static let accentSecondaire = Color(hex: "C6A6FF")

    // Borders
    static let bordure = Color(hex: "86A6FF").opacity(0.15)

    // Premium badge gradient colors
    static let premiumGold = Color(hex: "FFD700")
    static let premiumOrange = Color(hex: "FFA500")

    // MARK: - Gradients

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "1a1a2e"),
                Color(hex: "16213e"),
                Color(hex: "0f0f23")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [premiumGold, premiumOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentPrincipal, accentSecondaire],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Typography

    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .light, design: .rounded)
    }

    static func subtitle(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    // MARK: - Animations

    static let standardAnimation = Animation.easeInOut(duration: 0.3)
    static let slowAnimation = Animation.easeInOut(duration: 0.7)
    static let breatheAnimation = Animation.easeInOut(duration: 5.0)
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DiobooTheme.surface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DiobooTheme.bordure, lineWidth: 1)
                    )
            )
    }
}

struct PremiumBadge: View {
    var body: some View {
        Text("PRO")
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(Color(hex: "1a1a2e"))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(DiobooTheme.premiumGradient)
            .cornerRadius(6)
            .shadow(color: DiobooTheme.premiumGold.opacity(0.4), radius: 4, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Ambient Glow Effect

struct AmbientGlow: View {
    let color: Color
    let position: CGPoint
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.3), color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .position(position)
            .blur(radius: 60)
    }
}
