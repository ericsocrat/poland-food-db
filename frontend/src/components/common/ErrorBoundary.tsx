// ─── ErrorBoundary — Multi-level React Error Boundary ───────────────────────
// Three-level containment: page, section, component.
//
// - page:      Full-page fallback with "Try again" + "Go home" + error ID.
// - section:   Inline card replacing the crashed section, with "Try again".
// - component: Minimal dashed-border placeholder.
//
// All text sourced from i18n. Dark-mode compatible via design tokens.
// Errors logged via error-reporter.ts (console in dev, telemetry-ready in prod).
//
// Usage:
//   <ErrorBoundary level="section" context={{ page: "product" }}>
//     <NutritionFacts data={data} />
//   </ErrorBoundary>

"use client";

import React, { Component, type ErrorInfo, type ReactNode } from "react";
import { reportBoundaryError, type ErrorContext } from "@/lib/error-reporter";
import { translate } from "@/lib/i18n";
import { AlertTriangle } from "lucide-react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type ErrorBoundaryLevel = "page" | "section" | "component";

export interface ErrorBoundaryProps {
  /** Containment level — determines fallback style and recovery actions. */
  level: ErrorBoundaryLevel;
  /** Optional custom fallback. Receives the error and a reset callback. */
  fallback?: ReactNode | ((error: Error, reset: () => void) => ReactNode);
  /** Context metadata for error logging (e.g., EAN, page name). */
  context?: ErrorContext;
  /** Children to protect. */
  children: ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

// ─── Default Fallbacks ──────────────────────────────────────────────────────

function PageFallback({
  error,
  onReset,
}: {
  error: Error;
  onReset: () => void;
}) {
  const digest = (error as Error & { digest?: string }).digest;
  return (
    <div
      className="flex min-h-[60vh] flex-col items-center justify-center px-4 text-center"
      role="alert"
      data-testid="error-boundary-page"
    >
      <div className="mb-3" aria-hidden="true">
        <AlertTriangle size={40} style={{ color: "var(--color-warning)" }} />
      </div>
      <h2
        className="mb-2 text-xl font-bold"
        style={{ color: "var(--color-text-primary)" }}
      >
        {translate("en", "errorBoundary.pageTitle")}
      </h2>
      <p
        className="mb-6 max-w-md text-sm"
        style={{ color: "var(--color-text-secondary)" }}
      >
        {translate("en", "errorBoundary.pageDescription")}
      </p>
      {digest && (
        <p
          className="mb-4 font-mono text-xs"
          style={{ color: "var(--color-text-muted)" }}
        >
          {translate("en", "errorBoundary.errorId")}: {digest}
        </p>
      )}
      <div className="flex gap-3">
        <button
          onClick={onReset}
          className="rounded-lg px-5 py-2.5 text-sm font-medium text-white"
          style={{ backgroundColor: "var(--color-brand)" }}
        >
          {translate("en", "common.tryAgain")}
        </button>
        <a
          href="/app"
          className="rounded-lg border px-5 py-2.5 text-sm font-medium"
          style={{
            borderColor: "var(--color-border)",
            color: "var(--color-text-primary)",
          }}
        >
          {translate("en", "errorBoundary.goHome")}
        </a>
      </div>
    </div>
  );
}

function SectionFallback({ onReset }: { error: Error; onReset: () => void }) {
  return (
    <div
      className="my-4 flex flex-col items-center justify-center rounded-lg border border-dashed p-6 text-center"
      role="alert"
      data-testid="error-boundary-section"
      style={{ borderColor: "var(--color-border-strong)" }}
    >
      <div className="mb-2" aria-hidden="true">
        <AlertTriangle size={28} style={{ color: "var(--color-warning)" }} />
      </div>
      <p
        className="mb-3 text-sm font-medium"
        style={{ color: "var(--color-text-primary)" }}
      >
        {translate("en", "errorBoundary.sectionTitle")}
      </p>
      <button
        onClick={onReset}
        className="rounded-md px-4 py-1.5 text-sm font-medium text-white"
        style={{ backgroundColor: "var(--color-brand)" }}
      >
        {translate("en", "common.tryAgain")}
      </button>
    </div>
  );
}

function ComponentFallback() {
  return (
    <span
      className="inline-flex items-center justify-center rounded border border-dashed px-2 py-0.5 text-xs"
      role="alert"
      data-testid="error-boundary-component"
      style={{
        borderColor: "var(--color-border)",
        color: "var(--color-text-muted)",
      }}
      title={translate("en", "errorBoundary.componentTooltip")}
    >
      —
    </span>
  );
}

// ─── ErrorBoundary Class Component ──────────────────────────────────────────

export class ErrorBoundary extends Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    reportBoundaryError(error, errorInfo, {
      level: this.props.level,
      ...this.props.context,
    });
  }

  handleReset = (): void => {
    this.setState({ hasError: false, error: null });
  };

  renderFallback(): ReactNode {
    const { level, fallback } = this.props;
    const { error } = this.state;

    if (!error) return null;

    // Custom fallback takes precedence
    if (fallback) {
      return typeof fallback === "function"
        ? fallback(error, this.handleReset)
        : fallback;
    }

    // Default fallback per level
    switch (level) {
      case "page":
        return <PageFallback error={error} onReset={this.handleReset} />;
      case "section":
        return <SectionFallback error={error} onReset={this.handleReset} />;
      case "component":
        return <ComponentFallback />;
    }
  }

  render(): ReactNode {
    if (this.state.hasError) {
      return this.renderFallback();
    }
    return this.props.children;
  }
}
