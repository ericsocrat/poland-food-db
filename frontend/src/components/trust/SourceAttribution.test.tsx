import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { SourceAttribution, SourceField } from "./SourceAttribution";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const tMap: Record<string, string> = {
  "trust.sourceAttribution.title": "Data Sources",
  "trust.sourceAttribution.ariaLabel": "Source attribution",
  "trust.sourceAttribution.noSourceData": "No source data available",
  "trust.sourceAttribution.updatedAgo": "Updated {days} days ago",
};

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, unknown>) => {
      let value = tMap[key] ?? key;
      if (params) {
        Object.entries(params).forEach(([k, v]) => {
          value = value.replace(`{${k}}`, String(v));
        });
      }
      return value;
    },
  }),
}));

// ─── Fixtures ───────────────────────────────────────────────────────────────

const sampleSources: SourceField[] = [
  { field: "Nutrition", source: "Open Food Facts", daysSinceUpdate: 5 },
  { field: "Allergens", source: "Manual entry", daysSinceUpdate: 12 },
  { field: "Brand", source: "Open Food Facts", daysSinceUpdate: 30 },
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SourceAttribution", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // ─── Null / empty states ───

  describe("when sources is null", () => {
    it("renders the header but not the content", () => {
      render(<SourceAttribution sources={null} />);
      expect(screen.getByText("Data Sources")).toBeTruthy();
      expect(screen.queryByText("No source data available")).toBeNull();
    });
  });

  describe("when sources is undefined", () => {
    it("renders the header but not the content", () => {
      render(<SourceAttribution sources={undefined} />);
      expect(screen.getByText("Data Sources")).toBeTruthy();
      expect(screen.queryByText("No source data available")).toBeNull();
    });
  });

  describe("when sources is empty array", () => {
    it("shows no source data message after expanding", () => {
      render(<SourceAttribution sources={[]} />);
      fireEvent.click(screen.getByText("Data Sources"));
      expect(screen.getByText("No source data available")).toBeTruthy();
    });
  });

  // ─── Expand / collapse ───

  describe("expand/collapse behavior", () => {
    it("starts collapsed — no field rows visible", () => {
      render(<SourceAttribution sources={sampleSources} />);
      expect(screen.queryByText("Nutrition")).toBeNull();
      expect(screen.queryByText("Allergens")).toBeNull();
    });

    it("expands to show field rows on header click", () => {
      render(<SourceAttribution sources={sampleSources} />);
      fireEvent.click(screen.getByText("Data Sources"));
      expect(screen.getByText("Nutrition")).toBeTruthy();
      expect(screen.getByText("Allergens")).toBeTruthy();
      expect(screen.getByText("Brand")).toBeTruthy();
    });

    it("collapses back on second header click", () => {
      render(<SourceAttribution sources={sampleSources} />);
      const button = screen.getByText("Data Sources");
      fireEvent.click(button);
      expect(screen.getByText("Nutrition")).toBeTruthy();
      fireEvent.click(button);
      expect(screen.queryByText("Nutrition")).toBeNull();
    });
  });

  // ─── Field content rendering ───

  describe("field content", () => {
    it("renders source name and days since update", () => {
      render(<SourceAttribution sources={sampleSources} />);
      fireEvent.click(screen.getByText("Data Sources"));
      expect(
        screen.getByText(/Open Food Facts.*Updated 5 days ago/),
      ).toBeTruthy();
      expect(
        screen.getByText(/Manual entry.*Updated 12 days ago/),
      ).toBeTruthy();
    });

    it("renders correct count of field rows", () => {
      render(<SourceAttribution sources={sampleSources} />);
      fireEvent.click(screen.getByText("Data Sources"));
      const items = screen.getAllByRole("listitem");
      expect(items).toHaveLength(3);
    });
  });

  // ─── Single source ───

  describe("with a single source field", () => {
    it("renders one row correctly", () => {
      const single: SourceField[] = [
        { field: "EAN", source: "Barcode scan", daysSinceUpdate: 0 },
      ];
      render(<SourceAttribution sources={single} />);
      fireEvent.click(screen.getByText("Data Sources"));
      expect(screen.getByText("EAN")).toBeTruthy();
      expect(screen.getByText(/Barcode scan.*Updated 0 days ago/)).toBeTruthy();
    });
  });

  // ─── Accessibility ───

  describe("accessibility", () => {
    it("has aria-label on the container", () => {
      render(<SourceAttribution sources={sampleSources} />);
      expect(screen.getByLabelText("Source attribution")).toBeTruthy();
    });

    it("toggle button has aria-expanded false initially", () => {
      render(<SourceAttribution sources={sampleSources} />);
      const button = screen.getByRole("button");
      expect(button.getAttribute("aria-expanded")).toBe("false");
    });

    it("toggle button has aria-expanded true after click", () => {
      render(<SourceAttribution sources={sampleSources} />);
      const button = screen.getByRole("button");
      fireEvent.click(button);
      expect(button.getAttribute("aria-expanded")).toBe("true");
    });
  });
});
