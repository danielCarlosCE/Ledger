//
//  QontoApp.swift
//  Qonto
//
//  Created by Daniel Souza on 20.04.26.
//

import SwiftUI

@main
struct QontoApp: App {
    private let remoteService = DefaultRemoteTransactionsService()

    var body: some Scene {
        WindowGroup {
            TransactionsListView(
                viewModel: TransactionsViewModel(service: remoteService)
            )
        }
    }
}
