import { render, screen } from "@testing-library/react";
import { DVReferenceBadge } from "./DVReferenceBadge";

describe("DVReferenceBadge", () => {
  it("renders standard badge with regulation", () => {
    render(<DVReferenceBadge referenceType="standard" regulation="eu_ri" />);
    expect(screen.getByText(/eu_ri/)).toBeInTheDocument();
  });

  it("renders personalized badge", () => {
    render(
      <DVReferenceBadge referenceType="personalized" regulation="eu_ri" />
    );
    const badge = screen.getByText(/health profile/);
    expect(badge).toBeInTheDocument();
    expect(badge.closest("span")).toHaveClass("bg-blue-100");
  });

  it("renders standard badge with gray styling", () => {
    render(<DVReferenceBadge referenceType="standard" regulation="eu_ri" />);
    const badge = screen.getByText(/eu_ri/);
    expect(badge.closest("span")).toHaveClass("bg-gray-100");
  });

  it("renders nothing when referenceType is none", () => {
    const { container } = render(<DVReferenceBadge referenceType="none" />);
    expect(container).toBeEmptyDOMElement();
  });

  it("shows person emoji for personalized", () => {
    render(
      <DVReferenceBadge referenceType="personalized" regulation="eu_ri" />
    );
    expect(screen.getByText(/👤/)).toBeInTheDocument();
  });

  it("shows chart emoji for standard", () => {
    render(<DVReferenceBadge referenceType="standard" regulation="eu_ri" />);
    expect(screen.getByText(/📊/)).toBeInTheDocument();
  });
});
