//
//  TransactionRow.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import Foundation

struct TransactionRow: Identifiable, Hashable {
    let id: String
    let counterparty: String
    /// Pre-formatted, signed amount for visual display (e.g. `"+24 EUR"`, `"-89 EUR"`).
    let amount: String
    let isIncoming: Bool
    let status: Status
    /// Pre-formatted date label (e.g. `"Today"`, `"April 14th"`).
    /// Nil when the transaction has no settled date.
    let date: String?

    var accessibilityLabel: String {
        let direction = isIncoming ? "from" : "to"
        let spokenAmount = amount.drop(while: { $0 == "+" || $0 == "-" })
        let base = "\(status.statusText) payment of \(spokenAmount) \(direction) \(counterparty)"
        if let date {
            return "\(base), \(date)"
        }
        return base
    }

    enum Status {
        case completed
        case pending
        case declined

        var statusText: String {
            switch self {
            case .completed: "Completed"
            case .pending: "Pending"
            case .declined: "Declined"
            }
        }
    }
}
