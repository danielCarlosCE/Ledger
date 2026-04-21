//
//  TransactionsViewModelTests.swift
//  QontoTests
//
//  Created by Daniel Souza on 21.04.26.
//

import Testing
import Foundation
@testable import Qonto

struct TransactionsViewModelTests {

    let remote: MockRemoteTransactionsService
    let local: MockLocalTransactionsService
    let sut: TransactionsViewModel
    let itemsPerPage = 10

    init() {
        let remote = MockRemoteTransactionsService()
        let local = MockLocalTransactionsService()
        self.remote = remote
        self.local = local
        self.sut = TransactionsViewModel(remote: remote, local: local)
    }

    @Test("Given a full batch response, when load runs, then state is loaded with page 1")
    func loadStateLoadedWithPage1() async {
        remote.result = Array(repeating: sampleTransaction("x"), count: itemsPerPage)

        await sut.load(itemsPerPage: itemsPerPage)

        #expect(remote.calls.count == 1)
        #expect(remote.calls.first?.page == 1)
        #expect(remote.calls.first?.itemsPerPage == itemsPerPage)
        guard case .loaded(let content) = sut.state else {
            Issue.record("Expected .loaded state")
            return
        }
        #expect(content.page == 1)
        #expect(content.rows.count == itemsPerPage)
        #expect(content.loadMoreState == .hasMore)
    }

    @Test("Given successful initial load, when load runs, then local is wiped and new transactions are saved")
    func loadWipesLocalAndSavesOnSuccess() async {
        remote.result = [sampleTransaction("x"), sampleTransaction("y")]

        await sut.load(itemsPerPage: itemsPerPage)

        #expect(local.deleteAllCallCount == 1)
        #expect(local.saveCalls.count == 1)
    }

    @Test("Given a short batch response, when load runs, then loadMoreState is ended")
    func loadShortBatchEndsPagination() async {
        remote.result = Array(repeating: sampleTransaction("x"), count: itemsPerPage - 1)

        await sut.load(itemsPerPage: itemsPerPage)

        guard case .loaded(let content) = sut.state else {
            Issue.record("Expected .loaded")
            return
        }
        #expect(content.loadMoreState == .ended)
    }

    @Test("Given a loaded VM, when loadMore runs, then the service is called with the next page")
    func loadMoreUsesNextPage() async {
        remote.result = Array(repeating: sampleTransaction("x"), count: itemsPerPage)

        await sut.load(itemsPerPage: itemsPerPage)
        await sut.loadMore()

        #expect(remote.calls.count == 2)
        #expect(remote.calls.last?.page == 2)
        #expect(remote.calls.last?.itemsPerPage == itemsPerPage)
    }

    @Test("Given service throws general, when load runs, then state is error general")
    func loadErrorGeneral() async {
        remote.error = .general(URLError(.badServerResponse))

        await sut.load(itemsPerPage: itemsPerPage)

        guard case .error(let kind) = sut.state else {
            Issue.record("Expected .error state")
            return
        }
        #expect(kind == .general)
    }

    @Test("Given loadMore fails with offline, when loadMore runs, then loadMoreState is error offline and rows remain")
    func loadMoreErrorOffline() async {
        remote.result = Array(repeating: sampleTransaction("x"), count: itemsPerPage)

        await sut.load(itemsPerPage: itemsPerPage)
        remote.error = .offline
        await sut.loadMore()

        guard case .loaded(let content) = sut.state else { Issue.record("Expected .loaded"); return }
        #expect(content.rows.count == itemsPerPage)
        #expect(content.loadMoreState == .error(.offline))
    }

    @Test("Given loadMore fails with general, when loadMore runs, then loadMoreState is error general")
    func loadMoreErrorGeneral() async {
        remote.result = Array(repeating: sampleTransaction("x"), count: itemsPerPage)

        await sut.load(itemsPerPage: itemsPerPage)
        remote.error = .general(URLError(.badServerResponse))
        await sut.loadMore()

        guard case .loaded(let content) = sut.state else { Issue.record("Expected .loaded"); return }
        #expect(content.rows.count == itemsPerPage)
        #expect(content.loadMoreState == .error(.general))
    }

    @Test("Given remote offline and local has data, when load runs, then state shows cached transactions")
    func loadFallsBackToCacheWhenAvailable() async {
        remote.error = .offline
        local.storedTransactions = [sampleTransaction("c1"), sampleTransaction("c2")]

        await sut.load(itemsPerPage: itemsPerPage)

        guard case .loaded(let content) = sut.state else {
            Issue.record("Expected .loaded")
            return
        }
        #expect(content.rows.count == 2)
    }

    @Test("Given remote offline and local empty, when load runs, then state is error offline")
    func loadErrorWhenOfflineAndNoCache() async {
        remote.error = .offline
        // local.storedTransactions defaults to []

        await sut.load(itemsPerPage: itemsPerPage)

        guard case .error(.offline) = sut.state else {
            Issue.record("Expected .error(.offline)")
            return
        }
    }

    @Test("Given source is local after cache fallback, when loadMore runs, then local fetches next page")
    func loadMoreFromLocalFetchesNextPage() async {
        remote.error = .offline
        local.storedTransactions = Array(repeating: sampleTransaction("x"), count: itemsPerPage)
        await sut.load(itemsPerPage: itemsPerPage)

        await sut.loadMore()

        // First call: fallbackToCacheIfPossible fetched page 1.
        // Second call: loadMoreLocal fetched page 2.
        #expect(local.fetchCalls.count == 2)
        #expect(local.fetchCalls.last?.page == 2)
        #expect(local.fetchCalls.last?.itemsPerPage == itemsPerPage)
    }
}

// MARK: - Helpers

private func sampleTransaction(_ id: String) -> Transaction {
    Transaction(
        id: id,
        counterparty: "Test Counterparty",
        amount: Transaction.Amount(currency: "EUR", value: "10.00"),
        status: .completed,
        side: .debit,
        settledAt: nil
    )
}
