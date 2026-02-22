import { render, screen } from "@testing-library/react";
import { DVReferenceBadge, resolveRegulationLabel } from "./DVReferenceBadge";

// ─── resolveRegulationLabel ─────────────────────────────────────────────────

describe("resolveRegulationLabel", () => {
  it("maps 'eu_ri' to 'EU Reference Intakes'", () => {
    expect(resolveRegulationLabel("eu_ri")).toBe("EU Reference Intakes");
  });

  it("maps 'fda_dv' to 'FDA Daily Values'", () => {
    expect(resolveRegulationLabel("fda_dv")).toBe("FDA Daily Values");
  });

  it("returns the raw value for unknown regulation keys", () => {
    expect(resolveRegulationLabel("some_future_reg")).toBe("some_future_reg");
  });

  it("returns 'EU RI' fallback for undefined", () => {
    expect(resolveRegulationLabel(undefined)).toBe("EU RI");
  });

  it("returns 'EU RI' fallback for empty string", () => {
    expect(resolveRegulationLabel("")).toBe("EU RI");
  });
});

// ─── DVReferenceBadge component ─────────────────────────────────────────────

describe("DVReferenceBadge", () => {
  it("renders standard badge with resolved regulation label", () => {
    render(<DVReferenceBadge referenceType="standard" regulation="eu_ri" />);
    expect(screen.getByText(/EU Reference Intakes/)).toBeInTheDocument();
  });

  it("does NOT render raw 'eu_ri' constant in the DOM", () => {
    render(<DVReferenceBadge referenceType="standard" regulation="eu_ri" />);
    expect(screen.queryByText(/\beu_ri\b/)).not.toBeInTheDocument();
  });

  it("renders personalized badge", () => {
    render(
      <DVReferenceBadge referenceType="personalized" regulation="eu_ri" />,
    );
    const badge = screen.getByText(/health profile/);
    expect(badge).toBeInTheDocument();
    expect(badge.closest("span")).toHaveClass("bg-blue-100");
  });

  it("renders standard badge with gray styling", () => {
    render(<DVReferenceBadge referenceType="standard" regulation="eu_ri" />);
    const badge = screen.getByText(/EU Reference Intakes/);
    expect(badge.closest("span")).toHaveClass("bg-surface-muted");
  });

  it("renders nothing when referenceType is none", () => {
    const { container } = render(<DVReferenceBadge referenceType="none" />);
    expect(container).toBeEmptyDOMElement();
  });

  it("shows person icon for personalized", () => {
    const { container } = render(
      <DVReferenceBadge referenceType="personalized" regulation="eu_ri" />,
    );
    expect(container.querySelector("svg")).toBeInTheDocument();
  });

  it("shows chart icon for standard", () => {
    const { container } = render(
      <DVReferenceBadge referenceType="standard" regulation="eu_ri" />,
    );
    expect(container.querySelector("svg")).toBeInTheDocument();
  });

  it("falls back gracefully when regulation prop is omitted", () => {
    render(<DVReferenceBadge referenceType="standard" />);
    // Falls back to "EU RI" via resolveRegulationLabel
    expect(screen.getByText(/EU RI/)).toBeInTheDocument();
  });
});
