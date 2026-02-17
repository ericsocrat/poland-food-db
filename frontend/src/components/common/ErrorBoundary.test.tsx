import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ErrorBoundary } from "./ErrorBoundary";

// ─── Mocks ──────────────────────────────────────────────────────────────────

// Suppress console.error for expected error boundary triggers
const originalConsoleError = console.error;
beforeEach(() => {
  console.error = vi.fn();
  return () => {
    console.error = originalConsoleError;
  };
});

// ─── Helpers ────────────────────────────────────────────────────────────────

/** A component that throws on render — used to trigger error boundaries. */
function ThrowingComponent({ message }: { message?: string }): never {
  throw new Error(message ?? "Test crash");
}

/** A normal component that renders fine. */
function SafeComponent() {
  return <div data-testid="safe-content">Hello</div>;
}

// ─── Page-Level Boundary ────────────────────────────────────────────────────

describe("ErrorBoundary — page level", () => {
  it("renders children when no error occurs", () => {
    render(
      <ErrorBoundary level="page">
        <SafeComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByTestId("safe-content")).toBeInTheDocument();
    expect(screen.getByText("Hello")).toBeInTheDocument();
  });

  it("renders page fallback when child throws", () => {
    render(
      <ErrorBoundary level="page">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByTestId("error-boundary-page")).toBeInTheDocument();
    expect(
      screen.getByText("Something went wrong on this page"),
    ).toBeInTheDocument();
  });

  it("page fallback has role=alert for accessibility", () => {
    render(
      <ErrorBoundary level="page">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByRole("alert")).toBeInTheDocument();
  });

  it("page fallback shows Try again button", () => {
    render(
      <ErrorBoundary level="page">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByText("Try again")).toBeInTheDocument();
  });

  it("page fallback shows Go home link", () => {
    render(
      <ErrorBoundary level="page">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    const goHome = screen.getByText("Go home");
    expect(goHome).toBeInTheDocument();
    expect(goHome.closest("a")).toHaveAttribute("href", "/app");
  });

  it("page fallback shows description text", () => {
    render(
      <ErrorBoundary level="page">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(
      screen.getByText(/You can try again or go back/),
    ).toBeInTheDocument();
  });

  it("Try again resets the error state and re-renders children", () => {
    let shouldThrow = true;

    function ConditionalThrower() {
      if (shouldThrow) {
        throw new Error("First render crash");
      }
      return <div data-testid="recovered">Recovered!</div>;
    }

    render(
      <ErrorBoundary level="page">
        <ConditionalThrower />
      </ErrorBoundary>,
    );

    // First: error fallback is shown
    expect(screen.getByTestId("error-boundary-page")).toBeInTheDocument();

    // Fix the component
    shouldThrow = false;

    // Click "Try again"
    fireEvent.click(screen.getByText("Try again"));

    // Now the child renders successfully
    expect(screen.getByTestId("recovered")).toBeInTheDocument();
    expect(screen.getByText("Recovered!")).toBeInTheDocument();
  });
});

// ─── Section-Level Boundary ─────────────────────────────────────────────────

describe("ErrorBoundary — section level", () => {
  it("renders section fallback when child throws", () => {
    render(
      <ErrorBoundary level="section">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByTestId("error-boundary-section")).toBeInTheDocument();
  });

  it("section fallback shows 'This section couldn't load'", () => {
    render(
      <ErrorBoundary level="section">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByText("This section couldn't load")).toBeInTheDocument();
  });

  it("section fallback has role=alert", () => {
    render(
      <ErrorBoundary level="section">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByRole("alert")).toBeInTheDocument();
  });

  it("section fallback shows Try again button", () => {
    render(
      <ErrorBoundary level="section">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByText("Try again")).toBeInTheDocument();
  });

  it("section fallback does NOT show Go home link", () => {
    render(
      <ErrorBoundary level="section">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.queryByText("Go home")).not.toBeInTheDocument();
  });
});

// ─── Component-Level Boundary ───────────────────────────────────────────────

describe("ErrorBoundary — component level", () => {
  it("renders component placeholder when child throws", () => {
    render(
      <ErrorBoundary level="component">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByTestId("error-boundary-component")).toBeInTheDocument();
  });

  it("component placeholder shows dash", () => {
    render(
      <ErrorBoundary level="component">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByText("—")).toBeInTheDocument();
  });

  it("component placeholder has role=alert", () => {
    render(
      <ErrorBoundary level="component">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByRole("alert")).toBeInTheDocument();
  });

  it("component placeholder has tooltip text", () => {
    render(
      <ErrorBoundary level="component">
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    const el = screen.getByTestId("error-boundary-component");
    expect(el).toHaveAttribute("title", "This item couldn't display");
  });
});

// ─── Custom Fallback ────────────────────────────────────────────────────────

describe("ErrorBoundary — custom fallback", () => {
  it("renders custom ReactNode fallback", () => {
    render(
      <ErrorBoundary
        level="page"
        fallback={<div data-testid="custom-fallback">Custom!</div>}
      >
        <ThrowingComponent />
      </ErrorBoundary>,
    );
    expect(screen.getByTestId("custom-fallback")).toBeInTheDocument();
    expect(screen.getByText("Custom!")).toBeInTheDocument();
  });

  it("renders custom function fallback with error and reset", () => {
    render(
      <ErrorBoundary
        level="page"
        fallback={(error, reset) => (
          <div>
            <p data-testid="error-message">{error.message}</p>
            <button onClick={reset}>Reset</button>
          </div>
        )}
      >
        <ThrowingComponent message="Custom crash" />
      </ErrorBoundary>,
    );
    expect(screen.getByTestId("error-message")).toHaveTextContent(
      "Custom crash",
    );
    expect(screen.getByText("Reset")).toBeInTheDocument();
  });
});

// ─── Containment ────────────────────────────────────────────────────────────

describe("ErrorBoundary — containment", () => {
  it("crash in one section does not affect sibling", () => {
    render(
      <div>
        <ErrorBoundary level="section">
          <ThrowingComponent />
        </ErrorBoundary>
        <ErrorBoundary level="section">
          <SafeComponent />
        </ErrorBoundary>
      </div>,
    );
    // First section shows fallback
    expect(screen.getByTestId("error-boundary-section")).toBeInTheDocument();
    // Second section renders normally
    expect(screen.getByTestId("safe-content")).toBeInTheDocument();
    expect(screen.getByText("Hello")).toBeInTheDocument();
  });

  it("crash in component does not affect parent section", () => {
    render(
      <ErrorBoundary level="section">
        <div>
          <ErrorBoundary level="component">
            <ThrowingComponent />
          </ErrorBoundary>
          <SafeComponent />
        </div>
      </ErrorBoundary>,
    );
    // Component shows minimal placeholder
    expect(screen.getByTestId("error-boundary-component")).toBeInTheDocument();
    // Sibling is still visible
    expect(screen.getByTestId("safe-content")).toBeInTheDocument();
    // Section-level fallback is NOT shown
    expect(
      screen.queryByTestId("error-boundary-section"),
    ).not.toBeInTheDocument();
  });
});

// ─── Error Logging ──────────────────────────────────────────────────────────

describe("ErrorBoundary — error reporting", () => {
  it("logs error in development mode", () => {
    render(
      <ErrorBoundary level="page" context={{ page: "test" }}>
        <ThrowingComponent message="Logged crash" />
      </ErrorBoundary>,
    );
    // console.error is mocked — ErrorBoundary calls reportBoundaryError
    // which calls console.error in development
    expect(console.error).toHaveBeenCalled();
  });
});
