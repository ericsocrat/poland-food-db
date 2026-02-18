"use client";

// ─── ExportButton — dropdown button for CSV / Text export ───────────────────

import { useState, useRef, useEffect, useCallback } from "react";
import { BarChart3, FileText } from "lucide-react";
import {
  exportProducts,
  exportComparison,
  type ExportableProduct,
} from "@/lib/export";
import { useTranslation } from "@/lib/i18n";
import { showToast } from "@/lib/toast";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface ExportButtonProps {
  /** Products to export */
  products: ExportableProduct[];
  /** Base filename (without extension) */
  filename?: string;
  /** If true, use comparison format (products as columns) for CSV */
  comparison?: boolean;
  /** Additional CSS classes */
  className?: string;
}

// ---------------------------------------------------------------------------
// Component
// ---------------------------------------------------------------------------

export function ExportButton({
  products,
  filename = "food-export",
  comparison = false,
  className = "",
}: Readonly<ExportButtonProps>) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  // Close on outside click
  useEffect(() => {
    if (!open) return;
    function handleClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [open]);

  // Close on Escape
  useEffect(() => {
    if (!open) return;
    function handleKey(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false);
    }
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, [open]);

  const handleExport = useCallback(
    (format: "csv" | "text") => {
      setOpen(false);

      if (!products.length) {
        showToast({ type: "info", messageKey: "export.nothingToExport" });
        return;
      }

      try {
        if (comparison && format === "csv") {
          exportComparison(products, filename);
        } else {
          exportProducts({ filename, format, products });
        }
        showToast({ type: "success", messageKey: "export.downloadStarted" });
      } catch {
        showToast({ type: "error", messageKey: "export.failed" });
      }
    },
    [products, filename, comparison],
  );

  return (
    <div ref={ref} className={`relative inline-block ${className}`}>
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="touch-target flex items-center gap-1.5 rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm font-medium text-gray-700 shadow-sm transition-colors hover:bg-gray-50 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
        aria-expanded={open}
        aria-haspopup="true"
      >
        {/* Download icon */}
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden="true"
        >
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="7 10 12 15 17 10" />
          <line x1="12" y1="15" x2="12" y2="3" />
        </svg>
        {t("export.export")}
        {/* Chevron */}
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="12"
          height="12"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden="true"
          className={`transition-transform ${open ? "rotate-180" : ""}`}
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>

      {open && (
        <div
          className="absolute right-0 z-20 mt-1 w-44 rounded-lg border border-gray-200 bg-white py-1 shadow-lg dark:border-gray-700 dark:bg-gray-800"
          role="menu"
        >
          <button
            type="button"
            role="menuitem"
            onClick={() => handleExport("csv")}
            className="flex w-full items-center gap-2 px-4 py-2 text-left text-sm text-gray-700 transition-colors hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700"
          >
            <BarChart3 size={14} aria-hidden="true" className="inline" />{" "}
            {t("export.asCSV")}
          </button>
          <button
            type="button"
            role="menuitem"
            onClick={() => handleExport("text")}
            className="flex w-full items-center gap-2 px-4 py-2 text-left text-sm text-gray-700 transition-colors hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700"
          >
            <FileText size={14} aria-hidden="true" className="inline" />{" "}
            {t("export.asText")}
          </button>
        </div>
      )}
    </div>
  );
}
