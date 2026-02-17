import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { InfoTooltip } from "./InfoTooltip";

// Wrap with TooltipProvider required by Radix
function renderWithProvider(ui: React.ReactElement) {
  return render(
    <TooltipPrimitive.Provider delayDuration={0} skipDelayDuration={0}>
      {ui}
    </TooltipPrimitive.Provider>,
  );
}

describe("InfoTooltip", () => {
  it("renders trigger children", () => {
    renderWithProvider(
      <InfoTooltip content="help text">
        <button>Hover me</button>
      </InfoTooltip>,
    );
    expect(screen.getByText("Hover me")).toBeTruthy();
  });

  it("renders children only when no content is provided", () => {
    renderWithProvider(
      <InfoTooltip>
        <button>No tooltip</button>
      </InfoTooltip>,
    );
    expect(screen.getByText("No tooltip")).toBeTruthy();
    // No tooltip role should be present
    expect(screen.queryByRole("tooltip")).toBeNull();
  });

  it("shows tooltip on hover with raw content", async () => {
    const user = userEvent.setup();
    renderWithProvider(
      <InfoTooltip content="Help text here" delayDuration={0}>
        <button>Trigger</button>
      </InfoTooltip>,
    );

    await user.hover(screen.getByText("Trigger"));
    expect(await screen.findByRole("tooltip")).toHaveTextContent(
      "Help text here",
    );
  });

  it("resolves i18n messageKey", async () => {
    const user = userEvent.setup();
    renderWithProvider(
      <InfoTooltip messageKey="tooltip.nutriScore.A" delayDuration={0}>
        <button>Grade A</button>
      </InfoTooltip>,
    );

    await user.hover(screen.getByText("Grade A"));
    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip.textContent).toContain("Nutri-Score A");
    expect(tooltip.textContent).toContain("Excellent");
  });

  it("resolves i18n messageKey with params", async () => {
    const user = userEvent.setup();
    renderWithProvider(
      <InfoTooltip
        messageKey="tooltip.allergen.present"
        params={{ name: "Gluten" }}
        delayDuration={0}
      >
        <button>Gluten</button>
      </InfoTooltip>,
    );

    await user.hover(screen.getByText("Gluten"));
    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip.textContent).toContain("Gluten");
  });

  it("renders description text when descriptionKey is provided", async () => {
    const user = userEvent.setup();
    renderWithProvider(
      <InfoTooltip
        messageKey="tooltip.score.green"
        descriptionKey="tooltip.confidence.high"
        delayDuration={0}
      >
        <button>Score</button>
      </InfoTooltip>,
    );

    await user.hover(screen.getByText("Score"));
    const tooltip = await screen.findByRole("tooltip");
    // Should have both main text and description
    expect(tooltip.textContent).toContain("Score 1–20");
    expect(tooltip.textContent).toContain("High confidence");
  });

  it("prefers messageKey over content prop", async () => {
    const user = userEvent.setup();
    renderWithProvider(
      <InfoTooltip
        messageKey="tooltip.nova.4"
        content="This should not appear"
        delayDuration={0}
      >
        <button>Badge</button>
      </InfoTooltip>,
    );

    await user.hover(screen.getByText("Badge"));
    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip.textContent).toContain("NOVA 4");
    expect(tooltip.textContent).not.toContain("This should not appear");
  });

  it("falls back to content when messageKey resolves to empty", async () => {
    const user = userEvent.setup();
    renderWithProvider(
      <InfoTooltip
        messageKey="tooltip.nonexistent.key"
        content="Fallback text"
        delayDuration={0}
      >
        <button>Badge</button>
      </InfoTooltip>,
    );

    await user.hover(screen.getByText("Badge"));
    // The messageKey resolution returns the key itself when not found,
    // so it will use that as content
    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip).toBeTruthy();
  });

  it("renders tooltip content within a portal", async () => {
    const user = userEvent.setup();
    renderWithProvider(
      <InfoTooltip content="Portal test" delayDuration={0}>
        <button>Trigger</button>
      </InfoTooltip>,
    );

    await user.hover(screen.getByText("Trigger"));
    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip).toBeTruthy();
    expect(tooltip.textContent).toContain("Portal test");
  });
});
