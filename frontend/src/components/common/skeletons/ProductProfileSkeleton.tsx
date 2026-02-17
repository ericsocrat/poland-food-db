/**
 * ProductProfileSkeleton — shimmer placeholder for /app/product/[id].
 * Mirrors: back button, hero area, product name, tabs, content blocks.
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";

export function ProductProfileSkeleton() {
  return (
    <SkeletonContainer label="Loading product" className="space-y-4">
      {/* Back link */}
      <Skeleton variant="text" width="4rem" height={16} />

      {/* Hero / image area */}
      <div className="card space-y-4">
        {/* Product header */}
        <div className="flex items-start gap-4">
          {/* Hero image placeholder */}
          <Skeleton
            variant="rect"
            width={96}
            height={96}
            className="flex-shrink-0 !rounded-lg"
          />

          <div className="flex-1 space-y-2">
            {/* Product name */}
            <Skeleton variant="text" width="80%" height={20} />
            {/* Brand / category */}
            <Skeleton variant="text" width="50%" height={14} />
            {/* Score pill row */}
            <div className="flex items-center gap-2">
              <Skeleton
                variant="rect"
                width={48}
                height={24}
                className="!rounded-full"
              />
              <Skeleton variant="circle" width={24} height={24} />
            </div>
          </div>
        </div>

        {/* Action buttons row */}
        <div className="flex items-center gap-2">
          <Skeleton
            variant="rect"
            width={80}
            height={32}
            className="!rounded-lg"
          />
          <Skeleton
            variant="rect"
            width={80}
            height={32}
            className="!rounded-lg"
          />
          <Skeleton
            variant="rect"
            width={80}
            height={32}
            className="!rounded-lg"
          />
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 border-b border">
        {Array.from({ length: 4 }, (_, i) => (
          <Skeleton
            key={i}
            variant="rect"
            width={80}
            height={36}
            className="!rounded-t-lg !rounded-b-none"
          />
        ))}
      </div>

      {/* Tab content — nutrition-like blocks */}
      <div className="card space-y-3">
        <Skeleton variant="text" width="40%" height={18} />
        <Skeleton variant="text" lines={3} />
        <Skeleton
          variant="rect"
          width="100%"
          height={120}
          className="!rounded-lg"
        />
      </div>
    </SkeletonContainer>
  );
}
