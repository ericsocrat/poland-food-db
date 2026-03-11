/**
 * WatchlistSkeleton — shimmer placeholder for watchlist page.
 * Mirrors: product cards with score column + product info + sparkline area.
 * Used by: /app/watchlist (replaces ad-hoc animate-pulse blocks)
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function WatchlistSkeleton() {
  return (
    <SkeletonContainer label="Loading watchlist" className="space-y-3">
      {Array.from({ length: 4 }, (_, i) => (
        <div key={i} className="card flex items-center gap-3">
          <Skeleton
            variant="rect"
            width={48}
            height={48}
            className="rounded-lg!"
          />
          <div className="flex-1 space-y-1">
            <Skeleton variant="text" width="55%" height={14} />
            <Skeleton variant="text" width="35%" height={12} />
          </div>
          <Skeleton variant="rect" width={64} height={32} className="rounded-md!" />
        </div>
      ))}
    </SkeletonContainer>
  );
}
