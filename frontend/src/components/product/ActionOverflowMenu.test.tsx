import { fireEvent, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import { ActionOverflowMenu } from "./ActionOverflowMenu";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ActionOverflowMenu", () => {
  it("renders the kebab trigger button", () => {
    render(
      <ActionOverflowMenu>
        <button>Item</button>
      </ActionOverflowMenu>,
    );
    expect(screen.getByTestId("action-overflow-trigger")).toBeInTheDocument();
  });

  it("does not show menu content initially", () => {
    render(
      <ActionOverflowMenu>
        <button>Item</button>
      </ActionOverflowMenu>,
    );
    expect(screen.queryByTestId("action-overflow-menu")).not.toBeInTheDocument();
  });

  it("opens the menu on click", async () => {
    const user = userEvent.setup();
    render(
      <ActionOverflowMenu>
        <button>Item</button>
      </ActionOverflowMenu>,
    );

    await user.click(screen.getByTestId("action-overflow-trigger"));
    expect(screen.getByTestId("action-overflow-menu")).toBeInTheDocument();
  });

  it("closes the menu on second click (toggle)", async () => {
    const user = userEvent.setup();
    render(
      <ActionOverflowMenu>
        <button>Item</button>
      </ActionOverflowMenu>,
    );

    const trigger = screen.getByTestId("action-overflow-trigger");
    await user.click(trigger);
    expect(screen.getByTestId("action-overflow-menu")).toBeInTheDocument();

    await user.click(trigger);
    expect(screen.queryByTestId("action-overflow-menu")).not.toBeInTheDocument();
  });

  it("closes the menu on Escape key", async () => {
    const user = userEvent.setup();
    render(
      <ActionOverflowMenu>
        <button>Item</button>
      </ActionOverflowMenu>,
    );

    await user.click(screen.getByTestId("action-overflow-trigger"));
    expect(screen.getByTestId("action-overflow-menu")).toBeInTheDocument();

    await user.keyboard("{Escape}");
    expect(screen.queryByTestId("action-overflow-menu")).not.toBeInTheDocument();
  });

  it("closes the menu on click outside", () => {
    render(
      <div>
        <button data-testid="outside">Outside</button>
        <ActionOverflowMenu>
          <button>Item</button>
        </ActionOverflowMenu>
      </div>,
    );

    fireEvent.click(screen.getByTestId("action-overflow-trigger"));
    expect(screen.getByTestId("action-overflow-menu")).toBeInTheDocument();

    fireEvent.mouseDown(screen.getByTestId("outside"));
    expect(screen.queryByTestId("action-overflow-menu")).not.toBeInTheDocument();
  });

  it("renders children inside the dropdown", async () => {
    const user = userEvent.setup();
    render(
      <ActionOverflowMenu>
        <button data-testid="child-action">Watch</button>
      </ActionOverflowMenu>,
    );

    await user.click(screen.getByTestId("action-overflow-trigger"));
    expect(screen.getByTestId("child-action")).toBeInTheDocument();
  });

  it("sets aria-expanded correctly", async () => {
    const user = userEvent.setup();
    render(
      <ActionOverflowMenu>
        <button>Item</button>
      </ActionOverflowMenu>,
    );

    const trigger = screen.getByTestId("action-overflow-trigger");
    expect(trigger).toHaveAttribute("aria-expanded", "false");

    await user.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "true");
  });

  it("has proper ARIA attributes", () => {
    render(
      <ActionOverflowMenu>
        <button>Item</button>
      </ActionOverflowMenu>,
    );

    const trigger = screen.getByTestId("action-overflow-trigger");
    expect(trigger).toHaveAttribute("aria-haspopup", "true");
    expect(trigger).toHaveAttribute("aria-label");
  });

  it("applies className prop to container", () => {
    const { container } = render(
      <ActionOverflowMenu className="sm:hidden">
        <button>Item</button>
      </ActionOverflowMenu>,
    );

    expect(container.firstChild).toHaveClass("sm:hidden");
  });

  it("dropdown has role=menu", async () => {
    const user = userEvent.setup();
    render(
      <ActionOverflowMenu>
        <button>Item</button>
      </ActionOverflowMenu>,
    );

    await user.click(screen.getByTestId("action-overflow-trigger"));
    expect(screen.getByRole("menu")).toBeInTheDocument();
  });
});
