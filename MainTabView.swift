//
//  MainTabView.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//

import SwiftUI

struct MainTabView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color(hex: "#1D3D98").opacity(0.95))
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.7)
    }

    var body: some View {
        TabView {
            ClusterContentView()
                .tabItem {
                    Image(systemName: "circle.grid.2x2.fill")
                    Text("Clusters")
                }

            PhotoView()
                .tabItem {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                    Text("Photo")
                }

            FilterView()
                .tabItem {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    Text("Filter")
                }
        }
        .accentColor(.white) // Seçili tab rengi
        .onAppear {
            // Tab bar arka planı için
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(hex: "#1D3D98").opacity(0.95))
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
