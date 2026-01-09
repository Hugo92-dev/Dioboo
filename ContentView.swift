//
//  ContentView.swift
//  Dioboo
//
//  Main navigation controller
//

import SwiftUI

enum AppScreen {
    case splash
    case home
    case ritualChoice
    case parcoursBreathe
    case duration
    case read
    case breathe
    case end
    case paywall
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentScreen: AppScreen = .splash

    var body: some View {
        ZStack {
            // Background gradient (always present)
            DiobooTheme.backgroundGradient
                .ignoresSafeArea()

            // Current screen
            switch currentScreen {
            case .splash:
                SplashView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .home
                    }
                })

            case .home:
                HomeView(onBegin: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = .ritualChoice
                    }
                })

            case .ritualChoice:
                RitualChoiceView(
                    onSelectRead: {
                        appState.selectedRitual = .read
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .duration
                        }
                    },
                    onSelectBreathe: {
                        appState.selectedRitual = .breathe
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .parcoursBreathe
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .home
                        }
                    }
                )

            case .parcoursBreathe:
                ParcoursBreathView(
                    onSelectParcours: { parcours in
                        appState.selectedParcours = parcours
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .duration
                        }
                    },
                    onSelectPremiumParcours: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .paywall
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .ritualChoice
                        }
                    }
                )

            case .duration:
                DurationView(
                    ritual: appState.selectedRitual,
                    onSelectDuration: { duration in
                        appState.selectedDuration = duration
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if appState.selectedRitual == .read {
                                currentScreen = .read
                            } else {
                                currentScreen = .breathe
                            }
                        }
                    },
                    onSelectPremiumDuration: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .paywall
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if appState.selectedRitual == .read {
                                currentScreen = .ritualChoice
                            } else {
                                currentScreen = .parcoursBreathe
                            }
                        }
                    }
                )

            case .read:
                ReadView(
                    duration: appState.selectedDuration,
                    onComplete: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .end
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .duration
                        }
                    }
                )

            case .breathe:
                BreatheContainerView(
                    parcours: appState.selectedParcours,
                    duration: appState.selectedDuration,
                    onComplete: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .end
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .parcoursBreathe
                        }
                    }
                )

            case .end:
                EndView(
                    onAnotherRitual: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .ritualChoice
                        }
                    }
                )

            case .paywall:
                PaywallView(
                    onSubscribe: {
                        appState.isPremium = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .duration
                        }
                    },
                    onSkip: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            // Go back to previous logical screen
                            if appState.selectedRitual == .breathe {
                                currentScreen = .parcoursBreathe
                            } else {
                                currentScreen = .duration
                            }
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
