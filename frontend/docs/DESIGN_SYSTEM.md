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

### Brand Identity (#406)

| Token                       | Light     | Dark      | Tailwind Class          | WCAG on White |
| --------------------------- | --------- | --------- | ----------------------- | ------------- |
| `--color-brand-primary`     | `#0d7377` | `#2dd4bf` | `bg-brand-primary`      | 5.6:1 (AA)    |
| `--color-brand-primary-dark`| `#095456` | `#0d7377` | `bg-brand-primary-dark` | 8.5:1 (AAA)   |
| `--color-brand-secondary`   | `#f8fafc` | `#1e293b` | `bg-brand-secondary`    | Background    |
| `--color-brand-accent`      | `#d4a844` | `#fbbf24` | `bg-brand-accent`       | 2.2:1 (decorative) |

> **Warning**: `brand-accent` (gold) does NOT meet WCAG AA as text on white backgrounds. Use only for decorative elements, badges, or on dark surfaces where it achieves 7.8:1 contrast.

### Neutral Scale (#406)

| Token                | Light     | Dark      | Tailwind Class  |
| -------------------- | --------- | --------- | --------------- |
| `--color-neutral-50` | `#f8fafc` | `#0f172a` | `bg-neutral-50` |
| `--color-neutral-200`| `#e2e8f0` | `#334155` | `bg-neutral-200`|
| `--color-neutral-400`| `#94a3b8` | `#94a3b8` | `bg-neutral-400`|
| `--color-neutral-600`| `#475569` | `#cbd5e1` | `bg-neutral-600`|
| `--color-neutral-900`| `#0f172a` | `#f8fafc` | `bg-neutral-900`|

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

## Component Library

> **Issue**: #58 · **Import**: `@/components/common`

All reusable UI components live in `src/components/common/` with a barrel export from `index.ts`. Components use design tokens exclusively — no hardcoded colors.

### Primitives

#### Button

Styled button with variant, size, loading, and icon support.

```tsx
import { Button } from "@/components/common";

<Button variant="primary" size="md" loading={saving} icon={<SaveIcon />}>
  Save Changes
</Button>
```

| Prop                 | Type                                              | Default     |
| -------------------- | ------------------------------------------------- | ----------- |
| `variant`            | `"primary" \| "secondary" \| "ghost" \| "danger"` | `"primary"` |
| `size`               | `"sm" \| "md" \| "lg"`                            | `"md"`      |
| `loading`            | `boolean`                                         | `false`     |
| `icon` / `iconRight` | `ReactNode`                                       | —           |
| `fullWidth`          | `boolean`                                         | `false`     |

#### IconButton

Square icon-only button for toolbar actions.

```tsx
<IconButton icon={<TrashIcon />} label="Delete" variant="danger" size="sm" />
```

| Prop      | Type                                              | Default        |
| --------- | ------------------------------------------------- | -------------- |
| `icon`    | `ReactNode`                                       | **(required)** |
| `label`   | `string`                                          | **(required)** |
| `variant` | `"primary" \| "secondary" \| "ghost" \| "danger"` | `"ghost"`      |
| `size`    | `"sm" \| "md" \| "lg"`                            | `"md"`         |

#### Input

Text input with label, error, hint, and icon.

```tsx
<Input label="Product Name" error={errors.name} hint="Max 100 characters" icon={<SearchIcon />} />
```

| Prop    | Type                   | Default |
| ------- | ---------------------- | ------- |
| `label` | `string`               | —       |
| `error` | `string`               | —       |
| `hint`  | `string`               | —       |
| `icon`  | `ReactNode`            | —       |
| `size`  | `"sm" \| "md" \| "lg"` | `"md"`  |

#### Select

Native select with label, error, and placeholder.

```tsx
<Select label="Category" options={categories} placeholder="Choose…" error={errors.category} />
```

| Prop          | Type                      | Default        |
| ------------- | ------------------------- | -------------- |
| `label`       | `string`                  | —              |
| `options`     | `readonly SelectOption[]` | **(required)** |
| `error`       | `string`                  | —              |
| `placeholder` | `string`                  | —              |
| `size`        | `"sm" \| "md" \| "lg"`    | `"md"`         |

