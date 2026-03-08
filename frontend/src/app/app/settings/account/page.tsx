"use client";

// ─── Settings — Account (Email, Install App, Sign Out, Delete) ─────────────

import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { DeleteAccountDialog } from "@/components/settings/DeleteAccountDialog";
import { InstallAppSection } from "@/components/settings/InstallAppSection";
import { useAnalytics } from "@/hooks/use-analytics";
import {
    deleteUserData,
    getUserPreferences,
} from "@/lib/api";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Check, ChevronDown, Copy } from "lucide-react";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";

export default function AccountSettingsPage() {
  const router = useRouter();
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();

  const { data: prefs } = useQuery({
    queryKey: queryKeys.preferences,
    queryFn: async () => {
      const result = await getUserPreferences(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.preferences,
  });

  const [email, setEmail] = useState<string | null>(null);
  const [showDetails, setShowDetails] = useState(false);
  const [copied, setCopied] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [deleting, setDeleting] = useState(false);

  // Fetch user email from auth session
  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      setEmail(data.user?.email ?? null);
    });
  }, [supabase]);

  const handleCopyUserId = useCallback(async () => {
    if (!prefs?.user_id) return;
    await navigator.clipboard.writeText(prefs.user_id);
    setCopied(true);
    showToast({ type: "success", messageKey: "settings.copiedToClipboard" });
    setTimeout(() => setCopied(false), 2000);
  }, [prefs?.user_id]);

  async function handleLogout() {
    await supabase.auth.signOut();
    queryClient.clear();
    router.push("/auth/login");
    router.refresh();
  }

  async function handleDeleteAccount() {
    setDeleting(true);
    try {
      const result = await deleteUserData(supabase);
      if (!result.ok) {
        showToast({ type: "error", messageKey: "settings.deleteAccountError" });
        setDeleting(false);
        return;
      }
      track("account_deleted");
      showToast({
        type: "success",
        messageKey: "settings.deleteAccountSuccess",
      });
      queryClient.clear();
      router.push("/");
      router.refresh();
    } catch {
      showToast({ type: "error", messageKey: "settings.deleteAccountError" });
      setDeleting(false);
    }
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.settings", href: "/app/settings" },
          { labelKey: "settings.tabAccount" },
        ]}
      />
      <h1 className="text-xl font-bold text-foreground lg:text-2xl">
        {t("settings.tabAccount")}
      </h1>

      {/* Account section */}
      <section className="card border-red-100">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.account")}
        </h2>

        {/* Primary identifier: email */}
        {email && (
          <p className="mb-3 text-sm text-foreground-secondary">{email}</p>
        )}

        {/* Expandable account details with masked UUID + copy */}
        {prefs?.user_id && (
          <div className="mb-3">
            <button
              type="button"
              onClick={() => setShowDetails((prev) => !prev)}
              className="flex items-center gap-1 text-xs text-foreground-secondary hover:text-foreground-primary transition-colors"
              aria-expanded={showDetails}
            >
              <ChevronDown
                size={14}
                aria-hidden="true"
                className={`transition-transform ${showDetails ? "rotate-180" : ""}`}
              />
              {t("settings.accountDetails")}
            </button>

            {showDetails && (
              <div
                className="mt-2 flex items-center gap-2"
                data-testid="account-details"
              >
                <code className="text-xs text-foreground-secondary">
                  {prefs.user_id.slice(0, 4)}…{prefs.user_id.slice(-4)}
                </code>
                <button
                  type="button"
                  onClick={handleCopyUserId}
                  className="flex items-center gap-1 rounded border px-2 py-0.5 text-xs text-foreground-secondary hover:bg-surface-subtle transition-colors"
                  aria-label={t("settings.copyUserId")}
                >
                  {copied ? (
                    <Check size={12} aria-hidden="true" />
                  ) : (
                    <Copy size={12} aria-hidden="true" />
                  )}
                  {t("settings.copyUserId")}
                </button>
              </div>
            )}
          </div>
        )}

        <button
          onClick={handleLogout}
          className="w-full rounded-lg border border-red-200 px-4 py-2 text-sm font-medium text-red-600 transition-colors hover:bg-red-50"
        >
          {t("settings.signOut")}
        </button>

        <button
          type="button"
          onClick={() => setDeleteDialogOpen(true)}
          className="mt-3 w-full rounded-lg bg-error px-4 py-2 text-sm font-medium text-foreground-inverse transition-colors hover:bg-error/90"
          data-testid="delete-account-button"
        >
          {t("settings.deleteAccount")}
        </button>

        <DeleteAccountDialog
          open={deleteDialogOpen}
          loading={deleting}
          onConfirm={handleDeleteAccount}
          onCancel={() => setDeleteDialogOpen(false)}
        />
      </section>

      {/* Install App */}
      <InstallAppSection />
    </div>
  );
}
