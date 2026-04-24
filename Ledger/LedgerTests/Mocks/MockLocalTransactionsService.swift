//
//  MockLocalTransactionsService.swift
//  LedgerTests
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation
@testable import Ledger

final class MockLocalTransactionsService: LocalTransactionsService {
    struct SaveCall {
        let transactions: [Transaction]
    }

    struct FetchCall {
        let page: Int
        let itemsPerPage: Int
    }

    private(set) var saveCalls: [SaveCall] = []
    private(set) var fetchCalls: [FetchCall] = []
    private(set) var deleteAllCallCount = 0
    var storedTransactions: [Transaction] = []

    func transactions(page: Int, itemsPerPage: Int) async -> [Transaction] {
        fetchCalls.append(FetchCall(page: page, itemsPerPage: itemsPerPage))
        return storedTransactions
    }

    func save(_ transactions: [Transaction]) async {
        saveCalls.append(SaveCall(transactions: transactions))
    }

    func deleteAll() async {
        deleteAllCallCount += 1
    }
}
