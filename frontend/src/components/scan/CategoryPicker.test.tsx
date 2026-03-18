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
});
