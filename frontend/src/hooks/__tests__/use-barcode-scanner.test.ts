import type React from "react";

import { useBarcodeScanner } from "@/hooks/use-barcode-scanner";
import { act, renderHook } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

// ─── Hoisted mocks ──────────────────────────────────────────────────────────

const {
  mockListDevices,
  mockDecodeFromDevice,
  mockResetReader,
  mockClassify,
  mockGetBrowser,
  mockGetFacing,
  mockShowToast,
  mockIsValidEan,
  mockGetUserMedia,
} = vi.hoisted(() => ({
  mockListDevices: vi.fn(),
  mockDecodeFromDevice: vi.fn(),
  mockResetReader: vi.fn(),
  mockClassify: vi.fn(),
  mockGetBrowser: vi.fn(),
  mockGetFacing: vi.fn(),
  mockShowToast: vi.fn(),
  mockIsValidEan: vi.fn(),
  mockGetUserMedia: vi.fn(),
}));

// ─── Module mocks ───────────────────────────────────────────────────────────

vi.mock("@zxing/library", () => {
  function MockBrowserMultiFormatReader() {
    return {
      listVideoInputDevices: (...a: unknown[]) => mockListDevices(...a),
      decodeFromVideoDevice: (...a: unknown[]) => mockDecodeFromDevice(...a),
      reset: (...a: unknown[]) => mockResetReader(...a),
    };
  }
  return {
    BrowserMultiFormatReader: MockBrowserMultiFormatReader,
    DecodeHintType: { POSSIBLE_FORMATS: 0 },
    BarcodeFormat: { EAN_13: 0, EAN_8: 1, UPC_A: 2, UPC_E: 3 },
  };
});

vi.mock("@/lib/scanner-errors", () => ({
  classifyScannerError: (...a: unknown[]) => mockClassify(...a),
  getBrowserSummary: (...a: unknown[]) => mockGetBrowser(...a),
  getFacingMode: (...a: unknown[]) => mockGetFacing(...a),
}));

vi.mock("@/lib/toast", () => ({
  showToast: (...a: unknown[]) => mockShowToast(...a),
}));

vi.mock("@/lib/validation", () => ({
  isValidEan: (...a: unknown[]) => mockIsValidEan(...a),
}));

// ─── jsdom stubs ────────────────────────────────────────────────────────────

if (typeof globalThis.MediaStream === "undefined") {
  globalThis.MediaStream = class MediaStream {
    getVideoTracks() {
      return [];
    }
    getTracks() {
      return [];
    }
  } as unknown as typeof MediaStream;
}

// Pre-flight getUserMedia stub — delegates to hoisted mock
Object.defineProperty(navigator, "mediaDevices", {
  value: { getUserMedia: (...a: unknown[]) => mockGetUserMedia(...a) },
  writable: true,
  configurable: true,
});

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeOptions(overrides: Partial<Parameters<typeof useBarcodeScanner>[0]> = {}) {
  return {
    onBarcodeDetected: vi.fn(),
    enabled: false,
    track: vi.fn(),
    ...overrides,
  };
}

function makeDevice(
  id: string,
  label = "Camera",
): Pick<MediaDeviceInfo, "deviceId" | "label"> {
  return { deviceId: id, label };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
  vi.useFakeTimers();
  mockListDevices.mockResolvedValue([]);
  mockDecodeFromDevice.mockResolvedValue(undefined);
  mockGetBrowser.mockReturnValue("Chrome/120");
  mockGetFacing.mockReturnValue("environment");
  mockIsValidEan.mockReturnValue(true);
  mockGetUserMedia.mockResolvedValue({
    getTracks: () => [{ stop: vi.fn() }],
  });
});

afterEach(() => {
  vi.useRealTimers();
  vi.restoreAllMocks();
});

