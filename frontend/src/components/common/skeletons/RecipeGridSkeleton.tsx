/**
 * RecipeGridSkeleton — shimmer placeholder for /app/recipes browse page.
 * Mirrors: title + grid of recipe cards (1-col mobile, 2-col tablet, 3-col desktop).
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";

export function RecipeGridSkeleton() {
  return (
    <SkeletonContainer label="Loading recipes" className="space-y-4">
      {/* Breadcrumb */}
      <Skeleton variant="text" width="6rem" height={14} />

      {/* Title */}
      <Skeleton variant="text" width="8rem" height={28} />

      {/* Filter bar */}
      <div className="flex gap-2">
        {Array.from({ length: 3 }, (_, i) => (
          <Skeleton key={i} variant="rect" width={96} height={36} className="!rounded-lg" />
        ))}
      </div>

      {/* Recipe grid */}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3 lg:gap-4">
        {Array.from({ length: 6 }, (_, i) => (
          <div key={i} className="card flex flex-col gap-2 p-4">
            <Skeleton variant="text" width="80%" height={16} />
            <Skeleton variant="text" width="100%" height={12} />
            <div className="flex gap-3">
              <Skeleton variant="text" width="3rem" height={12} />
              <Skeleton variant="text" width="3rem" height={12} />
              <Skeleton variant="text" width="3rem" height={12} />
            </div>
            <div className="flex gap-1.5">
              <Skeleton variant="rect" width={48} height={18} className="!rounded-full" />
              <Skeleton variant="rect" width={48} height={18} className="!rounded-full" />
            </div>
          </div>
        ))}
      </div>
    </SkeletonContainer>
  );
}
