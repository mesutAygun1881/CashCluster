//
//  PermissionView.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//
import SwiftUI
import PhotosUI


struct PermissionView: View {
    var onPermissionGranted: () -> Void
    @State private var asked = false
    @State private var showAlert = false
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(width: 300, height: 120)
                    .overlay(
                        VStack(spacing: 16) {
                            Text("Allow access to your photo/folder?")
                                .foregroundColor(.black)
                            HStack {
                                Button("Deny") {
                                    onPermissionGranted() // Devam et ama izin verilmedi
                                }
                                Spacer()
                                Button("Allow") {
                                    requestPhotoPermission()
                                }
                                .fontWeight(.bold)
                            }
                            .padding(.horizontal, 24)
                        }
                    )
                Spacer()
            }
        }
        .onAppear {
            if !asked {
                asked = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Permission required"), message: Text("Please allow access to continue."), dismissButton: .default(Text("OK")))
        }
    }
    func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                onPermissionGranted()
            }
        }
    }
}
