/**
 * DashboardSkeleton — shimmer placeholder for the /app dashboard page.
 * Mirrors: title, stats bar (2×4 grid), section headers + product rows.
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";
import { ProductCardSkeleton } from "./ProductCardSkeleton";

export function DashboardSkeleton() {
  return (
    <SkeletonContainer label="Loading dashboard" className="space-y-6">
      {/* Title */}
      <Skeleton variant="text" width="10rem" height={24} />

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
