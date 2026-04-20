//
//  TransactionRow.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import Foundation

struct TransactionRow: Identifiable, Hashable {
    let id: String
    let counterpartyName: String
    /// Pre-formatted, signed amount (e.g. `"+24 EUR"`, `"-89 EUR"`).
    let amount: String
    let isIncoming: Bool
    let status: Status
    /// Pre-formatted date label (e.g. `"Today"`, `"April 14th"`).
    let date: String

    var accessibilityLabel: String {
        let digits = amount
            .replacingOccurrences(of: "EUR", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "-", with: "")
            .trimmingCharacters(in: .whitespaces)
        let direction = isIncoming ? "from" : "to"
        return "\(status.statusText) payment of \(digits) euros \(direction) \(counterpartyName), \(date)"
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
