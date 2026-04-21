//
//  TransactionsViewModel.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import Foundation

@Observable
final class TransactionsViewModel {

    private(set) var state: State = .idle

    private var itemsPerPage: Int = 0
    private var isLoadingMore: Bool = false
    private let service: RemoteTransactionsService

    init(service: RemoteTransactionsService) {
        self.service = service
    }

    func load(itemsPerPage: Int) async {
        if case .loading = state { return }
        self.itemsPerPage = itemsPerPage
        state = .loading
        do {
            let transactions = try await service.transactions(page: 1, itemsPerPage: itemsPerPage)
            let rows = makeRows(from: transactions)
            let content = State.Content(
                rows: rows,
                page: 1,
                loadMoreState: transactions.count == itemsPerPage ? .hasMore : .ended
            )
            state = .loaded(content)
        } catch {
            switch error {
            case .offline:
                state = .error(.offline)
            case .general:
                state = .error(.general)
            }
        }
    }

    /// Safe to call repeatedly — in-flight calls are ignored. Allows retry after an error.
    func loadMore() async {
        guard
            case .loaded(var content) = state,
            !isLoadingMore,
            content.loadMoreState != .ended
        else {
            return
        }

        isLoadingMore = true
        defer { isLoadingMore = false }
        
        content.loadMoreState = .hasMore
        state = .loaded(content)

        do {
            let transactions = try await service.transactions(page: content.page + 1, itemsPerPage: itemsPerPage)
            guard case .loaded(var updated) = state else { return }
            let newRows = makeRows(from: transactions)
            updated.rows.append(contentsOf: newRows)
            updated.page += 1
            updated.loadMoreState = (transactions.count == itemsPerPage) ? .hasMore : .ended
            state = .loaded(updated)
        } catch {
            guard case .loaded(var updated) = state else { return }
            switch error {
            case .offline:
                updated.loadMoreState = .error(.offline)
            case .general:
                updated.loadMoreState = .error(.general)
            }
            state = .loaded(updated)
        }
    }

    // MARK: - Domain → UI mapping

    private func makeRows(from transactions: [Transaction]) -> [TransactionRow] {
        transactions.map { transaction in
            TransactionRow(
                id: transaction.id,
                counterparty: transaction.counterparty,
                amount: formatAmount(transaction.amount, side: transaction.side),
                isIncoming: transaction.side == .credit,
                status: rowStatus(from: transaction.status),
                date: humanReadableDate(for: transaction.settledAt)
            )
        }
    }

    private func formatAmount(_ amount: Transaction.Amount, side: Transaction.Side) -> String {
        let sign = side == .credit ? "+" : "-"
        return "\(sign)\(amount.value) \(amount.currency)"
    }

    private func rowStatus(from status: Transaction.Status) -> TransactionRow.Status {
        switch status {
        case .completed: .completed
        case .pending: .pending
        case .declined: .declined
        }
    }

    private func humanReadableDate(for date: Date?) -> String? {
        guard let date else { return nil }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

extension TransactionsViewModel {

    // MARK: - Types

    enum State {
        case idle
        case loading
        case loaded(Content)
        case error(ErrorKind)

        struct Content {
            var rows: [TransactionRow]
            var page: Int
            var loadMoreState: LoadMoreState = .hasMore
        }
    }

    enum LoadMoreState: Equatable {
        case hasMore
        case error(ErrorKind)
        case ended
    }

    enum ErrorKind: Equatable {
        case offline
        case general

        var title: String {
            switch self {
            case .offline: "You're offline"
            case .general: "Something went wrong"
            }
        }

        var message: String {
            switch self {
            case .offline: "Check your connection and try again."
            case .general: "Please try again in a moment."
            }
        }
    }
}
