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
    functions: { invoke: vi.fn() },
  }),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

// Mock TurnstileWidget to expose a trigger for simulating token receipt
let capturedOnSuccess: ((token: string) => void) | undefined;
let capturedOnError: (() => void) | undefined;

vi.mock("@/components/common/TurnstileWidget", () => ({
  TurnstileWidget: ({
    onSuccess,
    onError,
  }: {
    onSuccess: (token: string) => void;
    onError?: () => void;
    onExpire?: () => void;
    action?: string;
    className?: string;
  }) => {
    capturedOnSuccess = onSuccess;
    capturedOnError = onError;
    return (
      <div data-testid="turnstile-widget">
        <button
          data-testid="turnstile-trigger"
          onClick={() => onSuccess("mock-captcha-token")}
        >
          Verify
        </button>
      </div>
    );
  },
}));

const mockVerify = vi.fn();
vi.mock("@/lib/turnstile", () => ({
  verifyTurnstileToken: (...args: unknown[]) => mockVerify(...args),
}));

beforeEach(() => {
  vi.clearAllMocks();
  capturedOnSuccess = undefined;
  capturedOnError = undefined;
  // Default: Turnstile verification passes
  mockVerify.mockResolvedValue({ valid: true });
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

  it("renders the Turnstile widget", () => {
    render(<SignupForm />);
    expect(screen.getByTestId("turnstile-widget")).toBeInTheDocument();
  });

  it("disables submit button until Turnstile token is received", () => {
    render(<SignupForm />);
    const button = screen.getByRole("button", { name: "Sign Up" });
    expect(button).toBeDisabled();
  });

  it("enables submit button after Turnstile token is received", async () => {
    const user = userEvent.setup();
    render(<SignupForm />);

    await user.click(screen.getByTestId("turnstile-trigger"));

    const button = screen.getByRole("button", { name: "Sign Up" });
    expect(button).not.toBeDisabled();
  });

  it("renders sign in link", () => {
    render(<SignupForm />);
    expect(screen.getByText("Sign In").closest("a")).toHaveAttribute(
      "href",
      "/auth/login",
    );
  });

  it("requires minimum 6 character password", () => {
    render(<SignupForm />);
    const passwordInput = screen.getByLabelText("Password");
    expect(passwordInput).toHaveAttribute("minLength", "6");
  });

  it("calls signUp on submit after Turnstile verification", async () => {
    mockSignUp.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "new@user.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByTestId("turnstile-trigger"));
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(mockVerify).toHaveBeenCalled();
      expect(mockSignUp).toHaveBeenCalledWith(
        expect.objectContaining({
          email: "new@user.com",
          password: "secret123",
        }),
      );
    });
  });

  it("passes captchaToken in signUp options", async () => {
    mockSignUp.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "new@user.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByTestId("turnstile-trigger"));
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(mockSignUp).toHaveBeenCalledWith(
        expect.objectContaining({
          options: expect.objectContaining({
            captchaToken: "mock-captcha-token",
          }),
        }),
      );
    });
  });

  it("shows error toast when Turnstile verification fails", async () => {
    const { showToast } = await import("@/lib/toast");
    mockVerify.mockResolvedValue({
      valid: false,
      error: "Token expired",
    });
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "new@user.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByTestId("turnstile-trigger"));
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "error",
          messageKey: "auth.captchaFailed",
        }),
      );
    });
    expect(mockSignUp).not.toHaveBeenCalled();
  });

  it("shows success toast and redirects on success", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSignUp.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "new@user.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByTestId("turnstile-trigger"));
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "success",
          messageKey: "auth.checkEmail",
        }),
      );
      expect(mockPush).toHaveBeenCalledWith("/auth/login?msg=check-email");
    });
  });

  it("shows error toast on auth failure", async () => {
    const { showToast } = await import("@/lib/toast");
    mockSignUp.mockResolvedValue({
      error: { message: "Email already in use" },
    });
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "dup@user.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByTestId("turnstile-trigger"));
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          type: "error",
          message: "Email already in use",
        }),
      );
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("shows 'Creating account…' while loading", async () => {
    mockSignUp.mockReturnValue(new Promise(() => {}));
    const user = userEvent.setup();

    render(<SignupForm />);
    await user.type(screen.getByLabelText("Email"), "a@b.com");
    await user.type(screen.getByLabelText("Password"), "secret123");
    await user.click(screen.getByTestId("turnstile-trigger"));
    await user.click(screen.getByRole("button", { name: "Sign Up" }));

    await waitFor(() => {
      expect(screen.getByText("Creating account…")).toBeInTheDocument();
    });
  });

  it("disables Turnstile token on error callback", async () => {
    render(<SignupForm />);
    // Simulate getting a token first, then an error
    await waitFor(() => {
      capturedOnSuccess?.("some-token");
    });
    await waitFor(() => {
      capturedOnError?.();
    });
    const button = screen.getByRole("button", { name: "Sign Up" });
    expect(button).toBeDisabled();
  });
});
