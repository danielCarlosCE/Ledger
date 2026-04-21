# Presentation Notes

## Context

I spent around 7–8 hours across two days. My first attempt I got mentally blocked — being evaluated isn't my best headspace, and I stopped and came back fresh the next day, which is when the work actually got done.

I took the time to deliver a product I'd be happy to open as a PR for colleagues to review — weighing scope and user flow over finishing quickly.

## Note on AI

I leveraged AI end-to-end for code generation — every edit in this repo went through an orchestration layer where I delegated focused tasks to sub-agents and kept the decisions in my hands.

**What I used AI for**
- Code generation across the whole stack (VM, services, views, tests).
- Research (Core Data + Swift 6 concurrency, the ProgressView-in-List freeze quirk, ISO8601 fractional seconds).
- Architectural discussions — I instructed a "senior iOS architect" agent to challenge my proposals and push back on my ideas.
- Large mechanical refactors (renames, folder moves, access-level changes).

**What I chose not to delegate**
- Scope: what each step covers, what's explicitly out.
- Final naming calls (pushed back when suggestions leaked implementation — e.g. `isShowingCache` → `canReconnect`; insisted on the backend's `side` over a "clearer" `direction`).
- Trade-offs: when to accept a bug, when to work around, when to refactor.

**How I prompted**
- Gave enough context for the agent to make judgement calls, not step-by-step instructions.
- Asked for alternatives before implementation when options weren't obvious.
- Treated research separately from implementation: "check the docs, come back with findings, then we decide."

**How I challenged / iterated**
- Rejected a `TimelineView`-based custom spinner as "too much complexity and wrong things to invest time on" — kept a minimal documented `.id` workaround.
- Reverted a `direction` rename back to `side` after recognizing the backend's bookkeeping term was actually correct.
- Removed a dedupe mechanism I'd asked for when the implementation got clever; accepted occasional duplicates instead.
- Caught a fabricated query-param name (`per_page`) when the docs clearly said `results`. Verified against the actual staging response.

## Architecture

Three layers, sibling at app level:

```
Qonto/
├─ Networking/       ApiClient, Route<Response>, HTTPMethod              (generic HTTP)
├─ Persistence/      PersistenceController, StorageClient, Persistable   (generic Core Data)
└─ Features/Transactions/
   ├─ Models/              Transaction (domain)
   ├─ Services/
   │  ├─ RemoteTransactionsService    (protocol)
   │  ├─ LocalTransactionsService     (protocol)
   │  ├─ TransactionsAPI/             (Default remote impl)
   │  ├─ TransactionsStorage/         (Default local impl + entity mapping)
   │  └─ Previews/                    (Stub — stripped from Release)
   ├─ ViewModels/          TransactionsViewModel, TransactionRow
   └─ Views/               TransactionsListView, TransactionRowView
```

- `TransactionsViewModel` depends on two protocols (`remote`, `local`) — trivially swappable for tests and previews.
- Internal `DataSource` enum tracks whether the visible list came from remote or local; `loadMore` branches on it.
- Offline falls back to the local cache; a "Reconnect" toolbar button appears so the user can retry the network on demand.
- Generic primitives (`ApiClient.fetch<Response>(Route<Response>)`, `StorageClient.fetch<Entity, Value>(...)`) mean future features don't rewrite transport or persistence plumbing.

## Good Practices

- **SRP** — each service owns one narrow concern.
- **DIP** — VM depends on protocols, not concrete Core Data / URLSession types.
- **OCP** — generic clients extend via type parameters, not modification.
- **KISS** — many iterations removed premature complexity (dedupe, typed errors, custom spinner, an `isLoading` flag — added then dropped when the simpler shape worked).
- **DRY** — `setFirstPage`, `appendNextPage`, `refreshCache` extracted so `load` / `loadMore` read as intent, not plumbing.
- **Testability** — small protocols, mocks under `QontoTests/Mocks/`, shared `sut` built in `init()`.

## Development Strategy

**Layer order:** UI-first with hardcoded strings → VM with stub service → real networking → Core Data persistence → cache fallback + reconnect UX → polish.

Seeing the UI shape early disciplined what the VM actually needed to expose. Integration work came once the state machine was stable.

**Commits** — each a focused unit:

1. `Add paginated transactions with infinite scroll`
2. `Introduce RemoteTransactionsService protocol`
3. `Load transactions from real service`
4. `Add unit test coverage for transactions`
5. `Handle load-more errors with inline retry`
6. `Add Core Data persistence for transactions`
7. `Make transactions cache-aware with remote/local fallback`
8. `Add reconnect action when reading from cache`

## Future-Proofness

- Protocol boundaries + generic clients mean SPM extraction is mechanical, not a rewrite.
- New backend endpoint: add a `Route` factory + a service method.
- New storage entity: conform to `Persistable`, get `save` / `fetch` / `deleteAll` for free.
- MainActor-by-default keeps the concurrency surface small now; moving off-main is opt-in when it actually pays off.

## Retro

1. **Time:** More than 6h — specifically 7–8h across two days.
2. **Pride:** Quite proud. Nothing architecturally complex here, but I'd happily open this as a PR for colleagues to review.
3. **Missing from the test / what I'd reconsider:**
   Setting up Core Data from scratch for a project of this size doesn't reveal much signal on its own — most of the setup is boilerplate, and the interesting decisions (store choice, migration strategy, cache invalidation, context threading) only emerge at real scale. A live conversation would surface more than the code itself. Replacing it with a lighter storage primitive (in-memory cache, GRDB, or a JSON-disk cache) would keep the test focused on architecture without losing signal.
