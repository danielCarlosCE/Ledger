# Ledger

Small iOS sample: a paginated transactions list with offline caching.

## What's inside

- Paginated list with infinite scroll
- Inline retry on failed load-more
- Full-screen error states (offline / general) with a retry action
- Core Data cache: successful loads wipe + save; offline falls back to cached rows
- "Reconnect" toolbar action when viewing cached data
- VoiceOver-friendly row read-out (single sentence per row)

## Architecture

MVVM with protocol-fronted services. Generic `ApiClient` and `StorageClient` primitives at the app level so feature services don't re-implement transport or persistence plumbing.

```
Ledger/
├─ Networking/       ApiClient, Route<Response>, HTTPMethod              (generic HTTP)
├─ Persistence/      PersistenceController, StorageClient, Persistable   (generic Core Data)
└─ Features/Transactions/
   ├─ Models/              Transaction (domain)
   ├─ Services/            Remote + Local service protocols + impls
   ├─ ViewModels/          TransactionsViewModel
   └─ Views/               TransactionsListView, TransactionRowView
```

## Setup

The app needs a backend base URL at build time. Set it in your shell:

    export LEDGER_API_BASE_URL=https://your-backend.here

Or create a `.env` file at the repo root (gitignored):

    LEDGER_API_BASE_URL=https://your-backend.here

A build-phase script generates `Ledger/Config.generated.swift` from this value. The generated file is gitignored; the secret never hits the repo. If the value is unset, the build fails with a clear message.

## Backend contract

The app expects a single endpoint:

    GET /transactions?page={int}&results={int}&seed={string}

Response:

    {
      "results": [Transaction, …],
      "info": { "seed": String }
    }

Where each `Transaction` looks like:

    {
      "id": String,
      "counterpartyName": String,
      "amount": { "currency": String, "value": String },
      "status": "COMPLETED" | "PENDING" | "DECLINED",
      "side": "CREDIT" | "DEBIT",
      "settledAt": ISO8601 String (nullable, e.g. "2025-06-15T10:30:45.000Z")
    }

The `seed` returned on the first request is reused on subsequent requests to keep pagination deterministic — useful for mock backends.

## About this repo

This repo is a working sample of AI-assisted iOS development. Every change landed via an orchestration layer where focused tasks were delegated to sub-agents and the final decisions — naming, scope, architecture, what to cut — stayed with the human.
