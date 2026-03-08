"use client";

import { SocialLoginButtons } from "@/components/auth/SocialLoginButtons";
import { Button } from "@/components/common/Button";
import { Logo } from "@/components/common/Logo";
import { SkipLink } from "@/components/common/SkipLink";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type { FormSubmitEvent } from "@/lib/types";
import { sanitizeRedirect } from "@/lib/validation";
import { Eye, EyeOff } from "lucide-react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";

function classifyAuthError(message: string): string {
  const lower = message.toLowerCase();
  if (lower.includes("rate") || lower.includes("too many")) {
    return "auth.tooManyAttempts";
  }
  return "auth.invalidCredentials";
}

export function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const supabase = createClient();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const { t } = useTranslation();

  const reason = searchParams.get("reason");
  const redirect = sanitizeRedirect(searchParams.get("redirect"));

  async function handleLogin(e: FormSubmitEvent) {
    e.preventDefault();
    setLoading(true);

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    setLoading(false);

    if (error) {
      showToast({ type: "error", messageKey: classifyAuthError(error.message) });
      return;
    }

    router.push(redirect);
    router.refresh();
  }

  return (
    <>
      <SkipLink />
      <div id="main-content" className="w-full max-w-sm">
        <div className="mb-2 flex justify-center lg:hidden">
          <Logo variant="lockup" size={36} />
        </div>
        <p className="mb-6 text-center text-xs font-medium uppercase tracking-widest text-brand lg:hidden">
          {t("landing.tagline")}
        </p>
        <h1 className="mb-2 text-center text-2xl font-bold text-foreground">
          {t("auth.welcomeBack")}
        </h1>
        <p className="mb-8 text-center text-sm text-foreground-secondary">
          {t("auth.signInSubtitle")}
        </p>

        {reason === "expired" && (
          <div className="mb-4 rounded-lg border border-warning-border bg-warning-bg p-3 text-sm text-warning-text">
            {t("auth.sessionExpiredBanner")}
          </div>
        )}

        <SocialLoginButtons />

        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label
              htmlFor="email"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("auth.email")}
            </label>
            <input
              id="email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="input-field"
              placeholder={t("auth.emailPlaceholder")}
            />
          </div>

          <div>
            <label
              htmlFor="password"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("auth.password")}
            </label>
            <div className="relative">
              <input
                id="password"
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="input-field pr-10"
              />
              <button
                type="button"
                onClick={() => setShowPassword((prev) => !prev)}
                className="absolute inset-y-0 right-0 flex items-center pr-3 text-foreground-muted hover:text-foreground-secondary"
                aria-label={
                  showPassword
                    ? t("auth.hidePassword")
                    : t("auth.showPassword")
                }
              >
                {showPassword ? (
                  <EyeOff className="h-4 w-4" />
                ) : (
                  <Eye className="h-4 w-4" />
                )}
              </button>
            </div>
            <div className="mt-1 text-right">
              <Link
                href="/auth/forgot-password"
                className="text-xs font-medium text-brand hover:text-brand-hover"
              >
                {t("auth.forgotPassword")}
              </Link>
            </div>
          </div>

          <Button type="submit" disabled={loading} fullWidth>
            {loading ? t("auth.signingIn") : t("auth.signIn")}
          </Button>
        </form>

        <p className="mt-6 text-center text-sm text-foreground-secondary">
          {t("auth.noAccount")}{" "}
          <Link
            href="/auth/signup"
            className="font-medium text-brand hover:text-brand-hover"
          >
            {t("auth.signUp")}
          </Link>
        </p>
      </div>
    </>
  );
}
