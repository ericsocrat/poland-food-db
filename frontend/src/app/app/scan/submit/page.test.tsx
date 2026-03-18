import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import SubmitProductPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockPush = vi.fn();
const mockSearchGet = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
  useSearchParams: () => ({ get: mockSearchGet }),
}));

vi.mock("@/lib/gs1", () => ({
  gs1CountryHint: (ean: string) =>
    ean.startsWith("590") ? { code: "PL", name: "Poland" } : null,
}));

vi.mock("@/lib/constants", () => ({
  FOOD_CATEGORIES: [
    { slug: "dairy", emoji: "\ud83e\uddc0", labelKey: "onboarding.catDairy" },
  ],
  getCountryFlag: (c: string) => (c === "PL" ? "\ud83c\uddf5\ud83c\uddf1" : ""),
  getCountryName: (c: string) => (c === "PL" ? "Poland" : c),
}));

vi.mock("@/components/common/RouteGuard", () => ({
  usePreferences: () => ({ country: "PL" }),
}));

const mockSubmitProduct = vi.fn();
vi.mock("@/lib/api", () => ({
  submitProduct: (...args: unknown[]) => mockSubmitProduct(...args),
}));

const mockShowToast = vi.fn();
vi.mock("@/lib/toast", () => ({
  showToast: (...args: unknown[]) => mockShowToast(...args),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function Wrapper({ children }: Readonly<{ children: React.ReactNode }>) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}

function createWrapper() {
  return Wrapper;
}

beforeEach(() => {
  vi.clearAllMocks();
  mockSearchGet.mockReturnValue(null);
  mockSubmitProduct.mockResolvedValue({
    ok: true,
    data: { id: "sub-1" },
  });
});

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SubmitProductPage", () => {
  it("renders page title", () => {
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    expect(
      screen.getByRole("heading", { name: /Submit Product/ }),
    ).toBeInTheDocument();
    expect(
      screen.getByText("Help us add a missing product"),
    ).toBeInTheDocument();
  });

  it("renders all form fields", () => {
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    expect(screen.getByLabelText("EAN Barcode *")).toBeInTheDocument();
    expect(screen.getByLabelText("Product Name *")).toBeInTheDocument();
    expect(screen.getByLabelText("Brand")).toBeInTheDocument();
    expect(screen.getByLabelText("Category")).toBeInTheDocument();
    expect(screen.getByLabelText("Notes")).toBeInTheDocument();
  });

  it("pre-fills EAN from URL search params", () => {
    mockSearchGet.mockReturnValue("5901234123457");
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    const input = screen.getByLabelText("EAN Barcode *");
    expect(input).toHaveValue("5901234123457");
    expect(input).toHaveAttribute("readOnly");
  });

  it("EAN is editable when not pre-filled", () => {
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    const input = screen.getByLabelText("EAN Barcode *");
    expect(input).not.toHaveAttribute("readOnly");
  });

  it("disables submit when EAN too short", async () => {
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();
    await user.type(screen.getByLabelText("EAN Barcode *"), "1234");
    await user.type(screen.getByLabelText("Product Name *"), "Test Product");
    expect(
      screen.getByRole("button", { name: "Submit Product" }),
    ).toBeDisabled();
  });

  it("disables submit when product name too short", async () => {
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();
    await user.type(screen.getByLabelText("EAN Barcode *"), "12345678");
    await user.type(screen.getByLabelText("Product Name *"), "A");
    expect(
      screen.getByRole("button", { name: "Submit Product" }),
    ).toBeDisabled();
  });

  it("enables submit when both EAN and name are valid", async () => {
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();
    await user.type(screen.getByLabelText("EAN Barcode *"), "12345678");
    await user.type(screen.getByLabelText("Product Name *"), "Test Product");
    expect(
      screen.getByRole("button", { name: "Submit Product" }),
    ).not.toBeDisabled();
  });

  it("submits form and shows success toast", async () => {
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.type(screen.getByLabelText("EAN Barcode *"), "12345678");
    await user.type(screen.getByLabelText("Product Name *"), "Test Product");
    await user.type(screen.getByLabelText("Brand"), "TestBrand");
    await user.click(screen.getByRole("button", { name: "Submit Product" }));

    await waitFor(() => {
      expect(mockShowToast).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "success",
          messageKey: "submit.successToast",
        }),
      );
    });
    expect(mockPush).toHaveBeenCalledWith("/app/scan/submissions");
  });

  it("shows error toast on failure", async () => {
    mockSubmitProduct.mockResolvedValue({
      ok: false,
      error: { message: "Duplicate EAN" },
    });
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.type(screen.getByLabelText("EAN Barcode *"), "12345678");
    await user.type(screen.getByLabelText("Product Name *"), "Test Product");
    await user.click(screen.getByRole("button", { name: "Submit Product" }));

    await waitFor(() => {
      expect(mockShowToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error", message: "Duplicate EAN" }),
      );
    });
  });

  it("shows submission review notice", () => {
    render(<SubmitProductPage />, { wrapper: createWrapper() });
    expect(
      screen.getByText(
        "Submissions are reviewed before being added to the database.",
      ),
    ).toBeInTheDocument();
  });
});
