// Server component wrapper — opts into dynamic rendering so
// createClient() in the client component doesn't run during SSG.

import { Suspense } from "react";
import { LoginForm } from "./LoginForm";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

export const dynamic = "force-dynamic";

export default function LoginPage() {
  return (
    <Suspense fallback={<LoadingSpinner className="min-h-screen" />}>
      <LoginForm />
    </Suspense>
  );
}
