import { Suspense } from "react";

import { LoadingSpinner } from "@/components/common/LoadingSpinner";

import { UpdatePasswordForm } from "./UpdatePasswordForm";

export const dynamic = "force-dynamic";

export default function UpdatePasswordPage() {
  return (
    <Suspense fallback={<LoadingSpinner className="min-h-screen" />}>
      <UpdatePasswordForm />
    </Suspense>
  );
}
