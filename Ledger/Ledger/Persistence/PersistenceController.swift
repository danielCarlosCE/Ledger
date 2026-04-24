//
//  PersistenceController.swift
//  Ledger
//
//  Created by Daniel Souza on 21.04.26.
//

import CoreData

public final class PersistenceController {
    public static let shared = PersistenceController()

    private let container: NSPersistentContainer

    public init() {
        container = NSPersistentContainer(name: "Ledger")
        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Failed to load Core Data store: \(error)")
            }
            print("Core Data store: \(description.url?.absoluteString ?? "unknown")")
        }
    }

    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}
