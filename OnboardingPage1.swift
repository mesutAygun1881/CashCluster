//
//  OnboardingPage1.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//


import SwiftUI



struct OnboardingPage1: View {
    var onContinue: () -> Void
    var onSkip: () -> Void
    var body: some View {
        ZStack {
            Color(hex: "#1D3D98")
                .ignoresSafeArea()
            VStack(spacing: 5) {
                Spacer()
                (Text("Welcome to the ")
                    .font(.custom("Exo 2 Medium", size: 20))
                    .foregroundColor(.white)
                + Text("Cash Cluster")
                    .font(.custom("Exo 2 ExtraBold", size: 20))
                    .foregroundColor(.white)
                + Text("!")
                    .font(.custom("Exo 2 Medium", size: 20))
                    .foregroundColor(.white))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                Image("onboard1")
                    .resizable()
                .scaledToFill()
                    .frame(maxWidth: 400, maxHeight: 600)
                    .shadow(radius: 10)
                Spacer()
                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    Button(action: onSkip) {
                        Text("Skip onboarding")
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding(.horizontal, 32)
                Spacer().frame(height: 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
