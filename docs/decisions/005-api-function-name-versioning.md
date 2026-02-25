# ADR-005: API Versioning via Function-Name Suffixes

> **Date:** 2026-02-13 (retroactive — formalized in `docs/API_VERSIONING.md`)
> **Status:** accepted
> **Deciders:** @ericsocrat

## Context

As the API surface grew to 109 functions, a versioning strategy became necessary. Three approaches were evaluated:

1. **URL-based versioning** (`/api/v1/products`, `/api/v2/products`) — standard for REST APIs but Supabase RPC calls go through a single `/rest/v1/rpc/{function_name}` endpoint. URL versioning doesn't apply naturally.
2. **Header-based versioning** (`Accept-Version: v2`) — requires custom middleware. Supabase doesn't natively support this.
3. **Function-name versioning** (`api_product_detail` → `api_v2_product_detail`) — works natively with Supabase RPC. No middleware needed. Old and new functions coexist in the database.

## Decision

Use **function-name suffixes** for API versioning:

- Current (unversioned) functions: `api_product_detail()`, `api_search_products()`
- Next version: `api_v2_product_detail()`, `api_v2_search_products()`
- All functions return `api_version` key in their response JSONB

**Deprecation policy:**
- Deprecated functions emit a `deprecated_at` field in response
- 90-day sunset window before removal
- CI enforces via `QA__api_contract.sql` that all active functions return `api_version`

**Breaking change definition:**
- Removing a response key
- Changing a response key's type
- Adding a required parameter without a default
- Changing function name without alias

## Consequences

### Positive

- **Zero middleware** — works natively with Supabase's RPC endpoint
- **Coexistence** — old and new versions run simultaneously in the same database
- **Client migration** — consumers can migrate at their own pace during the sunset window
- **CI-enforced** — `QA__api_contract.sql` (33 checks) validates versioning compliance

### Negative

- **Function proliferation** — a major version bump duplicates all `api_*` functions temporarily
- **No automatic routing** — clients must know the exact function name (no middleware to route `v1` → `v2`)
- **Naming convention burden** — developers must follow `api_v{N}_*` naming strictly

### Neutral

- Documented in `docs/API_VERSIONING.md` with deprecation timeline examples
- `docs/api-registry.yaml` tracks all 109 functions with version metadata
- Response shape contracts documented in `docs/API_CONTRACTS.md`
