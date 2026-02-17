# Design System Foundation

> **Issue**: #57 · **Status**: Active · **Last updated**: 2026-02-17

This document defines the design token vocabulary for the poland-food-db frontend. All visual properties (colors, spacing, typography, elevation, radii, transitions) are codified as CSS custom properties in `src/styles/globals.css` and mapped to Tailwind CSS utility classes via `tailwind.config.ts`.

---

## Core Principles

| Principle                   | Description                                                                                              |
| --------------------------- | -------------------------------------------------------------------------------------------------------- |
| **Single source of truth**  | All values defined as CSS custom properties in `globals.css`. No hardcoded hex/rgb values in components. |
| **Semantic naming**         | Tokens named by purpose, not value: `--color-surface` not `--color-white`.                               |
| **Contrast compliance**     | Every foreground/background pair meets WCAG AA (≥4.5:1 normal text, ≥3:1 large text).                    |
| **Backward compatibility**  | Existing `brand-*` and `nutri-*` Tailwind classes continue to work.                                      |
| **No runtime dependencies** | Tokens are pure CSS — zero JavaScript at runtime.                                                        |
| **Theme-ready**             | Dark mode via `[data-theme="dark"]` attribute swap with system preference fallback.                      |

---

## Token Reference

### Surface & Background

| Token                     | Light             | Dark              | Tailwind Class       |
| ------------------------- | ----------------- | ----------------- | -------------------- |
| `--color-surface`         | `#ffffff`         | `#111827`         | `bg-surface`         |
| `--color-surface-subtle`  | `#f9fafb`         | `#1f2937`         | `bg-surface-subtle`  |
| `--color-surface-muted`   | `#f3f4f6`         | `#374151`         | `bg-surface-muted`   |
| `--color-surface-overlay` | `rgba(0,0,0,0.5)` | `rgba(0,0,0,0.7)` | `bg-surface-overlay` |

### Text / Foreground

| Token                    | Light     | Dark      | Tailwind Class              |
| ------------------------ | --------- | --------- | --------------------------- |
| `--color-text-primary`   | `#111827` | `#f9fafb` | `text-foreground`           |
| `--color-text-secondary` | `#6b7280` | `#d1d5db` | `text-foreground-secondary` |
| `--color-text-muted`     | `#9ca3af` | `#9ca3af` | `text-foreground-muted`     |
| `--color-text-inverse`   | `#ffffff` | `#111827` | `text-foreground-inverse`   |

### Border & Divider

| Token                   | Light     | Dark      | Tailwind Class     |
| ----------------------- | --------- | --------- | ------------------ |
| `--color-border`        | `#e5e7eb` | `#374151` | `border` (DEFAULT) |
| `--color-border-strong` | `#d1d5db` | `#4b5563` | `border-strong`    |

### Brand (Primary Action)

| Token                  | Light     | Dark      | Tailwind Class           |
| ---------------------- | --------- | --------- | ------------------------ |
| `--color-brand`        | `#16a34a` | `#22c55e` | `bg-brand`, `text-brand` |
| `--color-brand-hover`  | `#15803d` | `#16a34a` | `bg-brand-hover`         |
| `--color-brand-subtle` | `#dcfce7` | `#14532d` | `bg-brand-subtle`        |

> **Note**: The full `brand-50` through `brand-900` palette is preserved for backward compatibility.

### Health Score Bands

| Token                   | Light     | Dark      | Tailwind Class                           | Score Range |
| ----------------------- | --------- | --------- | ---------------------------------------- | ----------- |
| `--color-score-green`   | `#22c55e` | `#4ade80` | `bg-score-green`, `text-score-green`     | 1–20        |
| `--color-score-yellow`  | `#eab308` | `#facc15` | `bg-score-yellow`, `text-score-yellow`   | 21–40       |
| `--color-score-orange`  | `#f97316` | `#fb923c` | `bg-score-orange`, `text-score-orange`   | 41–60       |
| `--color-score-red`     | `#ef4444` | `#f87171` | `bg-score-red`, `text-score-red`         | 61–80       |
| `--color-score-darkred` | `#991b1b` | `#dc2626` | `bg-score-darkred`, `text-score-darkred` | 81–100      |

> **Invariant**: Score band colors use the same hues in both themes — only brightness/contrast is adjusted. Users learn the color associations; don't change them between themes.

### Nutri-Score (EU Standard)

| Token             | Light     | Dark      | Tailwind Class |
| ----------------- | --------- | --------- | -------------- |
| `--color-nutri-A` | `#038141` | `#34d399` | `bg-nutri-A`   |
| `--color-nutri-B` | `#85bb2f` | `#a3e635` | `bg-nutri-B`   |
| `--color-nutri-C` | `#fecb02` | `#fde047` | `bg-nutri-C`   |
| `--color-nutri-D` | `#ee8100` | `#fb923c` | `bg-nutri-D`   |
| `--color-nutri-E` | `#e63e11` | `#f87171` | `bg-nutri-E`   |

