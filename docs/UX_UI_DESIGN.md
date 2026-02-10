# Poland Food DB — UX/UI Design Document

> **Status:** Conceptual — architecture, structure, and UX logic only.
> **No implementation yet.** This document guides future front-end development.

---

## 1. Design Philosophy

| Principle                  | Meaning                                                                                         |
| -------------------------- | ----------------------------------------------------------------------------------------------- |
| **Clarity**                | Every number, score, and label must be instantly understandable. No jargon without explanation. |
| **Explainability**         | Users can always ask "why?" — every score links to the data behind it.                          |
| **Trust**                  | Show data sources, methodology, confidence levels. Never hide limitations.                      |
| **No health halos**        | Avoid misleading binary "healthy/unhealthy" labels. Show nuance via multi-axis scoring.         |
| **Progressive disclosure** | Show summary first, then let users drill into detail on demand.                                 |

---

## 2. Information Architecture

### 2.1 Navigation Structure

```
Home (Dashboard)
├── Browse by Category  →  Category Grid  →  Product List  →  Product Detail
├── Compare Products    →  Side-by-side comparison (up to 4)
├── Search              →  Full-text search with filters
├── Best Choices        →  "Top picks" per category (lowest unhealthiness)
├── My Watchlist        →  Saved products for quick access (future)
└── About / Methodology →  How scores are calculated, data sources
```

### 2.2 URL Scheme (Web)

```
/                           →  Dashboard
/category/:slug             →  Category listing (e.g. /category/dairy)
/product/:id                →  Product detail
/compare?ids=1,2,3          →  Comparison view
/search?q=mleko&cat=dairy   →  Search results
/best/:category             →  Best choices for a category
/about                      →  Methodology & data sources
```

---

## 3. Core Views

### 3.1 Dashboard (Home)

**Purpose:** At-a-glance overview of the entire database.

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  🇵🇱  Poland Food DB                    [Search bar]    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Category Grid (5 × 4)                                  │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐         │
│  │Dairy │ │Chips │ │Meat  │ │Drinks│ │Sweets│         │
│  │ 28   │ │ 28   │ │ 28   │ │ 28   │ │ 28   │         │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘         │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐         │
│  │Bread │ │Cereal│ │Canned│ │Sauce │ │Condi │         │
│  │ 28   │ │ 28   │ │ 28   │ │ 17   │ │ 28   │         │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘         │
│  ... (4 rows total)                                     │
│                                                         │
│  ┌─────────────────────┐  ┌──────────────────────────┐  │
│  │ Quick Stats         │  │ Recently Scored           │  │
│  │ 485 active products │  │ 1. Lay's Classic     72   │  │
│  │ 20 categories       │  │ 2. Mlekovita Kefir   12   │  │
│  │ 139 brands          │  │ 3. Alpro Soja        18   │  │
│  └─────────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Interactions:**
- Each category card shows: icon, name, product count, average unhealthiness score (colour-coded)
- Click a card → navigate to category listing
- Search bar: instant results as you type (debounced 300ms)

---

### 3.2 Category Listing

