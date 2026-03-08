/**
 * IngredientDetailSkeleton — shimmer placeholder for ingredient detail page.
 * Mirrors: breadcrumbs + header card (icon + name + concern badge) + detail sections.
 * Used by: /app/ingredient/[id]
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function IngredientDetailSkeleton() {
  return (
    <SkeletonContainer label="Loading ingredient" className="space-y-6">
      {/* Breadcrumbs */}
      <div className="flex items-center gap-2">
        <Skeleton variant="text" width="3rem" height={14} />
        <Skeleton variant="text" width="1rem" height={14} />
        <Skeleton variant="text" width="6rem" height={14} />
      </div>

      {/* Header card */}
      <div className="card flex items-start gap-4">
        <Skeleton
          variant="rect"
          width={56}
          height={56}
          className="!rounded-xl"
        />
        <div className="flex-1 space-y-2">
          <Skeleton variant="text" width="10rem" height={22} />
          <div className="flex gap-2">
            <Skeleton
              variant="rect"
              width={72}
              height={24}
              className="!rounded-full"
            />
            <Skeleton
              variant="rect"
              width={56}
              height={24}
              className="!rounded-full"
            />
          </div>
        </div>
      </div>

      {/* Detail sections */}
      {Array.from({ length: 2 }, (_, i) => (
        <div key={i} className="card space-y-3">
          <Skeleton variant="text" width="7rem" height={18} />
          <Skeleton variant="text" width="100%" height={14} />
          <Skeleton variant="text" width="85%" height={14} />
          <Skeleton variant="text" width="60%" height={14} />
        </div>
      ))}
    </SkeletonContainer>
  );
}
