/**
 * SubmissionsSkeleton — shimmer placeholder for product submissions.
 * Mirrors: submission cards with status badge + text info.
 * Used by: /app/scan/submissions, /app/admin/submissions
 */

import { Skeleton, SkeletonContainer } from "@/components/common/Skeleton";

export function SubmissionsSkeleton() {
  return (
    <SkeletonContainer label="Loading submissions" className="space-y-3">
      {Array.from({ length: 4 }, (_, i) => (
        <div key={i} className="card space-y-3">
          <div className="flex items-center justify-between">
            <Skeleton variant="text" width="50%" height={16} />
            <Skeleton
              variant="rect"
              width={72}
              height={24}
              className="rounded-full!"
            />
          </div>
          <Skeleton variant="text" width="70%" height={12} />
          <div className="flex items-center gap-2">
            <Skeleton variant="text" width="6rem" height={12} />
            <Skeleton variant="circle" width={8} height={8} />
            <Skeleton variant="text" width="4rem" height={12} />
          </div>
        </div>
      ))}
    </SkeletonContainer>
  );
}
