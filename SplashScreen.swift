//
//  SplashScreen.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//

import SwiftUI

struct SplashScreen: View {
    var onFinish: () -> Void
    var body: some View {
        ZStack {
            Color(hex: "#1D3D98").ignoresSafeArea()
            Image("logoCash")
                .resizable()
                .frame(width: 150, height: 150)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onFinish()
            }
        }
    }
}
