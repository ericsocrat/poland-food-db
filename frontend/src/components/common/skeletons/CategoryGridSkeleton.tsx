/**
 * CategoryGridSkeleton — shimmer placeholder for /app/categories index.
 * Mirrors: title + grid of category cards (2-col mobile, 3-col desktop).
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";

export function CategoryGridSkeleton() {
  return (
    <SkeletonContainer label="Loading categories" className="space-y-4">
      {/* Title */}
      <Skeleton variant="text" width="10rem" height={24} />

      {/* Category grid */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-3 xl:grid-cols-4 lg:gap-4">
        {Array.from({ length: 9 }, (_, i) => (
          <div key={i} className="card flex flex-col items-center gap-2 py-4">
            <Skeleton
              variant="rect"
              width={40}
              height={40}
              className="!rounded-lg"
            />
            <Skeleton variant="text" width="70%" height={14} />
            <Skeleton variant="text" width="50%" height={12} />
          </div>
        ))}
      </div>
    </SkeletonContainer>
  );
}
