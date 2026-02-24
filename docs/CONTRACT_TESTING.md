# Contract Testing

> Issue #179 — Schema-to-UI Contract Validation (Quality Gate 9/9)

## Why

Backend migration changes a column name → the frontend receives malformed data → blank screens, wrong values, silent corruption. Contract tests catch this **in CI before merge**.

Example: A migration renames `product_name` to `name`. The frontend's product detail page renders a blank title. Nobody notices until a user reports it. With contract tests, CI fails instantly.

## How It Works

1. **Zod schemas** define the expected shape of every RPC response
2. **Unit tests** validate schemas against mock data (no Supabase needed)
3. **Integration tests** call real RPCs on staging and validate responses
4. **CI** (`api-contract.yml`) runs both suites on every PR that touches migrations or contracts
5. **Failures block merge** — contract violations must be resolved before deployment

```
Backend Migration
    ↓
CI: api-contract.yml triggers
    ↓
Zod safeParse(rpc_response) → FAIL
    ↓
PR blocked, developer notified
    ↓
Fix migration OR update schema + frontend
```

## Architecture

```
src/lib/rpc-contracts/
├── index.ts                         # Barrel re-export
├── helpers.ts                       # Shared enums (ScoreBand, NutriGrade, etc.)
├── product.contracts.ts             # api_product_detail, api_better_alternatives,
│                                    # api_score_explanation, api_data_confidence
├── search.contracts.ts              # api_search_products, api_search_autocomplete,
│                                    # api_get_filter_options, api_get_saved_searches
├── category.contracts.ts            # api_category_overview, api_category_listing
├── dashboard.contracts.ts           # api_get_dashboard_data, api_get_recently_viewed
├── health-profile.contracts.ts      # api_list_health_profiles,
│                                    # api_get_active_health_profile,
│                                    # api_product_health_warnings
├── lists.contracts.ts               # api_get_lists, api_get_list_items
├── compare.contracts.ts             # api_get_products_for_compare
├── scan.contracts.ts                # api_get_scan_history
├── user.contracts.ts                # api_get_user_preferences
└── __tests__/
    ├── contracts.integration.test.ts  # Live RPC validation (INTEGRATION=1)
    └── schema-validation.test.ts      # Pure unit tests (always runs)
```

## RPC Coverage Matrix

| Priority | RPC                             | Schema File                   | Contract                      |
| -------- | ------------------------------- | ----------------------------- | ----------------------------- |
| P0       | `api_product_detail`            | `product.contracts.ts`        | `ProductDetailContract`       |
| P0       | `api_better_alternatives`       | `product.contracts.ts`        | `BetterAlternativesContract`  |
| P0       | `api_score_explanation`         | `product.contracts.ts`        | `ScoreExplanationContract`    |
| P0       | `api_data_confidence`           | `product.contracts.ts`        | `DataConfidenceContract`      |
| P0       | `api_search_products`           | `search.contracts.ts`         | `SearchProductsContract`      |
| P0       | `api_search_autocomplete`       | `search.contracts.ts`         | `SearchAutocompleteContract`  |
| P0       | `api_category_overview`         | `category.contracts.ts`       | `CategoryOverviewContract`    |
| P0       | `api_category_listing`          | `category.contracts.ts`       | `CategoryListingContract`     |
| P0       | `api_get_dashboard_data`        | `dashboard.contracts.ts`      | `DashboardDataContract`       |
| P0       | `api_product_health_warnings`   | `health-profile.contracts.ts` | `HealthWarningsContract`      |
| P1       | `api_get_filter_options`        | `search.contracts.ts`         | `FilterOptionsContract`       |
| P1       | `api_get_saved_searches`        | `search.contracts.ts`         | `SavedSearchesContract`       |
| P1       | `api_get_lists`                 | `lists.contracts.ts`          | `ListsContract`               |
| P1       | `api_get_list_items`            | `lists.contracts.ts`          | `ListItemsContract`           |
| P1       | `api_get_products_for_compare`  | `compare.contracts.ts`        | `CompareContract`             |
| P1       | `api_list_health_profiles`      | `health-profile.contracts.ts` | `HealthProfileListContract`   |
| P1       | `api_get_active_health_profile` | `health-profile.contracts.ts` | `HealthProfileActiveContract` |
| P1       | `api_get_user_preferences`      | `user.contracts.ts`           | `UserPreferencesContract`     |
| P1       | `api_get_scan_history`          | `scan.contracts.ts`           | `ScanHistoryContract`         |
| P1       | `api_get_recently_viewed`       | `dashboard.contracts.ts`      | `RecentlyViewedContract`      |

