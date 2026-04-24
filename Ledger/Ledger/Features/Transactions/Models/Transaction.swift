//
//  Transaction.swift
//  Ledger
//
//  Created by Daniel Souza on 21.04.26.
//

import Foundation

public struct Transaction: Decodable, Identifiable {
    public let id: String
    let amount: Amount
    let status: Status
    /// Accounting side of the transaction.
    /// `.credit` = incoming (money in), `.debit` = outgoing (money out).
    let side: Side
    let settledAt: Date?

    /// Wire name; exposed via ``counterparty``.
    private let counterpartyName: String
    var counterparty: String { counterpartyName }

    public struct Amount: Decodable {
        public let currency: String
        public let value: String
    }

    public enum Status: String, Decodable {
        case completed = "COMPLETED"
        case pending = "PENDING"
        case declined = "DECLINED"
    }

    public enum Side: String, Decodable {
        case credit = "CREDIT"
        case debit = "DEBIT"
    }
}

extension Transaction {
    /// Memberwise initializer for test fixtures and mocks.
    public init(
        id: String,
        counterparty: String,
        amount: Amount,
        status: Status,
        side: Side,
        settledAt: Date?
    ) {
        self.id = id
        self.counterpartyName = counterparty
        self.amount = amount
        self.status = status
        self.side = side
        self.settledAt = settledAt
    }
}
