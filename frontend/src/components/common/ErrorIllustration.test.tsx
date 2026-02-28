import { describe, it, expect, vi } from "vitest";
import { render } from "@testing-library/react";
import {
  ErrorIllustration,
  getErrorTypes,
  getErrorMeta,
} from "./ErrorIllustration";
import type { ErrorType } from "./ErrorIllustration";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/image", () => ({
  default: ({ priority, ...props }: Record<string, unknown>) => (
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    <img {...props} data-priority={priority ? "true" : "false"} />
  ),
}));

// ─── Error Types ────────────────────────────────────────────────────────────

const ALL_TYPES: ErrorType[] = ["not-found", "server-error", "offline"];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ErrorIllustration", () => {
  // ── Rendering per type ────────────────────────────────────────────────

  describe("renders correct illustration for each type", () => {
    it.each(ALL_TYPES)("renders %s illustration", (type) => {
      const { container } = render(<ErrorIllustration type={type} />);

      const img = container.querySelector(
        `img[data-illustration="${type}"]`,
      ) as HTMLImageElement;
      expect(img).toBeInTheDocument();
    });
  });

  // ── SVG source paths ─────────────────────────────────────────────────

  describe("uses correct SVG source paths", () => {
    it.each([
      ["not-found", "/illustrations/errors/404-not-found.svg"],
      ["server-error", "/illustrations/errors/500-server-error.svg"],
      ["offline", "/illustrations/errors/offline.svg"],
    ] as [ErrorType, string][])(
      "%s uses %s",
      (type, expectedSrc) => {
        const { container } = render(<ErrorIllustration type={type} />);
        const img = container.querySelector("img") as HTMLImageElement;
        expect(img.getAttribute("src")).toBe(expectedSrc);
      },
    );
  });

  // ── Alt text ──────────────────────────────────────────────────────────

  describe("sets descriptive alt text per type", () => {
    it("not-found mentions page not found", () => {
      const { container } = render(<ErrorIllustration type="not-found" />);
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("not found");
    });

    it("server-error mentions server error", () => {
      const { container } = render(<ErrorIllustration type="server-error" />);
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("server error");
    });

    it("offline mentions no internet", () => {
      const { container } = render(<ErrorIllustration type="offline" />);
      const img = container.querySelector("img") as HTMLImageElement;
      expect(img.getAttribute("alt")).toContain("no internet");
    });
  });

  // ── Default dimensions ────────────────────────────────────────────────

  it("renders at default 240×200 dimensions", () => {
    const { container } = render(<ErrorIllustration type="not-found" />);
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("width")).toBe("240");
    expect(img.getAttribute("height")).toBe("200");
  });

  // ── Custom dimensions ─────────────────────────────────────────────────

  it("accepts custom width and height", () => {
    const { container } = render(
      <ErrorIllustration type="server-error" width={320} height={260} />,
    );
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("width")).toBe("320");
    expect(img.getAttribute("height")).toBe("260");
  });

  // ── data-testid ───────────────────────────────────────────────────────

  it("renders with data-testid error-illustration", () => {
    const { container } = render(<ErrorIllustration type="offline" />);
    const wrapper = container.querySelector(
      '[data-testid="error-illustration"]',
    );
    expect(wrapper).toBeInTheDocument();
  });

  // ── data-error-type attribute ─────────────────────────────────────────

  it.each(ALL_TYPES)("sets data-error-type=%s on wrapper", (type) => {
    const { container } = render(<ErrorIllustration type={type} />);
    const wrapper = container.querySelector(`[data-error-type="${type}"]`);
    expect(wrapper).toBeInTheDocument();
  });

  // ── data-illustration attribute ───────────────────────────────────────

  it.each(ALL_TYPES)("sets data-illustration=%s on the image", (type) => {
    const { container } = render(<ErrorIllustration type={type} />);
    const img = container.querySelector(`[data-illustration="${type}"]`);
    expect(img).toBeInTheDocument();
  });

  // ── className passthrough ─────────────────────────────────────────────

  it("passes className to wrapper div", () => {
    const { container } = render(
      <ErrorIllustration type="not-found" className="my-8 text-center" />,
    );
    const wrapper = container.querySelector(
      '[data-testid="error-illustration"]',
    );
    expect(wrapper?.className).toContain("my-8 text-center");
  });

  // ── priority loading ──────────────────────────────────────────────────

  it("sets priority=false by default", () => {
    const { container } = render(<ErrorIllustration type="not-found" />);
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("data-priority")).toBe("false");
  });

  it("passes priority=true when specified", () => {
    const { container } = render(
      <ErrorIllustration type="server-error" priority />,
    );
    const img = container.querySelector("img") as HTMLImageElement;
    expect(img.getAttribute("data-priority")).toBe("true");
  });
});

// ─── Utility Functions ──────────────────────────────────────────────────────

describe("getErrorTypes", () => {
  it("returns all 3 error types", () => {
    const types = getErrorTypes();
    expect(types).toHaveLength(3);
    expect(types).toEqual(expect.arrayContaining(ALL_TYPES));
  });
});

describe("getErrorMeta", () => {
  it("returns metadata with alt, src, and statusCode for each type", () => {
    for (const type of ALL_TYPES) {
      const meta = getErrorMeta(type);
      expect(meta.alt).toBeTruthy();
      expect(meta.src).toContain("errors");
      expect(meta.src).toMatch(/\.svg$/);
    }
  });

  it("not-found has status code 404", () => {
    const meta = getErrorMeta("not-found");
    expect(meta.statusCode).toBe(404);
  });

  it("server-error has status code 500", () => {
    const meta = getErrorMeta("server-error");
    expect(meta.statusCode).toBe(500);
  });

  it("offline has null status code", () => {
    const meta = getErrorMeta("offline");
    expect(meta.statusCode).toBeNull();
  });

  it("returns correct src path for not-found", () => {
    const meta = getErrorMeta("not-found");
    expect(meta.src).toBe("/illustrations/errors/404-not-found.svg");
  });
});