#### Textarea

Multi-line input with character counter.

```tsx
<Textarea label="Notes" showCount currentLength={notes.length} maxLength={500} />
```

| Prop            | Type      | Default |
| --------------- | --------- | ------- |
| `label`         | `string`  | —       |
| `error`         | `string`  | —       |
| `hint`          | `string`  | —       |
| `showCount`     | `boolean` | `false` |
| `currentLength` | `number`  | `0`     |

#### Toggle

Accessible boolean switch (`role="switch"`).

```tsx
<Toggle label="Dark mode" checked={dark} onChange={setDark} />
```

| Prop       | Type                         | Default        |
| ---------- | ---------------------------- | -------------- |
| `label`    | `string`                     | **(required)** |
| `checked`  | `boolean`                    | **(required)** |
| `onChange` | `(checked: boolean) => void` | **(required)** |
| `size`     | `"sm" \| "md"`               | `"md"`         |
| `disabled` | `boolean`                    | `false`        |

#### Checkbox

Checkbox with label and optional indeterminate state.

```tsx
<Checkbox label="I agree to terms" checked={agreed} onChange={handleCheck} />
```

| Prop            | Type      | Default        |
| --------------- | --------- | -------------- |
| `label`         | `string`  | **(required)** |
| `indeterminate` | `boolean` | `false`        |

#### Card

Semantic container with variant and padding.

```tsx
<Card variant="elevated" padding="lg" as="section">
  <h2>Product Details</h2>
</Card>
```

| Prop      | Type                                    | Default     |
| --------- | --------------------------------------- | ----------- |
| `variant` | `"default" \| "elevated" \| "outlined"` | `"default"` |
| `padding` | `"none" \| "sm" \| "md" \| "lg"`        | `"md"`      |
| `as`      | `ElementType`                           | `"div"`     |

### Display Components

#### Badge

Generic label pill for status indicators.

```tsx
<Badge variant="success" dot>Active</Badge>
```

| Prop      | Type                                                       | Default     |
| --------- | ---------------------------------------------------------- | ----------- |
| `variant` | `"info" \| "success" \| "warning" \| "error" \| "neutral"` | `"neutral"` |
| `size`    | `"sm" \| "md"`                                             | `"sm"`      |
| `dot`     | `boolean`                                                  | `false`     |

#### Chip

Removable tag for filters and categories.

```tsx
<Chip variant="primary" onRemove={() => removeFilter(id)}>Gluten Free</Chip>
```

| Prop          | Type                                                          | Default     |
| ------------- | ------------------------------------------------------------- | ----------- |
| `variant`     | `"default" \| "primary" \| "success" \| "warning" \| "error"` | `"default"` |
| `interactive` | `boolean`                                                     | `false`     |
| `onRemove`    | `() => void`                                                  | —           |
| `removeLabel` | `string`                                                      | `"Remove"`  |

#### ProgressBar

Visual progress / DV bar.

```tsx
<ProgressBar value={65} variant="warning" size="md" showLabel />
```

| Prop        | Type                                                      | Default        |
| ----------- | --------------------------------------------------------- | -------------- |
| `value`     | `number` (0–100)                                          | **(required)** |
| `variant`   | `"brand" \| "success" \| "warning" \| "error" \| "score"` | `"brand"`      |
| `size`      | `"sm" \| "md" \| "lg"`                                    | `"md"`         |
| `showLabel` | `boolean`                                                 | `false`        |

#### Tooltip

Pure-CSS hover/focus tooltip with arrow.

```tsx
<Tooltip content="Unhealthiness score 1–100" side="right">
  <InfoIcon />
</Tooltip>
```

| Prop      | Type                                     | Default        |
| --------- | ---------------------------------------- | -------------- |
| `content` | `string`                                 | **(required)** |
| `side`    | `"top" \| "right" \| "bottom" \| "left"` | `"top"`        |

### Feedback

#### Alert

Inline feedback banner with dismiss support.

```tsx
<Alert variant="error" title="Validation failed" dismissible>
  Please fix the highlighted fields.
</Alert>
```

