import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import type { ProductImage } from "@/lib/types";

// ── Mocks ────────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

vi.mock("next/image", () => ({
  default: (props: Record<string, unknown>) => {
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    return <img {...props} />;
  },
}));

import { ImageLightbox } from "./ImageLightbox";

// ── Fixtures ─────────────────────────────────────────────────────────────────

function makeImages(count = 3): ProductImage[] {
  return Array.from({ length: count }, (_, i) => ({
    image_id: i + 1,
    url: `https://images.example.com/img${i + 1}.jpg`,
    image_type: (["front", "ingredients", "nutrition_label"] as const)[
      i % 3
    ],
    source: "off_api" as const,
    width: 800,
    height: 800,
    alt_text: `Image ${i + 1}`,
  }));
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("ImageLightbox", () => {
  const onClose = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders the dialog with correct aria attributes", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    const dialog = screen.getByRole("dialog");
    expect(dialog).toHaveAttribute("aria-modal", "true");
    expect(dialog).toHaveAttribute("aria-label", "imageLightbox.title");
  });

  it("renders the initial image", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    expect(screen.getByAltText("Image 1")).toBeInTheDocument();
  });

  it("displays image counter", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={1}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    expect(screen.getByText("2 / 3")).toBeInTheDocument();
  });

  it("calls onClose when close button is clicked", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    await user.click(screen.getByLabelText("common.close"));
    expect(onClose).toHaveBeenCalledOnce();
  });

  it("calls onClose on Escape key", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    fireEvent.keyDown(document, { key: "Escape" });
    expect(onClose).toHaveBeenCalledOnce();
  });

  it("navigates to next image on ArrowRight key", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    fireEvent.keyDown(document, { key: "ArrowRight" });
    expect(screen.getByAltText("Image 2")).toBeInTheDocument();
    expect(screen.getByText("2 / 3")).toBeInTheDocument();
  });

  it("navigates to previous image on ArrowLeft key", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={1}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    fireEvent.keyDown(document, { key: "ArrowLeft" });
    expect(screen.getByAltText("Image 1")).toBeInTheDocument();
  });

  it("loops navigation: ArrowLeft at index 0 goes to last image", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    fireEvent.keyDown(document, { key: "ArrowLeft" });
    expect(screen.getByAltText("Image 3")).toBeInTheDocument();
    expect(screen.getByText("3 / 3")).toBeInTheDocument();
  });

  it("loops navigation: ArrowRight at last index goes to first image", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={2}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    fireEvent.keyDown(document, { key: "ArrowRight" });
    expect(screen.getByAltText("Image 1")).toBeInTheDocument();
  });

  it("navigates via prev/next buttons", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    await user.click(screen.getByLabelText("imageLightbox.next"));
    expect(screen.getByAltText("Image 2")).toBeInTheDocument();

    await user.click(screen.getByLabelText("imageLightbox.previous"));
    expect(screen.getByAltText("Image 1")).toBeInTheDocument();
  });

  it("does not render nav arrows for single image", () => {
    render(
      <ImageLightbox
        images={makeImages(1)}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    expect(
      screen.queryByLabelText("imageLightbox.next"),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByLabelText("imageLightbox.previous"),
    ).not.toBeInTheDocument();
  });

  it("does not render thumbnail strip for single image", () => {
    render(
      <ImageLightbox
        images={makeImages(1)}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    // Only the main image should exist, not thumbnails
    const imgs = screen.getAllByRole("img");
    expect(imgs).toHaveLength(1);
  });

  it("renders thumbnail strip for multiple images", () => {
    const { container } = render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    // 1 main image + 3 thumbnail images (alt="" → presentation role)
    const imgs = container.querySelectorAll("img");
    expect(imgs.length).toBeGreaterThanOrEqual(4);
  });

  it("switches image when thumbnail is clicked", async () => {
    const user = userEvent.setup();
    const images = makeImages();
    render(
      <ImageLightbox
        images={images}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    // Click the thumbnail for image 3
    const thumbBtn = screen.getByLabelText("nutrition_label (3)");
    await user.click(thumbBtn);
    expect(screen.getByAltText("Image 3")).toBeInTheDocument();
    expect(screen.getByText("3 / 3")).toBeInTheDocument();
  });

  it("zoom in button increases zoom level", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    const zoomInBtn = screen.getByLabelText("imageLightbox.zoomIn");
    const zoomOutBtn = screen.getByLabelText("imageLightbox.zoomOut");

    // Initially zoom out should be disabled (already at 1x)
    expect(zoomOutBtn).toBeDisabled();
    expect(zoomInBtn).not.toBeDisabled();

    // Zoom in once
    await user.click(zoomInBtn);
    expect(zoomOutBtn).not.toBeDisabled();
  });

  it("zoom out is disabled at minimum zoom", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    expect(screen.getByLabelText("imageLightbox.zoomOut")).toBeDisabled();
  });

  it("zoom resets when navigating to a different image", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    // Zoom in
    await user.click(screen.getByLabelText("imageLightbox.zoomIn"));
    expect(
      screen.getByLabelText("imageLightbox.zoomOut"),
    ).not.toBeDisabled();

    // Navigate to next
    await user.click(screen.getByLabelText("imageLightbox.next"));
    // Zoom should reset — zoom out should be disabled again
    expect(screen.getByLabelText("imageLightbox.zoomOut")).toBeDisabled();
  });

  it("keyboard + zooms in", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    fireEvent.keyDown(document, { key: "+" });
    // After zoom in, zoom out should be enabled
    expect(
      screen.getByLabelText("imageLightbox.zoomOut"),
    ).not.toBeDisabled();
  });

  it("keyboard - zooms out", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    // Zoom in first
    await user.click(screen.getByLabelText("imageLightbox.zoomIn"));
    fireEvent.keyDown(document, { key: "-" });
    // Should be back at min zoom
    expect(screen.getByLabelText("imageLightbox.zoomOut")).toBeDisabled();
  });

  it("prevents body scroll while open", () => {
    const { unmount } = render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    expect(document.body.style.overflow).toBe("hidden");
    unmount();
    // Should restore original overflow
    expect(document.body.style.overflow).not.toBe("hidden");
  });

  it("uses product name in alt text when image has no alt_text", () => {
    const images: ProductImage[] = [
      {
        image_id: 1,
        url: "https://images.example.com/img1.jpg",
        image_type: "front",
        source: "off_api",
        width: 800,
        height: 800,
        alt_text: null,
      },
    ];
    render(
      <ImageLightbox
        images={images}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    expect(
      screen.getByAltText("Test Product — front"),
    ).toBeInTheDocument();
  });

  it("returns null when image at index is undefined", () => {
    const { container } = render(
      <ImageLightbox
        images={[]}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("calls onClose when clicking the backdrop", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    // Click the dialog backdrop (the container div itself)
    const dialog = screen.getByRole("dialog");
    fireEvent.click(dialog);
    expect(onClose).toHaveBeenCalledOnce();
  });

  // ── Touch swipe tests ──────────────────────────────────────────────────

  it("swipes right to go to previous image", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={1}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    // Find the image area (the swipe container)
    const imageArea = screen.getByRole("dialog").querySelector(
      "[style*='cursor']",
    ) as HTMLElement;
    expect(imageArea).toBeTruthy();

    // Simulate touch swipe right (dx > 50)
    fireEvent.touchStart(imageArea, {
      touches: [{ clientX: 100, clientY: 200 }],
    });
    fireEvent.touchEnd(imageArea, {
      changedTouches: [{ clientX: 200, clientY: 200 }],
    });

    // Should show image 1 (previous)
    expect(screen.getByAltText("Image 1")).toBeInTheDocument();
  });

  it("swipes left to go to next image", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    const imageArea = screen.getByRole("dialog").querySelector(
      "[style*='cursor']",
    ) as HTMLElement;

    // Simulate touch swipe left (dx < -50)
    fireEvent.touchStart(imageArea, {
      touches: [{ clientX: 200, clientY: 200 }],
    });
    fireEvent.touchEnd(imageArea, {
      changedTouches: [{ clientX: 100, clientY: 200 }],
    });

    // Should show image 2 (next)
    expect(screen.getByAltText("Image 2")).toBeInTheDocument();
  });

  it("ignores small swipes below threshold", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    const imageArea = screen.getByRole("dialog").querySelector(
      "[style*='cursor']",
    ) as HTMLElement;

    // Small swipe (dx = 30, below 50 threshold)
    fireEvent.touchStart(imageArea, {
      touches: [{ clientX: 100, clientY: 200 }],
    });
    fireEvent.touchEnd(imageArea, {
      changedTouches: [{ clientX: 130, clientY: 200 }],
    });

    // Should still show image 1
    expect(screen.getByAltText("Image 1")).toBeInTheDocument();
  });

  it("does not swipe when zoomed in", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );

    // Zoom in first
    await user.click(screen.getByLabelText("imageLightbox.zoomIn"));

    const imageArea = screen.getByRole("dialog").querySelector(
      "[style*='cursor']",
    ) as HTMLElement;

    // Try swipe
    fireEvent.touchStart(imageArea, {
      touches: [{ clientX: 200, clientY: 200 }],
    });
    fireEvent.touchEnd(imageArea, {
      changedTouches: [{ clientX: 100, clientY: 200 }],
    });

    // Should still show image 1 (swipe ignored when zoomed)
    expect(screen.getByAltText("Image 1")).toBeInTheDocument();
  });

  // ── Mouse drag pan tests ───────────────────────────────────────────────

  it("enables panning cursor when zoomed in", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );

    const imageArea = screen.getByRole("dialog").querySelector(
      "[style*='cursor']",
    ) as HTMLElement;

    // Initially cursor should be default
    expect(imageArea.style.cursor).toBe("default");

    // Zoom in
    await user.click(screen.getByLabelText("imageLightbox.zoomIn"));

    // Now cursor should be grab
    expect(imageArea.style.cursor).toBe("grab");
  });

  it("changes cursor and does not pan when not zoomed", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );

    const imageArea = screen.getByRole("dialog").querySelector(
      "[style*='cursor']",
    ) as HTMLElement;

    // Try mouse down without zoom — should not set up panning
    fireEvent.mouseDown(imageArea, { clientX: 100, clientY: 100 });
    fireEvent.mouseMove(document, { clientX: 150, clientY: 150 });
    fireEvent.mouseUp(document);

    // Should complete without error, cursor stays default
    expect(imageArea.style.cursor).toBe("default");
  });

  it("pans the image on mouse drag when zoomed", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );

    // Zoom in
    await user.click(screen.getByLabelText("imageLightbox.zoomIn"));

    const imageArea = screen.getByRole("dialog").querySelector(
      "[style*='cursor']",
    ) as HTMLElement;

    // Mouse drag to pan
    fireEvent.mouseDown(imageArea, { clientX: 100, clientY: 100 });
    fireEvent.mouseMove(document, { clientX: 150, clientY: 120 });
    fireEvent.mouseUp(document);

    // Transform should include non-zero translate values
    const transformEl = imageArea.querySelector(
      ".transition-transform",
    ) as HTMLElement;
    expect(transformEl).toBeTruthy();
    expect(transformEl.style.transform).toContain("translate");
  });

  it("handles touchEnd without prior touchStart gracefully", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    const imageArea = screen.getByRole("dialog").querySelector(
      "[style*='cursor']",
    ) as HTMLElement;

    // Fire touchEnd without touchStart — should not throw
    fireEvent.touchEnd(imageArea, {
      changedTouches: [{ clientX: 200, clientY: 200 }],
    });
    expect(screen.getByAltText("Image 1")).toBeInTheDocument();
  });

  it("zooms to max and disables zoom in", async () => {
    const user = userEvent.setup();
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    const zoomInBtn = screen.getByLabelText("imageLightbox.zoomIn");

    // Zoom to max (4 levels: 1, 1.5, 2, 3)
    await user.click(zoomInBtn); // → 1.5x
    await user.click(zoomInBtn); // → 2x
    await user.click(zoomInBtn); // → 3x (max)

    expect(zoomInBtn).toBeDisabled();
  });

  it("keyboard = also zooms in", () => {
    render(
      <ImageLightbox
        images={makeImages()}
        initialIndex={0}
        productName="Test Product"
        onClose={onClose}
      />,
    );
    fireEvent.keyDown(document, { key: "=" });
    expect(
      screen.getByLabelText("imageLightbox.zoomOut"),
    ).not.toBeDisabled();
  });
});
