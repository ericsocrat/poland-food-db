import { describe, it, expect, afterEach } from "vitest";
import { translate } from "@/lib/i18n";
import { getTimeOfDay } from "./DashboardGreeting";
import { tipIndexForToday } from "./NutritionTip";

// ─── DashboardGreeting — getTimeOfDay() ─────────────────────────────────────

describe("getTimeOfDay", () => {
  const origDate = globalThis.Date;

  afterEach(() => {
    globalThis.Date = origDate;
  });

  function mockHour(hour: number) {
    globalThis.Date = class extends origDate {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      constructor(...args: any[]) {
        if (args.length === 0) {
          super(2026, 1, 10, hour, 0, 0);
        } else {
          super(...args);
        }
      }
      getHours() {
        return hour;
      }
    } as typeof Date;
  }

  it('returns "morning" between 5:00 and 11:59', () => {
    mockHour(5);
    expect(getTimeOfDay()).toBe("morning");
    mockHour(11);
    expect(getTimeOfDay()).toBe("morning");
  });

  it('returns "afternoon" between 12:00 and 16:59', () => {
    mockHour(12);
    expect(getTimeOfDay()).toBe("afternoon");
    mockHour(16);
    expect(getTimeOfDay()).toBe("afternoon");
  });

  it('returns "evening" between 17:00 and 21:59', () => {
    mockHour(17);
    expect(getTimeOfDay()).toBe("evening");
    mockHour(21);
    expect(getTimeOfDay()).toBe("evening");
  });

  it('returns "night" between 22:00 and 4:59', () => {
    mockHour(22);
    expect(getTimeOfDay()).toBe("night");
    mockHour(3);
    expect(getTimeOfDay()).toBe("night");
  });
});

// ─── DashboardGreeting — i18n keys ──────────────────────────────────────────

describe("DashboardGreeting i18n keys", () => {
  const times = ["morning", "afternoon", "evening", "night"] as const;

  for (const time of times) {
    it(`has EN greeting for ${time}`, () => {
      const result = translate("en", `dashboard.greeting.${time}`);
      expect(result).not.toBe(`dashboard.greeting.${time}`);
    });

    it(`has EN named greeting for ${time}`, () => {
      const result = translate("en", `dashboard.greeting.${time}Named`, {
        name: "Eric",
      });
      expect(result).toContain("Eric");
    });

    it(`has PL greeting for ${time}`, () => {
      const result = translate("pl", `dashboard.greeting.${time}`);
      expect(result).not.toBe(`dashboard.greeting.${time}`);
    });
  }

  it("has subtitle key", () => {
    expect(translate("en", "dashboard.subtitle")).not.toBe(
      "dashboard.subtitle",
    );
    expect(translate("pl", "dashboard.subtitle")).not.toBe(
      "dashboard.subtitle",
    );
  });
});

// ─── QuickActions — i18n keys ───────────────────────────────────────────────

describe("QuickActions i18n keys", () => {
  const actions = ["scan", "search", "compare", "lists"] as const;

  for (const action of actions) {
    it(`has EN label for ${action}`, () => {
      const result = translate("en", `dashboard.action.${action}`);
      expect(result).not.toBe(`dashboard.action.${action}`);
    });

    it(`has PL label for ${action}`, () => {
      const result = translate("pl", `dashboard.action.${action}`);
      expect(result).not.toBe(`dashboard.action.${action}`);
    });
  }

  it("has quickActions section label", () => {
    expect(translate("en", "dashboard.quickActions")).not.toBe(
      "dashboard.quickActions",
    );
  });
});

// ─── NutritionTip — tipIndexForToday() ──────────────────────────────────────

describe("tipIndexForToday", () => {
  it("returns a number between 0 and 13", () => {
    const index = tipIndexForToday();
    expect(index).toBeGreaterThanOrEqual(0);
    expect(index).toBeLessThanOrEqual(13);
  });

  it("is deterministic within the same day", () => {
    expect(tipIndexForToday()).toBe(tipIndexForToday());
  });
});

// ─── NutritionTip — i18n keys ───────────────────────────────────────────────

describe("NutritionTip i18n keys", () => {
  it("has tipTitle key", () => {
    expect(translate("en", "dashboard.tipTitle")).not.toBe(
      "dashboard.tipTitle",
    );
    expect(translate("pl", "dashboard.tipTitle")).not.toBe(
      "dashboard.tipTitle",
    );
  });

  it("has tipLearnMore key in both languages", () => {
    expect(translate("en", "dashboard.tipLearnMore")).not.toBe(
      "dashboard.tipLearnMore",
    );
    expect(translate("pl", "dashboard.tipLearnMore")).not.toBe(
      "dashboard.tipLearnMore",
    );
  });

  for (let i = 0; i < 14; i++) {
    it(`has EN tip.${i}`, () => {
      const result = translate("en", `dashboard.tip.${i}`);
      expect(result).not.toBe(`dashboard.tip.${i}`);
      expect(result.length).toBeGreaterThan(20);
    });

    it(`has PL tip.${i}`, () => {
      const result = translate("pl", `dashboard.tip.${i}`);
      expect(result).not.toBe(`dashboard.tip.${i}`);
      expect(result.length).toBeGreaterThan(20);
    });
  }
});

// ─── CategoriesBrowse — i18n keys ───────────────────────────────────────────

describe("CategoriesBrowse i18n keys", () => {
  it("has categoriesTitle key", () => {
    expect(translate("en", "dashboard.categoriesTitle")).not.toBe(
      "dashboard.categoriesTitle",
    );
    expect(translate("pl", "dashboard.categoriesTitle")).not.toBe(
      "dashboard.categoriesTitle",
    );
  });
});
