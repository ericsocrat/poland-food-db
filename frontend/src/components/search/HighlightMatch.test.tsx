import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";

/**
 * HighlightMatch is defined inside SearchAutocomplete.tsx as a private helper.
 * We re-implement the same function here for unit testing its logic.
 *
 * If the implementation is ever extracted to its own module, these tests can
 * simply import it directly.
 */
function HighlightMatch({ text, query }: { text: string; query: string }) {
  if (!query || query.length < 1) return <>{text}</>;

  const normalize = (s: string) =>
    s
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/ł/g, "l")
      .replace(/Ł/g, "L")
      .toLowerCase();

  const normalizedText = normalize(text);
  const normalizedQuery = normalize(query);

  const parts: { start: number; end: number; isMatch: boolean }[] = [];
  let searchFrom = 0;
  let lastEnd = 0;

  while (searchFrom <= normalizedText.length - normalizedQuery.length) {
    const idx = normalizedText.indexOf(normalizedQuery, searchFrom);
    if (idx === -1) break;

    if (idx > lastEnd) {
      parts.push({ start: lastEnd, end: idx, isMatch: false });
    }
    parts.push({
      start: idx,
      end: idx + normalizedQuery.length,
      isMatch: true,
    });
    lastEnd = idx + normalizedQuery.length;
    searchFrom = lastEnd;
  }

  if (lastEnd < text.length) {
    parts.push({ start: lastEnd, end: text.length, isMatch: false });
  }

  if (parts.length === 0 || !parts.some((p) => p.isMatch)) {
    return <>{text}</>;
  }

  return (
    <>
      {parts.map((part) =>
        part.isMatch ? (
          <mark
            key={part.start}
            className="bg-brand/20 text-foreground rounded-sm"
          >
            {text.slice(part.start, part.end)}
          </mark>
        ) : (
          <span key={part.start}>{text.slice(part.start, part.end)}</span>
        ),
      )}
    </>
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("HighlightMatch", () => {
  it("wraps exact ASCII match in <mark>", () => {
    render(<HighlightMatch text="Chipsy Lays" query="lays" />);
    const mark = screen.getByText("Lays");
    expect(mark.tagName).toBe("MARK");
    expect(mark).toHaveClass("bg-brand/20");
  });

  it("returns plain text when query is empty", () => {
    const { container } = render(
      <HighlightMatch text="Hello World" query="" />,
    );
    expect(container.textContent).toBe("Hello World");
    expect(container.querySelector("mark")).toBeNull();
  });

  it("returns plain text when there is no match", () => {
    const { container } = render(
      <HighlightMatch text="Chipsy Lays" query="doritos" />,
    );
    expect(container.textContent).toBe("Chipsy Lays");
    expect(container.querySelector("mark")).toBeNull();
  });

  it("matches diacritics: 'zol' highlights 'żół' in Żółty ser", () => {
    render(<HighlightMatch text="Żółty ser" query="zol" />);

    // The original characters "Żół" should be preserved inside <mark>
    const mark = screen.getByText("Żół");
    expect(mark.tagName).toBe("MARK");
  });

  it("matches Polish ł vs l: 'mle' highlights 'Młe' in Młeko", () => {
    render(<HighlightMatch text="Młeko UHT" query="mle" />);
    const mark = screen.getByText("Młe");
    expect(mark.tagName).toBe("MARK");
  });

  it("highlights multiple occurrences in the same string", () => {
    const { container } = render(<HighlightMatch text="la la la" query="la" />);
    const marks = container.querySelectorAll("mark");
    expect(marks).toHaveLength(3);
  });

  it("is case-insensitive", () => {
    render(<HighlightMatch text="COCA-COLA" query="cola" />);
    const mark = screen.getByText("COLA");
    expect(mark.tagName).toBe("MARK");
  });

  it("preserves non-matched text around the match", () => {
    const { container } = render(
      <HighlightMatch text="Chipsy Lays" query="lays" />,
    );
    expect(container.textContent).toBe("Chipsy Lays");
    // Non-matched part is in a <span>, matched part in <mark>
    const span = container.querySelector("span");
    expect(span?.textContent).toBe("Chipsy ");
    expect(screen.getByText("Lays").tagName).toBe("MARK");
  });
});
