import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import SharedListLayout, { metadata } from "./layout";

// ─── Metadata tests ─────────────────────────────────────────────────────────

describe("SharedListLayout", () => {
  it("renders children unchanged", () => {
    render(
      <SharedListLayout>
        <p>list content</p>
      </SharedListLayout>,
    );
    expect(screen.getByText("list content")).toBeInTheDocument();
  });

  it("exports noindex metadata for search engines", () => {
    expect(metadata.robots).toBeDefined();
    const robots = metadata.robots as Record<string, unknown>;
    expect(robots.index).toBe(false);
    expect(robots.follow).toBe(false);
  });

  it("exports noindex for googleBot specifically", () => {
    const robots = metadata.robots as Record<string, unknown>;
    const googleBot = robots.googleBot as Record<string, unknown>;
    expect(googleBot.index).toBe(false);
    expect(googleBot.follow).toBe(false);
  });
});
