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

import { buttonClasses } from "@/components/common/Button";
import { type ErrorType, ErrorIllustration } from "@/components/common/ErrorIllustration";
import { classifyError, type ErrorCategory } from "@/lib/error-classifier";
import { reportBoundaryError, type ErrorContext } from "@/lib/error-reporter";
import { useTranslation } from "@/lib/i18n";
import { Component, type ErrorInfo, type ReactNode } from "react";

// ─── Error Category → Illustration + i18n mapping ──────────────────────────

const CATEGORY_ILLUSTRATION: Record<ErrorCategory, ErrorType> = {
  network: "offline",
  auth: "server-error",
  server: "server-error",
  unknown: "server-error",
};

const CATEGORY_I18N: Record<ErrorCategory, { title: string; description: string }> = {
  network: {
    title: "errorBoundary.networkTitle",
    description: "errorBoundary.networkDescription",
  },
  auth: {
    title: "errorBoundary.authTitle",
    description: "errorBoundary.authDescription",
  },
  server: {
    title: "errorBoundary.serverTitle",
    description: "errorBoundary.serverDescription",
  },
  unknown: {
    title: "errorBoundary.pageTitle",
    description: "errorBoundary.pageDescription",
  },
};

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
}: Readonly<{
  error: Error;
  onReset: () => void;
}>) {
  const { t } = useTranslation();
  const digest = (error as Error & { digest?: string }).digest;
  const category = classifyError(error);
  const illustration = CATEGORY_ILLUSTRATION[category];
  const i18nKeys = CATEGORY_I18N[category];

  return (
    <div
      className="flex min-h-[60vh] flex-col items-center justify-center px-4 text-center"
      role="alert"
      data-testid="error-boundary-page"
      data-error-category={category}
    >
      <div className="mb-4" aria-hidden="true">
        <ErrorIllustration type={illustration} width={160} height={133} />
      </div>
      <h2 className="mb-2 text-xl font-bold text-foreground">
        {t(i18nKeys.title)}
      </h2>
      <p className="mb-6 max-w-md text-sm text-foreground-secondary">
        {t(i18nKeys.description)}
      </p>
      {digest && (
        <p className="mb-4 font-mono text-xs text-foreground-muted">
          {t("errorBoundary.errorId")}: {digest}
        </p>
      )}
      <div className="flex gap-3">
        <button
          onClick={onReset}
          className={buttonClasses("primary", "md")}
        >
          {t("common.tryAgain")}
        </button>
        {category === "auth" ? (
          <a
            href="/auth/login"
            className={buttonClasses("secondary", "md")}
          >
            {t("errorBoundary.signIn")}
          </a>
        ) : (
          <a
            href="/app"
            className={buttonClasses("secondary", "md")}
          >
            {t("errorBoundary.goHome")}
          </a>
        )}
      </div>
    </div>
  );
}

function SectionFallback({ onReset }: Readonly<{ onReset: () => void }>) {
  const { t } = useTranslation();
  return (
    <div
      className="my-4 flex flex-col items-center justify-center rounded-lg border border-dashed border-strong p-6 text-center"
      role="alert"
      data-testid="error-boundary-section"
    >
      <div className="mb-2" aria-hidden="true">
        <ErrorIllustration type="server-error" width={80} height={67} />
      </div>
      <p className="mb-3 text-sm font-medium text-foreground">
        {t("errorBoundary.sectionTitle")}
      </p>
      <button
        onClick={onReset}
        className={buttonClasses("primary", "sm")}
      >
        {t("common.tryAgain")}
      </button>
    </div>
  );
}

function ComponentFallback() {
  const { t } = useTranslation();
  return (
    <span
      className="inline-flex items-center justify-center rounded border border-dashed border-border px-2 py-0.5 text-xs text-foreground-muted"
      role="alert"
      data-testid="error-boundary-component"
      title={t("errorBoundary.componentTooltip")}
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
        return <SectionFallback onReset={this.handleReset} />;
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
