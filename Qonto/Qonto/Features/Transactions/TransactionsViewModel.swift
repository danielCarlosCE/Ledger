//
//  TransactionsViewModel.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import Foundation

@Observable
final class TransactionsViewModel {
    enum State: Sendable {
        case loading
        case loaded([TransactionRow])
    }

    private(set) var state: State = .loading

    func load() async {
        try? await Task.sleep(for: .seconds(1.5))
        state = .loaded(Self.makeMockRows(count: 20))
    }

    // MARK: - Mock generation

    private static let names = [
        "Daniel Souza", "Amazon", "Spotify", "Uber",
        "Salary", "Netflix", "Apple", "Rent"
    ]

    private static let dates = [
        "Today", "Yesterday", "April 14th", "April 1st",
        "March 28th", "March 15th", "March 1st"
    ]

    private static let statuses: [TransactionRow.Status] = [
        .completed, .completed, .completed, .pending, .declined
    ]

    private static func makeMockRows(count: Int) -> [TransactionRow] {
        (0..<count).map { index in
            let name = names[index % names.count]
            let status = statuses[index % statuses.count]
            let date = dates[index % dates.count]
            let isIncoming = (index % 3 == 0)
            let magnitude = (index + 1) * 12
            let sign = isIncoming ? "+" : "-"
            let amount = "\(sign)\(magnitude) EUR"
            return TransactionRow(
                id: "mock-\(index)",
                counterpartyName: name,
                amount: amount,
                isIncoming: isIncoming,
                status: status,
                date: date
            )
        }
    }
}
