/**
 * ProductCardSkeleton — shimmer placeholder matching the ProductRow layout.
 * Used in search results, category listings, and dashboard sections.
 */

import { Skeleton, SkeletonContainer } from "../Skeleton";

interface ProductCardSkeletonProps {
  /** Number of card skeletons to render. @default 3 */
  count?: number;
}

export function ProductCardSkeleton({
  count = 3,
}: Readonly<ProductCardSkeletonProps>) {
  return (
    <SkeletonContainer label="Loading products" className="space-y-2">
      {Array.from({ length: count }, (_, i) => (
        <div key={i} className="card flex items-center gap-3">
          {/* Score badge */}
          <Skeleton
            variant="rect"
            width={48}
            height={48}
            className="flex-shrink-0 !rounded-lg"
          />

          {/* Product info */}
          <div className="min-w-0 flex-1 space-y-2">
            <Skeleton variant="text" width="70%" height={14} />
            <Skeleton variant="text" width="50%" height={12} />
          </div>

          {/* Nutri badge */}
          <Skeleton
            variant="circle"
            width={32}
            height={32}
            className="flex-shrink-0"
          />
        </div>
      ))}
    </SkeletonContainer>
  );
}
