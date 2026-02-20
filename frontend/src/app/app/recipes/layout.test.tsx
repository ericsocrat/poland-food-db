import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import RecipesLayout from "./layout";

describe("RecipesLayout", () => {
  it("renders children as-is", () => {
    render(
      <RecipesLayout>
        <p>hello</p>
      </RecipesLayout>,
    );
    expect(screen.getByText("hello")).toBeInTheDocument();
  });

  it("exports metadata with title", async () => {
    const mod = await import("./layout");
    expect(mod.metadata).toBeDefined();
    expect(mod.metadata?.title).toBe("Recipes");
  });
});
