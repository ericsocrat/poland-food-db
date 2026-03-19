import type { CameraErrorKind } from "@/hooks/use-barcode-scanner";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ScannerErrorState } from "./ScannerErrorState";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

vi.mock("@/components/common/Button", () => ({
  Button: ({
    children,
    onClick,
    ...rest
  }: {
    children: React.ReactNode;
    onClick?: () => void;
    variant?: string;
    icon?: React.ReactNode;
  }) => (
    <button onClick={onClick} {...rest}>
      {children}
    </button>
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

const ALL_ERROR_KINDS: CameraErrorKind[] = [
  "permission-prompt",
  "permission-denied",
  "permission-unknown",
  "no-camera",
  "generic",
];

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ScannerErrorState", () => {
  const onRetry = vi.fn();
  const onManualEntry = vi.fn();

  beforeEach(() => vi.clearAllMocks());

  // ─── Rendering for all 5 error kinds ────────────────────────────────────

  it.each(ALL_ERROR_KINDS)("renders without crashing for error=%s", (kind) => {
    const { container } = render(
      <ScannerErrorState
        error={kind}
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(container.firstChild).toBeTruthy();
  });

  // ─── Title text per error kind ──────────────────────────────────────────

  it("shows noCameraTitle for no-camera error", () => {
    render(
      <ScannerErrorState
        error="no-camera"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.noCameraTitle")).toBeInTheDocument();
  });

  it("shows cameraBlocked for permission-denied error", () => {
    render(
      <ScannerErrorState
        error="permission-denied"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.cameraBlocked")).toBeInTheDocument();
  });

  it("shows cameraPermissionRequired for permission-prompt error", () => {
    render(
      <ScannerErrorState
        error="permission-prompt"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(
      screen.getByText("scan.cameraPermissionRequired"),
    ).toBeInTheDocument();
  });

  it("shows cameraPermissionRequired for permission-unknown error", () => {
    render(
      <ScannerErrorState
        error="permission-unknown"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(
      screen.getByText("scan.cameraPermissionRequired"),
    ).toBeInTheDocument();
  });

  it("shows cameraUnavailable for generic error", () => {
    render(
      <ScannerErrorState
        error="generic"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.cameraUnavailable")).toBeInTheDocument();
  });

  // ─── Hint text per error kind ───────────────────────────────────────────

  it("shows noCameraHint for no-camera error", () => {
    render(
      <ScannerErrorState
        error="no-camera"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.noCameraHint")).toBeInTheDocument();
  });

  it("shows cameraBlockedHint for permission-denied", () => {
    render(
      <ScannerErrorState
        error="permission-denied"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.cameraBlockedHint")).toBeInTheDocument();
  });

  it("shows cameraPermissionHint for permission-prompt", () => {
    render(
      <ScannerErrorState
        error="permission-prompt"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.cameraPermissionHint")).toBeInTheDocument();
  });

  it("shows cameraPermissionUnknownHint for permission-unknown", () => {
    render(
      <ScannerErrorState
        error="permission-unknown"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(
      screen.getByText("scan.cameraPermissionUnknownHint"),
    ).toBeInTheDocument();
  });

  it("shows cameraUnavailableHint for generic", () => {
    render(
      <ScannerErrorState
        error="generic"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.cameraUnavailableHint")).toBeInTheDocument();
  });

  // ─── CTA Button visibility ─────────────────────────────────────────────

  it("shows reload button for permission errors", () => {
    render(
      <ScannerErrorState
        error="permission-denied"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.reloadPage")).toBeInTheDocument();
  });

  it("does NOT show reload button for permission-prompt", () => {
    render(
      <ScannerErrorState
        error="permission-prompt"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.queryByText("scan.reloadPage")).toBeNull();
  });

  it("does NOT show reload button for generic error", () => {
    render(
      <ScannerErrorState
        error="generic"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.queryByText("scan.reloadPage")).toBeNull();
  });

  it("shows retry button for generic error", () => {
    render(
      <ScannerErrorState
        error="generic"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.getByText("scan.retryCamera")).toBeInTheDocument();
  });

  it("does NOT show retry button for permission-denied", () => {
    render(
      <ScannerErrorState
        error="permission-denied"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    expect(screen.queryByText("scan.retryCamera")).toBeNull();
  });

  it("always shows manual entry button", () => {
    for (const kind of ALL_ERROR_KINDS) {
      const { unmount } = render(
        <ScannerErrorState
          error={kind}
          onRetry={onRetry}
          onManualEntry={onManualEntry}
        />,
      );
      expect(screen.getByText("scan.enterManually")).toBeInTheDocument();
      unmount();
    }
  });

  // ─── Callbacks ──────────────────────────────────────────────────────────

  it("calls onRetry when retry button clicked", async () => {
    const user = userEvent.setup();
    render(
      <ScannerErrorState
        error="generic"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    await user.click(screen.getByText("scan.retryCamera"));
    expect(onRetry).toHaveBeenCalledOnce();
  });

  it("calls onManualEntry when manual entry button clicked", async () => {
    const user = userEvent.setup();
    render(
      <ScannerErrorState
        error="generic"
        onRetry={onRetry}
        onManualEntry={onManualEntry}
      />,
    );
    await user.click(screen.getByText("scan.enterManually"));
    expect(onManualEntry).toHaveBeenCalledOnce();
  });
});
