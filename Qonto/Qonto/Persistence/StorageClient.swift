//
//  StorageClient.swift
//  Qonto
//
//  Created by Daniel Souza on 21.04.26.
//

import CoreData

public final class StorageClient {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    /// Best-effort save. Failures are swallowed.
    public func save<T: Persistable>(_ items: [T]) async {
        for item in items {
            _ = item.makeEntity(in: context)
        }
        do {
            try context.save()
        } catch {
            // Swallowed: save is best-effort.
        }
    }

    /// Fetch a page of entities, sorted by `keyPath`. Returns `[]` on any internal failure.
    public func fetch<Entity: NSManagedObject, Value>(
        _ type: Entity.Type,
        page: Int,
        itemsPerPage: Int,
        sortBy keyPath: KeyPath<Entity, Value>,
        ascending: Bool = false
    ) async -> [Entity] {
        let request = NSFetchRequest<Entity>(entityName: String(describing: type))
        request.fetchLimit = itemsPerPage
        request.fetchOffset = max(0, (page - 1) * itemsPerPage)
        request.sortDescriptors = [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
        return (try? context.fetch(request)) ?? []
    }

    /// Best-effort wipe of all entities of `type`. Failures are swallowed.
    public func deleteAll<Entity: NSManagedObject>(_ type: Entity.Type) async {
        let request = NSFetchRequest<Entity>(entityName: String(describing: type))
        let entities = (try? context.fetch(request)) ?? []
        for entity in entities {
            context.delete(entity)
        }
        do {
            try context.save()
        } catch {
            // Swallowed: best-effort.
        }
    }
}
