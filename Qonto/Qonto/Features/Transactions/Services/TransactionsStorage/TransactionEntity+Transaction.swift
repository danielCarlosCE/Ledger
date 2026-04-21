//
//  TransactionEntity+Transaction.swift
//  Qonto
//
//  Created by Daniel Souza on 21.04.26.
//

import CoreData

extension TransactionEntity {
    convenience init(context: NSManagedObjectContext, transaction: Transaction) {
        self.init(context: context)
        self.id = transaction.id
        self.counterpartyName = transaction.counterparty
        self.amountCurrency = transaction.amount.currency
        self.amountValue = transaction.amount.value
        self.statusRaw = transaction.status.rawValue
        self.sideRaw = transaction.side.rawValue
        self.settledAt = transaction.settledAt
    }
}

extension Transaction: Persistable {
    @MainActor public func makeEntity(in context: NSManagedObjectContext) -> TransactionEntity {
        TransactionEntity(context: context, transaction: self)
    }
}

extension Transaction {
    init?(entity: TransactionEntity) {
        guard
            let id = entity.id,
            let counterpartyName = entity.counterpartyName,
            let amountCurrency = entity.amountCurrency,
            let amountValue = entity.amountValue,
            let statusRaw = entity.statusRaw, let status = Transaction.Status(rawValue: statusRaw),
            let sideRaw = entity.sideRaw, let side = Transaction.Side(rawValue: sideRaw)
        else { return nil }
        self.init(
            id: id,
            counterparty: counterpartyName,
            amount: .init(currency: amountCurrency, value: amountValue),
            status: status,
            side: side,
            settledAt: entity.settledAt
        )
    }
}
