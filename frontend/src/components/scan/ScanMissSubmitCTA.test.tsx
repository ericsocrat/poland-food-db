import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ScanMissSubmitCTA } from "./ScanMissSubmitCTA";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

vi.mock("@/components/common/Button", () => ({
  ButtonLink: ({
    children,
    href,
  }: {
    children: React.ReactNode;
    href: string;
  }) => <a href={href}>{children}</a>,
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ScanMissSubmitCTA", () => {
  beforeEach(() => vi.clearAllMocks());

  // ─── Submit CTA (default state) ─────────────────────────────────────────

  it("renders submit button when hasPendingSubmission is false", () => {
    render(<ScanMissSubmitCTA ean="5901234123457" />);
    expect(screen.getByText("scan.helpAdd")).toBeTruthy();
  });

  it("links to submit page with ean in query string", () => {
    render(<ScanMissSubmitCTA ean="5901234123457" />);
    const link = screen.getByRole("link");
    expect(link.getAttribute("href")).toBe(
      "/app/scan/submit?ean=5901234123457"
    );
  });

  it("includes country in submit link when provided", () => {
    render(<ScanMissSubmitCTA ean="5901234123457" country="DE" />);
    const link = screen.getByRole("link");
    expect(link.getAttribute("href")).toBe(
      "/app/scan/submit?ean=5901234123457&country=DE"
    );
  });

  it("renders hint text below the button", () => {
    render(<ScanMissSubmitCTA ean="5901234123457" />);
    expect(screen.getByText("scan.helpAddHint")).toBeTruthy();
  });

  // ─── Pending submission warning ─────────────────────────────────────────

  it("renders already-submitted warning when hasPendingSubmission is true", () => {
    render(
      <ScanMissSubmitCTA ean="5901234123457" hasPendingSubmission={true} />
    );
    expect(screen.getByText("scan.alreadySubmitted")).toBeTruthy();
  });

  it("does not render submit button when hasPendingSubmission is true", () => {
    render(
      <ScanMissSubmitCTA ean="5901234123457" hasPendingSubmission={true} />
    );
    expect(screen.queryByText("scan.helpAdd")).toBeNull();
  });
});
