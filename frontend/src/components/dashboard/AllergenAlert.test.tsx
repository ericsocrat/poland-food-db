import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { AllergenAlert } from "./AllergenAlert";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string>) => {
      const map: Record<string, string> = {
        "dashboard.allergenAlertTitle": "Allergen Warning",
        "dashboard.allergenAlertBody": `${params?.count ?? "0"} products contain ${params?.allergens ?? ""}`,
        "dashboard.allergenAlertReview": "Review your lists",
      };
      return map[key] ?? key;
    },
  }),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    className,
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} className={className}>
      {children}
    </a>
  ),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AllergenAlert", () => {
  it("renders nothing when count is 0", () => {
    const { container } = render(
      <AllergenAlert alerts={{ count: 0, products: [] }} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders alert when count > 0", () => {
    render(
      <AllergenAlert
        alerts={{
          count: 2,
          products: [
            { product_id: 1, product_name: "Chips", allergen: "en:gluten" },
            { product_id: 2, product_name: "Cookies", allergen: "en:milk" },
          ],
        }}
      />,
    );
    const alert = screen.getByTestId("allergen-alert");
    expect(alert).toBeInTheDocument();
  });

  it("has alert role for accessibility", () => {
    render(
      <AllergenAlert
        alerts={{
          count: 1,
          products: [
            { product_id: 1, product_name: "Chips", allergen: "gluten" },
          ],
        }}
      />,
    );
    expect(screen.getByRole("alert")).toBeInTheDocument();
  });

  it("shows the title and body", () => {
    render(
      <AllergenAlert
        alerts={{
          count: 1,
          products: [
            { product_id: 1, product_name: "Chips", allergen: "gluten" },
          ],
        }}
      />,
    );
    expect(screen.getByText("Allergen Warning")).toBeInTheDocument();
    expect(
      screen.getByText("1 products contain gluten"),
    ).toBeInTheDocument();
  });

  it("deduplicates allergen tags", () => {
    render(
      <AllergenAlert
        alerts={{
          count: 3,
          products: [
            { product_id: 1, product_name: "A", allergen: "gluten" },
            { product_id: 2, product_name: "B", allergen: "gluten" },
            { product_id: 3, product_name: "C", allergen: "milk" },
          ],
        }}
      />,
    );
    // Should show "gluten, milk" (deduplicated), not "gluten, gluten, milk"
    expect(
      screen.getByText("3 products contain gluten, milk"),
    ).toBeInTheDocument();
  });

  it("strips en: prefix from allergen tags", () => {
    render(
      <AllergenAlert
        alerts={{
          count: 1,
          products: [
            { product_id: 1, product_name: "A", allergen: "en:soybeans" },
          ],
        }}
      />,
    );
    expect(
      screen.getByText("1 products contain soybeans"),
    ).toBeInTheDocument();
  });

  it("includes a link to the lists page", () => {
    render(
      <AllergenAlert
        alerts={{
          count: 1,
          products: [
            { product_id: 1, product_name: "A", allergen: "milk" },
          ],
        }}
      />,
    );
    const link = screen.getByRole("link");
    expect(link).toHaveAttribute("href", "/app/lists");
  });
});
