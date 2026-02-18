import { render, screen } from "@testing-library/react";
import { DVReferenceBadge } from "./DVReferenceBadge";

describe("DVReferenceBadge", () => {
  it("renders standard badge with regulation", () => {
    render(<DVReferenceBadge referenceType="standard" regulation="eu_ri" />);
    expect(screen.getByText(/eu_ri/)).toBeInTheDocument();
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
    const badge = screen.getByText(/eu_ri/);
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
});
