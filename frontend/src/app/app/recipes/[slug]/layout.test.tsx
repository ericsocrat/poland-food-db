import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import RecipeDetailLayout from "./layout";

describe("RecipeDetailLayout", () => {
  it("renders children as-is", () => {
    render(
      <RecipeDetailLayout>
        <p>detail content</p>
      </RecipeDetailLayout>,
    );
    expect(screen.getByText("detail content")).toBeInTheDocument();
  });

  it("exports metadata with title", async () => {
    const mod = await import("./layout");
    expect(mod.metadata).toBeDefined();
    expect(mod.metadata?.title).toBe("Recipe Detail");
  });
});