| Prop          | Type                                          | Default  |
| ------------- | --------------------------------------------- | -------- |
| `variant`     | `"info" \| "success" \| "warning" \| "error"` | `"info"` |
| `title`       | `string`                                      | —        |
| `dismissible` | `boolean`                                     | `false`  |
| `icon`        | `ReactNode`                                   | —        |

### Domain-Specific Badges

#### ScoreBadge

Unhealthiness score (1–100) with color band.

```tsx
<ScoreBadge score={42} size="lg" showLabel />
```

| Prop        | Type                   | Default        |
| ----------- | ---------------------- | -------------- |
| `score`     | `number \| null`       | **(required)** |
| `size`      | `"sm" \| "md" \| "lg"` | `"md"`         |
| `showLabel` | `boolean`              | `false`        |

#### NutriScoreBadge

EU Nutri-Score grade (A–E).

```tsx
<NutriScoreBadge grade="B" size="md" />
```

| Prop    | Type                   | Default        |
| ------- | ---------------------- | -------------- |
| `grade` | `string \| null`       | **(required)** |
| `size`  | `"sm" \| "md" \| "lg"` | `"md"`         |

#### NovaBadge

NOVA processing classification (1–4).

```tsx
<NovaBadge group={4} showLabel />
```

| Prop        | Type                   | Default        |
| ----------- | ---------------------- | -------------- |
| `group`     | `number \| null`       | **(required)** |
| `size`      | `"sm" \| "md" \| "lg"` | `"md"`         |
| `showLabel` | `boolean`              | `false`        |

#### ConfidenceBadge

Data confidence level indicator.

```tsx
<ConfidenceBadge level="high" percentage={95} />
```

| Prop         | Type                                  | Default        |
| ------------ | ------------------------------------- | -------------- |
| `level`      | `"high" \| "medium" \| "low" \| null` | **(required)** |
| `percentage` | `number`                              | —              |
| `size`       | `"sm" \| "md"`                        | `"sm"`         |

#### NutrientTrafficLight

FSA/EFSA traffic-light for fat, saturates, sugars, salt per 100 g.

```tsx
<NutrientTrafficLight nutrient="sugars" value={12.5} unit="g" />
```

| Prop       | Type                                         | Default        |
| ---------- | -------------------------------------------- | -------------- |
| `nutrient` | `"fat" \| "saturates" \| "sugars" \| "salt"` | **(required)** |
| `value`    | `number`                                     | **(required)** |
| `unit`     | `string`                                     | `"g"`          |

#### AllergenBadge

Allergen presence indicator.

```tsx
<AllergenBadge status="traces" allergenName="Milk" />
```

| Prop           | Type                              | Default        |
| -------------- | --------------------------------- | -------------- |
| `status`       | `"present" \| "traces" \| "free"` | **(required)** |
| `allergenName` | `string`                          | **(required)** |
| `size`         | `"sm" \| "md"`                    | `"sm"`         |

### Existing Components (pre-#58)

| Component        | Description                  |
| ---------------- | ---------------------------- |
| `ConfirmDialog`  | Modal confirmation dialog    |
| `CountryChip`    | Country flag + label chip    |
| `EmptyState`     | Placeholder for empty lists  |
| `ErrorBoundary`  | React error boundary wrapper |
| `LoadingSpinner` | Animated spinner             |
| `RouteGuard`     | Auth-gated route wrapper     |
| `Skeleton`       | Loading skeleton primitives  |

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

| File                              | Purpose                                                                                         |
| --------------------------------- | ----------------------------------------------------------------------------------------------- |
| `src/styles/globals.css`          | CSS custom property definitions (`:root`, `[data-theme="dark"]`, `@media prefers-color-scheme`) |
| `tailwind.config.ts`              | Tailwind theme extension mapping CSS vars to utility classes                                    |
| `src/lib/constants.ts`            | Score band, Nutri-Score, warning severity, concern tier color maps                              |
| `docs/assets/design-tokens.json`  | Structured JSON export for design tools and documentation (#406)                                |
| `docs/DESIGN_SYSTEM.md`           | This document                                                                                   |
