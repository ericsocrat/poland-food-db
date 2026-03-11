/**
 * ListDetailSkeleton — shimmer placeholder for list detail pages.
 * Mirrors: list info card + product item rows with scores.
 * Used by: /app/lists/[id], /lists/shared/[token]
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function ListDetailSkeleton() {
  return (
    <SkeletonContainer label="Loading list" className="space-y-6">
      {/* Breadcrumbs */}
      <div className="flex items-center gap-2">
        <Skeleton variant="text" width="3rem" height={14} />
        <Skeleton variant="text" width="1rem" height={14} />
        <Skeleton variant="text" width="6rem" height={14} />
      </div>

      {/* List header card */}
      <div className="card space-y-3">
        <div className="flex items-center justify-between">
          <Skeleton variant="text" width="10rem" height={22} />
          <div className="flex gap-2">
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
        <Skeleton variant="text" width="70%" height={14} />
        <Skeleton variant="text" width="5rem" height={12} />
      </div>

      {/* Product items */}
      {Array.from({ length: 5 }, (_, i) => (
        <div key={i} className="card flex items-center gap-3">
          <Skeleton
            variant="rect"
            width={48}
            height={48}
            className="rounded-lg!"
          />
          <div className="flex-1 space-y-1">
            <Skeleton variant="text" width="60%" height={14} />
            <Skeleton variant="text" width="40%" height={12} />
          </div>
          <Skeleton variant="circle" width={36} height={36} />
        </div>
      ))}
    </SkeletonContainer>
  );
}
