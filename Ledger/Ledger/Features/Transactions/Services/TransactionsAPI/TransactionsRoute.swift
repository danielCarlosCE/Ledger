//
//  TransactionsRoute.swift
//  Ledger
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

extension Route where Response == TransactionsPage {
    static func transactions(page: Int, itemsPerPage: Int, seed: String?) -> Route {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "results", value: "\(itemsPerPage)"),
        ]
        if let seed {
            queryItems.append(URLQueryItem(name: "seed", value: seed))
        }
        return Route(
            path: "/transactions",
            method: .get(queryItems: queryItems)
        )
    }
}
