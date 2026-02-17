import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Textarea } from "./Textarea";

describe("Textarea", () => {
  it("renders with label", () => {
    render(<Textarea label="Notes" />);
    expect(screen.getByLabelText("Notes")).toBeTruthy();
  });

  it("links error via aria-describedby", () => {
    render(<Textarea label="Notes" error="Too short" />);
    const textarea = screen.getByLabelText("Notes");
    expect(textarea.getAttribute("aria-invalid")).toBe("true");
    const errorId = textarea.getAttribute("aria-describedby");
    expect(errorId).toBeTruthy();
    expect(screen.getByRole("alert")).toHaveTextContent("Too short");
  });

  it("shows hint when no error", () => {
    render(<Textarea hint="Max 500 characters" />);
    expect(screen.getByText("Max 500 characters")).toBeTruthy();
  });

  it("hides hint when error is present", () => {
    render(<Textarea hint="Max 500" error="Required" />);
    expect(screen.queryByText("Max 500")).toBeNull();
    expect(screen.getByText("Required")).toBeTruthy();
  });

  it("shows character count when showCount + maxLength", () => {
    render(<Textarea maxLength={100} showCount currentLength={42} />);
    expect(screen.getByText("42/100")).toBeTruthy();
  });

  it("applies error styling to character count when over limit", () => {
    render(<Textarea maxLength={10} showCount currentLength={15} />);
    const count = screen.getByText("15/10");
    expect(count.className).toContain("text-error");
  });

  it("respects rows prop", () => {
    render(<Textarea label="Notes" rows={5} />);
    const textarea = screen.getByLabelText("Notes") as HTMLTextAreaElement;
    expect(textarea.rows).toBe(5);
  });
});
