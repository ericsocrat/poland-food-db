# Security

## Known Vulnerabilities

Last audited: 2026-02-14

### Summary

| Package               | Severity | Advisory                                        | Status         |
| --------------------- | -------- | ----------------------------------------------- | -------------- |
| `next` 14.2.35        | High     | [GHSA-9g9p-9gw9-jx7f][1] (Image Optimizer DoS) | Accepted risk  |
| `next` 14.2.35        | High     | [GHSA-h25m-26qc-wcjf][2] (RSC deserialization)  | Accepted risk  |
| `glob` 10.3.10        | High     | [GHSA-5j98-mcp5-4vw2][3] (CLI injection)        | Accepted risk  |
| `@next/eslint-plugin` | High     | Transitive via `glob`                            | Accepted risk  |

[1]: https://github.com/advisories/GHSA-9g9p-9gw9-jx7f
[2]: https://github.com/advisories/GHSA-h25m-26qc-wcjf
[3]: https://github.com/advisories/GHSA-5j98-mcp5-4vw2

### Risk Assessment

**GHSA-9g9p-9gw9-jx7f — Image Optimizer DoS:**
- Affects self-hosted Next.js with `remotePatterns` in image config.
- We deploy on Vercel (managed infrastructure), not self-hosted.
- Our `next.config.js` does not configure `remotePatterns`.
- **Not practically exploitable in this deployment.**

**GHSA-h25m-26qc-wcjf — RSC deserialization DoS:**
- Requires "insecure React Server Components" usage patterns.
- Our RSC usage is standard (data fetching via Supabase client).
- Vercel's infrastructure provides additional request-level protections.
- **Low practical risk.** Will be resolved on Next.js 15/16 upgrade.

**GHSA-5j98-mcp5-4vw2 — glob CLI injection:**
- The `glob` CLI (`--cmd` flag) allows command injection.
- This is a **dev/build-time dependency** (via `eslint-config-next`).
- Never exposed to user input at runtime.
- **Not exploitable** — only runs during development/CI builds with trusted input.

### Remediation Plan

All vulnerabilities require upgrading to Next.js 16.x (a major breaking change). Plan:
1. **Current (v14.2.35):** Accept risk — vulnerabilities are not practically exploitable in our deployment model.
2. **Next milestone:** Evaluate Next.js 15.x upgrade when the app's feature set stabilizes.
3. **Long-term:** Upgrade to Next.js 16.x when the ecosystem (React 19, testing tools) is mature.

### Application Security Measures

- **Row Level Security (RLS):** All Supabase tables have RLS enabled.
- **SECURITY DEFINER functions:** All 10 API RPCs use `SECURITY DEFINER` with `anon_can_execute = false`.
- **Auth middleware:** All `/app/*` routes require authenticated sessions.
- **Open redirect prevention:** Login redirect param validated (relative paths only, no `//` prefix).
- **No hardcoded secrets:** All credentials via environment variables.
