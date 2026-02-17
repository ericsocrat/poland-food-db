/**
 * ComparisonGridSkeleton — shimmer placeholder for /app/compare.
 * Mirrors: header row + 2–3 product columns side by side.
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";

export function ComparisonGridSkeleton() {
  const columns = 3;

  return (
    <SkeletonContainer label="Loading comparison" className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <Skeleton variant="text" width="10rem" height={24} />
        <div className="flex gap-2">
          <Skeleton
            variant="rect"
            width={80}
            height={28}
            className="!rounded-lg"
          />
          <Skeleton
            variant="rect"
            width={60}
            height={28}
            className="!rounded-lg"
          />
        </div>
      </div>

      {/* Toolbar card */}
      <div className="card flex items-center justify-between">
        <Skeleton variant="text" width="8rem" height={14} />
        <Skeleton
          variant="rect"
          width={60}
          height={28}
          className="!rounded-lg"
        />
      </div>

      {/* Comparison grid */}
      <div className="card overflow-x-auto">
        {/* Product header row */}
        <div
          className="grid gap-4"
          style={{ gridTemplateColumns: `repeat(${columns}, 1fr)` }}
        >
          {Array.from({ length: columns }, (_, i) => (
            <div key={i} className="space-y-2 p-2">
              <Skeleton
                variant="rect"
                width="100%"
                height={60}
                className="!rounded-lg"
              />
              <Skeleton variant="text" width="80%" height={14} />
              <Skeleton variant="text" width="60%" height={12} />
            </div>
          ))}
        </div>

        {/* Data rows */}
        {Array.from({ length: 5 }, (_, row) => (
          <div
            key={row}
            className="grid gap-4 border-t py-3"
            style={{ gridTemplateColumns: `repeat(${columns}, 1fr)` }}
          >
            {Array.from({ length: columns }, (_, col) => (
              <div key={col} className="px-2">
                <Skeleton variant="text" width="70%" height={14} />
              </div>
            ))}
          </div>
        ))}
      </div>
    </SkeletonContainer>
  );
}
