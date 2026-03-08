/**
 * SettingsSkeleton — shimmer placeholder for settings pages.
 * Mirrors: breadcrumbs + heading + 2–3 settings card sections.
 * Used by: /app/settings, /app/settings/nutrition, /app/settings/notifications
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function SettingsSkeleton() {
  return (
    <SkeletonContainer label="Loading settings" className="space-y-6">
      {/* Breadcrumbs */}
      <div className="flex items-center gap-2">
        <Skeleton variant="text" width="3rem" height={14} />
        <Skeleton variant="text" width="1rem" height={14} />
        <Skeleton variant="text" width="5rem" height={14} />
      </div>

      {/* Page heading */}
      <div className="space-y-1">
        <Skeleton variant="text" width="10rem" height={24} />
        <Skeleton variant="text" width="16rem" height={14} />
      </div>

      {/* Settings cards */}
      {Array.from({ length: 3 }, (_, i) => (
        <div key={i} className="card space-y-4">
          <Skeleton variant="text" width="8rem" height={18} />
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
            {Array.from({ length: 3 }, (_, j) => (
              <Skeleton
                key={j}
                variant="rect"
                height={44}
                className="!rounded-lg"
              />
            ))}
          </div>
          <Skeleton variant="text" width="60%" height={12} />
        </div>
      ))}

      {/* Sticky save bar */}
      <div className="flex justify-end">
        <Skeleton
          variant="rect"
          width={120}
          height={40}
          className="!rounded-lg"
        />
      </div>
    </SkeletonContainer>
  );
}
