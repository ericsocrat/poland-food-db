"use client";

import { Logo } from "@/components/common/Logo";
import { SkipLink } from "@/components/common/SkipLink";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type { FormSubmitEvent } from "@/lib/types";
import Link from "next/link";
import { useState } from "react";

export function ForgotPasswordForm() {
  const supabase = createClient();
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const { t } = useTranslation();

  async function handleSubmit(e: FormSubmitEvent) {
    e.preventDefault();
    setLoading(true);

    await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${globalThis.location.origin}/auth/callback?type=recovery`,
    });

    setLoading(false);
    setSent(true);
    showToast({ type: "success", messageKey: "auth.resetEmailSent" });
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
          {t("auth.resetPasswordTitle")}
        </h1>
        <p className="mb-8 text-center text-sm text-foreground-secondary">
          {t("auth.resetPasswordSubtitle")}
        </p>

        {sent ? (
          <div className="space-y-4">
            <div className="rounded-lg border border-green-200 bg-green-50 p-4 text-sm text-green-800">
              {t("auth.resetEmailSent")}
            </div>
            <Link
              href="/auth/login"
              className="btn-primary block w-full text-center"
            >
              {t("auth.backToLogin")}
            </Link>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
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

            <button
              type="submit"
              disabled={loading}
              className="btn-primary w-full"
            >
              {loading
                ? t("auth.sendingResetLink")
                : t("auth.sendResetLink")}
            </button>

            <p className="text-center text-sm text-foreground-secondary">
              <Link
                href="/auth/login"
                className="font-medium text-brand hover:text-brand-hover"
              >
                {t("auth.backToLogin")}
              </Link>
            </p>
          </form>
        )}
      </div>
    </>
  );
}
