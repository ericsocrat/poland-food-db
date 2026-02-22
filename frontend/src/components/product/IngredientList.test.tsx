import { describe, it, expect, vi } from "vitest";
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import type { ProfileIngredients } from "@/lib/types";

// ── Mocks ────────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string | number>) => {
      if (params) {
        let result = key;
        for (const [k, v] of Object.entries(params)) result += ` ${k}=${v}`;
        return result;
      }
      return key;
    },
  }),
}));

vi.mock("next/link", () => ({
  default: ({
    children,
    href,
    ...rest
  }: {
    children: React.ReactNode;
    href: string;
    [key: string]: unknown;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

import { IngredientList } from "./IngredientList";

// ── Fixtures ─────────────────────────────────────────────────────────────────

function makeIngredients(
  overrides?: Partial<ProfileIngredients>,
): ProfileIngredients {
  return {
    count: 5,
    additive_count: 1,
    additive_names: "E330",
    has_palm_oil: false,
    vegan_status: "yes",
    vegetarian_status: "yes",
    vegan_contradiction: false,
    vegetarian_contradiction: false,
    ingredients_text: "water, sugar, citric acid (E330), salt, flavouring",
    top_ingredients: [
      {
        ingredient_id: 1,
        name: "water",
        position: 1,
        concern_tier: 0,
        is_additive: false,
        concern_reason: null,
      },
      {
        ingredient_id: 2,
        name: "SUGAR",
        position: 2,
        concern_tier: 2,
        is_additive: false,
        concern_reason: "High sugar intake linked to obesity",
      },
      {
        ingredient_id: 3,
        name: "citric_acid",
        position: 3,
        concern_tier: 1,
        is_additive: true,
        concern_reason: "Low concern additive",
      },
    ],
    ...overrides,
  };
}

function emptyIngredients(): ProfileIngredients {
  return {
    count: 0,
    additive_count: 0,
    additive_names: null,
    has_palm_oil: false,
    vegan_status: null,
    vegetarian_status: null,
    vegan_contradiction: false,
    vegetarian_contradiction: false,
    ingredients_text: null,
    top_ingredients: [],
  };
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("IngredientList", () => {
  it("renders empty state when no data", () => {
    render(<IngredientList ingredients={emptyIngredients()} />);
    expect(screen.getByText("product.noIngredientData")).toBeInTheDocument();
    expect(
      screen.getByText("product.noIngredientDataHint"),
    ).toBeInTheDocument();
  });

  it("renders summary stats", () => {
    render(<IngredientList ingredients={makeIngredients()} />);
    expect(
      screen.getByText("product.ingredientCount count=5"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("product.additiveCount count=1"),
    ).toBeInTheDocument();
    expect(screen.getByText("E330")).toBeInTheDocument(); // additive_names
    expect(
      screen.getByText("product.vegan status=yes"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("product.vegetarian status=yes"),
    ).toBeInTheDocument();
  });

  it("shows unknown status when vegan/vegetarian is null", () => {
    render(
      <IngredientList
        ingredients={makeIngredients({
          vegan_status: null,
          vegetarian_status: null,
        })}
      />,
    );
    expect(
      screen.getByText("product.vegan status=unknown"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("product.vegetarian status=unknown"),
    ).toBeInTheDocument();
  });

  it("toggles full ingredient text on click", async () => {
    const user = userEvent.setup();
    render(<IngredientList ingredients={makeIngredients()} />);

    // Text hidden by default
    expect(
      screen.queryByText(/water, sugar, citric acid/),
    ).not.toBeInTheDocument();

    // Click to expand
    const toggle = screen.getByText("product.fullIngredientText");
    expect(toggle.closest("button")).toHaveAttribute(
      "aria-expanded",
      "false",
    );
    await user.click(toggle);
    expect(
      screen.getByText("water, sugar, citric acid (E330), salt, flavouring"),
    ).toBeInTheDocument();
    expect(toggle.closest("button")).toHaveAttribute(
      "aria-expanded",
      "true",
    );

    // Click to collapse
    await user.click(toggle);
    expect(
      screen.queryByText(/water, sugar, citric acid/),
    ).not.toBeInTheDocument();
  });

  it("does not render ingredient text section when ingredients_text is null", () => {
    render(
      <IngredientList
        ingredients={makeIngredients({ ingredients_text: null })}
      />,
    );
    expect(
      screen.queryByText("product.fullIngredientText"),
    ).not.toBeInTheDocument();
  });

  it("renders top ingredients as pills with correct names", () => {
    render(<IngredientList ingredients={makeIngredients()} />);
    // Water — tier 0 natural ingredient
    expect(screen.getByText(/water/i)).toBeInTheDocument();
    // SUGAR → Title Case "Sugar" (cleanIngredientName)
    expect(screen.getByText(/Sugar/)).toBeInTheDocument();
    // citric_acid → "citric acid" (underscores removed)
    expect(screen.getByText(/citric acid/i)).toBeInTheDocument();
  });

  it("renders additive emoji for additives and natural emoji for non-additives", () => {
    render(<IngredientList ingredients={makeIngredients()} />);
    // Ingredient links
    const links = screen.getAllByRole("link");
    // water (natural) — should have 🌿
    const waterLink = links.find((l) => l.textContent?.includes("water"));
    expect(waterLink?.textContent).toContain("🌿");
    // citric acid (additive) — should have 🧪
    const additiveLink = links.find((l) =>
      l.textContent?.includes("citric acid"),
    );
    expect(additiveLink).toBeDefined();
    expect(additiveLink!.textContent).toContain("🧪");
  });

  it("links ingredients to their profile pages", () => {
    render(<IngredientList ingredients={makeIngredients()} />);
    const links = screen.getAllByRole("link");
    const waterLink = links.find((l) => l.textContent?.includes("water"));
    expect(waterLink).toHaveAttribute("href", "/app/ingredient/1");
    const sugarLink = links.find((l) => l.textContent?.includes("Sugar"));
    expect(sugarLink).toHaveAttribute("href", "/app/ingredient/2");
  });

  it("shows concern tier label on pills with concern_tier > 0", () => {
    render(<IngredientList ingredients={makeIngredients()} />);
    // Sugar has concern_tier 2 — should show tier label key
    const sugarLink = screen
      .getAllByRole("link")
      .find((l) => l.textContent?.includes("Sugar"));
    expect(sugarLink?.textContent).toContain("·");
  });

  it("expands concern detail on info button click", async () => {
    const user = userEvent.setup();
    render(<IngredientList ingredients={makeIngredients()} />);

    // Concern reason not visible initially
    expect(
      screen.queryByText("High sugar intake linked to obesity"),
    ).not.toBeInTheDocument();

    // Click the info button for sugar (concern_tier 2 with reason)
    const detailButtons = screen.getAllByLabelText(
      "product.toggleConcernDetail",
    );
    await user.click(detailButtons[0]); // first one is sugar (tier 2)

    expect(
      screen.getByText("High sugar intake linked to obesity"),
    ).toBeInTheDocument();

    // Click again to collapse
    await user.click(detailButtons[0]);
    expect(
      screen.queryByText("High sugar intake linked to obesity"),
    ).not.toBeInTheDocument();
  });

  it("renders concern tier legend", () => {
    render(<IngredientList ingredients={makeIngredients()} />);
    const legend = screen.getByLabelText("product.concernTierLegend");
    expect(within(legend).getByText("product.concernTier.none")).toBeInTheDocument();
    expect(within(legend).getByText("product.concernTier.low")).toBeInTheDocument();
    expect(
      within(legend).getByText("product.concernTier.medium"),
    ).toBeInTheDocument();
    expect(
      within(legend).getByText("product.concernTier.high"),
    ).toBeInTheDocument();
  });

  it("does not render top ingredients or legend when top_ingredients is empty", () => {
    render(
      <IngredientList
        ingredients={makeIngredients({
          top_ingredients: [],
          // still has count/text so it's not empty state
          count: 3,
          ingredients_text: "water, salt, pepper",
        })}
      />,
    );
    expect(screen.queryByText("product.topIngredients")).not.toBeInTheDocument();
    expect(
      screen.queryByLabelText("product.concernTierLegend"),
    ).not.toBeInTheDocument();
  });

  it("treats count > 0 as having data even without ingredients_text", () => {
    render(
      <IngredientList
        ingredients={makeIngredients({
          count: 2,
          ingredients_text: null,
          top_ingredients: [],
        })}
      />,
    );
    // Should show summary stats, NOT empty state
    expect(screen.getByText("product.ingredientCount count=2")).toBeInTheDocument();
    expect(
      screen.queryByText("product.noIngredientData"),
    ).not.toBeInTheDocument();
  });

  // ── Contradiction warnings ──────────────────────────────────────────────

  it("shows vegan contradiction warning when vegan_contradiction is true", () => {
    render(
      <IngredientList
        ingredients={makeIngredients({
          vegan_status: null,
          vegan_contradiction: true,
        })}
      />,
    );
    const alert = screen.getAllByRole("alert")[0];
    expect(alert).toBeInTheDocument();
    expect(alert.textContent).toContain("product.veganContradiction");
  });

  it("shows vegetarian contradiction warning when vegetarian_contradiction is true", () => {
    render(
      <IngredientList
        ingredients={makeIngredients({
          vegetarian_status: null,
          vegetarian_contradiction: true,
        })}
      />,
    );
    const alerts = screen.getAllByRole("alert");
    const vegAlert = alerts.find((a) =>
      a.textContent?.includes("product.vegetarianContradiction"),
    );
    expect(vegAlert).toBeDefined();
  });

  it("shows both contradiction warnings simultaneously", () => {
    render(
      <IngredientList
        ingredients={makeIngredients({
          vegan_status: null,
          vegetarian_status: null,
          vegan_contradiction: true,
          vegetarian_contradiction: true,
        })}
      />,
    );
    const alerts = screen.getAllByRole("alert");
    expect(alerts).toHaveLength(2);
  });

  it("does not show contradiction warnings when flags are false", () => {
    render(
      <IngredientList
        ingredients={makeIngredients({
          vegan_contradiction: false,
          vegetarian_contradiction: false,
        })}
      />,
    );
    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
  });
});
