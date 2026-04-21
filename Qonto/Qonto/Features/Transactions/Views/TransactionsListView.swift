//
//  TransactionsListView.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

struct TransactionsListView: View {
    @State private var viewModel = TransactionsViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Transactions")
        }
        .task {
            await viewModel.load()
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
                            viewModel.loadMore()
                        }
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    TransactionsListView()
}
