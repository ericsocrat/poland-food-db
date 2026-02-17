import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { SaveSearchDialog } from "./SaveSearchDialog";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockSaveSearch = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  saveSearch: (...args: unknown[]) => mockSaveSearch(...args),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

// JSDOM doesn't implement showModal/close on <dialog>, so we polyfill them
beforeEach(() => {
  HTMLDialogElement.prototype.showModal ??= function (this: HTMLDialogElement) {
    this.setAttribute("open", "");
  };
  HTMLDialogElement.prototype.close ??= function (this: HTMLDialogElement) {
    this.removeAttribute("open");
  };
});

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

const defaultProps: {
  query: string | null;
  filters: { category: string[] };
  show: boolean;
  onClose: () => void;
} = {
  query: "chips",
  filters: { category: ["Chips"] },
  show: true,
  onClose: vi.fn(),
};

function renderDialog(overrides?: Partial<typeof defaultProps>) {
  return render(<SaveSearchDialog {...defaultProps} {...overrides} />, {
    wrapper: createWrapper(),
  });
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SaveSearchDialog", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockSaveSearch.mockResolvedValue({
      ok: true,
      data: { search_id: "s1" },
    });
  });

  it("dialog is closed when show is false", () => {
    renderDialog({ show: false });
    const dialog = screen.getByRole("dialog", { hidden: true });
    expect(dialog).not.toHaveAttribute("open");
  });

  it("dialog is open when show is true", () => {
    renderDialog();
    const dialog = screen.getByRole("dialog");
    expect(dialog).toHaveAttribute("open");
  });

  it("renders dialog title when show is true", () => {
    renderDialog();
    expect(screen.getByText("💾 Save Search")).toBeTruthy();
  });

  it("has aria-labelledby linking to title", () => {
    renderDialog();
    const dialog = screen.getByRole("dialog");
    expect(dialog.getAttribute("aria-labelledby")).toBe("save-search-title");
    expect(document.getElementById("save-search-title")).toBeTruthy();
  });

  it("shows query in description", () => {
    renderDialog();
    expect(screen.getByText(/Query: "chips"/)).toBeTruthy();
  });

  it("shows browse mode when query is null", () => {
    renderDialog({ query: null });
    expect(screen.getByText(/Browse mode/)).toBeTruthy();
  });

  it("shows + filters when filters present", () => {
    renderDialog();
    expect(screen.getByText(/\+ filters/)).toBeTruthy();
  });

  it("save button is disabled when name is empty", () => {
    renderDialog();
    const saveBtn = screen.getByText("Save");
    expect(saveBtn).toBeDisabled();
  });

  it("save button enables after typing a name", async () => {
    renderDialog();
    const input = screen.getByPlaceholderText("Search name…");
    await userEvent.type(input, "My Search");
    const saveBtn = screen.getByText("Save");
    expect(saveBtn).not.toBeDisabled();
  });

  it("calls saveSearch on form submit", async () => {
    renderDialog();
    const input = screen.getByPlaceholderText("Search name…");
    await userEvent.type(input, "My Search");
    fireEvent.click(screen.getByText("Save"));

    await waitFor(() => {
      expect(mockSaveSearch).toHaveBeenCalledWith(
        expect.anything(),
        "My Search",
        "chips",
        { category: ["Chips"] },
      );
    });
  });

  it("calls onClose on cancel click", () => {
    renderDialog();
    fireEvent.click(screen.getByText("Cancel"));
    expect(defaultProps.onClose).toHaveBeenCalledTimes(1);
  });

  it("calls onClose on Escape via dialog cancel event", () => {
    renderDialog();
    const dialog = screen.getByRole("dialog");
    fireEvent(dialog, new Event("cancel"));
    expect(defaultProps.onClose).toHaveBeenCalledTimes(1);
  });

  it("calls onClose after successful save", async () => {
    renderDialog();
    const input = screen.getByPlaceholderText("Search name…");
    await userEvent.type(input, "Test");
    fireEvent.click(screen.getByText("Save"));

    await waitFor(() => {
      expect(defaultProps.onClose).toHaveBeenCalledTimes(1);
    });
  });

  it("shows error message on save failure", async () => {
    mockSaveSearch.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "Save failed" },
    });

    renderDialog();
    const input = screen.getByPlaceholderText("Search name…");
    await userEvent.type(input, "Test");
    fireEvent.click(screen.getByText("Save"));

    await waitFor(() => {
      expect(screen.getByText("Save failed")).toBeTruthy();
    });
  });

  it("error message has role=alert", async () => {
    mockSaveSearch.mockResolvedValue({
      ok: false,
      error: { code: "ERR", message: "Save failed" },
    });

    renderDialog();
    const input = screen.getByPlaceholderText("Search name…");
    await userEvent.type(input, "Test");
    fireEvent.click(screen.getByText("Save"));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toBeTruthy();
    });
  });

  it("input has maxLength of 100", () => {
    renderDialog();
    const input = screen.getByPlaceholderText("Search name…");
    expect(input.getAttribute("maxLength")).toBe("100");
  });

  it("input has accessible label", () => {
    renderDialog();
    const input = screen.getByPlaceholderText("Search name…");
    expect(input.id).toBe("save-search-name");
    const label = document.querySelector('label[for="save-search-name"]');
    expect(label).toBeTruthy();
  });
});