> **Immutable**: Nutri-Score colors follow EU regulation.

### Nutrition Traffic Light (FSA/EFSA)

| Token                     | Light     | Dark      | Tailwind Class                               | Meaning   |
| ------------------------- | --------- | --------- | -------------------------------------------- | --------- |
| `--color-nutrient-low`    | `#22c55e` | `#4ade80` | `bg-nutrient-low`, `text-nutrient-low`       | Low risk  |
| `--color-nutrient-medium` | `#f59e0b` | `#fbbf24` | `bg-nutrient-medium`, `text-nutrient-medium` | Moderate  |
| `--color-nutrient-high`   | `#ef4444` | `#f87171` | `bg-nutrient-high`, `text-nutrient-high`     | High risk |

### NOVA Processing Groups

| Token            | Light     | Dark      | Tailwind Class | Group              |
| ---------------- | --------- | --------- | -------------- | ------------------ |
| `--color-nova-1` | `#22c55e` | `#4ade80` | `bg-nova-1`    | Unprocessed        |
| `--color-nova-2` | `#84cc16` | `#a3e635` | `bg-nova-2`    | Processed culinary |
| `--color-nova-3` | `#f59e0b` | `#fbbf24` | `bg-nova-3`    | Processed          |
| `--color-nova-4` | `#ef4444` | `#f87171` | `bg-nova-4`    | Ultra-processed    |

### Confidence Bands

| Token                       | Light     | Dark      | Tailwind Class         |
| --------------------------- | --------- | --------- | ---------------------- |
| `--color-confidence-high`   | `#22c55e` | `#4ade80` | `bg-confidence-high`   |
| `--color-confidence-medium` | `#f59e0b` | `#fbbf24` | `bg-confidence-medium` |
| `--color-confidence-low`    | `#ef4444` | `#f87171` | `bg-confidence-low`    |

### Allergen Severity

| Token                      | Light     | Dark      | Tailwind Class        |
| -------------------------- | --------- | --------- | --------------------- |
| `--color-allergen-present` | `#ef4444` | `#f87171` | `bg-allergen-present` |
| `--color-allergen-traces`  | `#f59e0b` | `#fbbf24` | `bg-allergen-traces`  |
| `--color-allergen-free`    | `#22c55e` | `#4ade80` | `bg-allergen-free`    |

### Semantic Feedback

| Token             | Light     | Dark      | Tailwind Class               |
| ----------------- | --------- | --------- | ---------------------------- |
| `--color-success` | `#22c55e` | `#4ade80` | `bg-success`, `text-success` |
| `--color-warning` | `#f59e0b` | `#fbbf24` | `bg-warning`, `text-warning` |
| `--color-error`   | `#ef4444` | `#f87171` | `bg-error`, `text-error`     |
| `--color-info`    | `#3b82f6` | `#60a5fa` | `bg-info`, `text-info`       |

### Elevation (Shadows)

| Token         | Light                              | Dark                               | Tailwind Class |
| ------------- | ---------------------------------- | ---------------------------------- | -------------- |
| `--shadow-sm` | `0 1px 2px 0 rgba(0,0,0,0.05)`     | `0 1px 2px 0 rgba(0,0,0,0.3)`      | `shadow-sm`    |
| `--shadow-md` | `0 4px 6px -1px rgba(0,0,0,0.1)`   | `0 4px 6px -1px rgba(0,0,0,0.4)`   | `shadow-md`    |
| `--shadow-lg` | `0 10px 15px -3px rgba(0,0,0,0.1)` | `0 10px 15px -3px rgba(0,0,0,0.4)` | `shadow-lg`    |

### Spacing Scale

| Token        | Value     | Pixels |
| ------------ | --------- | ------ |
| `--space-1`  | `0.25rem` | 4px    |
| `--space-2`  | `0.5rem`  | 8px    |
| `--space-3`  | `0.75rem` | 12px   |
| `--space-4`  | `1rem`    | 16px   |
| `--space-5`  | `1.25rem` | 20px   |
| `--space-6`  | `1.5rem`  | 24px   |
| `--space-8`  | `2rem`    | 32px   |
| `--space-10` | `2.5rem`  | 40px   |
| `--space-12` | `3rem`    | 48px   |
| `--space-16` | `4rem`    | 64px   |

> Spacing tokens match Tailwind's default scale. Use Tailwind utilities (`p-4`, `gap-6`) directly — the CSS variables serve as documentation and for non-Tailwind contexts.

