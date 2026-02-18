/**
 * ListViewSkeleton — shimmer placeholder for /app/lists.
 * Mirrors: title + "new list" button, list cards with item counts.
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";

export function ListViewSkeleton() {
  return (
    <SkeletonContainer label="Loading lists" className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <Skeleton variant="text" width="8rem" height={24} />
        <Skeleton
          variant="rect"
          width={80}
          height={36}
          className="!rounded-lg"
        />
      </div>

      {/* List cards */}
      <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
        {Array.from({ length: 4 }, (_, i) => (
          <div key={i} className="card flex items-center justify-between">
            <div className="space-y-2 flex-1">
              <Skeleton variant="text" width="60%" height={16} />
              <Skeleton variant="text" width="40%" height={12} />
            </div>
            <div className="flex items-center gap-2">
              <Skeleton
                variant="rect"
                width={48}
                height={24}
                className="!rounded-full"
              />
              <Skeleton
                variant="rect"
                width={20}
                height={20}
                className="!rounded-md"
              />
            </div>
          </div>
        ))}
      </div>
    </SkeletonContainer>
  );
}
