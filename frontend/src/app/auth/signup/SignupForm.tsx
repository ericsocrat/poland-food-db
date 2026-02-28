"use client";

import { useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { showToast } from "@/lib/toast";
import { createClient } from "@/lib/supabase/client";
import { useTranslation } from "@/lib/i18n";
import { SkipLink } from "@/components/common/SkipLink";
import { TurnstileWidget } from "@/components/common/TurnstileWidget";
import { verifyTurnstileToken } from "@/lib/turnstile";
import type { FormSubmitEvent } from "@/lib/types";

export function SignupForm() {
  const router = useRouter();
  const supabase = createClient();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [turnstileToken, setTurnstileToken] = useState<string | null>(null);
  const { t } = useTranslation();

  const handleTurnstileSuccess = useCallback((token: string) => {
    setTurnstileToken(token);
  }, []);

  const handleTurnstileError = useCallback(() => {
    setTurnstileToken(null);
  }, []);

  const handleTurnstileExpire = useCallback(() => {
    setTurnstileToken(null);
  }, []);

  async function handleSignup(e: FormSubmitEvent) {
    e.preventDefault();

    if (!turnstileToken) {
      showToast({ type: "error", messageKey: "auth.captchaRequired" });
      return;
    }

    setLoading(true);

    // Server-side Turnstile verification
    const verification = await verifyTurnstileToken(supabase, turnstileToken);
    if (!verification.valid) {
      setLoading(false);
      showToast({ type: "error", messageKey: "auth.captchaFailed" });
      return;
    }

    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: `${globalThis.location.origin}/auth/callback`,
        captchaToken: turnstileToken,
      },
    });

    setLoading(false);

    if (error) {
      showToast({ type: "error", message: error.message });
      return;
    }

    showToast({ type: "success", messageKey: "auth.checkEmail" });
    router.push("/auth/login?msg=check-email");
  }

  return (
    <div className="flex min-h-screen items-center justify-center px-4">
      <SkipLink />
      <div id="main-content" className="w-full max-w-sm">
        <h1 className="mb-2 text-center text-2xl font-bold text-foreground">
          {t("auth.createAccount")}
        </h1>
        <p className="mb-8 text-center text-sm text-foreground-secondary">
          {t("auth.signUpSubtitle")}
        </p>

        <form onSubmit={handleSignup} className="space-y-4">
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
            <input
              id="password"
              type="password"
              required
              minLength={6}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="input-field"
              placeholder={t("auth.passwordPlaceholder")}
            />
          </div>

          <TurnstileWidget
            onSuccess={handleTurnstileSuccess}
            onError={handleTurnstileError}
            onExpire={handleTurnstileExpire}
            action="signup"
            className="flex justify-center"
          />

          <button
            type="submit"
            disabled={loading || !turnstileToken}
            className="btn-primary w-full"
          >
            {loading ? t("auth.creatingAccount") : t("auth.signUp")}
          </button>
        </form>

        <p className="mt-6 text-center text-sm text-foreground-secondary">
          {t("auth.hasAccount")}{" "}
          <Link
            href="/auth/login"
            className="font-medium text-brand hover:text-brand-hover"
          >
            {t("auth.signIn")}
          </Link>
        </p>
      </div>
    </div>
  );
}
