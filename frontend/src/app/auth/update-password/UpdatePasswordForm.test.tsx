import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { UpdatePasswordForm } from "./UpdatePasswordForm";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
const mockUpdateUser = vi.fn();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      updateUser: (...args: unknown[]) => mockUpdateUser(...args),
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

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const map: Record<string, string> = {
        "auth.updatePasswordTitle": "Update your password",
        "auth.updatePasswordSubtitle":
          "Enter a new password for your account.",
        "auth.newPassword": "New password",
        "auth.confirmPassword": "Confirm password",
        "auth.updatePassword": "Update password",
        "auth.updatingPassword": "Updating\u2026",
        "auth.backToLogin": "Back to login",
        "auth.showPassword": "Show password",
        "auth.hidePassword": "Hide password",
        "landing.tagline": "tagline",
      };
      return map[key] ?? key;
    },
  }),
}));

beforeEach(() => {
  vi.clearAllMocks();
});

describe("UpdatePasswordForm", () => {
  it("renders password fields and submit button", () => {
    render(<UpdatePasswordForm />);
    expect(screen.getByLabelText("New password")).toBeInTheDocument();
    expect(screen.getByLabelText("Confirm password")).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "Update password" }),
    ).toBeInTheDocument();
  });

  it("renders back to login link", () => {
    render(<UpdatePasswordForm />);
    const link = screen.getByText("Back to login").closest("a");
    expect(link).toHaveAttribute("href", "/auth/login");
  });

  it("shows password mismatch error when passwords differ", async () => {
    const { showToast } = await import("@/lib/toast");
    const user = userEvent.setup();

    render(<UpdatePasswordForm />);
    await user.type(screen.getByLabelText("New password"), "password1");
    await user.type(screen.getByLabelText("Confirm password"), "password2");
    await user.click(
      screen.getByRole("button", { name: "Update password" }),
    );

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith({
        type: "error",
        messageKey: "auth.passwordMismatch",
      });
    });
    expect(mockUpdateUser).not.toHaveBeenCalled();
  });

  it("calls updateUser when passwords match", async () => {
    mockUpdateUser.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<UpdatePasswordForm />);
    await user.type(screen.getByLabelText("New password"), "newpass123");
    await user.type(screen.getByLabelText("Confirm password"), "newpass123");
    await user.click(
      screen.getByRole("button", { name: "Update password" }),
    );

    await waitFor(() => {
      expect(mockUpdateUser).toHaveBeenCalledWith({ password: "newpass123" });
    });
  });

  it("redirects to login on success", async () => {
    const { showToast } = await import("@/lib/toast");
    mockUpdateUser.mockResolvedValue({ error: null });
    const user = userEvent.setup();

    render(<UpdatePasswordForm />);
    await user.type(screen.getByLabelText("New password"), "newpass123");
    await user.type(screen.getByLabelText("Confirm password"), "newpass123");
    await user.click(
      screen.getByRole("button", { name: "Update password" }),
    );

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith({
        type: "success",
        messageKey: "auth.passwordUpdated",
      });
      expect(mockPush).toHaveBeenCalledWith("/auth/login");
    });
  });

  it("shows error toast on update failure", async () => {
    const { showToast } = await import("@/lib/toast");
    mockUpdateUser.mockResolvedValue({
      error: { message: "Password too weak" },
    });
    const user = userEvent.setup();

    render(<UpdatePasswordForm />);
    await user.type(screen.getByLabelText("New password"), "weak");
    await user.type(screen.getByLabelText("Confirm password"), "weak");
    await user.click(
      screen.getByRole("button", { name: "Update password" }),
    );

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith({
        type: "error",
        message: "Password too weak",
      });
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  // ─── Password Toggle ──────────────────────────────────────────────────────

  it("toggles new password visibility", async () => {
    const user = userEvent.setup();
    render(<UpdatePasswordForm />);

    const passwordInput = screen.getByLabelText("New password");
    expect(passwordInput).toHaveAttribute("type", "password");

    const toggleButtons = screen.getAllByRole("button", {
      name: "Show password",
    });
    await user.click(toggleButtons[0]);
    expect(passwordInput).toHaveAttribute("type", "text");
  });

  it("toggles confirm password visibility independently", async () => {
    const user = userEvent.setup();
    render(<UpdatePasswordForm />);

    const confirmInput = screen.getByLabelText("Confirm password");
    expect(confirmInput).toHaveAttribute("type", "password");

    const toggleButtons = screen.getAllByRole("button", {
      name: "Show password",
    });
    await user.click(toggleButtons[1]);
    expect(confirmInput).toHaveAttribute("type", "text");

    // First field should remain password
    expect(screen.getByLabelText("New password")).toHaveAttribute(
      "type",
      "password",
    );
  });

  it("shows updating state while loading", async () => {
    mockUpdateUser.mockReturnValue(new Promise(() => {}));
    const user = userEvent.setup();

    render(<UpdatePasswordForm />);
    await user.type(screen.getByLabelText("New password"), "newpass123");
    await user.type(screen.getByLabelText("Confirm password"), "newpass123");
    await user.click(
      screen.getByRole("button", { name: "Update password" }),
    );

    await waitFor(() => {
      expect(screen.getByText("Updating…")).toBeInTheDocument();
    });
  });
});
