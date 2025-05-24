//
//  CoreDataManager.swift
//  Cash Cluster
//
//  Created by Mesut Aygün on 23.05.2025.
//


import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "ClusterModel2") // .xcdatamodeld dosyanın adı
        persistentContainer.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("Core Data yüklenemedi: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
