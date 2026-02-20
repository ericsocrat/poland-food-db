// ─── Event Taxonomy — canonical app events for achievement tracking ──────────
// Issue #52: Telemetry Mapping for Achievements

/**
 * Discriminated union of all application events that can trigger
 * achievement progress increments via the event bus.
 */
export type AppEvent =
  | { type: "product.scanned"; payload: { ean: string } }
  | {
      type: "product.searched";
      payload: { query: string; resultCount?: number };
    }
  | { type: "product.viewed"; payload: { productId: number; score: number } }
  | { type: "product.compared"; payload: { productIds: number[] } }
  | {
      type: "product.added_to_list";
      payload: { productId: number; listId: string };
    }
  | {
      type: "product.shared";
      payload: { productId: number; method: "native" | "clipboard" };
    }
  | { type: "product.submitted"; payload: { ean: string } }
  | { type: "list.created"; payload: { listId?: string } }
  | { type: "filter.allergen_applied"; payload: { allergenTags: string[] } }
  | {
      type: "category.viewed";
      payload: { categorySlug: string };
    }
  | { type: "learn.page_viewed"; payload: { pageSlug?: string } }
  | {
      type: "session.weekly_visit";
      payload: { weekNumber: number; year: number };
    };

/** Extract the payload type for a given event type string */
export type EventPayload<T extends AppEvent["type"]> = Extract<
  AppEvent,
  { type: T }
>["payload"];
