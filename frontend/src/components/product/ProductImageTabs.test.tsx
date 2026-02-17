import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { ProductImageTabs } from "./ProductImageTabs";
import type { ProductImages } from "@/lib/types";

// Mock next/image
vi.mock("next/image", () => ({
  default: (props: Record<string, unknown>) => {
    // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
    return <img {...props} />;
  },
}));

function makeMultiImages(): ProductImages {
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
    additional: [
      {
        image_id: 2,
        url: "https://images.openfoodfacts.org/images/products/123/ingredients.jpg",
        image_type: "ingredients",
        source: "off_api",
        width: 400,
        height: 400,
        alt_text: "Ingredients photo",
      },
      {
        image_id: 3,
        url: "https://images.openfoodfacts.org/images/products/123/nutrition.jpg",
        image_type: "nutrition_label",
        source: "off_api",
        width: 400,
        height: 400,
        alt_text: "Nutrition label photo",
      },
    ],
  };
}

describe("ProductImageTabs", () => {
  it("renders nothing when fewer than 2 images", () => {
    const images: ProductImages = {
      has_image: true,
      primary: {
        image_id: 1,
        url: "https://images.openfoodfacts.org/front.jpg",
        image_type: "front",
        source: "off_api",
        width: 400,
        height: 400,
        alt_text: "Front",
      },
      additional: [],
    };
    const { container } = render(
      <ProductImageTabs images={images} productName="Single" />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders tab buttons for multiple images", () => {
    render(<ProductImageTabs images={makeMultiImages()} productName="Multi" />);
    expect(screen.getByText("Front")).toBeTruthy();
    expect(screen.getByText("Ingredients")).toBeTruthy();
    expect(screen.getByText("Nutrition")).toBeTruthy();
  });

  it("shows first image by default", () => {
    render(<ProductImageTabs images={makeMultiImages()} productName="Multi" />);
    expect(screen.getByAltText("Front photo")).toBeTruthy();
  });

  it("switches image on tab click", async () => {
    const user = userEvent.setup();
    render(<ProductImageTabs images={makeMultiImages()} productName="Multi" />);

    await user.click(screen.getByText("Ingredients"));
    expect(screen.getByAltText("Ingredients photo")).toBeTruthy();
  });

  it("shows heading", () => {
    render(<ProductImageTabs images={makeMultiImages()} productName="Multi" />);
    expect(screen.getByText("Product Photos")).toBeTruthy();
  });

  it("renders nothing when no images at all", () => {
    const images: ProductImages = {
      has_image: false,
      primary: null,
      additional: [],
    };
    const { container } = render(
      <ProductImageTabs images={images} productName="None" />,
    );
    expect(container.innerHTML).toBe("");
  });
});
