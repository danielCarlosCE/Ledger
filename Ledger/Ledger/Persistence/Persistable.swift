//
//  Persistable.swift
//  Ledger
//
//  Created by Daniel Souza on 21.04.26.
//

import CoreData

/// Types that can be projected into a Core Data entity.
public protocol Persistable {
    associatedtype Entity: NSManagedObject
    @MainActor func makeEntity(in context: NSManagedObjectContext) -> Entity
}
