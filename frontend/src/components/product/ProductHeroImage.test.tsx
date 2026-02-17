import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { ProductHeroImage } from "./ProductHeroImage";
import type { ProductImages } from "@/lib/types";

// Mock next/image to render a plain img tag for testing
vi.mock("next/image", () => ({
  default: (props: Record<string, unknown>) => {
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    return <img {...props} />;
  },
}));

function makeImages(overrides: Partial<ProductImages> = {}): ProductImages {
  return {
    has_image: true,
    primary: {
      image_id: 1,
      url: "https://images.openfoodfacts.org/images/products/123/front.jpg",
      image_type: "front",
      source: "off_api",
      width: 400,
      height: 400,
      alt_text: "Front photo",
    },
    additional: [],
    ...overrides,
  };
}

describe("ProductHeroImage", () => {
  it("renders product image when has_image is true", () => {
    render(
      <ProductHeroImage
        images={makeImages()}
        productName="Test Product"
        categoryIcon="🍕"
      />,
    );
    const img = screen.getByAltText("Front photo");
    expect(img).toBeTruthy();
    expect(img.getAttribute("src")).toContain("openfoodfacts.org");
  });

  it("renders CategoryPlaceholder when has_image is false", () => {
    render(
      <ProductHeroImage
        images={makeImages({ has_image: false, primary: null })}
        productName="No Image Product"
        categoryIcon="📦"
      />,
    );
    expect(screen.getByLabelText("No Image Product — no image available")).toBeTruthy();
    expect(screen.getByText("📦")).toBeTruthy();
  });

  it("renders CategoryPlaceholder when primary is null", () => {
    render(
      <ProductHeroImage
        images={makeImages({ has_image: false, primary: null })}
        productName="Fallback Product"
        categoryIcon="🧀"
      />,
    );
    expect(screen.getByText("🧀")).toBeTruthy();
  });

  it("shows ImageSourceBadge with OFF source", () => {
    render(
      <ProductHeroImage
        images={makeImages()}
        productName="Badge Product"
        categoryIcon="🍕"
      />,
    );
    expect(screen.getByText(/Open Food Facts/)).toBeTruthy();
  });

  it("uses product name as alt text when alt_text is null", () => {
    const images = makeImages();
    images.primary!.alt_text = null;
    render(
      <ProductHeroImage
        images={images}
        productName="Fallback Alt"
        categoryIcon="🍕"
      />,
    );
    expect(screen.getByAltText("Fallback Alt")).toBeTruthy();
  });
});