### Typography Scale

| Token         | Value      | Pixels |
| ------------- | ---------- | ------ |
| `--text-xs`   | `0.75rem`  | 12px   |
| `--text-sm`   | `0.875rem` | 14px   |
| `--text-base` | `1rem`     | 16px   |
| `--text-lg`   | `1.125rem` | 18px   |
| `--text-xl`   | `1.25rem`  | 20px   |
| `--text-2xl`  | `1.5rem`   | 24px   |
| `--text-3xl`  | `1.875rem` | 30px   |

| Token               | Value |
| ------------------- | ----- |
| `--font-normal`     | 400   |
| `--font-medium`     | 500   |
| `--font-semibold`   | 600   |
| `--font-bold`       | 700   |
| `--leading-tight`   | 1.25  |
| `--leading-normal`  | 1.5   |
| `--leading-relaxed` | 1.625 |

### Border Radius

| Token           | Value      | Pixels | Tailwind Class |
| --------------- | ---------- | ------ | -------------- |
| `--radius-sm`   | `0.375rem` | 6px    | `rounded-sm`   |
| `--radius-md`   | `0.5rem`   | 8px    | `rounded-md`   |
| `--radius-lg`   | `0.75rem`  | 12px   | `rounded-lg`   |
| `--radius-xl`   | `1rem`     | 16px   | `rounded-xl`   |
| `--radius-full` | `9999px`   | —      | `rounded-full` |

### Transitions

| Token                 | Value        |
| --------------------- | ------------ |
| `--transition-fast`   | `150ms ease` |
| `--transition-normal` | `200ms ease` |
| `--transition-slow`   | `300ms ease` |

---

## Component Classes

Four global component classes are defined in `globals.css` using design tokens:

| Class            | Description                                            |
| ---------------- | ------------------------------------------------------ |
| `.btn-primary`   | Primary action button — brand background, inverse text |
| `.btn-secondary` | Secondary action button — surface background, bordered |
| `.input-field`   | Standard text input — surface background, bordered     |
| `.card`          | Content card — surface background, bordered, shadow    |

---

## Migration Guide

### Replacing hardcoded colors

```tsx
// ❌ Before — hardcoded grays
<div className="bg-white text-gray-900 border-gray-200">
  <p className="text-gray-500">Secondary text</p>
</div>

// ✅ After — semantic tokens
<div className="bg-surface text-foreground border">
  <p className="text-foreground-secondary">Secondary text</p>
</div>
```

### Replacing health/score colors

```tsx
// ❌ Before — hardcoded colors
<span className="text-green-600 bg-green-100">Low</span>
<span className="text-red-600 bg-red-100">High</span>

// ✅ After — semantic tokens
<span className="text-score-green bg-score-green/10">Low</span>
<span className="text-score-red bg-score-red/10">High</span>
```

### Replacing feedback colors

```tsx
// ❌ Before
<p className="text-red-600">Error message</p>
<div className="bg-green-50 text-green-700">Success</div>

// ✅ After
<p className="text-error">Error message</p>
<div className="bg-success/10 text-success">Success</div>
```

---

## Theme Switching

Tokens support theme switching via the `data-theme` attribute:

```html
<!-- Light mode (default) -->
<html data-theme="light">

<!-- Dark mode -->
<html data-theme="dark">

<!-- System preference (no attribute — falls back to prefers-color-scheme) -->
<html>
```

The system preference media query (`prefers-color-scheme: dark`) serves as fallback when no `data-theme` attribute is set. The explicit `data-theme="light"` overrides the system preference.

---

## Remaining Migration

Phase 3 (component migration) is incremental. The following areas still use hardcoded color utilities and should be migrated in subsequent PRs:

- `components/product/` — score badges, nutrition bars, health warnings
- `components/search/` — filter panel, autocomplete, chips
- `components/compare/` — comparison grid, cell highlighting
- `components/settings/` — health profile section
- `components/pwa/` — install prompt, offline indicator
- `app/app/` pages — product detail, scan, submissions, admin
- `app/auth/` — login/signup forms
- `app/onboarding/` — region/preferences forms

Use the token mapping from this document when migrating these files.

---

## Files

| File                     | Purpose                                                                                         |
| ------------------------ | ----------------------------------------------------------------------------------------------- |
| `src/styles/globals.css` | CSS custom property definitions (`:root`, `[data-theme="dark"]`, `@media prefers-color-scheme`) |
| `tailwind.config.ts`     | Tailwind theme extension mapping CSS vars to utility classes                                    |
| `src/lib/constants.ts`   | Score band, Nutri-Score, warning severity, concern tier color maps                              |
| `docs/DESIGN_SYSTEM.md`  | This document                                                                                   |
