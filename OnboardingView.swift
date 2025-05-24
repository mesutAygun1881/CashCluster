//
//  OnboardingView.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//
import SwiftUI

struct OnboardingView: View {
    @State private var page = 0
    var onComplete: () -> Void
    
    var body: some View {
        TabView(selection: $page) {
            OnboardingPage1(
                onContinue: { page = 1 },
                onSkip: { onComplete() }
            )
            .tag(0)
            OnboardingPage2(
                onContinue: { page = 2 },
                onSkip: { onComplete() }
            )
            .tag(1)
            OnboardingPage3(
                onContinue: { page = 3 },
                onSkip: { onComplete() }
            )
            .tag(2)
            OnboardingPage4(
                onContinue: { onComplete() },
                onSkip: { onComplete() }
            )
            .tag(3)
            // Diğer onboarding sayfalarını buraya ekleyebilirsin
//            ForEach(1..<4) { i in
//                VStack {
//                    Text("Onboarding Page \(i+1)")
//                        .font(.largeTitle)
//                        .foregroundColor(.white)
//                }
//                .tag(i)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.blue)
//            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}
