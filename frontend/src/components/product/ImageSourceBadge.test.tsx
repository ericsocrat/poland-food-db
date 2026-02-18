import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ImageSourceBadge } from "./ImageSourceBadge";

describe("ImageSourceBadge", () => {
  it("shows 'Open Food Facts' for off_api source", () => {
    render(<ImageSourceBadge source="off_api" />);
    expect(screen.getByText(/Open Food Facts/)).toBeTruthy();
  });

  it("shows 'Manual' for manual source", () => {
    render(<ImageSourceBadge source="manual" />);
    expect(screen.getByText(/Manual/)).toBeTruthy();
  });

  it("includes camera icon", () => {
    const { container } = render(<ImageSourceBadge source="off_api" />);
    expect(container.querySelector("svg")).toBeTruthy();
  });
});
