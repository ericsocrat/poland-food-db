/**
 * ScanHistorySkeleton — shimmer placeholder for scan history page.
 * Mirrors: filter toggle bar + scan item list with nutri-score badges.
 * Used by: /app/scan/history
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function ScanHistorySkeleton() {
  return (
    <SkeletonContainer label="Loading scan history" className="space-y-4">
      {/* Filter toggle bar */}
      <div className="flex items-center gap-3">
        <Skeleton
          variant="rect"
          width={80}
          height={32}
          className="rounded-full!"
        />
        <Skeleton
          variant="rect"
          width={80}
          height={32}
          className="rounded-full!"
        />
        <Skeleton
          variant="rect"
          width={80}
          height={32}
          className="rounded-full!"
        />
      </div>

      {/* Scan items */}
      {Array.from({ length: 5 }, (_, i) => (
        <div key={i} className="card flex items-center gap-3">
          <Skeleton
            variant="rect"
            width={44}
            height={44}
            className="rounded-lg!"
          />
          <div className="flex-1 space-y-1">
            <Skeleton variant="text" width="55%" height={14} />
            <Skeleton variant="text" width="35%" height={12} />
          </div>
          <div className="flex flex-col items-end gap-1">
            <Skeleton
              variant="rect"
              width={28}
              height={28}
              className="rounded-md!"
            />
            <Skeleton variant="text" width="3rem" height={10} />
          </div>
        </div>
      ))}
    </SkeletonContainer>
  );
}
