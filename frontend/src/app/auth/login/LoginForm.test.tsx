import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { LoginForm } from "./LoginForm";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
const mockRefresh = vi.fn();
const mockSearchParams = new URLSearchParams();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush, refresh: mockRefresh }),
  useSearchParams: () => mockSearchParams,
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

const mockSignIn = vi.fn();
vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      signInWithPassword: (...args: unknown[]) => mockSignIn(...args),
    },
  }),
}));

vi.mock("@/lib/validation", () => ({
  sanitizeRedirect: (raw: string | null) =>
    raw?.startsWith("/") && !raw.startsWith("//") ? raw : "/app/search",
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

beforeEach(() => {
  vi.clearAllMocks();
  // Reset search params
  for (const key of mockSearchParams.keys()) {
    mockSearchParams.delete(key);
  }
});

describe("LoginForm", () => {
  it("renders email and password fields", () => {
    render(<LoginForm />);
    expect(screen.getByLabelText("Email")).toBeInTheDocument();
    expect(screen.getByLabelText("Password")).toBeInTheDocument();
  });

  it("renders sign in button", () => {
    render(<LoginForm />);
    expect(screen.getByRole("button", { name: "Sign In" })).toBeInTheDocument();
  });

  it("renders sign up link", () => {
    render(<LoginForm />);
    expect(screen.getByText("Sign Up").closest("a")).toHaveAttribute(
      "href",
      "/auth/signup",
    );
  });

  it("shows expired session banner when reason=expired", () => {
    mockSearchParams.set("reason", "expired");
    render(<LoginForm />);
    expect(screen.getByText(/session has expired/i)).toBeInTheDocument();
  });

  it("does not show banner when no reason", () => {
    render(<LoginForm />);
    expect(screen.queryByText(/session has expired/i)).not.toBeInTheDocument();
  });

  it("calls signInWithPassword on submit", async () => {
    mockSignIn.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<LoginForm />);
    await user.type(screen.getByLabelText("Email"), "a@b.com");
    await user.type(screen.getByLabelText("Password"), "secret");
    await user.click(screen.getByRole("button", { name: "Sign In" }));

    await waitFor(() => {
      expect(mockSignIn).toHaveBeenCalledWith({
        email: "a@b.com",
        password: "secret",
      });
    });
  });

  it("redirects on success", async () => {
    mockSignIn.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<LoginForm />);
    await user.type(screen.getByLabelText("Email"), "a@b.com");
    await user.type(screen.getByLabelText("Password"), "pass");
    await user.click(screen.getByRole("button", { name: "Sign In" }));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/app/search");
      expect(mockRefresh).toHaveBeenCalled();
    });
  });

  it("shows error toast on auth failure", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSignIn.mockResolvedValue({
      error: { message: "Invalid credentials" },
    });
    const user = userEvent.setup();

    render(<LoginForm />);
    await user.type(screen.getByLabelText("Email"), "a@b.com");
    await user.type(screen.getByLabelText("Password"), "wrong");
    await user.click(screen.getByRole("button", { name: "Sign In" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "error",
          message: "Invalid credentials",
        }),
      );
    });
    // Should NOT redirect
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("shows 'Signing in…' while loading", async () => {
    // Never resolve to keep loading state
    mockSignIn.mockReturnValue(new Promise(() => {}));
    const user = userEvent.setup();

    render(<LoginForm />);
    await user.type(screen.getByLabelText("Email"), "a@b.com");
    await user.type(screen.getByLabelText("Password"), "pass");
    await user.click(screen.getByRole("button", { name: "Sign In" }));

    await waitFor(() => {
      expect(screen.getByText("Signing in…")).toBeInTheDocument();
    });
  });
});