**Total: 20 RPCs** (10 P0 + 10 P1) — exceeds the 19-endpoint minimum.

## Running Tests

### Unit tests (always, no Supabase needed)

```bash
cd frontend && npx vitest run schema-validation
```

### Integration tests (requires live Supabase)

```bash
cd frontend && INTEGRATION=1 npx vitest run rpc-contracts
```

### All contract tests (unit + integration)

```bash
cd frontend && INTEGRATION=1 npx vitest run rpc-contract
```

### CI

The **API Contract Guard** workflow (`.github/workflows/api-contract.yml`) runs automatically on:
- PRs touching `supabase/migrations/**`, `db/**`, or `frontend/src/lib/rpc-contract*`
- Every push to `main`
- Nightly at 03:00 UTC (drift detection)
- Manual dispatch

## Adding a New Contract

### 1. Define the schema

Create or extend a file in `src/lib/rpc-contracts/`:

```typescript
// src/lib/rpc-contracts/myfeature.contracts.ts
import { z } from "zod";

export const MyFeatureContract = z
  .object({
    api_version: z.string(),
    my_field: z.number(),
    optional_field: z.string().nullable(),
  })
  .passthrough(); // Allow extra fields initially
```

### 2. Export from index

```typescript
// src/lib/rpc-contracts/index.ts
export { MyFeatureContract } from "./myfeature.contracts";
```

### 3. Add unit test

In `__tests__/schema-validation.test.ts`, add a valid-data and missing-key test case.

### 4. Add integration test

In `__tests__/contracts.integration.test.ts`:

```typescript
describeIntegration("Contract: api_my_feature", () => {
  it("returns valid shape", async () => {
    const { data, error } = await supabase.rpc("api_my_feature", { ... });
    expect(error).toBeNull();
    assertContract("api_my_feature", data, MyFeatureContract);
  });
});
```

### 5. Run locally

```bash
cd frontend && INTEGRATION=1 npx vitest run rpc-contract
```

## Schema Strategy

| Phase       | Approach                                          | When                        |
| ----------- | ------------------------------------------------- | --------------------------- |
| **Initial** | `.passthrough()` on all objects                   | Now (Issue #179)            |
| **Tighten** | Remove `.passthrough()` → `.strict()` per domain  | When domain stabilizes      |
| **Lock**    | Remove `.nullable()` where data is always present | After production data audit |

### Rules

- **Required fields must never become nullable** without updating the schema first
- **New fields** are automatically allowed by `.passthrough()` — no schema update needed
- **Renamed fields** will cause test failure — this is the primary protection mechanism
- **Type changes** (e.g., `number` → `string`) will cause test failure

## Relationship to TypeScript Types

The Zod schemas in `rpc-contracts/` mirror the TypeScript interfaces in `types.ts`. They are **not** generated from the TS types — they are independent validation contracts. This intentional duplication provides:

1. **Runtime validation** (Zod) vs compile-time checking (TypeScript)
2. **CI enforcement** — TypeScript won't catch a backend column rename
3. **Documentation** — schemas serve as machine-readable API documentation

If a TypeScript type changes, the corresponding Zod schema should be updated to match.

## Troubleshooting

### "Contract violation" in CI

1. Read the error output — it shows exactly which field failed and why
2. Check recent migrations for column renames, type changes, or removed fields
3. Either fix the migration or update the Zod schema + frontend code
4. Run `INTEGRATION=1 npx vitest run rpc-contract` locally to verify

### Auth-required RPCs return errors

Integration tests for auth-required RPCs (e.g., `api_get_lists`, `api_get_user_preferences`) gracefully skip when the service-role key cannot satisfy `auth.uid()` checks. These tests validate shapes when data is returned, and skip otherwise.

### Schema drift between environments

The nightly schedule in `api-contract.yml` detects drift from manual DB changes. If nightly tests fail but PRs pass, someone modified the database outside of migrations.
