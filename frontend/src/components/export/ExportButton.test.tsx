import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ExportButton } from "./ExportButton";
import type { ExportableProduct } from "@/lib/export";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/export", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@/lib/export")>();
  return {
    ...actual,
    exportProducts: vi.fn(),
    exportComparison: vi.fn(),
    downloadFile: vi.fn(),
  };
});

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

import { exportProducts, exportComparison } from "@/lib/export";
import { showToast } from "@/lib/toast";

// ─── Helpers ────────────────────────────────────────────────────────────────

const PRODUCTS: ExportableProduct[] = [
  {
    product_name: "Test Product",
    brand: "TestBrand",
    category: "Snacks",
    unhealthiness_score: 45,
    nutri_score_label: "C",
    nova_group: "3",
    calories_kcal: 200,
  },
  {
    product_name: "Another Product",
    brand: "OtherBrand",
    category: "Dairy",
    unhealthiness_score: 12,
    nutri_score_label: "A",
    nova_group: "1",
  },
];

beforeEach(() => {
  vi.clearAllMocks();
});

afterEach(() => {
  vi.restoreAllMocks();
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ExportButton", () => {
  it("renders the Export button", () => {
    render(<ExportButton products={PRODUCTS} />);
    expect(screen.getByRole("button", { expanded: false })).toBeInTheDocument();
    expect(screen.getByText("Export")).toBeInTheDocument();
  });

  it("shows dropdown with CSV and Text options when clicked", () => {
    render(<ExportButton products={PRODUCTS} />);
    fireEvent.click(screen.getByText("Export"));

    expect(screen.getByRole("menu")).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: /CSV/i })).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: /text/i })).toBeInTheDocument();
  });

  it("calls exportProducts with CSV format when CSV option clicked", () => {
    render(<ExportButton products={PRODUCTS} filename="my-list" />);
    fireEvent.click(screen.getByText("Export"));
    fireEvent.click(screen.getByRole("menuitem", { name: /CSV/i }));

    expect(exportProducts).toHaveBeenCalledWith(
      expect.objectContaining({
        filename: "my-list",
        format: "csv",
        products: PRODUCTS,
      }),
    );
  });

  it("calls exportProducts with text format when Text option clicked", () => {
    render(<ExportButton products={PRODUCTS} filename="my-list" />);
    fireEvent.click(screen.getByText("Export"));
    fireEvent.click(screen.getByRole("menuitem", { name: /text/i }));

    expect(exportProducts).toHaveBeenCalledWith(
      expect.objectContaining({
        filename: "my-list",
        format: "text",
        products: PRODUCTS,
      }),
    );
  });

  it("calls exportComparison for comparison mode CSV", () => {
    render(<ExportButton products={PRODUCTS} filename="compare" comparison />);
    fireEvent.click(screen.getByText("Export"));
    fireEvent.click(screen.getByRole("menuitem", { name: /CSV/i }));

    expect(exportComparison).toHaveBeenCalledWith(PRODUCTS, "compare");
  });

  it("shows toast when exporting empty list", () => {
    render(<ExportButton products={[]} />);
    fireEvent.click(screen.getByText("Export"));
    fireEvent.click(screen.getByRole("menuitem", { name: /CSV/i }));

    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({
        type: "info",
        messageKey: "export.nothingToExport",
      }),
    );
    expect(exportProducts).not.toHaveBeenCalled();
  });

  it("closes dropdown after selecting an option", () => {
    render(<ExportButton products={PRODUCTS} />);
    fireEvent.click(screen.getByText("Export"));
    expect(screen.getByRole("menu")).toBeInTheDocument();

    fireEvent.click(screen.getByRole("menuitem", { name: /CSV/i }));
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();
  });

  it("closes dropdown on Escape key", () => {
    render(<ExportButton products={PRODUCTS} />);
    fireEvent.click(screen.getByText("Export"));
    expect(screen.getByRole("menu")).toBeInTheDocument();

    fireEvent.keyDown(document, { key: "Escape" });
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();
  });

  it("shows error toast when export throws", () => {
    vi.mocked(exportProducts).mockImplementation(() => {
      throw new Error("oops");
    });

    render(<ExportButton products={PRODUCTS} />);
    fireEvent.click(screen.getByText("Export"));
    fireEvent.click(screen.getByRole("menuitem", { name: /text/i }));

    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ type: "error", messageKey: "export.failed" }),
    );
  });
});
