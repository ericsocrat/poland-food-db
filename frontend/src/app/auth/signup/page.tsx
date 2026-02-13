// Server component wrapper — opts into dynamic rendering.

import { SignupForm } from "./SignupForm";

export const dynamic = "force-dynamic";

export default function SignupPage() {
  return <SignupForm />;
}
