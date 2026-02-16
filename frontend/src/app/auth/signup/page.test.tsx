import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import SignupPage from "./page";

vi.mock("./SignupForm", () => ({
  SignupForm: () => <div data-testid="signup-form" />,
}));

describe("SignupPage", () => {
  it("renders the SignupForm", () => {
    render(<SignupPage />);
    expect(screen.getByTestId("signup-form")).toBeInTheDocument();
  });

  it("exports dynamic = force-dynamic", async () => {
    const mod = await import("./page");
    expect(mod.dynamic).toBe("force-dynamic");
  });
});
