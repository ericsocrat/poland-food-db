// ─── Tests for ThemeToggle component ─────────────────────────────────────────

import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ThemeToggle } from "@/components/settings/ThemeToggle";

// Mock useTheme
const mockSetMode = vi.fn();
let mockMode: "light" | "dark" | "system" = "system";

vi.mock("@/hooks/use-theme", () => ({
  useTheme: () => ({
    mode: mockMode,
    resolved: mockMode === "system" ? "light" : mockMode,
    setMode: mockSetMode,
  }),
}));

beforeEach(() => {
  mockMode = "system";
  mockSetMode.mockClear();
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe("ThemeToggle", () => {
  it("renders 3 options", () => {
    render(<ThemeToggle />);
    const radios = screen.getAllByRole("radio");
    expect(radios).toHaveLength(3);
  });

  it("renders Light, Dark, and System labels", () => {
    render(<ThemeToggle />);
    expect(screen.getByText("Light")).toBeInTheDocument();
    expect(screen.getByText("Dark")).toBeInTheDocument();
    expect(screen.getByText("System")).toBeInTheDocument();
  });

  it("has a radiogroup with accessible label", () => {
    render(<ThemeToggle />);
    const group = screen.getByRole("radiogroup");
    expect(group).toHaveAttribute("aria-label", "Theme preference");
  });

  it("marks the current mode as checked", () => {
    mockMode = "dark";
    render(<ThemeToggle />);
    const darkRadio = screen.getByText("Dark").closest("[role='radio']");
    expect(darkRadio).toHaveAttribute("aria-checked", "true");

    const lightRadio = screen.getByText("Light").closest("[role='radio']");
    expect(lightRadio).toHaveAttribute("aria-checked", "false");
  });

  it("calls setMode when clicking Light", () => {
    render(<ThemeToggle />);
    fireEvent.click(screen.getByText("Light"));
    expect(mockSetMode).toHaveBeenCalledWith("light");
  });

  it("calls setMode when clicking Dark", () => {
    render(<ThemeToggle />);
    fireEvent.click(screen.getByText("Dark"));
    expect(mockSetMode).toHaveBeenCalledWith("dark");
  });

  it("calls setMode when clicking System", () => {
    mockMode = "dark";
    render(<ThemeToggle />);
    fireEvent.click(screen.getByText("System"));
    expect(mockSetMode).toHaveBeenCalledWith("system");
  });

  it("shows sun icon for light mode", () => {
    render(<ThemeToggle />);
    expect(screen.getByText("☀️")).toBeInTheDocument();
  });

  it("shows moon icon for dark mode", () => {
    render(<ThemeToggle />);
    expect(screen.getByText("🌙")).toBeInTheDocument();
  });

  it("shows computer icon for system mode", () => {
    render(<ThemeToggle />);
    expect(screen.getByText("💻")).toBeInTheDocument();
  });
});
