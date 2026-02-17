import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Select } from "./Select";

const options = [
  { value: "a", label: "Option A" },
  { value: "b", label: "Option B" },
  { value: "c", label: "Option C", disabled: true },
];

describe("Select", () => {
  it("renders with label and options", () => {
    render(<Select label="Country" options={options} />);
    expect(screen.getByLabelText("Country")).toBeTruthy();
    expect(screen.getByText("Option A")).toBeTruthy();
    expect(screen.getByText("Option B")).toBeTruthy();
  });

  it("renders placeholder as disabled option", () => {
    render(
      <Select label="Pick" options={options} placeholder="Choose one..." />,
    );
    const placeholder = screen.getByText("Choose one...") as HTMLOptionElement;
    expect(placeholder.disabled).toBe(true);
  });

  it("renders disabled options", () => {
    render(<Select label="Pick" options={options} />);
    const opt = screen.getByText("Option C") as HTMLOptionElement;
    expect(opt.disabled).toBe(true);
  });

  it("links error to select via aria-describedby", () => {
    render(<Select label="Pick" options={options} error="Required" />);
    const select = screen.getByLabelText("Pick");
    expect(select.getAttribute("aria-invalid")).toBe("true");
    const errorId = select.getAttribute("aria-describedby");
    expect(errorId).toBeTruthy();
    expect(screen.getByRole("alert")).toHaveTextContent("Required");
  });

  it("applies error border styling", () => {
    render(<Select label="Err" options={options} error="Bad" />);
    const select = screen.getByLabelText("Err");
    expect(select.className).toContain("border-error");
  });

  it("renders without label", () => {
    render(<Select options={options} />);
    expect(screen.getByText("Option A")).toBeTruthy();
  });
});
