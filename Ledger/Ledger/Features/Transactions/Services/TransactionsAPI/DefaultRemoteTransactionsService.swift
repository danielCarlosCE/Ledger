//
//  DefaultRemoteTransactionsService.swift
//  Ledger
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation
import Playgrounds

public final class DefaultRemoteTransactionsService: RemoteTransactionsService {
    private let client: ApiClient

    /// Captured from the first response. Sent on subsequent requests so pagination stays consistent.
    private var seed: String?

    public init(client: ApiClient = DefaultApiClient()) {
        self.client = client
    }

    public func transactions(
        page: Int,
        itemsPerPage: Int
    ) async throws(RemoteTransactionsServiceError) -> [Transaction] {
        let route = Route.transactions(page: page, itemsPerPage: itemsPerPage, seed: seed)
        do {
            let response = try await client.fetch(route)
            seed = response.info.seed
            return response.results
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
            throw .offline
        } catch {
            throw .general(error)
        }
    }
}

#Playground {
    do {
        let result = try await DefaultRemoteTransactionsService().transactions(page: 1, itemsPerPage: 20)
        print(result)
    } catch {
        print(error)
    }
}
