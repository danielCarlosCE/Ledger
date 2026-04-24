//
//  MockApiClient.swift
//  LedgerTests
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation
@testable import Ledger

final class MockApiClient: ApiClient {
    var capturedQueryItems: [[URLQueryItem]] = []
    var response: TransactionsPage = TransactionsPage(
        results: [],
        info: .init(seed: "test-seed")
    )

    func fetch<Response: Decodable>(_ route: Route<Response>) async throws -> Response {
        if case let .get(items) = route.method {
            capturedQueryItems.append(items)
        }
        guard let casted = response as? Response else {
            throw NSError(domain: "Invalid cast", code: 0, userInfo: nil)
        }
        return casted
    }
}
