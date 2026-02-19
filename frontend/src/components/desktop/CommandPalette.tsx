"use client";

// ─── CommandPalette — Ctrl+K quick navigation & search ──────────────────────
// VS Code / Spotlight-style command palette for power users.
// Desktop only (lg+). Uses native <dialog> following the SaveSearchDialog pattern.

import {
  useState,
  useRef,
  useEffect,
  useCallback,
  useMemo,
  type KeyboardEvent,
} from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import {
  Search,
  Home,
  Camera,
  ClipboardList,
  Scale,
  FolderOpen,
  Settings,
  ArrowRight,
} from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { getRecentlyViewed } from "@/lib/api";
import { queryKeys } from "@/lib/query-keys";
import { useTranslation } from "@/lib/i18n";
import type { LucideIcon } from "lucide-react";

// ─── Types ──────────────────────────────────────────────────────────────────

interface NavItem {
  id: string;
  label: string;
  href: string;
  icon: LucideIcon;
  section: "navigation";
}

interface ProductItem {
  id: string;
  label: string;
  sublabel: string;
  href: string;
  section: "recent";
}

interface SearchItem {
  id: string;
  label: string;
  href: string;
  section: "search";
}

type PaletteItem = NavItem | ProductItem | SearchItem;

// ─── Props ──────────────────────────────────────────────────────────────────

