import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { NovaIndicator } from "./NovaIndicator";

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const msgs: Record<string, string> = {
        "product.novaGroup1": "Unprocessed",
        "product.novaGroup2": "Processed ingredient",
        "product.novaGroup3": "Processed food",
        "product.novaGroup4": "Ultra-processed",
      };
      return msgs[key] ?? key;
    },
  }),
}));

describe("NovaIndicator", () => {
  it("renders NOVA group label", () => {
    render(<NovaIndicator novaGroup="1" />);
    expect(screen.getByText("NOVA 1")).toBeTruthy();
    expect(screen.getByText("Unprocessed")).toBeTruthy();
  });

  it("highlights correct group for NOVA 4", () => {
    render(<NovaIndicator novaGroup="4" />);
    expect(screen.getByText("NOVA 4")).toBeTruthy();
    expect(screen.getByText("Ultra-processed")).toBeTruthy();
  });

  it("renders aria-label for NOVA group", () => {
    render(<NovaIndicator novaGroup="3" />);
    expect(screen.getByLabelText("NOVA Group 3")).toBeTruthy();
  });

  it("renders 4 bar segments", () => {
    const { container } = render(<NovaIndicator novaGroup="2" />);
    const bars = container.querySelectorAll("[aria-hidden='true'] > div");
    expect(bars.length).toBe(4);
  });
});
