//
//  Cash_ClusterApp.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 22.05.2025.
//

import SwiftUI

@main
struct Cash_ClusterApp: App {
    let persistenceController = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
