import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { FormField } from "./FormField";

describe("FormField", () => {
  it("renders label text", () => {
    render(
      <FormField label="Email" name="email">
        <input />
      </FormField>,
    );
    expect(screen.getByText("Email")).toBeTruthy();
  });

  it("shows required indicator when required", () => {
    render(
      <FormField label="Email" name="email" required>
        <input />
      </FormField>,
    );
    expect(screen.getByText("*")).toBeTruthy();
  });

  it("does NOT show required indicator when not required", () => {
    render(
      <FormField label="Email" name="email">
        <input />
      </FormField>,
    );
    expect(screen.queryByText("*")).toBeNull();
  });

  it("shows error message with role=alert", () => {
    render(
      <FormField label="Email" name="email" error="Invalid email">
        <input />
      </FormField>,
    );
    const alert = screen.getByRole("alert");
    expect(alert.textContent).toBe("Invalid email");
  });

  it("links error to input via aria-describedby", () => {
    render(
      <FormField label="Email" name="email" error="Bad email">
        <input />
      </FormField>,
    );
    const input = screen.getByRole("textbox");
    expect(input.getAttribute("aria-describedby")).toBe("email-error");
    expect(input.getAttribute("aria-invalid")).toBe("true");
  });

  it("shows hint when no error", () => {
    render(
      <FormField label="Email" name="email" hint="We'll never share it">
        <input />
      </FormField>,
    );
    expect(screen.getByText("We'll never share it")).toBeTruthy();
  });

  it("hides hint when error is present", () => {
    render(
      <FormField
        label="Email"
        name="email"
        error="Required"
        hint="We'll never share it"
      >
        <input />
      </FormField>,
    );
    expect(screen.queryByText("We'll never share it")).toBeNull();
    expect(screen.getByText("Required")).toBeTruthy();
  });

  it("sets aria-required on input when required", () => {
    render(
      <FormField label="Email" name="email" required>
        <input />
      </FormField>,
    );
    const input = screen.getByRole("textbox");
    expect(input.getAttribute("aria-required")).toBe("true");
  });

  it("injects name attribute on child input", () => {
    render(
      <FormField label="Email" name="email">
        <input />
      </FormField>,
    );
    const input = screen.getByRole("textbox");
    expect(input.getAttribute("name")).toBe("email");
  });
});
