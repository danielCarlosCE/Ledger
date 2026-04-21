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

    @Test("Given a full batch response, when load runs, then state is loaded with page 1")
    func loadStateLoadedWithPage1() async {
        let service = MockRemoteTransactionsService()
        service.result = Array(repeating: sampleTransaction("x"), count: 20)
        let sut = TransactionsViewModel(service: service)

        await sut.load(itemsPerPage: 20)

        #expect(service.calls.count == 1)
        #expect(service.calls.first?.page == 1)
        #expect(service.calls.first?.itemsPerPage == 20)
        guard case .loaded(let content) = sut.state else {
            Issue.record("Expected .loaded state")
            return
        }
        #expect(content.page == 1)
        #expect(content.rows.count == 20)
        #expect(content.canLoadMore == true)
    }

    @Test("Given a short batch response, when load runs, then canLoadMore is false")
    func canLoadMoreFalseOnShortBatch() async {
        let service = MockRemoteTransactionsService()
        service.result = Array(repeating: sampleTransaction("x"), count: 3)
        let sut = TransactionsViewModel(service: service)

        await sut.load(itemsPerPage: 20)

        guard case .loaded(let content) = sut.state else {
            Issue.record("Expected .loaded")
            return
        }
        #expect(content.canLoadMore == false)
    }

    @Test("Given a loaded VM, when loadMore runs, then the service is called with the next page")
    func loadMoreUsesNextPage() async {
        let service = MockRemoteTransactionsService()
        service.result = Array(repeating: sampleTransaction("x"), count: 20)
        let sut = TransactionsViewModel(service: service)

        await sut.load(itemsPerPage: 20)
        await sut.loadMore()

        #expect(service.calls.count == 2)
        #expect(service.calls.last?.page == 2)
        #expect(service.calls.last?.itemsPerPage == 20)
    }

    // Placeholder — expand when error state lands in scope.
    @Test("Given a service that throws, when load runs, then state reflects the error (TBD)")
    func errorCasesPlaceholder() {
        // TODO: assert state behavior when service throws .offline / .general
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
