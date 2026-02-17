/**
 * SearchResultsSkeleton — shimmer placeholder for /app/search results.
 * Mirrors: results count bar + list of product rows.
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";
import { ProductCardSkeleton } from "./ProductCardSkeleton";

export function SearchResultsSkeleton() {
  return (
    <SkeletonContainer label="Loading search results" className="space-y-4">
      {/* Results count bar */}
      <div className="flex items-center justify-between">
        <Skeleton variant="text" width="10rem" height={14} />
        <Skeleton variant="text" width="4rem" height={12} />
      </div>

      {/* Product list */}
      <ProductCardSkeleton count={6} />
    </SkeletonContainer>
  );
}
