//
//  OnboardingPage2 2.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//


import SwiftUI

struct OnboardingPage3: View {
    var onContinue: () -> Void
    var onSkip: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Alt mavi arka plan
                Color(hex: "#1D3D98").ignoresSafeArea()
                // Üst beyaz alanı Rectangle ile çiz
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: geometry.size.height * 0.35)
                    Spacer()
                }
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    // onboard2 görseli: sadece genişlik sınırı, scaledToFit
                    Image("onboard3")
                        .resizable()
                        //.scaledToFit()
                        .frame(width: 300 , height: 500)
                        .clipped()
                        .shadow(radius: 10)
                        .offset(y: geometry.size.height * 0.35 * 0.33 - geometry.size.height * 0.10)

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photo")
                            .font(.custom("Exo 2 ExtraBold", size: 22))
                            .foregroundColor(.white)
                        Text("Add new exhibits and build to your collections")
                            .font(.custom("Exo 2 Medium", size: 15))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)

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
                    Spacer().frame(height: 10)
                }
               
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
} 
