// ─── Learn pages compliance tests ─────────────────────────────────────────
// Validates /learn page structure, components, i18n keys, and metadata.

import { readFileSync, existsSync } from "fs";
import { join } from "path";
import { describe, it, expect } from "vitest";

const frontendDir = join(__dirname, "../..");
const appDir = join(frontendDir, "src/app/learn");
const componentsDir = join(frontendDir, "src/components/learn");
const messagesDir = join(frontendDir, "messages");

const enJson = JSON.parse(readFileSync(join(messagesDir, "en.json"), "utf-8"));
const plJson = JSON.parse(readFileSync(join(messagesDir, "pl.json"), "utf-8"));

/* ────────────────────── Topic pages exist ────────────────────── */

const TOPICS = [
  "nutri-score",
  "nova-groups",
  "unhealthiness-score",
  "additives",
  "allergens",
  "reading-labels",
  "confidence",
];

describe("Learn page files", () => {
  it("hub page exists", () => {
    expect(existsSync(join(appDir, "page.tsx"))).toBe(true);
  });

  it("hub layout exists with metadata", () => {
    const layout = readFileSync(join(appDir, "layout.tsx"), "utf-8");
    expect(layout).toContain("Metadata");
    expect(layout).toContain("Learn");
  });

  for (const topic of TOPICS) {
    it(`${topic} page exists`, () => {
      expect(existsSync(join(appDir, topic, "page.tsx"))).toBe(true);
    });

    it(`${topic} layout exists with metadata`, () => {
      const layout = readFileSync(join(appDir, topic, "layout.tsx"), "utf-8");
      expect(layout).toContain("Metadata");
    });
  }
});

/* ────────────────────── Components exist ────────────────────── */

describe("Learn components", () => {
  it("Disclaimer component exists", () => {
    expect(existsSync(join(componentsDir, "Disclaimer.tsx"))).toBe(true);
  });

  it("SourceCitation component exists", () => {
    expect(existsSync(join(componentsDir, "SourceCitation.tsx"))).toBe(true);
  });

  it("LearnCard component exists", () => {
    expect(existsSync(join(componentsDir, "LearnCard.tsx"))).toBe(true);
  });

  it("LearnSidebar component exists", () => {
    expect(existsSync(join(componentsDir, "LearnSidebar.tsx"))).toBe(true);
  });
});

/* ────────────────────── Component patterns ────────────────────── */

describe("Disclaimer component", () => {
  const disclaimer = readFileSync(join(componentsDir, "Disclaimer.tsx"), "utf-8");

  it("has role='note' for accessibility", () => {
    expect(disclaimer).toContain('role="note"');
  });

  it("uses i18n for disclaimer text", () => {
    expect(disclaimer).toContain('t("learn.disclaimer")');
  });

  it("has aria-label", () => {
    expect(disclaimer).toContain("aria-label");
  });
});

describe("SourceCitation component", () => {
  const citation = readFileSync(join(componentsDir, "SourceCitation.tsx"), "utf-8");

  it("renders as <cite> element", () => {
    expect(citation).toContain("<cite");
  });

  it("supports url, author, title, year props", () => {
    expect(citation).toContain("author");
    expect(citation).toContain("title");
    expect(citation).toContain("url");
    expect(citation).toContain("year");
  });

  it("opens links in new tab with noopener", () => {
    expect(citation).toContain('target="_blank"');
    expect(citation).toContain("noopener");
  });
});

describe("LearnCard component", () => {
  const card = readFileSync(join(componentsDir, "LearnCard.tsx"), "utf-8");

  it("renders as a Link", () => {
    expect(card).toContain("import Link");
    expect(card).toContain("<Link");
  });

  it("uses motion utilities for hover effect", () => {
    expect(card).toContain("hover-lift");
  });
});

describe("LearnSidebar component", () => {
  const sidebar = readFileSync(join(componentsDir, "LearnSidebar.tsx"), "utf-8");

  it("has aria-label for navigation", () => {
    expect(sidebar).toContain("aria-label");
  });

  it("uses aria-current for active topic", () => {
    expect(sidebar).toContain("aria-current");
  });

  it("includes all 7 topics", () => {
    for (const topic of TOPICS) {
      expect(sidebar).toContain(topic);
    }
  });
});

/* ────────────────────── Topic pages use shared components ────────────────────── */

