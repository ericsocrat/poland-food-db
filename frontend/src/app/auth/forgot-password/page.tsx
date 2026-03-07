import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { Suspense } from "react";
import { ForgotPasswordForm } from "./ForgotPasswordForm";

export const dynamic = "force-dynamic";

export default function ForgotPasswordPage() {
  return (
    <Suspense fallback={<LoadingSpinner className="min-h-screen" />}>
      <ForgotPasswordForm />
    </Suspense>
  );
}
