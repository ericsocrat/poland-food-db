import { fireEvent, render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { CategoryPicker } from "./CategoryPicker";

// ─── Mocks ──────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

vi.mock("@/lib/constants", () => ({
  FOOD_CATEGORIES: [
    { slug: "bread", emoji: "🍞", labelKey: "onboarding.catBread" },
    { slug: "dairy", emoji: "🧀", labelKey: "onboarding.catDairy" },
    { slug: "drinks", emoji: "🥤", labelKey: "onboarding.catDrinks" },
  ],
}));

// ─── CategoryPicker ─────────────────────────────────────

describe("CategoryPicker", () => {
  const onChange = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders all category buttons", () => {
    render(<CategoryPicker value="" onChange={onChange} />);
    const buttons = screen.getAllByRole("button");
    expect(buttons).toHaveLength(3);
  });

  it("displays emoji and translated label", () => {
    render(<CategoryPicker value="" onChange={onChange} />);
    expect(screen.getByText(/🍞/)).toBeInTheDocument();
    expect(screen.getByText(/onboarding\.catBread/)).toBeInTheDocument();
  });

  it("marks selected category with aria-pressed=true", () => {
    render(<CategoryPicker value="dairy" onChange={onChange} />);
    const dairyBtn = screen.getByRole("button", { pressed: true });
    expect(dairyBtn).toHaveTextContent("🧀");
  });

  it("marks unselected categories with aria-pressed=false", () => {
    render(<CategoryPicker value="dairy" onChange={onChange} />);
    const unpressed = screen.getAllByRole("button", { pressed: false });
    expect(unpressed).toHaveLength(2);
  });

  it("calls onChange with slug when clicking a category", () => {
    render(<CategoryPicker value="" onChange={onChange} />);
    fireEvent.click(screen.getByText(/🍞/));
    expect(onChange).toHaveBeenCalledWith("bread");
  });

  it("toggles off when clicking the already-selected category", () => {
    render(<CategoryPicker value="bread" onChange={onChange} />);
    fireEvent.click(screen.getByText(/🍞/));
    expect(onChange).toHaveBeenCalledWith("");
  });

  it("selects a different category when one is already selected", () => {
    render(<CategoryPicker value="bread" onChange={onChange} />);
    fireEvent.click(screen.getByText(/🥤/));
    expect(onChange).toHaveBeenCalledWith("drinks");
  });

  it("applies active:scale-95 class on category buttons", () => {
    render(<CategoryPicker value="" onChange={onChange} />);
    const button = screen.getAllByRole("button")[0];
    expect(button.className).toContain("active:scale-95");
  });

  it("does not show expand/collapse toggle with few categories", () => {
    render(<CategoryPicker value="" onChange={onChange} />);
    expect(screen.queryByText("categoryPicker.showAll")).not.toBeInTheDocument();
    expect(screen.queryByText("categoryPicker.showLess")).not.toBeInTheDocument();
  });
});

// ─── Expand / Collapse (>8 categories) ──────────────────

describe("CategoryPicker — expand/collapse", () => {
  const onChange = vi.fn();
  const manyCategories = Array.from({ length: 12 }, (_, i) => ({
    slug: `cat-${i}`,
    emoji: "🔹",
    labelKey: `onboarding.cat${i}`,
  }));

  beforeEach(() => {
    vi.clearAllMocks();
    vi.resetModules();
    // Override FOOD_CATEGORIES with 12 items for this suite
    vi.doMock("@/lib/constants", () => ({
      FOOD_CATEGORIES: manyCategories,
    }));
  });

  // Use dynamic import to get the module with overridden mock
  async function renderPicker(value = "") {
    const mod = await import("./CategoryPicker");
    const { rerender } = render(<mod.CategoryPicker value={value} onChange={onChange} />);
    return rerender;
  }

  it("shows only 8 categories when collapsed", async () => {
    await renderPicker();
    // 8 category buttons + 1 "Show All" toggle button = 9 total
    const buttons = screen.getAllByRole("button");
    const categoryButtons = buttons.filter((b) => b.getAttribute("aria-pressed") !== null);
    expect(categoryButtons).toHaveLength(8);
  });

  it("shows expand toggle with correct label", async () => {
    await renderPicker();
    expect(screen.getByText("categoryPicker.showAll")).toBeInTheDocument();
  });

  it("shows all categories after expanding", async () => {
    await renderPicker();
    fireEvent.click(screen.getByText("categoryPicker.showAll"));
    const buttons = screen.getAllByRole("button");
    const categoryButtons = buttons.filter((b) => b.getAttribute("aria-pressed") !== null);
    expect(categoryButtons).toHaveLength(12);
    expect(screen.getByText("categoryPicker.showLess")).toBeInTheDocument();
  });

  it("collapses back to 8 when clicking Show Less", async () => {
    await renderPicker();
    fireEvent.click(screen.getByText("categoryPicker.showAll"));
    fireEvent.click(screen.getByText("categoryPicker.showLess"));
    const buttons = screen.getAllByRole("button");
    const categoryButtons = buttons.filter((b) => b.getAttribute("aria-pressed") !== null);
    expect(categoryButtons).toHaveLength(8);
  });
});
