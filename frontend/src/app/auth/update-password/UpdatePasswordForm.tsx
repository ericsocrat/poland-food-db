"use client";

import { Logo } from "@/components/common/Logo";
import { SkipLink } from "@/components/common/SkipLink";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type { FormSubmitEvent } from "@/lib/types";
import { Eye, EyeOff } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";

export function UpdatePasswordForm() {
  const router = useRouter();
  const supabase = createClient();
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const { t } = useTranslation();

  async function handleSubmit(e: FormSubmitEvent) {
    e.preventDefault();

    if (password !== confirmPassword) {
      showToast({ type: "error", messageKey: "auth.passwordMismatch" });
      return;
    }

    setLoading(true);

    const { error } = await supabase.auth.updateUser({ password });

    setLoading(false);

    if (error) {
      showToast({ type: "error", message: error.message });
      return;
    }

    showToast({ type: "success", messageKey: "auth.passwordUpdated" });
    router.push("/auth/login");
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
          {t("auth.updatePasswordTitle")}
        </h1>
        <p className="mb-8 text-center text-sm text-foreground-secondary">
          {t("auth.updatePasswordSubtitle")}
        </p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label
              htmlFor="new-password"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("auth.newPassword")}
            </label>
            <div className="relative">
              <input
                id="new-password"
                type={showPassword ? "text" : "password"}
                required
                minLength={6}
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
          </div>

          <div>
            <label
              htmlFor="confirm-password"
              className="mb-1 block text-sm font-medium text-foreground-secondary"
            >
              {t("auth.confirmPassword")}
            </label>
            <div className="relative">
              <input
                id="confirm-password"
                type={showConfirmPassword ? "text" : "password"}
                required
                minLength={6}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className="input-field pr-10"
              />
              <button
                type="button"
                onClick={() => setShowConfirmPassword((prev) => !prev)}
                className="absolute inset-y-0 right-0 flex items-center pr-3 text-foreground-muted hover:text-foreground-secondary"
                aria-label={
                  showConfirmPassword
                    ? t("auth.hidePassword")
                    : t("auth.showPassword")
                }
              >
                {showConfirmPassword ? (
                  <EyeOff className="h-4 w-4" />
                ) : (
                  <Eye className="h-4 w-4" />
                )}
              </button>
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="btn-primary w-full"
          >
            {loading
              ? t("auth.updatingPassword")
              : t("auth.updatePassword")}
          </button>
        </form>

        <p className="mt-6 text-center text-sm text-foreground-secondary">
          <Link
            href="/auth/login"
            className="font-medium text-brand hover:text-brand-hover"
          >
            {t("auth.backToLogin")}
          </Link>
        </p>
      </div>
    </>
  );
}
