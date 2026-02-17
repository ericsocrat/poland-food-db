/**
 * DashboardSkeleton — shimmer placeholder for the /app dashboard page.
 * Mirrors: greeting, quick actions, categories, stats bar, sections + product rows.
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";
import { ProductCardSkeleton } from "./ProductCardSkeleton";

export function DashboardSkeleton() {
  return (
    <SkeletonContainer label="Loading dashboard" className="space-y-6">
      {/* Greeting */}
      <div className="space-y-1">
        <Skeleton variant="text" width="14rem" height={24} />
        <Skeleton variant="text" width="10rem" height={14} />
      </div>

      {/* Quick actions — 4-col grid */}
      <div className="grid grid-cols-4 gap-3">
        {Array.from({ length: 4 }, (_, i) => (
          <div key={i} className="card flex flex-col items-center gap-2 py-3">
            <Skeleton variant="rect" width={32} height={32} />
            <Skeleton variant="text" width="3rem" height={12} />
          </div>
        ))}
      </div>

      {/* Categories browse — horizontal row */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <Skeleton variant="text" width="8rem" height={20} />
          <Skeleton variant="text" width="4rem" height={14} />
        </div>
        <div className="flex gap-3 overflow-hidden">
          {Array.from({ length: 6 }, (_, i) => (
            <div
              key={i}
              className="flex shrink-0 flex-col items-center gap-1.5 rounded-xl border bg-surface px-3 py-3"
              style={{ minWidth: "5rem" }}
            >
              <Skeleton variant="rect" width={32} height={32} />
              <Skeleton variant="text" width="3.5rem" height={12} />
            </div>
          ))}
        </div>
      </div>

      {/* Stats bar — 2×2 on mobile, 4-col on sm+ */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {Array.from({ length: 4 }, (_, i) => (
          <div key={i} className="card flex flex-col items-center gap-1 py-3">
            <Skeleton
              variant="rect"
              width={32}
              height={32}
              className="!rounded-md"
            />
            <Skeleton variant="text" width="3rem" height={20} />
            <Skeleton variant="text" width="4rem" height={12} />
          </div>
        ))}
      </div>

      {/* Nutrition tip */}
      <div className="card flex items-start gap-3">
        <Skeleton variant="rect" width={32} height={32} />
        <div className="min-w-0 flex-1 space-y-1">
          <Skeleton variant="text" width="6rem" height={14} />
          <Skeleton variant="text" width="100%" height={14} />
        </div>
      </div>

      {/* Recently viewed section */}
      <div className="space-y-2">
        <Skeleton variant="text" width="12rem" height={20} />
        <ProductCardSkeleton count={3} />
      </div>

      {/* Favorites section */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <Skeleton variant="text" width="8rem" height={20} />
          <Skeleton variant="text" width="4rem" height={14} />
        </div>
        <ProductCardSkeleton count={2} />
      </div>
    </SkeletonContainer>
  );
}