interface CommandPaletteProps {
  open: boolean;
  onClose: () => void;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function CommandPalette({
  open,
  onClose,
}: Readonly<CommandPaletteProps>) {
  const router = useRouter();
  const { t } = useTranslation();
  const [query, setQuery] = useState("");
  const [activeIndex, setActiveIndex] = useState(0);
  const dialogRef = useRef<HTMLDialogElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const listRef = useRef<HTMLDivElement>(null);

  // Fetch recent products (lightweight — reuses cache if dashboard was visited)
  const supabase = createClient();
  const { data: recentData } = useQuery({
    queryKey: queryKeys.recentlyViewed(5),
    queryFn: () => getRecentlyViewed(supabase, 5),
    staleTime: 60_000,
    enabled: open,
  });

  // Navigation items
  const navItems: NavItem[] = useMemo(
    () => [
      {
        id: "nav-dashboard",
        label: t("commandPalette.goToDashboard"),
        href: "/app",
        icon: Home,
        section: "navigation",
      },
      {
        id: "nav-search",
        label: t("commandPalette.goToSearch"),
        href: "/app/search",
        icon: Search,
        section: "navigation",
      },
      {
        id: "nav-scan",
        label: t("commandPalette.goToScan"),
        href: "/app/scan",
        icon: Camera,
        section: "navigation",
      },
      {
        id: "nav-lists",
        label: t("commandPalette.goToLists"),
        href: "/app/lists",
        icon: ClipboardList,
        section: "navigation",
      },
      {
        id: "nav-categories",
        label: t("commandPalette.goToCategories"),
        href: "/app/categories",
        icon: FolderOpen,
        section: "navigation",
      },
      {
        id: "nav-compare",
        label: t("commandPalette.goToCompare"),
        href: "/app/compare",
        icon: Scale,
        section: "navigation",
      },
      {
        id: "nav-settings",
        label: t("commandPalette.goToSettings"),
        href: "/app/settings",
        icon: Settings,
        section: "navigation",
      },
    ],
    [t],
  );

  // Recent product items
  const recentItems: ProductItem[] = useMemo(() => {
    if (!recentData?.ok || !recentData.data?.products) return [];
    return recentData.data.products.slice(0, 5).map((p) => ({
      id: `recent-${p.product_id}`,
      label: p.product_name,
      sublabel: p.brand ?? p.category,
      href: `/app/product/${p.product_id}`,
      section: "recent" as const,
    }));
  }, [recentData]);

  // Filter items by query
  const filteredItems: PaletteItem[] = useMemo(() => {
    const q = query.toLowerCase().trim();
    const items: PaletteItem[] = [];

    // Filter nav items
    const matchedNav = q
      ? navItems.filter((item) => item.label.toLowerCase().includes(q))
      : navItems;
    items.push(...matchedNav);

    // Filter recent products
    const matchedRecent = q
      ? recentItems.filter(
          (item) =>
            item.label.toLowerCase().includes(q) ||
            item.sublabel.toLowerCase().includes(q),
        )
      : recentItems;
    items.push(...matchedRecent);

    // If query doesn't match much, offer a search option
    if (q && matchedNav.length === 0) {
      items.push({
        id: "search-query",
        label: t("commandPalette.searchFor", { query }),
        href: `/app/search?q=${encodeURIComponent(query)}`,
        section: "search",
      });
    }

    return items;
  }, [query, navItems, recentItems, t]);

  // Reset state when opening/closing
  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    if (open && !el.open) {
      setQuery("");
      setActiveIndex(0);
      el.showModal();
      // Focus input after dialog opens
      requestAnimationFrame(() => inputRef.current?.focus());
    } else if (!open && el.open) {
      el.close();
    }
  }, [open]);

  // Keep active index in bounds
  useEffect(() => {
    if (activeIndex >= filteredItems.length) {
      setActiveIndex(Math.max(0, filteredItems.length - 1));
    }
  }, [filteredItems.length, activeIndex]);

  // Scroll active item into view
  useEffect(() => {
    const list = listRef.current;
    if (!list) return;
    const activeEl = list.querySelector("[data-active='true']");
    activeEl?.scrollIntoView({ block: "nearest" });
  }, [activeIndex]);

  // Handle native dialog cancel (Escape)
  const handleCancel = useCallback(() => {
    onClose();
  }, [onClose]);

  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    el.addEventListener("cancel", handleCancel);
    return () => el.removeEventListener("cancel", handleCancel);
  }, [handleCancel]);

  // Navigate to selected item
  const selectItem = useCallback(
    (item: PaletteItem) => {
      onClose();
      router.push(item.href);
    },
    [onClose, router],
  );

  // Keyboard navigation within the palette
  const handleKeyDown = useCallback(
    (e: KeyboardEvent<HTMLInputElement>) => {
      switch (e.key) {
        case "ArrowDown":
          e.preventDefault();
          setActiveIndex((i) => Math.min(i + 1, filteredItems.length - 1));
          break;
        case "ArrowUp":
          e.preventDefault();
          setActiveIndex((i) => Math.max(i - 1, 0));
          break;
        case "Enter":
          e.preventDefault();
          if (filteredItems[activeIndex]) {
            selectItem(filteredItems[activeIndex]);
          }
          break;
      }
    },
    [filteredItems, activeIndex, selectItem],
  );

  // Click on backdrop closes
  const handleBackdropClick = useCallback(
    (e: React.MouseEvent<HTMLDialogElement>) => {
      if (e.target === dialogRef.current) {
        onClose();
      }
    },
    [onClose],
  );

  // Section separators
  const getSectionLabel = useCallback(
    (item: PaletteItem, index: number): string | null => {
      const LABELS: Record<string, string> = {
        navigation: t("commandPalette.navigation"),
        recent: t("commandPalette.recentProducts"),
      };

      if (index === 0) {
        return LABELS[item.section] ?? null;
      }
      const prevItem = filteredItems[index - 1];
      if (prevItem.section !== item.section) {
        return LABELS[item.section] ?? null;
      }
      return null;
    },
    [filteredItems, t],
  );

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <dialog
      ref={dialogRef}
      aria-label={t("commandPalette.placeholder")}
      onClick={handleBackdropClick}
      className="fixed inset-0 z-50 m-auto mt-[15vh] mb-auto w-full max-w-lg rounded-2xl bg-surface p-0 shadow-2xl backdrop:bg-black/40"
    >
      {/* Search input */}
      <div className="flex items-center gap-3 border-b border-border px-4 py-3">
        <Search
          size={18}
          aria-hidden="true"
          className="shrink-0 text-foreground-secondary"
        />
        <input
          ref={inputRef}
          type="text"
          value={query}
          onChange={(e) => {
            setQuery(e.target.value);
            setActiveIndex(0);
          }}
          onKeyDown={handleKeyDown}
          placeholder={t("commandPalette.placeholder")}
          className="flex-1 bg-transparent text-base text-foreground outline-none placeholder:text-foreground-secondary/60"
          aria-label={t("commandPalette.placeholder")}
          autoComplete="off"
          spellCheck={false}
        />
        <kbd className="hidden rounded border border-border bg-surface-muted px-1.5 py-0.5 text-xs text-foreground-secondary sm:inline-block">
          ESC
        </kbd>
      </div>

      {/* Results list */}
      <div ref={listRef} className="max-h-[50vh] overflow-y-auto py-2">
        {filteredItems.length === 0 && (
          <p className="px-4 py-6 text-center text-sm text-foreground-secondary">
            {t("commandPalette.noResults")}
          </p>
        )}

        {filteredItems.map((item, index) => {
          const sectionLabel = getSectionLabel(item, index);
          const isActive = index === activeIndex;

          return (
            <div key={item.id}>
              {sectionLabel && (
                <div className="px-4 pb-1 pt-3 text-xs font-semibold uppercase tracking-wider text-foreground-secondary/70">
                  {sectionLabel}
                </div>
              )}
              <button
                type="button"
                aria-current={isActive || undefined}
                data-active={isActive}
                onClick={() => selectItem(item)}
                onMouseEnter={() => setActiveIndex(index)}
                className={`flex w-full cursor-pointer items-center gap-3 px-4 py-2.5 text-left text-sm transition-colors ${
                  isActive
                    ? "bg-brand-subtle text-brand"
                    : "text-foreground hover:bg-surface-subtle"
                }`}
              >
                {item.section === "navigation" && (
                  <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-surface-muted">
                    <item.icon size={16} aria-hidden="true" />
                  </span>
                )}
                {item.section === "search" && (
                  <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-brand-subtle text-brand">
                    <ArrowRight size={16} aria-hidden="true" />
                  </span>
                )}
                <div className="min-w-0 flex-1">
                  <span className="block truncate font-medium">
                    {item.label}
                  </span>
                  {item.section === "recent" && "sublabel" in item && (
                    <span className="block truncate text-xs text-foreground-secondary">
                      {item.sublabel}
                    </span>
                  )}
                </div>
                {isActive && (
                  <kbd className="hidden shrink-0 rounded border border-border bg-surface-muted px-1.5 py-0.5 text-xs text-foreground-secondary sm:inline-block">
                    ↵
                  </kbd>
                )}
              </button>
            </div>
          );
        })}
      </div>
    </dialog>
  );
}