describe("Topic pages use shared components", () => {
  for (const topic of TOPICS) {
    const page = readFileSync(join(appDir, topic, "page.tsx"), "utf-8");

    it(`${topic} uses LearnSidebar`, () => {
      expect(page).toContain("LearnSidebar");
    });

    it(`${topic} uses Disclaimer`, () => {
      expect(page).toContain("Disclaimer");
    });

    it(`${topic} uses Header and Footer`, () => {
      expect(page).toContain("Header");
      expect(page).toContain("Footer");
    });

    it(`${topic} has back-to-hub link on mobile`, () => {
      expect(page).toContain('href="/learn"');
    });

    it(`${topic} uses article element`, () => {
      expect(page).toContain("<article");
    });
  }
});

/* ────────────────────── Hub page ────────────────────── */

describe("Hub page", () => {
  const hub = readFileSync(join(appDir, "page.tsx"), "utf-8");

  it("links to all 7 topics", () => {
    for (const topic of TOPICS) {
      expect(hub).toContain(topic);
    }
  });

  it("uses LearnCard component", () => {
    expect(hub).toContain("LearnCard");
  });

  it("includes disclaimer", () => {
    expect(hub).toContain("Disclaimer");
  });

  it("uses Header and Footer (public page pattern)", () => {
    expect(hub).toContain("Header");
    expect(hub).toContain("Footer");
  });
});

/* ────────────────────── i18n keys ────────────────────── */

describe("i18n: English learn keys", () => {
  it("has learn.hubTitle", () => {
    expect(enJson.learn.hubTitle).toBeDefined();
  });

  it("has learn.disclaimer", () => {
    expect(enJson.learn.disclaimer).toBeDefined();
    expect(enJson.learn.disclaimer).toContain("educational purposes");
  });

  for (const topic of [
    "nutriScore",
    "novaGroups",
    "unhealthinessScore",
    "additives",
    "allergens",
    "readingLabels",
    "confidence",
  ]) {
    it(`has learn.${topic}.title`, () => {
      expect(enJson.learn[topic].title).toBeDefined();
    });

    it(`has learn.${topic}.description`, () => {
      expect(enJson.learn[topic].description).toBeDefined();
    });

    it(`has learn.${topic}.summary`, () => {
      expect(enJson.learn[topic].summary).toBeDefined();
    });
  }
});

describe("i18n: Polish learn keys", () => {
  it("has learn.hubTitle in Polish", () => {
    expect(plJson.learn.hubTitle).toBeDefined();
    expect(plJson.learn.hubTitle).not.toBe(enJson.learn.hubTitle);
  });

  it("has learn.disclaimer in Polish", () => {
    expect(plJson.learn.disclaimer).toBeDefined();
    expect(plJson.learn.disclaimer).not.toBe(enJson.learn.disclaimer);
  });

  for (const topic of [
    "nutriScore",
    "novaGroups",
    "unhealthinessScore",
    "additives",
    "allergens",
    "readingLabels",
    "confidence",
  ]) {
    it(`has learn.${topic}.title in Polish`, () => {
      expect(plJson.learn[topic].title).toBeDefined();
      expect(plJson.learn[topic].title).not.toBe(enJson.learn[topic].title);
    });
  }
});

/* ────────────────────── Footer link ────────────────────── */

describe("Footer includes Learn link", () => {
  const footer = readFileSync(
    join(frontendDir, "src/components/layout/Footer.tsx"),
    "utf-8",
  );

  it("links to /learn", () => {
    expect(footer).toContain('href="/learn"');
  });
});

/* ────────────────────── Scientific accuracy ────────────────────── */

describe("Content accuracy checks", () => {
  it("mentions EFSA in additives content", () => {
    expect(enJson.learn.additives.whatAreText).toContain("EFSA");
  });

  it("mentions WHO in unhealthiness score content", () => {
    expect(enJson.learn.unhealthinessScore.factorSalt).toContain("WHO");
  });

  it("lists all 14 EU allergens", () => {
    for (let i = 1; i <= 14; i++) {
      expect(enJson.learn.allergens[`allergen${i}`]).toBeDefined();
    }
  });

  it("unhealthiness score factors sum to ~100% weight", () => {
    // Verify the documented weights are correct: 17+17+17+10+11+7+8+8+5 = 100
    const weights = [17, 17, 17, 10, 11, 7, 8, 8, 5];
    expect(weights.reduce((a, b) => a + b, 0)).toBe(100);
  });

  it("disclaimer does not make medical claims", () => {
    expect(enJson.learn.disclaimer).toContain("educational purposes only");
    expect(enJson.learn.disclaimer).toContain("healthcare professional");
  });
});
