//
//  TransactionsViewModel.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import Foundation

@Observable
final class TransactionsViewModel {
    enum State {
        case loading
        case loaded(Content)

        struct Content {
            var rows: [TransactionRow]
            var page: Int
            var canLoadMore: Bool
        }
    }

    private(set) var state: State = .loading

    private var isLoadingMore = false

    func load() async {
        try? await Task.sleep(for: .seconds(1.5))
        let content = State.Content(
            rows: Self.makeMockRows(page: 0),
            page: 0,
            canLoadMore: true
        )
        state = .loaded(content)
    }

    /// Safe to call repeatedly — in-flight calls are ignored.
    func loadMore() {
        guard
            case .loaded(let content) = state,
            content.canLoadMore,
            !isLoadingMore
        else { return }

        isLoadingMore = true
        Task {
            await performLoadMore()
            isLoadingMore = false
        }
    }

    private func performLoadMore() async {
        guard case .loaded(var content) = state else { return }

        try? await Task.sleep(for: .seconds(1.5))

        let nextPage = content.page + 1
        let newRows = Self.makeMockRows(page: nextPage)
        content.rows.append(contentsOf: newRows)
        content.page = nextPage
        content.canLoadMore = nextPage < Self.lastPage
        state = .loaded(content)
    }

    // MARK: - Mock generation

    /// Pages 0...lastPage load; after that `canLoadMore` becomes false.
    private static let lastPage = 4
    private static let rowsPerPage = 20

    private static let names = [
        "Daniel Souza", "Amazon", "Spotify", "Uber",
        "Salary", "Netflix", "Apple", "Rent"
    ]

    private static let statuses: [TransactionRow.Status] = [
        .completed, .completed, .completed, .pending, .declined
    ]

    private static let datesByPage: [[String]] = [
        ["Today", "Yesterday"],
        ["April 14th", "April 10th", "April 7th"],
        ["March 28th", "March 22nd", "March 15th"],
        ["February 20th", "February 10th", "February 3rd"],
        ["January 25th", "January 12th", "January 4th"]
    ]

    private static func makeMockRows(page: Int) -> [TransactionRow] {
        let dates = datesByPage[min(page, datesByPage.count - 1)]
        return (0..<rowsPerPage).map { index in
            let name = names[(index + page) % names.count]
            let status = statuses[index % statuses.count]
            let date = dates[index % dates.count]
            let isIncoming = ((index + page) % 3 == 0)
            let magnitude = (index + 1) * 12 + page * 7
            let sign = isIncoming ? "+" : "-"
            let amount = "\(sign)\(magnitude) EUR"
            return TransactionRow(
                id: "p\(page)-\(index)",
                counterpartyName: name,
                amount: amount,
                isIncoming: isIncoming,
                status: status,
                date: date
            )
        }
    }
}
