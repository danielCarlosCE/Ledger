//
//  LocalTransactionsService.swift
//  Qonto
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

public protocol LocalTransactionsService {
    /// Reads persisted transactions. Returns `[]` on any internal failure.
    func transactions(page: Int, itemsPerPage: Int) async -> [Transaction]

    /// Best-effort persistence. Failures are swallowed.
    func save(_ transactions: [Transaction]) async

    /// Wipes all persisted transactions. Best-effort.
    func deleteAll() async
}
