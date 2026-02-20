import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Watchlist",
};

export default function WatchlistLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
