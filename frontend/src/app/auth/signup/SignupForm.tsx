"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import { useTranslation } from "@/lib/i18n";
import type { FormSubmitEvent } from "@/lib/types";

export function SignupForm() {
  const router = useRouter();
  const supabase = createClient();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const { t } = useTranslation();

  async function handleSignup(e: FormSubmitEvent) {
    e.preventDefault();
    setLoading(true);

    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: `${globalThis.location.origin}/auth/callback`,
      },
    });

    setLoading(false);

    if (error) {
      toast.error(error.message);
      return;
    }

    toast.success(t("auth.checkEmail"));
    router.push("/auth/login?msg=check-email");
  }

  return (
    <div className="flex min-h-screen items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <h1 className="mb-2 text-center text-2xl font-bold text-gray-900">
          {t("auth.createAccount")}
        </h1>
        <p className="mb-8 text-center text-sm text-gray-500">
          {t("auth.signUpSubtitle")}
        </p>

        <form onSubmit={handleSignup} className="space-y-4">
          <div>
            <label
              htmlFor="email"
              className="mb-1 block text-sm font-medium text-gray-700"
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
              className="mb-1 block text-sm font-medium text-gray-700"
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

          <button
            type="submit"
            disabled={loading}
            className="btn-primary w-full"
          >
            {loading ? t("auth.creatingAccount") : t("auth.signUp")}
          </button>
        </form>

        <p className="mt-6 text-center text-sm text-gray-500">
          {t("auth.hasAccount")}{" "}
          <Link
            href="/auth/login"
            className="font-medium text-brand-600 hover:text-brand-700"
          >
            {t("auth.signIn")}
          </Link>
        </p>
      </div>
    </div>
  );
}