describe("useBarcodeScanner", () => {
  // ─── Initial state ────────────────────────────────────────────────────

  describe("initial state", () => {
    it("returns null cameraError, torchOn false, feedActive false", () => {
      const { result } = renderHook(() => useBarcodeScanner(makeOptions()));

      expect(result.current.cameraError).toBeNull();
      expect(result.current.torchOn).toBe(false);
      expect(result.current.feedActive).toBe(false);
      expect(result.current.streamReadyTime).toBe(0);
    });

    it("exposes videoRef", () => {
      const { result } = renderHook(() => useBarcodeScanner(makeOptions()));
      expect(result.current.videoRef).toBeDefined();
      expect(result.current.videoRef.current).toBeNull();
    });
  });

  // ─── Auto-start via enabled flag ──────────────────────────────────────

  describe("auto-start/stop", () => {
    it("does not start scanner when enabled=false", () => {
      renderHook(() => useBarcodeScanner(makeOptions({ enabled: false })));

      expect(mockListDevices).not.toHaveBeenCalled();
    });

    it("starts scanner automatically when enabled=true", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);

      await act(async () => {
        renderHook(() => useBarcodeScanner(makeOptions({ enabled: true })));
      });

      expect(mockListDevices).toHaveBeenCalled();
    });

    it("stops scanner on unmount", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);
      const mockTrack = { stop: vi.fn() };
      const mockStream = {
        getTracks: () => [mockTrack],
        getVideoTracks: () => [],
      };
      Object.defineProperty(HTMLVideoElement.prototype, "srcObject", {
        set() {
          // no-op for test
        },
        get() {
          return mockStream;
        },
        configurable: true,
      });

      let hookResult: ReturnType<typeof renderHook>;
      await act(async () => {
        hookResult = renderHook(() =>
          useBarcodeScanner(makeOptions({ enabled: true })),
        );
      });

      act(() => {
        hookResult!.unmount();
      });

      expect(mockResetReader).toHaveBeenCalled();
    });
  });

  // ─── No-camera error ──────────────────────────────────────────────────

  describe("no-camera error", () => {
    it("sets cameraError to no-camera when no devices found", async () => {
      mockListDevices.mockResolvedValue([]);

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(result.current.cameraError).toBe("no-camera");
    });

    it("fires scanner_init_error telemetry with no-camera error", async () => {
      mockListDevices.mockResolvedValue([]);
      const track = vi.fn();

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions({ track })),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(track).toHaveBeenCalledWith("scanner_init_error", expect.objectContaining({
        error_type: "no-camera",
      }));
    });
  });

  // ─── Successful start ─────────────────────────────────────────────────

  describe("successful start", () => {
    it("fires scanner_init_start telemetry", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);
      const track = vi.fn();

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions({ track })),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(track).toHaveBeenCalledWith("scanner_init_start", expect.objectContaining({
        browser: "Chrome/120",
      }));
    });

    it("calls decodeFromVideoDevice with selected device", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(mockDecodeFromDevice).toHaveBeenCalledWith(
        "cam1",
        null, // videoRef.current is null in jsdom
        expect.any(Function),
      );
    });

    it("prefers back camera when available", async () => {
      mockListDevices.mockResolvedValue([
        makeDevice("front", "Front Camera"),
        makeDevice("back", "Back Camera"),
      ]);

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(mockDecodeFromDevice).toHaveBeenCalledWith(
        "back",
        null, // videoRef.current is null in jsdom
        expect.any(Function),
      );
    });

    it("falls back to first device when no back camera", async () => {
      mockListDevices.mockResolvedValue([
        makeDevice("only", "Webcam"),
      ]);

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(mockDecodeFromDevice).toHaveBeenCalledWith(
        "only",
        null, // videoRef.current is null in jsdom
        expect.any(Function),
      );
    });
  });

  // ─── Barcode detection ────────────────────────────────────────────────

  describe("barcode detection", () => {
    it("calls onBarcodeDetected for valid EAN", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);
      mockIsValidEan.mockReturnValue(true);

      let decodeCallback: (result: { getText: () => string } | null, error: unknown) => void;
      mockDecodeFromDevice.mockImplementation(
        (_id: string, _el: unknown, cb: typeof decodeCallback) => {
          decodeCallback = cb;
          return Promise.resolve();
        },
      );

      const onBarcodeDetected = vi.fn();
      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions({ onBarcodeDetected })),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      act(() => {
        decodeCallback!({ getText: () => "5901234123457" }, null);
      });

      expect(onBarcodeDetected).toHaveBeenCalledWith("5901234123457");
    });

    it("does not call onBarcodeDetected for invalid EAN", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);
      mockIsValidEan.mockReturnValue(false);

      let decodeCallback: (result: { getText: () => string } | null, error: unknown) => void;
      mockDecodeFromDevice.mockImplementation(
        (_id: string, _el: unknown, cb: typeof decodeCallback) => {
          decodeCallback = cb;
          return Promise.resolve();
        },
      );

      const onBarcodeDetected = vi.fn();
      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions({ onBarcodeDetected })),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      act(() => {
        decodeCallback!({ getText: () => "invalid" }, null);
      });

      expect(onBarcodeDetected).not.toHaveBeenCalled();
    });

    it("ignores null decode results", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);

      let decodeCallback: (result: null, error: unknown) => void;
      mockDecodeFromDevice.mockImplementation(
        (_id: string, _el: unknown, cb: typeof decodeCallback) => {
          decodeCallback = cb;
          return Promise.resolve();
        },
      );

      const onBarcodeDetected = vi.fn();
      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions({ onBarcodeDetected })),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      act(() => {
        decodeCallback!(null, null);
      });

      expect(onBarcodeDetected).not.toHaveBeenCalled();
    });
  });

  // ─── Permission errors ────────────────────────────────────────────────

  describe("permission errors", () => {
    it("sets permission-denied when permissions.query returns denied", async () => {
      mockGetUserMedia.mockRejectedValue(new DOMException("NotAllowedError", "NotAllowedError"));
      mockClassify.mockReturnValue("permission-denied");

      // Mock permissions API
      Object.defineProperty(navigator, "permissions", {
        value: {
          query: vi.fn().mockResolvedValue({ state: "denied" }),
        },
        writable: true,
        configurable: true,
      });

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(result.current.cameraError).toBe("permission-denied");
    });

    it("sets permission-prompt when permissions.query returns prompt", async () => {
      mockGetUserMedia.mockRejectedValue(new DOMException("NotAllowedError", "NotAllowedError"));
      mockClassify.mockReturnValue("permission-denied");

      Object.defineProperty(navigator, "permissions", {
        value: {
          query: vi.fn().mockResolvedValue({ state: "prompt" }),
        },
        writable: true,
        configurable: true,
      });

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        // "prompt" is not "denied", so pre-flight retries — advance timers
        // to flush all 5 retry delays (250+500+1000+2000+4000 = 7750ms).
        const promise = result.current.startScanner();
        await vi.advanceTimersByTimeAsync(8_000);
        await promise;
      });

      expect(result.current.cameraError).toBe("permission-prompt");
    });

    it("sets permission-unknown when permissions API unavailable", async () => {
      mockGetUserMedia.mockRejectedValue(new DOMException("NotAllowedError", "NotAllowedError"));
      mockClassify.mockReturnValue("permission-denied");

      Object.defineProperty(navigator, "permissions", {
        value: undefined,
        writable: true,
        configurable: true,
      });

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        // Permissions API unavailable → not explicitly denied → retries
        const promise = result.current.startScanner();
        await vi.advanceTimersByTimeAsync(8_000);
        await promise;
      });

      expect(result.current.cameraError).toBe("permission-unknown");
    });

    it("sets generic error for non-permission errors", async () => {
      mockListDevices.mockRejectedValue(new Error("Something broke"));
      mockClassify.mockReturnValue("unknown");

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(result.current.cameraError).toBe("generic");
    });

    it("fires scanner_init_error telemetry on error", async () => {
      mockListDevices.mockRejectedValue(new Error("fail"));
      mockClassify.mockReturnValue("unknown");
      const track = vi.fn();

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions({ track })),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(track).toHaveBeenCalledWith("scanner_init_error", expect.objectContaining({
        error_type: "unknown",
      }));
    });

    it("pre-flight retries getUserMedia on transient SPA error (permission granted)", async () => {
      // First getUserMedia call fails, second succeeds
      mockGetUserMedia
        .mockRejectedValueOnce(
          new DOMException("NotAllowedError", "NotAllowedError"),
        )
        .mockResolvedValueOnce({ getTracks: () => [{ stop: vi.fn() }] });

      mockListDevices.mockResolvedValue([makeDevice("cam1")]);

      Object.defineProperty(navigator, "permissions", {
        value: {
          query: vi.fn().mockResolvedValue({ state: "granted" }),
        },
        writable: true,
        configurable: true,
      });

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        const promise = result.current.startScanner();
        // Advance past the first pre-flight retry delay (250ms)
        await vi.advanceTimersByTimeAsync(300);
        await promise;
      });

      // Scanner recovered via pre-flight — no error shown
      expect(result.current.cameraError).toBeNull();
      expect(mockGetUserMedia).toHaveBeenCalledTimes(2);
    });

    it("pre-flight retries getUserMedia when permission state is prompt (not denied)", async () => {
      // First getUserMedia call fails (transient), second succeeds
      mockGetUserMedia
        .mockRejectedValueOnce(
          new DOMException("NotAllowedError", "NotAllowedError"),
        )
        .mockResolvedValueOnce({ getTracks: () => [{ stop: vi.fn() }] });

      mockListDevices.mockResolvedValue([makeDevice("cam1")]);

      // Permission state is "prompt" — should still retry (not bail)
      Object.defineProperty(navigator, "permissions", {
        value: {
          query: vi.fn().mockResolvedValue({ state: "prompt" }),
        },
        writable: true,
        configurable: true,
      });

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        const promise = result.current.startScanner();
        await vi.advanceTimersByTimeAsync(300);
        await promise;
      });

      // Scanner recovered via pre-flight retry — no error shown
      expect(result.current.cameraError).toBeNull();
      expect(mockGetUserMedia).toHaveBeenCalledTimes(2);
    });
  });

  // ─── Watchdog timeout ─────────────────────────────────────────────────

  describe("watchdog timeout", () => {
    it("sets generic error after 5s if feed not ready", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);
      const track = vi.fn();

      // Create a mock video element with stale readyState so watchdog fires
      const mockVideoEl = {
        readyState: 0,
        videoWidth: 0,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        srcObject: null,
      } as unknown as HTMLVideoElement;

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions({ track, enabled: false })),
      );

      // Attach mock video element before starting scanner
      (result.current.videoRef as React.MutableRefObject<HTMLVideoElement | null>).current = mockVideoEl;

      await act(async () => {
        await result.current.startScanner();
      });

      // Advance past watchdog timeout
      await act(async () => {
        vi.advanceTimersByTime(5_100);
      });

      expect(result.current.cameraError).toBe("generic");
      expect(track).toHaveBeenCalledWith("scanner_init_error", expect.objectContaining({
        error_type: "feed-timeout",
      }));
    });
  });

  // ─── Stop scanner ─────────────────────────────────────────────────────

  describe("stopScanner", () => {
    it("resets reader and stops stream tracks", async () => {
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      act(() => {
        result.current.stopScanner();
      });

      expect(mockResetReader).toHaveBeenCalled();
      expect(result.current.torchOn).toBe(false);
      expect(result.current.feedActive).toBe(false);
    });
  });

  // ─── Clear error ──────────────────────────────────────────────────────

  describe("clearError", () => {
    it("clears cameraError back to null", async () => {
      mockListDevices.mockResolvedValue([]);

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(result.current.cameraError).toBe("no-camera");

      act(() => {
        result.current.clearError();
      });

      expect(result.current.cameraError).toBeNull();
    });
  });

  // ─── Torch toggle ────────────────────────────────────────────────────

  describe("toggleTorch", () => {
    it("does nothing when no stream is active", async () => {
      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.toggleTorch();
      });

      expect(result.current.torchOn).toBe(false);
    });
  });

  // ─── startScanner clears previous error ───────────────────────────────

  describe("error recovery", () => {
    it("clears previous error when startScanner is called", async () => {
      // First call: no camera
      mockListDevices.mockResolvedValue([]);

      const { result } = renderHook(() =>
        useBarcodeScanner(makeOptions()),
      );

      await act(async () => {
        await result.current.startScanner();
      });

      expect(result.current.cameraError).toBe("no-camera");

      // Second call: has camera
      mockListDevices.mockResolvedValue([makeDevice("cam1")]);

      await act(async () => {
        await result.current.startScanner();
      });

      expect(result.current.cameraError).toBeNull();
    });
  });
});
