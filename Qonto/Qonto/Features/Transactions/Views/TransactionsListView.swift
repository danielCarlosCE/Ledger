//
//  TransactionsListView.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

struct TransactionsListView: View {
    @State private var viewModel: TransactionsViewModel

    init(viewModel: TransactionsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Transactions")
        }
        .task {
            await viewModel.load(itemsPerPage: 20)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView() {
                Text("loading...")
            }
        case .loaded(let content):
            List {
                ForEach(content.rows) { row in
                    TransactionRowView(row: row)
                }

                if content.canLoadMore {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .listRowSeparator(.hidden)
                        .accessibilityLabel("Loading more transactions")
                        // ProgressView in List freezes after reattach; new id per page forces a fresh instance.
                        .id(content.page)
                        .onAppear {
                            Task { await viewModel.loadMore() }
                        }
                }
            }
            .listStyle(.plain)
        case .error(let kind):
            ContentUnavailableView {
                Label(kind.title, systemImage: icon(for: kind))
            } description: {
                Text(kind.message)
            } actions: {
                Button("Try again") {
                    Task { await viewModel.load(itemsPerPage: 20) }
                }
            }
        }
    }

    private func icon(for kind: TransactionsViewModel.ErrorKind) -> String {
        switch kind {
        case .offline: "wifi.slash"
        case .general: "exclamationmark.triangle"
        }
    }
}

#Preview("Success") {
    TransactionsListView(viewModel: TransactionsViewModel(service: StubRemoteTransactionsService(.success)))
}

#Preview("Offline") {
    TransactionsListView(viewModel: TransactionsViewModel(service: StubRemoteTransactionsService(.failure(.offline))))
}

#Preview("General Error") {
    TransactionsListView(viewModel: TransactionsViewModel(service: StubRemoteTransactionsService(.failure(.general(NSError())))))
}

#Preview("Loading") {
    TransactionsListView(viewModel: TransactionsViewModel(service: StubRemoteTransactionsService(.loading)))
}
