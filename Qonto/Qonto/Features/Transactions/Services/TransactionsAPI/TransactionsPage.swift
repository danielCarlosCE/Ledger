//
//  TransactionsPage.swift
//  Qonto
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

struct TransactionsPage: Decodable {
    let results: [Transaction]
    let info: Info

    struct Info: Decodable {
        let seed: String
    }
}
