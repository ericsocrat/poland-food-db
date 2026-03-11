/**
 * SavedItemsSkeleton — shimmer placeholder for saved items lists.
 * Mirrors: card rows with title, subtitle, and action buttons.
 * Used by: /app/search/saved, /app/compare/saved
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function SavedItemsSkeleton() {
  return (
    <SkeletonContainer label="Loading saved items" className="space-y-3">
      {Array.from({ length: 4 }, (_, i) => (
        <div key={i} className="card flex items-center justify-between">
          <div className="flex-1 space-y-2">
            <Skeleton variant="text" width="55%" height={16} />
            <Skeleton variant="text" width="75%" height={12} />
            <Skeleton variant="text" width="30%" height={12} />
          </div>
          <div className="flex items-center gap-2">
            <Skeleton
              variant="rect"
              width={32}
              height={32}
              className="rounded-md!"
            />
            <Skeleton
              variant="rect"
              width={32}
              height={32}
              className="rounded-md!"
            />
          </div>
        </div>
      ))}
    </SkeletonContainer>
  );
}
