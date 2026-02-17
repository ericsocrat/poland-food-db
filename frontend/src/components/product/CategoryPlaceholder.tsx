// ─── CategoryPlaceholder ─────────────────────────────────────────────────────
// Placeholder icon shown when a product has no image. Uses the
// category_icon emoji from the product profile.

interface CategoryPlaceholderProps {
  readonly icon: string;
  readonly productName: string;
  readonly size?: "sm" | "md" | "lg";
}

const sizeClasses = {
  sm: "h-10 w-10 text-lg",
  md: "h-16 w-16 text-2xl",
  lg: "h-48 w-full text-6xl",
} as const;

export function CategoryPlaceholder({
  icon,
  productName,
  size = "md",
}: CategoryPlaceholderProps) {
  return (
    <div
      aria-label={`${productName} — no image available`}
      className={`flex items-center justify-center rounded-xl bg-surface-muted text-foreground-muted ${sizeClasses[size]}`}
    >
      <span className="select-none" aria-hidden="true">
        {icon}
      </span>
    </div>
  );
}