**Purpose:** Explore all products in a category with sorting and filtering.

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  ← Back    Dairy (28 products)         [Sort ▼] [Filter]│
├─────────────────────────────────────────────────────────┤
│  Sort: Unhealthiness ↑ | Calories | Name | Nutri-Score  │
│  Filter: [Brand ▼] [Nutri-Score ▼] [Processing ▼]      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │ [img]  Mlekovita Kefir Naturalny         12 🟢  │    │
│  │        Mlekovita · Nutri-Score A · NOVA 1       │    │
│  │        85 kcal · 3.2g fat · 4.0g protein        │    │
│  └─────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────┐    │
│  │ [img]  Piątnica Twaróg Półtłusty          18 🟢  │    │
│  │        Piątnica · Nutri-Score A · NOVA 1        │    │
│  │        112 kcal · 4.0g fat · 18.0g protein      │    │
│  └─────────────────────────────────────────────────┘    │
│  ...                                                    │
└─────────────────────────────────────────────────────────┘
```

**Key elements per product card:**
- Product name + brand
- Unhealthiness score (numeric + colour dot: 🟢 0-25, 🟡 26-50, 🟠 51-75, 🔴 76-100)
- Nutri-Score badge (A-E with standard colours)
- NOVA group indicator
- Key nutrition highlights (calories, fat, protein)
- Click → product detail

**Sort options:**
- Unhealthiness score (default, ascending = healthiest first)
- Calories (low→high)
- Protein (high→low)
- Name (A-Z)
- Nutri-Score (A first)

**Filter options:**
- Brand (multi-select dropdown)
- Nutri-Score grade (A, B, C, D, E)
- Processing risk (Low, Moderate, High)
- Flags (high salt, high sugar, high sat fat — toggle)
- Prep method

---

### 3.3 Product Detail

**Purpose:** Deep dive into a single product — all nutrition, scores, and context.

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  ← Dairy    Mlekovita Kefir Naturalny                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────┐   Brand: Mlekovita                        │
│  │          │   Category: Dairy                         │
│  │  [image] │   Type: kefir                             │
│  │          │   EAN: 5900512345678                       │
│  └──────────┘   Stores: Biedronka, Lidl                 │
│                                                         │
│  ╔═══════════════════════════════════════════════════╗   │
│  ║  HEALTH SUMMARY                                   ║   │
│  ║                                                   ║   │
│  ║  Unhealthiness Score    12 / 100  ████░░░░░░ 🟢   ║   │
│  ║  Nutri-Score            A        [green badge]    ║   │
│  ║  Processing Risk        Low      NOVA 1           ║   │
│  ║  Confidence             Full data                 ║   │
│  ╚═══════════════════════════════════════════════════╝   │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  NUTRITION FACTS (per 100g)                       │  │
│  │  ─────────────────────────────────────────────    │  │
│  │  Calories           85 kcal                       │  │
│  │  Total Fat          3.2 g        ██░░░░░░░░       │  │
│  │  · Saturated Fat    2.0 g        █░░░░░░░░░       │  │
│  │  · Trans Fat        0.0 g        ░░░░░░░░░░       │  │
│  │  Carbohydrates      4.1 g        █░░░░░░░░░       │  │
│  │  · Sugars           4.0 g        █░░░░░░░░░       │  │
│  │  Fibre              0.0 g        ░░░░░░░░░░       │  │
│  │  Protein            4.0 g        ██░░░░░░░░       │  │
│  │  Salt               0.1 g        ░░░░░░░░░░       │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  FLAGS & WARNINGS                                 │  │
│  │  ✅ Salt OK    ✅ Sugar OK    ✅ Sat Fat OK        │  │
│  │  ✅ Low additive load (0 additives)               │  │
│  │  ✅ No controversies                              │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  INGREDIENTS                                      │  │
│  │  Mleko pasteryzowane, kultury bakterii...         │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  [Compare with...]  [Add to Watchlist]                  │
│                                                         │
│  Data source: Open Food Facts · Scored: 2025-02-07      │
│  Scoring version: v3.2 · Completeness: 90%              │
└─────────────────────────────────────────────────────────┘
```

**Hover/tooltip behaviour (links to `column_metadata`):**
- Hovering over any score or label shows `tooltip_text` from `column_metadata`
- Example: hover "Nutri-Score" → "Nutri-Score: A (healthiest) to E (least healthy)."
- Example: hover "NOVA 1" → "NOVA: 1=natural, 2=basic, 3=processed, 4=ultra-processed."
- Example: hover "Unhealthiness Score" → "Higher means less healthy. Combines sugar, fat, salt, processing."

**Mini bar charts:**
- Each nutrition value has a proportional bar (relative to daily reference intake)
- Reference: Calories 2000, Fat 70g, Sat Fat 20g, Carbs 260g, Sugars 90g, Fibre 30g, Protein 50g, Salt 6g

---

### 3.4 Compare View

**Purpose:** Side-by-side comparison of 2-4 products.

**Layout:**
```
┌──────────────────────────────────────────────────────────────┐
│  Compare Products (3 selected)                  [+ Add]      │
├──────────────┬──────────────┬──────────────┬─────────────────┤
│              │ Mlekovita    │ Danone       │ Piątnica        │
│              │ Kefir Nat.   │ Activia Nat. │ Jogurt Nat.     │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Unhealthiness│ 12 🟢        │ 22 🟢        │ 15 🟢           │
│ Nutri-Score  │ A            │ B            │ A               │
│ NOVA         │ 1            │ 3            │ 1               │
│ Processing   │ Low          │ Moderate     │ Low             │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Calories     │ 85           │ 95           │ 78              │
│ Total Fat    │ 3.2          │ 2.8          │ 3.0             │
│ Sat Fat      │ 2.0          │ 1.8          │ 1.9             │
│ Carbs        │ 4.1          │ 12.0         │ 4.5             │
│ Sugars       │ 4.0          │ 11.5         │ 4.2             │
│ Protein      │ 4.0          │ 4.5          │ 5.0             │
│ Salt         │ 0.1          │ 0.12         │ 0.08            │
│ Fibre        │ 0.0          │ 0.0          │ 0.0             │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Flags        │ None         │ ⚠ sugar      │ None            │
│ Additives    │ 0            │ 3            │ 0               │
│ Controversies│ none         │ none         │ none            │
├──────────────┼──────────────┼──────────────┼─────────────────┤
│ Winner       │ ★ Best pick  │              │ ★ Runner-up     │
└──────────────┴──────────────┴──────────────┴─────────────────┘
```

