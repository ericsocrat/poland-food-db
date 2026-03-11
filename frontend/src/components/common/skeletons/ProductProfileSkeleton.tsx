/**
 * ProductProfileSkeleton — shimmer placeholder for /app/product/[id].
 * Mirrors the 2-column grid layout with progressive disclosure.
 * Left: hero image, score gauge, name, badges, flags.
 * Right: quick summary cards (score interpretation, traffic lights, alternatives).
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function ProductProfileSkeleton() {
  return (
    <SkeletonContainer label="Loading product" className="space-y-4 lg:space-y-6">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2">
        <Skeleton variant="text" width="3rem" height={14} />
        <Skeleton variant="text" width="1rem" height={14} />
        <Skeleton variant="text" width="4rem" height={14} />
        <Skeleton variant="text" width="1rem" height={14} />
        <Skeleton variant="text" width="8rem" height={14} />
      </div>

      {/* Desktop: 2-column grid; Mobile: single column */}
      <div className="lg:grid lg:grid-cols-12 lg:gap-6">
        {/* Left column */}
        <div className="space-y-4 lg:col-span-5 lg:space-y-6">
          <div className="card">
            {/* Hero image placeholder */}
            <div className="mb-4">
              <Skeleton
                variant="rect"
                width="100%"
                height={200}
                className="rounded-xl!"
              />
            </div>

            {/* Score gauge + product info */}
            <div className="flex items-start gap-4">
              <Skeleton
                variant="circle"
                width={64}
                height={64}
                className="shrink-0"
              />
              <div className="min-w-0 flex-1 space-y-2">
                {/* Product name */}
                <Skeleton variant="text" width="85%" height={22} />
                {/* Brand */}
                <Skeleton variant="text" width="50%" height={16} />
                {/* Action buttons */}
                <div className="flex flex-wrap gap-2">
                  {Array.from({ length: 4 }, (_, i) => (
                    <Skeleton
                      key={i}
                      variant="rect"
                      width={36}
                      height={36}
                      className="rounded-lg!"
                    />
                  ))}
                </div>
              </div>
            </div>

            {/* Badge row: Nutri-Score, NOVA, score band */}
            <div className="mt-2 flex items-center gap-2">
              <Skeleton variant="rect" width={56} height={22} className="rounded-full!" />
              <Skeleton variant="rect" width={64} height={22} className="rounded-full!" />
              <Skeleton variant="rect" width={60} height={22} className="rounded-full!" />
            </div>

            {/* Metadata row */}
            <div className="mt-3 flex flex-wrap gap-2">
              <Skeleton variant="text" width="5rem" height={12} />
              <Skeleton variant="text" width="7rem" height={12} />
            </div>
          </div>

          {/* Score interpretation card */}
          <div className="card">
            <Skeleton variant="text" width="70%" height={16} />
          </div>
        </div>

        {/* Right column — quick summary (default collapsed state) */}
        <div className="mt-4 space-y-4 lg:col-span-7 lg:mt-0 lg:space-y-6">
          {/* Score summary card */}
          <div className="card space-y-3">
            <Skeleton variant="text" width="60%" height={18} />
            <Skeleton variant="text" lines={2} />
          </div>

          {/* Traffic light strip card */}
          <div className="card">
            <div className="flex items-center justify-between gap-2">
              {Array.from({ length: 4 }, (_, i) => (
                <Skeleton
                  key={i}
                  variant="rect"
                  width="24%"
                  height={48}
                  className="rounded-lg!"
                />
              ))}
            </div>
          </div>

          {/* Alternatives preview card */}
          <div className="card space-y-3">
            <Skeleton variant="text" width="50%" height={16} />
            {Array.from({ length: 2 }, (_, i) => (
              <div key={i} className="flex items-center gap-3">
                <Skeleton
                  variant="rect"
                  width={48}
                  height={48}
                  className="shrink-0 rounded-lg!"
                />
                <div className="flex-1 space-y-1">
                  <Skeleton variant="text" width="70%" height={14} />
                  <Skeleton variant="text" width="40%" height={12} />
                </div>
              </div>
            ))}
          </div>

          {/* Expand button */}
          <Skeleton
            variant="rect"
            width="100%"
            height={40}
            className="rounded-lg!"
          />
        </div>
      </div>
    </SkeletonContainer>
  );
}
