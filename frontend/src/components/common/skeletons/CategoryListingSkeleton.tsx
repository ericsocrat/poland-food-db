/**
 * CategoryListingSkeleton — shimmer placeholder for /app/categories/[slug].
 * Mirrors: back link, header with count, sort controls, product list.
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";
import { ProductCardSkeleton } from "./ProductCardSkeleton";

export function CategoryListingSkeleton() {
  return (
    <SkeletonContainer label="Loading category" className="space-y-4">
      {/* Back link */}
      <Skeleton variant="text" width="5rem" height={16} />

      {/* Header */}
      <div className="flex items-center justify-between">
        <Skeleton variant="text" width="10rem" height={24} />
        <Skeleton variant="text" width="5rem" height={14} />
      </div>

      {/* Sort controls */}
      <div className="flex items-center gap-2">
        <Skeleton
          variant="rect"
          width={120}
          height={36}
          className="!rounded-lg"
        />
        <Skeleton
          variant="rect"
          width={50}
          height={36}
          className="!rounded-lg"
        />
      </div>

      {/* Product list */}
      <ProductCardSkeleton count={5} />
    </SkeletonContainer>
  );
}
