"use client";

export default function OfflinePage() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center px-4 text-center">
      <p className="text-5xl">📡</p>
      <h1 className="mt-4 text-xl font-bold text-gray-900">
        You&apos;re Offline
      </h1>
      <p className="mt-2 max-w-sm text-sm text-gray-500">
        It looks like you&apos;ve lost your internet connection. Previously
        viewed pages may still be available. Reconnect to browse new products.
      </p>
      <button
        className="btn-primary mt-6"
        onClick={() => window.location.reload()}
      >
        Try Again
      </button>
    </div>
  );
}
