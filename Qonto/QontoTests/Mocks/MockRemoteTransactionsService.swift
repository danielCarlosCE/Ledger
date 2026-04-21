//
//  MockRemoteTransactionsService.swift
//  QontoTests
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation
@testable import Qonto

final class MockRemoteTransactionsService: RemoteTransactionsService {
    struct Call {
        let page: Int
        let itemsPerPage: Int
    }

    private(set) var calls: [Call] = []
    var result: [Transaction] = []
    var error: RemoteTransactionsServiceError?

    func transactions(page: Int, itemsPerPage: Int) async throws(RemoteTransactionsServiceError) -> [Transaction] {
        calls.append(Call(page: page, itemsPerPage: itemsPerPage))
        if let error { throw error }
        return result
    }
}
