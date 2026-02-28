import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import {
  EmptyStateIllustration,
  getIllustrationTypes,
  getIllustrationMeta,
} from "./EmptyStateIllustration";
import type { EmptyStateIllustrationType } from "./EmptyStateIllustration";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/image", () => ({
  default: (props: Record<string, unknown>) => (
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    <img {...props} />
  ),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

// ─── Illustration Types ─────────────────────────────────────────────────────

const ALL_TYPES: EmptyStateIllustrationType[] = [
  "no-results",
  "no-favorites",
  "no-scan-history",
  "no-comparisons",
  "no-lists",
  "no-products-category",
  "no-submissions",
  "no-saved-searches",
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("EmptyStateIllustration", () => {
  // ── Rendering per type ──────────────────────────────────────────────────

  describe("renders correct illustration for each type", () => {
    it.each(ALL_TYPES)("renders %s illustration", (type) => {
      const { container } = render(
        <EmptyStateIllustration type={type} titleKey="common.noResults" />,
      );

      const img = container.querySelector(
        `img[data-illustration="${type}"]`,
      ) as HTMLImageElement;
      expect(img).toBeInTheDocument();
      expect(img.getAttribute("src")).toBe(
        `/illustrations/empty-states/${type}.svg`,
      );
    });
  });

  // ── Alt text ──────────────────────────────────────────────────────────

  describe("sets descriptive alt text per type", () => {
    it("no-results has magnifying glass alt text", () => {
      const { container } = render(
        <EmptyStateIllustration type="no-results" titleKey="common.noResults" />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("no results found");
    });

    it("no-favorites has heart-shaped plate alt text", () => {
      const { container } = render(
        <EmptyStateIllustration
          type="no-favorites"
          titleKey="common.noResults"
        />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("no favorites saved");
    });

    it("no-scan-history has barcode scanner alt text", () => {
      const { container } = render(
        <EmptyStateIllustration
          type="no-scan-history"
          titleKey="common.noResults"
        />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("no scans recorded");
    });

    it("no-comparisons has two plates alt text", () => {
      const { container } = render(
        <EmptyStateIllustration
          type="no-comparisons"
          titleKey="common.noResults"
        />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("no comparisons saved");
    });

    it("no-lists has shopping basket alt text", () => {
      const { container } = render(
        <EmptyStateIllustration type="no-lists" titleKey="common.noResults" />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("no lists created");
    });

    it("no-products-category has empty shelf alt text", () => {
      const { container } = render(
        <EmptyStateIllustration
          type="no-products-category"
          titleKey="common.noResults"
        />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("no products match");
    });

    it("no-submissions has clipboard alt text", () => {
      const { container } = render(
        <EmptyStateIllustration
          type="no-submissions"
          titleKey="common.noResults"
        />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("submissions reviewed");
    });

    it("no-saved-searches has bookmark alt text", () => {
      const { container } = render(
        <EmptyStateIllustration
          type="no-saved-searches"
          titleKey="common.noResults"
        />,
      );
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("no saved searches");
    });
  });

  // ── Title rendering ───────────────────────────────────────────────────

  it("renders title from i18n key", () => {
    render(
      <EmptyStateIllustration type="no-results" titleKey="common.noResults" />,
    );
    expect(screen.getByText("No results found")).toBeInTheDocument();
  });

  // ── Description rendering ─────────────────────────────────────────────

  it("renders description when descriptionKey is provided", () => {
    render(
      <EmptyStateIllustration
        type="no-favorites"
        titleKey="common.noResults"
        descriptionKey="common.errorDescription"
      />,
    );
    expect(
      screen.getByText("An unexpected error occurred. Please try again."),
    ).toBeInTheDocument();
  });

  it("does not render description when descriptionKey is omitted", () => {
    const { container } = render(
      <EmptyStateIllustration type="no-results" titleKey="common.noResults" />,
    );
    const descriptions = container.querySelectorAll("p");
    expect(descriptions).toHaveLength(0);
  });

  // ── Action button ─────────────────────────────────────────────────────

  it("renders action button when onClick is provided", () => {
    const onClick = vi.fn();
    render(
      <EmptyStateIllustration
        type="no-favorites"
        titleKey="common.noResults"
        action={{ labelKey: "common.tryAgain", onClick }}
      />,
    );
    const button = screen.getByRole("button", { name: "Try again" });
    fireEvent.click(button);
    expect(onClick).toHaveBeenCalledOnce();
  });

  it("renders action link when href is provided", () => {
    render(
      <EmptyStateIllustration
        type="no-scan-history"
        titleKey="common.noResults"
        action={{ labelKey: "common.retry", href: "/app/scan" }}
      />,
    );
    const link = screen.getByRole("link", { name: "Retry" });
    expect(link).toHaveAttribute("href", "/app/scan");
  });

  it("does not render action when none provided", () => {
    render(
      <EmptyStateIllustration type="no-lists" titleKey="common.noResults" />,
    );
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
    expect(screen.queryByRole("link")).not.toBeInTheDocument();
  });

  // ── Secondary action ──────────────────────────────────────────────────

  it("renders secondary action when provided", () => {
    render(
      <EmptyStateIllustration
        type="no-comparisons"
        titleKey="common.noResults"
        action={{ labelKey: "common.clear", href: "/app/search" }}
        secondaryAction={{ labelKey: "common.back", href: "/app" }}
      />,
    );
    expect(screen.getByRole("link", { name: "Clear" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Back" })).toBeInTheDocument();
  });

  // ── Data attribute ────────────────────────────────────────────────────

  it("passes variant to underlying EmptyState data-variant", () => {
    render(
      <EmptyStateIllustration type="no-results" titleKey="common.noResults" />,
    );
    expect(screen.getByTestId("empty-state")).toHaveAttribute(
      "data-variant",
      "no-results",
    );
  });

  it("maps no-data types to no-data variant", () => {
    render(
      <EmptyStateIllustration
        type="no-favorites"
        titleKey="common.noResults"
      />,
    );
    expect(screen.getByTestId("empty-state")).toHaveAttribute(
      "data-variant",
      "no-data",
    );
  });

  // ── data-illustration attribute ───────────────────────────────────────

  it.each(ALL_TYPES)("sets data-illustration=%s on the image", (type) => {
    const { container } = render(
      <EmptyStateIllustration type={type} titleKey="common.noResults" />,
    );
    const img = container.querySelector(`[data-illustration="${type}"]`);
    expect(img).toBeInTheDocument();
  });

  // ── Image dimensions ──────────────────────────────────────────────────

  it("renders illustration at 240×200", () => {
    const { container } = render(
      <EmptyStateIllustration type="no-results" titleKey="common.noResults" />,
    );
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("width")).toBe("240");
    expect(img.getAttribute("height")).toBe("200");
  });

  // ── className passthrough ─────────────────────────────────────────────

  it("passes className to underlying EmptyState", () => {
    render(
      <EmptyStateIllustration
        type="no-submissions"
        titleKey="common.noResults"
        className="mt-8"
      />,
    );
    expect(screen.getByTestId("empty-state").className).toContain("mt-8");
  });

  // ── Title params interpolation ────────────────────────────────────────

  it("passes titleParams for i18n interpolation", () => {
    render(
      <EmptyStateIllustration
        type="no-results"
        titleKey="common.items"
        titleParams={{ count: 0 }}
      />,
    );
    expect(screen.getByText("0 items")).toBeInTheDocument();
  });
});

// ─── Utility Functions ──────────────────────────────────────────────────────

describe("getIllustrationTypes", () => {
  it("returns all 8 illustration types", () => {
    const types = getIllustrationTypes();
    expect(types).toHaveLength(8);
    expect(types).toEqual(expect.arrayContaining(ALL_TYPES));
  });
});

describe("getIllustrationMeta", () => {
  it("returns metadata with alt, src, and variant for each type", () => {
    for (const type of ALL_TYPES) {
      const meta = getIllustrationMeta(type);
      expect(meta.alt).toBeTruthy();
      expect(meta.src).toContain(type);
      expect(["no-data", "no-results", "error", "offline"]).toContain(
        meta.variant,
      );
    }
  });

  it("returns correct src path for no-favorites", () => {
    const meta = getIllustrationMeta("no-favorites");
    expect(meta.src).toBe("/illustrations/empty-states/no-favorites.svg");
  });
});
