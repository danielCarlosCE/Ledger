//
//  LedgerApp.swift
//  Ledger
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

@main
struct LedgerApp: App {
    var body: some Scene {
        WindowGroup {
            TransactionsListView(
                viewModel: TransactionsViewModel()
            )
        }
    }
}
