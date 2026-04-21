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
    private var itemsPerPage: Int = 0
    private let service: RemoteTransactionsService

    init(service: RemoteTransactionsService) {
        self.service = service
    }

    func load(itemsPerPage: Int) async {
        self.itemsPerPage = itemsPerPage
        do {
            let transactions = try await service.transactions(page: 1, itemsPerPage: itemsPerPage)
            let rows = makeRows(from: transactions)
            let content = State.Content(
                rows: rows,
                page: 1,
                canLoadMore: transactions.count == itemsPerPage
            )
            state = .loaded(content)
        } catch {
            // Error states not yet in scope — leave state as-is.
        }
    }

    /// Safe to call repeatedly — in-flight calls are ignored.
    func loadMore() async {
        guard
            case .loaded(let content) = state,
            content.canLoadMore,
            !isLoadingMore
        else { return }

        isLoadingMore = true
        await performLoadMore()
        isLoadingMore = false
    }

    private func performLoadMore() async {
        guard case .loaded(var content) = state else { return }

        let nextPage = content.page + 1

        do {
            let transactions = try await service.transactions(page: nextPage, itemsPerPage: itemsPerPage)
            let newRows = makeRows(from: transactions)
            content.rows.append(contentsOf: newRows)
            content.page = nextPage
            content.canLoadMore = transactions.count == itemsPerPage
            state = .loaded(content)
        } catch {
            // Error states not yet in scope — leave state as-is.
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
