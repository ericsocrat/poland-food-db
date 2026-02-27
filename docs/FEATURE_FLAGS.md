# Feature Flag Framework

> **Issue:** [#191 — Feature Flag Framework](https://github.com/ericsocrat/poland-food-db/issues/191)
> **Status:** Implemented
> **Migration:** `20260224000000_feature_flags.sql`

---

## Overview

The feature flag framework enables progressive rollout, country-based gating, percentage-based experiments, and instant kill switches — all without redeploying.

**Key capabilities:**
- Boolean flags (on/off)
- Percentage rollout (0-100%, deterministic per user)
- Country targeting (enable features per country)
- Role and environment targeting
- Multivariate flags (A/B/C variant assignment)
- Real-time updates via Supabase Realtime
- Automatic expiration + flag health monitoring
- Full audit trail for every flag change

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FEATURE FLAG FRAMEWORK                     │
│                                                               │
│  ┌──────────────┐  ┌───────────────────┐  ┌──────────────┐  │
│  │ Flag Store    │  │ Evaluation Engine  │  │ Admin RPCs   │  │
│  │ (Supabase)    │  │                    │  │              │  │
│  │               │  │ evaluateFlag()     │  │ toggle_flag  │  │
│  │ feature_flags │  │ - % rollout        │  │ set_rollout  │  │
│  │ flag_overrides│  │ - country match    │  │ flag_overview │  │
│  │ flag_audit_log│  │ - role check       │  │ health_report│  │
│  └───────┬──────┘  │ - env check        │  └──────────────┘  │
│          │         │ - expiration        │                     │
│          │         └──────────┬─────────┘                     │
│          │                    │                                │
│          ▼                    ▼                                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              CONSUMERS                                  │  │
│  │  ┌──────────┐  ┌───────────┐  ┌─────────────────────┐ │  │
│  │  │ API Route │  │ React Hook│  │ Server Component    │ │  │
│  │  │ /api/flags│  │ useFlag() │  │ getFlag()           │ │  │
│  │  │           │  │ <Feature> │  │                     │ │  │
│  │  └──────────┘  └───────────┘  └─────────────────────┘ │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### Client Components (React Hooks)

```tsx
import { useFlag, useFlagVariant, Feature } from "@/lib/flags";

// Hook-based check
function SearchPage() {
  const newSearch = useFlag("new_search_ui");
  return newSearch ? <NewSearch /> : <OldSearch />;
}

// Declarative gate component
function ProductPage() {
  return (
    <Feature flag="allergen_v2" fallback={<AllergenFilterV1 />}>
      <AllergenFilterV2 />
    </Feature>
  );
}

// Multivariate (A/B test)
function Dashboard() {
  const variant = useFlagVariant("dashboard_experiment");
  switch (variant) {
    case "treatment": return <NewDashboard />;
    default: return <OriginalDashboard />;
  }
}
```

### Server Components

```tsx
import { getFlag, getFlagVariant } from "@/lib/flags/server";

async function ServerPage() {
  const ctx = { country: "PL", environment: "production" };
  const showBeta = await getFlag("beta_feature", ctx);
  return showBeta ? <BetaFeature /> : <StandardFeature />;
}
```

### API Routes

```tsx
import { evaluateAllFlags } from "@/lib/flags/server";

export async function GET() {
  const ctx = { country: "PL", environment: "production" };
  const { flags } = await evaluateAllFlags(ctx);
  return NextResponse.json(flags);
}
```

---

## Database Tables

### `feature_flags`

| Column         | Type          | Description                                |
| -------------- | ------------- | ------------------------------------------ |
| `id`           | `SERIAL`      | Auto-incrementing PK                       |
| `key`          | `TEXT UNIQUE` | Machine-readable flag identifier           |
| `name`         | `TEXT`        | Human-readable display name                |
| `description`  | `TEXT`        | What this flag controls                    |
| `flag_type`    | `TEXT`        | `boolean`, `percentage`, or `variant`      |
| `enabled`      | `BOOLEAN`     | Master on/off switch                       |
| `percentage`   | `INT`         | Rollout percentage (0-100)                 |
| `countries`    | `TEXT[]`      | Country codes (empty = all)                |
| `roles`        | `TEXT[]`      | Role names (empty = all)                   |
| `environments` | `TEXT[]`      | Environment names (empty = all)            |
| `variants`     | `JSONB`       | `[{"name": "control", "weight": 50}, ...]` |
| `expires_at`   | `TIMESTAMPTZ` | Auto-disable after this date               |
| `tags`         | `TEXT[]`      | Grouping tags for organization             |
| `activation_criteria` | `JSONB` | Prerequisites to satisfy before enabling  |
| `activation_order`    | `INTEGER` | Recommended sequential activation order  |
| `depends_on`          | `TEXT[]` | Flag keys that must be enabled first      |

### `flag_overrides`

Per-user/session/country overrides that take priority over targeting rules.

| Column           | Type      | Description                                       |
| ---------------- | --------- | ------------------------------------------------- |
| `flag_key`       | `TEXT FK` | References `feature_flags(key)`                   |
| `target_type`    | `TEXT`    | `user`, `session`, or `country`                   |
| `target_value`   | `TEXT`    | User UUID, session ID, or country code            |
| `override_value` | `JSONB`   | `{"enabled": true}` or `{"variant": "treatment"}` |

### `flag_audit_log`

Immutable audit trail populated automatically by trigger.

---

## Flag Naming Convention

```
{domain}_{feature}_{version?}
```

Examples:
- `scoring_v4` — Scoring engine version 4
- `new_search_ui` — Redesigned search interface
- `de_country_launch` — Germany-specific features
- `allergen_v2` — Allergen filter version 2
- `maintenance_mode` — Ops: redirect all traffic
- `qa_mode` — Testing: suppress non-determinism

---

## Evaluation Rules

Flags are evaluated in this strict order:

1. **Not found** → `{enabled: false, source: "default"}`
2. **Expired** (past `expires_at`) → `{enabled: false, source: "expired"}`
3. **Kill switch** (`enabled = false`) → `{enabled: false, source: "kill"}`
4. **Override** (user/session/country) → override value, `source: "override"`
5. **Environment** mismatch → `{enabled: false, source: "rule"}`
6. **Country** mismatch → `{enabled: false, source: "rule"}`
7. **Role** mismatch → `{enabled: false, source: "rule"}`
8. **Percentage** rollout (deterministic hash) → may disable, `source: "rule"`
9. **Variant** assignment (for multivariate) → `{enabled: true, variant: "name"}`
10. **Default** → `{enabled: true, source: "rule"}`

### Deterministic Hashing

Percentage rollout uses FNV-1a hash of `{flagKey}:{userId}`, producing a value 0-99. The same user always gets the same bucket for the same flag, ensuring consistent experience across page reloads.

---

## Admin RPCs

### `admin_toggle_flag(p_key, p_enabled, p_reason)`

Toggle a flag on or off with an optional reason (logged to audit trail).

```sql
SELECT admin_toggle_flag('scoring_v4', true, 'Launching scoring v4 for all users');
```

### `admin_set_rollout(p_key, p_percentage)`

Set the rollout percentage for progressive rollout.

```sql
SELECT admin_set_rollout('new_search_ui', 25);  -- Enable for 25% of users
```

### `admin_flag_overview()`

List all flags with current status.

```sql
SELECT * FROM admin_flag_overview();
```

### `flag_health_report()`

Detect flags that need attention:
- **Stale**: >90 days old, no toggle in 60+ days
- **Graduate**: At 100% for 30+ days (should be hardcoded)
- **No expiry**: Missing `expires_at` after 14+ days

### `expire_stale_flags()`

Auto-disable flags past their `expires_at`. Returns count of expired flags.

---

## Flag Lifecycle

```
Created (disabled) ──► Enabled (% rollout) ──► 100% ──► Graduated (hardcoded + removed)
     │                       │                              │
     └── Deleted              └── Killed (emergency)        └── Permanent (ops flags)
```

### Emergency Kill Switch

To disable a broken feature in <30 seconds:

```sql
SELECT admin_toggle_flag('broken_feature', false, 'Emergency: causing 500 errors');
```

Changes propagate via Supabase Realtime within ~2 seconds.

---

## Seeded Flags

| Key                 | Type       | Purpose                            | Default  |
| ------------------- | ---------- | ---------------------------------- | -------- |
| `scoring_v4`        | boolean    | Scoring engine v4                  | disabled |
| `new_search_ui`     | percentage | New search interface               | disabled |
| `de_country_launch` | boolean    | Germany-specific features          | disabled |
| `allergen_v2`       | boolean    | Allergen filter v2                 | disabled |
| `maintenance_mode`  | boolean    | Maintenance mode redirect          | disabled |
| `qa_mode`           | boolean    | QA mode (suppress non-determinism) | disabled |

---

## Performance

| Operation                | Target | Approach                      |
| ------------------------ | ------ | ----------------------------- |
| Flag evaluation (cached) | <1ms   | In-memory map lookup          |
| Cache refresh            | <50ms  | Single SELECT on small table  |
| `/api/flags` response    | <20ms  | Cached + filtered evaluation  |
| Realtime propagation     | <2s    | Supabase channel subscription |

### Caching Strategy

- **Server**: 5s TTL in-memory cache (1 query fetches all flags)
- **Client**: React state via FlagProvider, refreshed via Supabase Realtime
- **API route**: 5s `Cache-Control: private, max-age=5`

---

## Activation Roadmap

> **Issue:** [#372 — Feature Flag Activation Roadmap](https://github.com/ericsocrat/poland-food-db/issues/372)
> **Migration:** `20260312000500_flag_activation_roadmap.sql`

All 8 flags shipped disabled. Each has documented activation criteria, a recommended order, and dependency tracking via `check_flag_readiness()`.

### Recommended Activation Order

| Order | Flag | Status | Criteria | Dependencies |
|-------|------|--------|----------|--------------|
| 1 | `qa_mode` | Ready | No prerequisites. Testing utility. | None |
| 2 | `de_country_launch` | Ready | DE enrichment ≥ 80%, 252 products available | None |
| 3 | `data_provenance_ui` | Ready | Source coverage ≥ 95% (currently ~96%) | None |
| 4 | `new_search_ranking` | Ready | Search synonyms ≥ 250 rows, DE synonyms ≥ 50 | None |
| 5 | `allergen_v2` | Ready | Allergen normalization complete (#351) | None |
| 6 | `new_search_ui` | Blocked | Validate new ranking for ≥ 14 days | `new_search_ranking` |
| 7 | `scoring_v4` | Ready | Shadow mode <5% drift, regression suite passes | None |
| — | `maintenance_mode` | Ready | Emergency only. Never scheduled. | None |

### Readiness Check

```sql
SELECT flag_key, status, days_until_expiry, dependencies_met
FROM check_flag_readiness();
```

Returns one row per flag with status: `ready`, `blocked`, `expired`, or `enabled`.

### Expiry Policy

- **30 days before expiry**: QA check warns if flag is still disabled
- **At expiry**: Consciously extend or remove flag + clean up dead code
- **Never**: Allow silent expiry with unreachable code paths

---

## Security

| Concern                 | Mitigation                                          |
| ----------------------- | --------------------------------------------------- |
| Client-side flag bypass | Server-side evaluation is authoritative             |
| Flag state tampering    | RLS: `service_role` only for write access           |
| Override abuse          | Audit trail + optional `expires_at` on overrides    |
| Flag enumeration        | `/api/flags` returns only evaluated boolean results |

---

## Testing

### Unit Tests (`evaluator.test.ts` — 34 tests)

- Boolean flag evaluation (enabled/disabled/undefined)
- Deterministic hash consistency and range
- Percentage rollout at 0%, 50%, 100%
- Country, environment, role targeting (match/mismatch/empty)
- Variant assignment (deterministic, weighted)
- Expiration handling (past/future/null)
- Evaluation priority order
- Override priority (user > session > country)

### React Hook Tests (`hooks.test.tsx` — 16 tests)

- `useFlag()` returns correct boolean
- `useFlagVariant()` returns variant name
- `useFlagsLoading()` reflects initialization state
- `Feature` component renders/hides based on flag
- `FlagProvider` Realtime subscription lifecycle
- Fetch behavior with/without `initialFlags`
