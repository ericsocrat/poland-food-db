import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { Header } from "./Header";

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

describe("Header", () => {
  it("renders logo linking to home", () => {
    render(<Header />);
    const logo = screen.getByText(/FoodDB/);
    expect(logo.closest("a")).toHaveAttribute("href", "/");
  });

  it("renders Sign In link", () => {
    render(<Header />);
    expect(screen.getByText("Sign In").closest("a")).toHaveAttribute(
      "href",
      "/auth/login",
    );
  });

  it("renders Contact link", () => {
    render(<Header />);
    expect(screen.getByText("Contact").closest("a")).toHaveAttribute(
      "href",
      "/contact",
    );
  });
});
