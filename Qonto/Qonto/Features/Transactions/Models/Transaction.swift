//
//  Transaction.swift
//  Qonto
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

public struct Transaction: Identifiable {
    public let id: String
    let counterparty: String
    let amount: Amount
    let status: Status
    /// Accounting side of the transaction.
    /// `.credit` = incoming (money in), `.debit` = outgoing (money out).
    let side: Side
    let settledAt: Date?

    struct Amount {
        let currency: String
        let value: String
    }

    enum Status {
        case completed
        case pending
        case declined
    }

    enum Side {
        case credit
        case debit
    }
}
