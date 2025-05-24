//
//  ContentView.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var currentStep: Step = .splash
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    enum Step {
        case splash, permission, onboarding, main
    }

    func checkPhotoPermission() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .authorized || status == .limited
    }

    var body: some View {
        switch currentStep {
        case .splash:
            SplashScreen {
                if hasSeenOnboarding {
                    currentStep = .main
                } else if checkPhotoPermission() {
                    currentStep = .onboarding
                } else {
                    currentStep = .permission
                }
            }
        case .permission:
            PermissionView {
                currentStep = .onboarding
            }
        case .onboarding:
            OnboardingView {
                hasSeenOnboarding = true
                currentStep = .main
            }
        case .main:
            MainTabView()
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
