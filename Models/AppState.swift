//
//  AppState.swift
//  Dioboo
//
//  Global app state management
//

import SwiftUI
import Combine

enum Ritual {
    case read
    case breathe
}

enum BreatheParcours: String, CaseIterable {
    case chairlift = "Chairlift"
    case seagull = "Seagull"
    case ferriswheel = "Ferris wheel"
    case astronaut = "Astronaut"
    case hotairballoon = "Hot air balloon"
    case wave = "Ocean wave"
    case branch = "Tree branch"
    case buoy = "Buoy"
    case glidingbird = "Gliding bird"

    var icon: String {
        switch self {
        case .chairlift: return "🚠"
        case .seagull: return "🕊️"
        case .ferriswheel: return "🎡"
        case .astronaut: return "👨‍🚀"
        case .hotairballoon: return "🎈"
        case .wave: return "🌊"
        case .branch: return "🌿"
        case .buoy: return "🛟"
        case .glidingbird: return "🕊️"
        }
    }

    var description: String {
        switch self {
        case .chairlift: return "Glide over the slopes"
        case .seagull: return "Glide above the sea"
        case .ferriswheel: return "A slow turn above the lights"
        case .astronaut: return "Float in silence"
        case .hotairballoon: return "Drift between wind layers"
        case .wave: return "Rise and release"
        case .branch: return "Sway with the breeze"
        case .buoy: return "Rock gently on the water"
        case .glidingbird: return "Soar through the canyon"
        }
    }

    var isPremium: Bool {
        switch self {
        case .chairlift, .seagull:
            return false
        default:
            return true
        }
    }
}

class AppState: ObservableObject {
    @Published var selectedRitual: Ritual = .read
    @Published var selectedParcours: BreatheParcours = .chairlift
    @Published var selectedDuration: Int = 3

    // Premium state - In production, this would be managed by StoreKit
    @Published var isPremium: Bool = UserDefaults.standard.bool(forKey: "dioboo_premium") {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "dioboo_premium")
        }
    }

    // Check if a duration is premium
    func isDurationPremium(_ duration: Int) -> Bool {
        return duration > 3 && !isPremium
    }

    // Check if a parcours is premium
    func isParcoursPremium(_ parcours: BreatheParcours) -> Bool {
        return parcours.isPremium && !isPremium
    }

    // Reset for new session
    func resetSession() {
        selectedRitual = .read
        selectedParcours = .chairlift
        selectedDuration = 3
    }
}
