import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { SignupForm } from "./SignupForm";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
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

const mockSignUp = vi.fn();
vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      signUp: (...args: unknown[]) => mockSignUp(...args),
    },
  }),
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn() },
}));

beforeEach(() => {
  vi.clearAllMocks();
});

describe("SignupForm", () => {
  it("renders email and password fields", () => {
    render(<SignupForm />);
    expect(screen.getByLabelText("Email")).toBeInTheDocument();
    expect(screen.getByLabelText("Password")).toBeInTheDocument();
  });

  it("renders sign up button", () => {
    render(<SignupForm />);
    expect(screen.getByRole("button", { name: "Sign Up" })).toBeInTheDocument();
  });

  it("renders sign in link", () => {
    render(<SignupForm />);
    expect(screen.getByText("Sign in").closest("a")).toHaveAttribute(
      "href",
      "/auth/login",
    );
  });

  it("requires minimum 6 character password", () => {
    render(<SignupForm />);
    const passwordInput = screen.getByLabelText("Password");
    expect(passwordInput).toHaveAttribute("minLength", "6");
  });

  it("calls signUp on submit", async () => {
    mockSignUp.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "new@user.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(mockSignUp).toHaveBeenCalledWith(
        expect.objectContaining({
          email: "new@user.com",
          password: "secret123",
        }),
      );
    });
  });

  it("shows success toast and redirects on success", async () => {
    const { toast } = await import("sonner");
    mockSignUp.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "new@user.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(toast.success).toHaveBeenCalledWith(
        "Check your email to confirm your account.",
      );
      expect(mockPush).toHaveBeenCalledWith("/auth/login?msg=check-email");
    });
  });

  it("shows error toast on failure", async () => {
    const { toast } = await import("sonner");
    mockSignUp.mockResolvedValue({
      error: { message: "Email already in use" },
    });
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "dup@user.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith("Email already in use");
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("shows 'Creating account…' while loading", async () => {
    mockSignUp.mockReturnValue(new Promise(() => {}));
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "a@b.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(screen.getByText("Creating account…")).toBeInTheDocument();
    });
  });
});
