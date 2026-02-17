import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Input } from "./Input";

describe("Input", () => {
  it("renders with label", () => {
    render(<Input label="Name" />);
    expect(screen.getByLabelText("Name")).toBeTruthy();
  });

  it("links error to input via aria-describedby", () => {
    render(<Input label="Email" error="Invalid email" />);
    const input = screen.getByLabelText("Email");
    expect(input.getAttribute("aria-invalid")).toBe("true");
    const errorId = input.getAttribute("aria-describedby");
    expect(errorId).toBeTruthy();
    expect(screen.getByText("Invalid email").id).toBe(errorId);
  });

  it("shows error with alert role", () => {
    render(<Input error="Required" />);
    expect(screen.getByRole("alert")).toHaveTextContent("Required");
  });

  it("shows hint when no error", () => {
    render(<Input hint="At least 8 characters" />);
    expect(screen.getByText("At least 8 characters")).toBeTruthy();
  });

  it("hides hint when error is present", () => {
    render(<Input hint="At least 8 characters" error="Too short" />);
    expect(screen.queryByText("At least 8 characters")).toBeNull();
    expect(screen.getByText("Too short")).toBeTruthy();
  });

  it("renders icon", () => {
    render(<Input icon={<span data-testid="search-icon">🔍</span>} />);
    expect(screen.getByTestId("search-icon")).toBeTruthy();
  });

  it("applies size classes", () => {
    render(<Input label="Small" size="sm" />);
    const input = screen.getByLabelText("Small");
    expect(input.className).toContain("text-xs");
  });

  it("applies error border styling", () => {
    render(<Input label="Err" error="Bad" />);
    const input = screen.getByLabelText("Err");
    expect(input.className).toContain("border-error");
  });

  it("renders without label", () => {
    render(<Input placeholder="Search..." />);
    expect(screen.getByPlaceholderText("Search...")).toBeTruthy();
  });
});
