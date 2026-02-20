// ─── Events barrel export ────────────────────────────────────────────────────
// Issue #52: Telemetry Mapping for Achievements

export { eventBus } from "./bus";
export { ACHIEVEMENT_MAP, MAPPED_SLUGS, MAPPED_EVENT_TYPES } from "./achievement-map";
export { initAchievementMiddleware, processEvent } from "./achievement-middleware";
export type { AppEvent, EventPayload } from "./types";
export type { AchievementMapping } from "./achievement-map";
