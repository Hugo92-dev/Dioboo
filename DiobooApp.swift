//
//  DiobooApp.swift
//  Dioboo
//
//  Evening ritual app - Close your day peacefully
//

import SwiftUI
import Combine

@main
struct DiobooApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}
