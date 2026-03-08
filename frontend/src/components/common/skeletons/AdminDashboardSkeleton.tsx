/**
 * AdminDashboardSkeleton — shimmer placeholder for admin pages.
 * Mirrors: metric summary cards + data tables / content area.
 * Used by: /app/admin/monitoring, /app/admin/metrics
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function AdminDashboardSkeleton() {
  return (
    <SkeletonContainer label="Loading admin dashboard" className="space-y-6">
      {/* Summary metric cards */}
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        {Array.from({ length: 4 }, (_, i) => (
          <div key={i} className="card space-y-2">
            <Skeleton variant="text" width="60%" height={12} />
            <Skeleton variant="text" width="4rem" height={28} />
            <Skeleton variant="text" width="40%" height={12} />
          </div>
        ))}
      </div>

      {/* Content rows */}
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        {Array.from({ length: 2 }, (_, i) => (
          <div key={i} className="card space-y-3">
            <Skeleton variant="text" width="8rem" height={18} />
            {Array.from({ length: 4 }, (_, j) => (
              <div key={j} className="flex items-center justify-between">
                <Skeleton variant="text" width="50%" height={14} />
                <Skeleton variant="text" width="3rem" height={14} />
              </div>
            ))}
          </div>
        ))}
      </div>

      {/* Bottom section */}
      <div className="card space-y-3">
        <Skeleton variant="text" width="10rem" height={18} />
        <Skeleton variant="rect" height={120} className="!rounded-lg" />
      </div>
    </SkeletonContainer>
  );
}