**Interactions:**
- Row highlighting: the best value in each row is highlighted (green background)
- Products can be added from search or category listing
- "Winner" row automatically highlights the product with the lowest unhealthiness score
- Each column header links to the full product detail page

---

### 3.5 Best Choices

**Purpose:** Curated "healthiest option" per category — like a recommendation engine.

**Logic:**
1. Filter: `is_deprecated = false`
2. Sort: `unhealthiness_score ASC`
3. Show top 5 per category
4. Add "Why this is a good pick" explainer for each (based on flags/NOVA/nutri-score)

**Anti-health-halo safeguards:**
- Always show the actual score, not just "good" / "bad"
- Include a disclaimer: "Scores are based on available nutrition data and should not replace professional dietary advice."
- Show data completeness — a product with 60% completeness gets a visible "⚠ Limited data" badge
- Show the NOVA group to prevent ultra-processed products with good Nutri-Scores from looking "healthy"

---

### 3.6 Search

**Features:**
- Full-text search across product_name, brand, ingredients_raw
- Auto-suggest from existing product names
- Filters persist from category view
- Results show the same card format as category listing

---

## 4. Scoring Visualisation Strategy

### 4.1 Unhealthiness Score (0-100)

**Visual treatment:**
- Horizontal progress bar with colour gradient
- 0-25: Green (#22c55e) — "Low concern"
- 26-50: Yellow (#eab308) — "Moderate concern"
- 51-75: Orange (#f97316) — "High concern"
- 76-100: Red (#ef4444) — "Very high concern"
- Always show the numeric value alongside the bar

**Never say "healthy" or "unhealthy" as a binary label.** Instead:
- "Lower concern" / "Higher concern"
- "Relatively better" / "Relatively worse"
- Always in context: "within this category" or "compared to similar products"

### 4.2 Nutri-Score (A-E)

**Visual treatment:** Standard EU Nutri-Score badge format
- A: Dark green
- B: Light green
- C: Yellow
- D: Orange
- E: Red
- UNKNOWN: Grey with "?" icon

### 4.3 NOVA (1-4)

**Visual treatment:** Numbered badge with colour
- 1: Green — "Unprocessed or minimally processed"
- 2: Yellow — "Processed culinary ingredients"
- 3: Orange — "Processed foods"
- 4: Red — "Ultra-processed food and drink products"

### 4.4 Flags

**Visual treatment:** Simple YES/NO indicators
- YES: Warning icon (⚠) with red text
- NO: Check icon (✅) with muted text
- NULL: Dash (—) to indicate "not assessed"

---

## 5. Mobile App Design

### 5.1 Navigation (Bottom Tab Bar)

```
┌─────────────────────────────────────┐
│           [Screen Content]           │
├────────┬────────┬────────┬──────────┤
│ 🏠     │ 🔍     │ ⚖️     │ ★        │
│ Home   │ Search │ Compare│ Best     │
└────────┴────────┴────────┴──────────┘
```

### 5.2 Mobile-Specific Features

**Barcode Scanner (future):**
- Tap camera icon in search → scan EAN barcode
- Instant lookup against products.ean
- If found: show product detail
- If not found: "Not in our database yet" with suggestion to add

**Swipe Gestures:**
- Swipe left on product card → add to compare
- Swipe right on product card → add to watchlist
- Pull down to refresh / re-sort

### 5.3 Mobile Layout Adaptations

**Category grid:** 2×10 instead of 5×4
**Product cards:** Full-width, stacked vertically
**Compare view:** Horizontal scroll between products (1 visible at a time) with dot indicator
**Nutrition table:** Collapsible accordion sections

---

## 6. Tooltip / Hover System (from `column_metadata`)

### 6.1 Implementation Plan

The `column_metadata` table drives all tooltips:

```
API endpoint:  GET /api/metadata/:table_name/:column_name
Response:      { display_label, description, tooltip_text, unit, value_range }
```

**Web:** On hover, show a small popover with:
- `display_label` as title
- `tooltip_text` as body
- `unit` and `value_range` as footnote

**Mobile:** On long-press, show a bottom sheet with:
- `display_label` as title
- `description` (full text)
- `example_values` for context

### 6.2 Example Tooltips

| Column                | Tooltip                                                             |
| --------------------- | ------------------------------------------------------------------- |
| unhealthiness_score   | "Higher means less healthy. Combines sugar, fat, salt, processing." |
| nutri_score_label     | "Nutri-Score: A (healthiest) to E (least healthy)."                 |
| nova_classification   | "NOVA: 1=natural, 2=basic, 3=processed, 4=ultra-processed."         |
| high_salt_flag        | "Flags products with salt > 1.5g per 100g."                         |
| data_completeness_pct | "How complete the source data was for scoring."                     |
| calories              | "Kilocalories per serving."                                         |
| ean                   | "Barcode number. 590 prefix indicates Polish origin."               |

---

## 7. Colour Palette & Typography

### 7.1 Colours

| Token          | Hex       | Usage                                    |
| -------------- | --------- | ---------------------------------------- |
| `--green-500`  | `#22c55e` | Good scores, Nutri-Score A, NOVA 1       |
| `--green-700`  | `#15803d` | Nutri-Score A badge                      |
| `--yellow-500` | `#eab308` | Moderate scores, Nutri-Score C, NOVA 2   |
| `--orange-500` | `#f97316` | High concern, Nutri-Score D, NOVA 3      |
| `--red-500`    | `#ef4444` | Very high concern, Nutri-Score E, NOVA 4 |
| `--slate-50`   | `#f8fafc` | Background                               |
| `--slate-900`  | `#0f172a` | Primary text                             |
| `--slate-500`  | `#64748b` | Secondary text                           |
| `--blue-600`   | `#2563eb` | Links, interactive elements              |
| `--white`      | `#ffffff` | Cards, surfaces                          |

### 7.2 Typography

| Element           | Font           | Size            | Weight         |
| ----------------- | -------------- | --------------- | -------------- |
| Page title        | Inter          | 24px / 1.5rem   | 700 (Bold)     |
| Section heading   | Inter          | 18px / 1.125rem | 600 (Semibold) |
| Card title        | Inter          | 16px / 1rem     | 600            |
| Body text         | Inter          | 14px / 0.875rem | 400 (Regular)  |
| Caption / tooltip | Inter          | 12px / 0.75rem  | 400            |
| Score number      | JetBrains Mono | 20px / 1.25rem  | 700            |

---

## 8. Data Flow Architecture

```
┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│ PostgreSQL   │───▶│ Supabase      │───▶│ REST / RPC   │
│ (Docker)     │    │ PostgREST     │    │ API          │
└──────────────┘    └───────────────┘    └──────┬───────┘
                                                │
                                    ┌───────────┴──────────┐
                                    │                      │
                              ┌─────▼─────┐         ┌─────▼────┐
                              │ Web App   │         │ Mobile   │
                              │ (Next.js) │         │ (React   │
                              │           │         │  Native) │
                              └───────────┘         └──────────┘
```

**API endpoints (via Supabase PostgREST):**
- `GET /rest/v1/v_master?is_deprecated=eq.false&order=unhealthiness_score.asc`
- `GET /rest/v1/v_master?category=eq.Dairy&order=unhealthiness_score.asc`
- `GET /rest/v1/v_master?product_id=eq.42`
- `GET /rest/v1/column_metadata?table_name=eq.scores`
- `GET /rest/v1/rpc/search_products?query=mleko`

**Key queries pre-defined as Postgres functions:**
- `search_products(query text)` — full-text search
- `category_stats()` — product count + avg score per category
- `top_picks(category text, limit int)` — best choices per category

---

## 9. Accessibility

- WCAG 2.1 AA compliance minimum
- All colour-coded elements also have text labels (never colour alone)
- Score bars have aria-labels: `aria-label="Unhealthiness score: 12 out of 100, low concern"`
- Nutri-Score badges have alt text: `alt="Nutri-Score A"`
- Focus management: keyboard-navigable product cards, modals trap focus
- High-contrast mode: ensure score colours pass 4.5:1 contrast ratio on both light and dark backgrounds
- Screen reader: all tooltips also accessible via `aria-describedby`

---

## 10. Trust & Transparency

### 10.1 Source Attribution
Every product shows: data source, scoring version, scored date, and completeness percentage.

### 10.2 Limitations Badge
Products with `data_completeness_pct < 70` or `confidence = 'estimated'` show a visible badge:
`⚠ Limited data — score is estimated`

### 10.3 Methodology Page (`/about`)
- How unhealthiness_score is calculated (formula breakdown)
- What each NOVA group means
- How Nutri-Score is assigned
- Data sources (Open Food Facts, Żabka manual data)
- Update frequency
- Known limitations

### 10.4 Anti-Health-Halo Principles
1. **Never rank a category as "healthy" overall** — e.g. "Dairy" is not inherently healthy.
2. **Always show NOVA alongside Nutri-Score** — prevents ultra-processed foods with good Nutri-Scores from appearing "healthy."
3. **Show context**: "12/100 within Dairy" not just "12/100."
4. **Disclaimers visible (not buried in footer)**: "This data is for informational purposes only."
