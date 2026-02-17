import { describe, it, expect } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { Alert } from "./Alert";

describe("Alert", () => {
  it("renders with alert role", () => {
    render(<Alert>Something happened</Alert>);
    expect(screen.getByRole("alert")).toBeTruthy();
  });

  it("renders children content", () => {
    render(<Alert>Message text</Alert>);
    expect(screen.getByText("Message text")).toBeTruthy();
  });

  it("renders title when provided", () => {
    render(<Alert title="Warning">Details here</Alert>);
    expect(screen.getByText("Warning")).toBeTruthy();
    expect(screen.getByText("Details here")).toBeTruthy();
  });

  it.each(["info", "success", "warning", "error"] as const)(
    "applies %s variant styling",
    (variant) => {
      render(<Alert variant={variant}>Message</Alert>);
      const alert = screen.getByRole("alert");
      expect(alert.className).toContain(`bg-${variant}/10`);
      expect(alert.className).toContain(`border-${variant}/30`);
    },
  );

  it("applies info variant by default", () => {
    render(<Alert>Default</Alert>);
    const alert = screen.getByRole("alert");
    expect(alert.className).toContain("bg-info/10");
  });

  it("shows dismiss button when dismissible", () => {
    render(<Alert dismissible>Dismissible alert</Alert>);
    expect(screen.getByLabelText("Dismiss")).toBeTruthy();
  });

  it("hides alert when dismissed", () => {
    render(<Alert dismissible>Go away</Alert>);
    fireEvent.click(screen.getByLabelText("Dismiss"));
    expect(screen.queryByRole("alert")).toBeNull();
  });

  it("does not show dismiss button by default", () => {
    render(<Alert>Persistent alert</Alert>);
    expect(screen.queryByLabelText("Dismiss")).toBeNull();
  });

  it("renders custom icon", () => {
    render(
      <Alert icon={<span data-testid="custom-icon">🔔</span>}>Custom</Alert>,
    );
    expect(screen.getByTestId("custom-icon")).toBeTruthy();
  });

  it("renders default variant icon", () => {
    render(<Alert variant="success">Done</Alert>);
    expect(screen.getByText("✅")).toBeTruthy();
  });
});
