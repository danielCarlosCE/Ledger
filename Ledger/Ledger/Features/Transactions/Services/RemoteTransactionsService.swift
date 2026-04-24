//
//  RemoteTransactionsService.swift
//  Ledger
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

public protocol RemoteTransactionsService {
    func transactions(page: Int, itemsPerPage: Int) async throws(RemoteTransactionsServiceError) -> [Transaction]
}

public enum RemoteTransactionsServiceError: Error {
    case offline
    case general(Error)
}
