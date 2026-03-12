import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { Header } from "./Header";

const mockGetUser = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      getUser: () => mockGetUser(),
    },
  }),
}));

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
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetUser.mockResolvedValue({ data: { user: null } });
  });

  it("renders logo linking to home", () => {
    render(<Header />);
    const logo = screen.getByAltText("TryVit");
    expect(logo.closest("a")).toHaveAttribute("href", "/");
  });

  it("renders Sign In link when not authenticated", () => {
    render(<Header />);
    expect(screen.getByText("Sign In").closest("a")).toHaveAttribute(
      "href",
      "/auth/login",
    );
  });

  it("renders Dashboard link when authenticated", async () => {
    mockGetUser.mockResolvedValue({ data: { user: { id: "u1" } } });
    render(<Header />);
    const link = await screen.findByText("Dashboard");
    expect(link.closest("a")).toHaveAttribute("href", "/app");
  });

  it("renders Contact link", () => {
    render(<Header />);
    expect(screen.getByText("Contact").closest("a")).toHaveAttribute(
      "href",
      "/contact",
    );
  });
});
