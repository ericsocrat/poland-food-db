import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Skeleton, SkeletonContainer } from "./Skeleton";

// ─── Skeleton primitive ─────────────────────────────────────────────────────

describe("Skeleton", () => {
  it("renders a skeleton block with aria-hidden", () => {
    const { container } = render(<Skeleton />);
    const el = container.querySelector(".skeleton");
    expect(el).toBeTruthy();
    expect(el?.getAttribute("aria-hidden")).toBe("true");
  });

  it("applies default text variant dimensions", () => {
    const { container } = render(<Skeleton />);
    const el = container.querySelector(".skeleton") as HTMLElement;
    expect(el.style.width).toBe("100%");
    expect(el.style.height).toBe("1rem");
  });

  it("renders circle variant with full border-radius", () => {
    const { container } = render(<Skeleton variant="circle" />);
    const el = container.querySelector(".skeleton") as HTMLElement;
    expect(el.style.width).toBe("2.5rem");
    expect(el.style.height).toBe("2.5rem");
    expect(el.style.borderRadius).toBe("var(--radius-full)");
  });

  it("renders rect variant", () => {
    const { container } = render(<Skeleton variant="rect" />);
    const el = container.querySelector(".skeleton") as HTMLElement;
    expect(el.style.height).toBe("4rem");
  });

  it("renders card variant with lg border-radius", () => {
    const { container } = render(<Skeleton variant="card" />);
    const el = container.querySelector(".skeleton") as HTMLElement;
    expect(el.style.height).toBe("8rem");
    expect(el.style.borderRadius).toBe("var(--radius-lg)");
  });

  it("accepts custom width and height as strings", () => {
    const { container } = render(<Skeleton width="10rem" height="3rem" />);
    const el = container.querySelector(".skeleton") as HTMLElement;
    expect(el.style.width).toBe("10rem");
    expect(el.style.height).toBe("3rem");
  });

  it("accepts custom width and height as numbers (px)", () => {
    const { container } = render(<Skeleton width={120} height={48} />);
    const el = container.querySelector(".skeleton") as HTMLElement;
    expect(el.style.width).toBe("120px");
    expect(el.style.height).toBe("48px");
  });

  it("renders multiple lines for text variant", () => {
    const { container } = render(<Skeleton variant="text" lines={3} />);
    const blocks = container.querySelectorAll(".skeleton");
    expect(blocks.length).toBe(3);
  });

  it("makes last line shorter when lines > 1", () => {
    const { container } = render(<Skeleton variant="text" lines={3} />);
    const blocks = container.querySelectorAll(".skeleton");
    const lastBlock = blocks[2] as HTMLElement;
    expect(lastBlock.style.width).toBe("66%");
  });

  it("applies custom className", () => {
    const { container } = render(<Skeleton className="mt-4" />);
    const el = container.querySelector(".skeleton");
    expect(el?.className).toContain("mt-4");
  });
});

// ─── SkeletonContainer ──────────────────────────────────────────────────────

describe("SkeletonContainer", () => {
  it("renders with role=status and aria-busy", () => {
    render(
      <SkeletonContainer label="Loading products">
        <div>child</div>
      </SkeletonContainer>,
    );
    const container = screen.getByRole("status");
    expect(container).toBeTruthy();
    expect(container.getAttribute("aria-busy")).toBe("true");
    expect(container.getAttribute("aria-label")).toBe("Loading products");
  });

  it("includes sr-only text for screen readers", () => {
    render(
      <SkeletonContainer label="Loading dashboard">
        <div>child</div>
      </SkeletonContainer>,
    );
    expect(screen.getByText("Loading dashboard")).toBeTruthy();
  });

  it("renders children", () => {
    render(
      <SkeletonContainer>
        <div data-testid="child">content</div>
      </SkeletonContainer>,
    );
    expect(screen.getByTestId("child")).toBeTruthy();
  });

  it("uses default label when none provided", () => {
    render(
      <SkeletonContainer>
        <div>child</div>
      </SkeletonContainer>,
    );
    const container = screen.getByRole("status");
    expect(container.getAttribute("aria-label")).toBe("Loading");
  });
});
