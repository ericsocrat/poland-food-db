import { describe, expect, it, beforeEach } from "vitest";
import { useLanguageStore } from "./language-store";

describe("language-store", () => {
  beforeEach(() => {
    useLanguageStore.getState().reset();
  });

  it("initializes with English and loaded=false", () => {
    const state = useLanguageStore.getState();
    expect(state.language).toBe("en");
    expect(state.loaded).toBe(false);
  });

  it("setLanguage updates language and sets loaded=true", () => {
    useLanguageStore.getState().setLanguage("pl");
    const state = useLanguageStore.getState();
    expect(state.language).toBe("pl");
    expect(state.loaded).toBe(true);
  });

  it("setLanguage to de works", () => {
    useLanguageStore.getState().setLanguage("de");
    expect(useLanguageStore.getState().language).toBe("de");
  });

  it("reset restores default state", () => {
    useLanguageStore.getState().setLanguage("pl");
    expect(useLanguageStore.getState().loaded).toBe(true);

    useLanguageStore.getState().reset();
    const state = useLanguageStore.getState();
    expect(state.language).toBe("en");
    expect(state.loaded).toBe(false);
  });

  it("multiple setLanguage calls update correctly", () => {
    useLanguageStore.getState().setLanguage("pl");
    useLanguageStore.getState().setLanguage("de");
    useLanguageStore.getState().setLanguage("en");
    expect(useLanguageStore.getState().language).toBe("en");
    expect(useLanguageStore.getState().loaded).toBe(true);
  });
});
