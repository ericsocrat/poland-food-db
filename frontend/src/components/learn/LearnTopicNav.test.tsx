import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { LearnTopicNav } from "./LearnTopicNav";

// ─── Mocks ──────────────────────────────────────────────────────────────────

let mockPathname = "/learn/additives";

vi.mock("next/navigation", () => ({
  usePathname: () => mockPathname,
}));

vi.mock("next/link", () => ({
  default: ({
    children,
    href,
  }: {
    children: React.ReactNode;
    href: string;
  }) => <a href={href}>{children}</a>,
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("LearnTopicNav", () => {
  it("renders navigation landmark", () => {
    mockPathname = "/learn/additives";
    render(<LearnTopicNav />);
    expect(
      screen.getByRole("navigation", { name: "learn.topicNavLabel" }),
    ).toBeInTheDocument();
  });

  it("shows prev and next links for middle topic", () => {
    mockPathname = "/learn/additives";
    render(<LearnTopicNav />);
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(2);
  });

  it("hides prev link for first topic", () => {
    mockPathname = "/learn/nutri-score";
    render(<LearnTopicNav />);
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(1);
    expect(links[0]).toHaveAttribute("href", "/learn/nova-groups");
  });

  it("hides next link for last topic", () => {
    mockPathname = "/learn/healthy-choices";
    render(<LearnTopicNav />);
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(1);
    expect(links[0]).toHaveAttribute("href", "/learn/confidence");
  });

  it("returns null for non-topic pathname", () => {
    mockPathname = "/learn";
    const { container } = render(<LearnTopicNav />);
    expect(container.innerHTML).toBe("");
  });
});
