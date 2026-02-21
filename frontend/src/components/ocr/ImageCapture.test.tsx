import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";

// ── Mocks ────────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

import { ImageCapture } from "./ImageCapture";

// ── Helpers ──────────────────────────────────────────────────────────────────

function makeFile(name = "label.jpg", type = "image/jpeg"): File {
  return new File(["fake image data"], name, { type });
}

// ── Camera mock helpers ──────────────────────────────────────────────────────

const mockStop = vi.fn();
const mockTrack = { stop: mockStop, kind: "video", id: "t1" };
const mockStream = {
  getTracks: () => [mockTrack],
  getVideoTracks: () => [mockTrack],
  getAudioTracks: () => [],
  active: true,
} as unknown as MediaStream;

const mockGetUserMedia = vi.fn<[], Promise<MediaStream>>();
const mockDrawImage = vi.fn();
const mockClearRect = vi.fn();
const mockCtx = {
  drawImage: mockDrawImage,
  clearRect: mockClearRect,
} as unknown as CanvasRenderingContext2D;

function setupCameraSupport(): void {
  Object.defineProperty(navigator, "mediaDevices", {
    value: { getUserMedia: mockGetUserMedia },
    writable: true,
    configurable: true,
  });
}

/** Start the camera in a rendered component and wait for the UI to show */
async function openCamera(): Promise<void> {
  await waitFor(() => {
    expect(screen.getByTestId("open-camera-btn")).toBeInTheDocument();
  });
  fireEvent.click(screen.getByTestId("open-camera-btn"));
  await waitFor(() => {
    expect(screen.getByTestId("capture-btn")).toBeInTheDocument();
  });
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("ImageCapture", () => {
  let origGetContext: typeof HTMLCanvasElement.prototype.getContext;
  let origToBlob: typeof HTMLCanvasElement.prototype.toBlob;
  let origPlay: typeof HTMLVideoElement.prototype.play;

  beforeEach(() => {
    vi.clearAllMocks();
    mockGetUserMedia.mockResolvedValue(mockStream);

    // Save originals
    origGetContext = HTMLCanvasElement.prototype.getContext;
    origToBlob = HTMLCanvasElement.prototype.toBlob;
    origPlay = HTMLVideoElement.prototype.play;

    // Mock video.play
    HTMLVideoElement.prototype.play = vi
      .fn()
      .mockResolvedValue(undefined) as typeof HTMLVideoElement.prototype.play;

    // Mock canvas.getContext to return our stub
    HTMLCanvasElement.prototype.getContext = vi
      .fn()
      .mockReturnValue(mockCtx) as typeof HTMLCanvasElement.prototype.getContext;

    // Mock canvas.toBlob — calls callback synchronously with a Blob
    HTMLCanvasElement.prototype.toBlob = vi
      .fn()
      .mockImplementation(function (this: HTMLCanvasElement, cb: BlobCallback) {
        cb(new Blob(["frame"], { type: "image/jpeg" }));
      }) as typeof HTMLCanvasElement.prototype.toBlob;
  });

  afterEach(() => {
    // Restore original prototypes
    HTMLCanvasElement.prototype.getContext = origGetContext;
    HTMLCanvasElement.prototype.toBlob = origToBlob;
    HTMLVideoElement.prototype.play = origPlay;
  });

  // ── Basic rendering ──────────────────────────────────────────────────────

  it("renders upload button", () => {
    render(<ImageCapture onCapture={vi.fn()} processing={false} />);
    expect(screen.getByTestId("upload-btn")).toBeInTheDocument();
  });

  it("renders instructions text", () => {
    render(<ImageCapture onCapture={vi.fn()} processing={false} />);
    expect(
      screen.getByText("imageSearch.instructions"),
    ).toBeInTheDocument();
  });

  it("renders tips text", () => {
    render(<ImageCapture onCapture={vi.fn()} processing={false} />);
    expect(screen.getByText("imageSearch.tips")).toBeInTheDocument();
  });

  it("has a hidden file input with correct attributes", () => {
    render(<ImageCapture onCapture={vi.fn()} processing={false} />);
    const input = screen.getByTestId("file-input");
    expect(input).toBeInTheDocument();
    expect(input).toHaveAttribute("type", "file");
    expect(input).toHaveAttribute("accept", "image/*");
  });

  it("clicking upload button triggers file input", () => {
    render(<ImageCapture onCapture={vi.fn()} processing={false} />);
    const input = screen.getByTestId("file-input");
    const clickSpy = vi.spyOn(input, "click");

    fireEvent.click(screen.getByTestId("upload-btn"));
    expect(clickSpy).toHaveBeenCalled();
  });

  // ── File upload ──────────────────────────────────────────────────────────

  it("calls onCapture when file is selected", async () => {
    const onCapture = vi.fn();
    render(<ImageCapture onCapture={onCapture} processing={false} />);

    const input = screen.getByTestId("file-input");
    const file = makeFile();
    fireEvent.change(input, { target: { files: [file] } });

    await waitFor(() => {
      expect(onCapture).toHaveBeenCalledWith(file);
    });
  });

  it("does not call onCapture when file selection is cancelled", () => {
    const onCapture = vi.fn();
    render(<ImageCapture onCapture={onCapture} processing={false} />);

    const input = screen.getByTestId("file-input");
    fireEvent.change(input, { target: { files: [] } });

    expect(onCapture).not.toHaveBeenCalled();
  });

  it("resets file input after selection so same file can be re-selected", async () => {
    const onCapture = vi.fn();
    render(<ImageCapture onCapture={onCapture} processing={false} />);

    const input = screen.getByTestId("file-input") as HTMLInputElement;
    const file = makeFile();

    // Simulate first selection
    fireEvent.change(input, { target: { files: [file] } });
    await waitFor(() => expect(onCapture).toHaveBeenCalledTimes(1));

    // After reset, the input value should be empty
    expect(input.value).toBe("");
  });

  // ── Processing state ─────────────────────────────────────────────────────

  it("disables upload button when processing", () => {
    render(<ImageCapture onCapture={vi.fn()} processing={true} />);
    expect(screen.getByTestId("upload-btn")).toBeDisabled();
  });

  // ── Camera support detection ─────────────────────────────────────────────

  it("hides camera button when getUserMedia is not available", () => {
    // Default jsdom has no mediaDevices, so camera should be hidden
    render(<ImageCapture onCapture={vi.fn()} processing={false} />);
    expect(screen.queryByTestId("open-camera-btn")).not.toBeInTheDocument();
  });

  it("shows camera button when getUserMedia is available", async () => {
    setupCameraSupport();
    render(<ImageCapture onCapture={vi.fn()} processing={false} />);

    await waitFor(() => {
      expect(screen.getByTestId("open-camera-btn")).toBeInTheDocument();
    });
  });

  // ── Camera workflow ──────────────────────────────────────────────────────

  describe("camera workflow", () => {
    beforeEach(() => {
      setupCameraSupport();
    });

    it("opens camera and shows preview + capture controls", async () => {
      render(<ImageCapture onCapture={vi.fn()} processing={false} />);
      await openCamera();

      expect(mockGetUserMedia).toHaveBeenCalledWith({
        video: { facingMode: "environment" },
      });
      expect(screen.getByTestId("camera-preview")).toBeInTheDocument();
      expect(screen.getByTestId("capture-btn")).toBeInTheDocument();
      expect(screen.getByLabelText("common.cancel")).toBeInTheDocument();

      // Action buttons (upload/open-camera) should be hidden while camera active
      expect(screen.queryByTestId("open-camera-btn")).not.toBeInTheDocument();
    });

    it("shows camera error when getUserMedia rejects", async () => {
      mockGetUserMedia.mockRejectedValueOnce(new Error("Permission denied"));
      render(<ImageCapture onCapture={vi.fn()} processing={false} />);

      await waitFor(() => {
        expect(screen.getByTestId("open-camera-btn")).toBeInTheDocument();
      });

      fireEvent.click(screen.getByTestId("open-camera-btn"));

      await waitFor(() => {
        expect(screen.getByRole("alert")).toHaveTextContent(
          "imageSearch.cameraError",
        );
      });

      // Camera preview should NOT be shown
      expect(screen.queryByTestId("camera-preview")).not.toBeInTheDocument();
    });

    it("captures frame, calls onCapture with blob, and stops camera", async () => {
      const onCapture = vi.fn();
      render(<ImageCapture onCapture={onCapture} processing={false} />);
      await openCamera();

      // Mock video dimensions
      const video = screen.getByTestId("camera-preview");
      Object.defineProperty(video, "videoWidth", {
        value: 640,
        configurable: true,
      });
      Object.defineProperty(video, "videoHeight", {
        value: 480,
        configurable: true,
      });

      fireEvent.click(screen.getByTestId("capture-btn"));

      await waitFor(() => {
        expect(onCapture).toHaveBeenCalledTimes(1);
      });

      const blob = onCapture.mock.calls[0][0];
      expect(blob).toBeInstanceOf(Blob);
      expect(mockDrawImage).toHaveBeenCalled();
      expect(mockClearRect).toHaveBeenCalled();

      // Camera should have been stopped
      expect(mockStop).toHaveBeenCalled();
      expect(screen.queryByTestId("camera-preview")).not.toBeInTheDocument();
    });

    it("does not call onCapture when toBlob returns null", async () => {
      const onCapture = vi.fn();

      // Override toBlob to return null
      HTMLCanvasElement.prototype.toBlob = vi
        .fn()
        .mockImplementation(function (
          this: HTMLCanvasElement,
          cb: BlobCallback,
        ) {
          cb(null);
        }) as typeof HTMLCanvasElement.prototype.toBlob;

      render(<ImageCapture onCapture={onCapture} processing={false} />);
      await openCamera();

      const video = screen.getByTestId("camera-preview");
      Object.defineProperty(video, "videoWidth", {
        value: 640,
        configurable: true,
      });
      Object.defineProperty(video, "videoHeight", {
        value: 480,
        configurable: true,
      });

      fireEvent.click(screen.getByTestId("capture-btn"));

      // onCapture should NOT be called when blob is null
      expect(onCapture).not.toHaveBeenCalled();
      // Canvas cleanup still runs
      expect(mockClearRect).toHaveBeenCalled();
    });

    it("handles captureFrame when getContext returns null", async () => {
      const onCapture = vi.fn();

      // Override getContext to return null
      HTMLCanvasElement.prototype.getContext = vi
        .fn()
        .mockReturnValue(null) as typeof HTMLCanvasElement.prototype.getContext;

      render(<ImageCapture onCapture={onCapture} processing={false} />);
      await openCamera();

      const video = screen.getByTestId("camera-preview");
      Object.defineProperty(video, "videoWidth", {
        value: 640,
        configurable: true,
      });
      Object.defineProperty(video, "videoHeight", {
        value: 480,
        configurable: true,
      });

      fireEvent.click(screen.getByTestId("capture-btn"));

      // Should bail out — no drawImage, no onCapture
      expect(mockDrawImage).not.toHaveBeenCalled();
      expect(onCapture).not.toHaveBeenCalled();
    });

    it("stops camera and removes preview when cancel is clicked", async () => {
      render(<ImageCapture onCapture={vi.fn()} processing={false} />);
      await openCamera();

      fireEvent.click(screen.getByLabelText("common.cancel"));

      await waitFor(() => {
        expect(mockStop).toHaveBeenCalled();
        expect(
          screen.queryByTestId("camera-preview"),
        ).not.toBeInTheDocument();
      });

      // Action buttons should reappear
      expect(screen.getByTestId("open-camera-btn")).toBeInTheDocument();
      expect(screen.getByTestId("upload-btn")).toBeInTheDocument();
    });

    it("cleans up camera stream on component unmount", async () => {
      const { unmount } = render(
        <ImageCapture onCapture={vi.fn()} processing={false} />,
      );
      await openCamera();

      unmount();
      expect(mockStop).toHaveBeenCalled();
    });

    it("disables camera and capture buttons when processing", async () => {
      setupCameraSupport();
      render(<ImageCapture onCapture={vi.fn()} processing={true} />);

      await waitFor(() => {
        expect(screen.getByTestId("open-camera-btn")).toBeInTheDocument();
      });

      expect(screen.getByTestId("open-camera-btn")).toBeDisabled();
      expect(screen.getByTestId("upload-btn")).toBeDisabled();
    });
  });
});
