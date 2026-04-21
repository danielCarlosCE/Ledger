//
//  DefaultLocalTransactionsService.swift
//  Qonto
//
//  Created by Daniel Souza on 21.04.26.
//

public final class DefaultLocalTransactionsService: LocalTransactionsService {
    private let client: StorageClient

    public init(client: StorageClient = StorageClient()) {
        self.client = client
    }

    public func transactions(page: Int, itemsPerPage: Int) async -> [Transaction] {
        let entities = await client.fetch(
            TransactionEntity.self,
            page: page,
            itemsPerPage: itemsPerPage,
            sortBy: \.settledAt
        )
        return entities.compactMap(Transaction.init(entity:))
    }

    public func save(_ transactions: [Transaction]) async {
        await client.save(transactions)
    }

    public func deleteAll() async {
        await client.deleteAll(TransactionEntity.self)
    }
}
