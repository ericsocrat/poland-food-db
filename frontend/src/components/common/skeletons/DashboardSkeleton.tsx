/**
 * DashboardSkeleton — shimmer placeholder for the /app dashboard page.
 * Mirrors actual composition: greeting → health summary → quick win → recently viewed → quick actions.
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function DashboardSkeleton() {
  return (
    <SkeletonContainer
      label="Loading dashboard"
      className="space-y-6 lg:space-y-8"
    >
      {/* Greeting */}
      <div className="space-y-2">
        <Skeleton variant="text" width="16rem" height={28} />
        <Skeleton variant="text" width="10rem" height={16} />
        <Skeleton variant="rect" width="6rem" height={22} className="rounded-full!" />
      </div>

      {/* Health summary */}
      <div className="card space-y-3">
        <Skeleton variant="text" width="10rem" height={18} />
        <div className="flex items-center gap-4">
          <Skeleton variant="rect" width={64} height={64} className="rounded-full!" />
          <div className="flex-1 space-y-2">
            <Skeleton variant="text" width="100%" height={12} />
            <Skeleton variant="text" width="80%" height={12} />
          </div>
        </div>
      </div>

      {/* Health insights panel */}
      <div className="space-y-3">
        <Skeleton variant="rect" width="100%" height={80} className="rounded-xl!" />
        <Skeleton variant="rect" width="100%" height={112} className="rounded-xl!" />
        <Skeleton variant="rect" width="100%" height={40} className="rounded-xl!" />
      </div>

      {/* Quick win card */}
      <div className="card space-y-3">
        <Skeleton variant="text" width="8rem" height={18} />
        <div className="flex items-center gap-3">
          <Skeleton variant="rect" width={32} height={32} className="rounded-full!" />
          <Skeleton variant="text" width="60%" height={14} />
          <Skeleton variant="rect" width={32} height={32} className="rounded-full!" />
        </div>
        <Skeleton variant="text" width="12rem" height={14} />
      </div>

      {/* Nutrition tip */}
      <div className="rounded-xl border bg-surface p-4 space-y-2">
        <div className="flex items-start gap-3">
          <Skeleton variant="rect" width={28} height={28} className="rounded-md!" />
          <div className="flex-1 space-y-1.5">
            <Skeleton variant="text" width="6rem" height={14} />
            <Skeleton variant="text" width="90%" height={12} />
            <Skeleton variant="text" width="60%" height={12} />
          </div>
        </div>
      </div>

      {/* Recently viewed */}
      <div className="space-y-2">
        <Skeleton variant="text" width="10rem" height={18} />
        <div className="space-y-2">
          {Array.from({ length: 3 }, (_, i) => (
            <div key={i} className="card flex items-center gap-3">
              <Skeleton variant="rect" width={40} height={40} className="rounded-lg!" />
              <div className="min-w-0 flex-1 space-y-1">
                <Skeleton variant="text" width="70%" height={14} />
                <Skeleton variant="text" width="40%" height={12} />
              </div>
              <Skeleton variant="rect" width={32} height={32} className="rounded-full!" />
            </div>
          ))}
        </div>
      </div>

      {/* Categories browse */}
      <div className="space-y-2">
        <Skeleton variant="text" width="10rem" height={18} />
        <div className="flex gap-3 overflow-hidden">
          {Array.from({ length: 6 }, (_, i) => (
            <div
              key={i}
              className="flex shrink-0 flex-col items-center gap-1.5 rounded-xl border bg-surface px-3 py-3"
              style={{ minWidth: "5rem" }}
            >
              <Skeleton variant="rect" width={32} height={32} />
              <Skeleton variant="text" width="3.5rem" height={12} />
            </div>
          ))}
        </div>
      </div>

      {/* Quick actions */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {Array.from({ length: 4 }, (_, i) => (
          <div
            key={i}
            className="card flex flex-col items-center gap-2 py-4 lg:py-6"
          >
            <Skeleton variant="rect" width={40} height={40} className="rounded-xl!" />
            <Skeleton variant="text" width="3.5rem" height={12} />
          </div>
        ))}
      </div>
    </SkeletonContainer>
  );
}
