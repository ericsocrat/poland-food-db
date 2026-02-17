import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { FormErrorSummary } from "./FormErrorSummary";

const mockErrors = {
  email: { type: "required", message: "Email is required" },
  password: { type: "minLength", message: "Password too short" },
};

const fieldLabels = {
  email: "Email address",
  password: "Password",
};

describe("FormErrorSummary", () => {
  it("renders nothing when no errors", () => {
    const { container } = render(
      <FormErrorSummary errors={{}} fieldLabels={fieldLabels} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("lists all errors", () => {
    render(<FormErrorSummary errors={mockErrors} fieldLabels={fieldLabels} />);
    const items = screen.getAllByRole("listitem");
    expect(items).toHaveLength(2);
    expect(items[0].textContent).toContain("Email address");
    expect(items[0].textContent).toContain("Email is required");
    expect(items[1].textContent).toContain("Password");
    expect(items[1].textContent).toContain("Password too short");
  });

  it("has aria-live=assertive for screen readers", () => {
    render(<FormErrorSummary errors={mockErrors} fieldLabels={fieldLabels} />);
    const alert = screen.getByRole("alert");
    expect(alert.getAttribute("aria-live")).toBe("assertive");
  });

  it("renders error links for each field", () => {
    render(<FormErrorSummary errors={mockErrors} fieldLabels={fieldLabels} />);
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(2);
    expect(links[0].textContent).toBe("Email address");
    expect(links[1].textContent).toBe("Password");
  });

  it("clicking a link focuses the corresponding field", () => {
    const input = document.createElement("input");
    input.name = "email";
    document.body.appendChild(input);
    const focusSpy = vi.spyOn(input, "focus");

    render(<FormErrorSummary errors={mockErrors} fieldLabels={fieldLabels} />);
    const link = screen.getAllByRole("link")[0];
    fireEvent.click(link);
    expect(focusSpy).toHaveBeenCalled();

    document.body.removeChild(input);
  });

  it("uses custom heading", () => {
    render(
      <FormErrorSummary
        errors={mockErrors}
        fieldLabels={fieldLabels}
        heading="Fix these:"
      />,
    );
    expect(screen.getByText("Fix these:")).toBeTruthy();
  });

  it("falls back to field name when no label mapping exists", () => {
    const errors = {
      unknownField: { type: "required", message: "Is required" },
    };
    render(<FormErrorSummary errors={errors} fieldLabels={{}} />);
    expect(screen.getByText("unknownField")).toBeTruthy();
  });
});
