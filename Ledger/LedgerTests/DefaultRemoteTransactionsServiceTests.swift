//
//  DefaultRemoteTransactionsServiceTests.swift
//  LedgerTests
//
//  Created by Daniel Souza on 21.04.26.
//

import Testing
import Foundation
@testable import Ledger

struct DefaultRemoteTransactionsServiceTests {

    @Test("Given a seed is returned in the first response, when a second call runs, then that seed is sent as a query item")
    func seedIsReusedAcrossCalls() async throws {
        let client = MockApiClient()
        let sut = DefaultRemoteTransactionsService(client: client)

        // First call — no seed yet.
        _ = try await sut.transactions(page: 1, itemsPerPage: 20)
        #expect(client.capturedQueryItems.last == [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "results", value: "20"),
        ])

        // Second call — seed captured from first response.
        _ = try await sut.transactions(page: 2, itemsPerPage: 20)
        #expect(client.capturedQueryItems.last == [
            URLQueryItem(name: "page", value: "2"),
            URLQueryItem(name: "results", value: "20"),
            URLQueryItem(name: "seed", value: "test-seed"),
        ])
    }
}
