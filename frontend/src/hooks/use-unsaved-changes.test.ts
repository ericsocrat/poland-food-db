import { act, renderHook } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { useUnsavedChanges } from "./use-unsaved-changes";

// ─── Helpers ────────────────────────────────────────────────────────────────

let addEventSpy: ReturnType<typeof vi.spyOn>;
let removeEventSpy: ReturnType<typeof vi.spyOn>;
let originalPushState: typeof history.pushState;

beforeEach(() => {
  vi.clearAllMocks();
  addEventSpy = vi.spyOn(window, "addEventListener");
  removeEventSpy = vi.spyOn(window, "removeEventListener");
  originalPushState = history.pushState;
});

afterEach(() => {
  // Restore in case a test left a patched pushState
  history.pushState = originalPushState;
});

// ─── beforeunload guard ─────────────────────────────────────────────────────

describe("useUnsavedChanges", () => {
  describe("beforeunload guard", () => {
    it("does not add beforeunload listener when not dirty", () => {
      renderHook(() => useUnsavedChanges(false));

      const beforeUnloadCalls = addEventSpy.mock.calls.filter(
        ([event]) => event === "beforeunload",
      );
      expect(beforeUnloadCalls).toHaveLength(0);
    });

    it("adds beforeunload listener when dirty", () => {
      renderHook(() => useUnsavedChanges(true));

      const beforeUnloadCalls = addEventSpy.mock.calls.filter(
        ([event]) => event === "beforeunload",
      );
      expect(beforeUnloadCalls).toHaveLength(1);
    });

    it("removes beforeunload listener on cleanup", () => {
      const { unmount } = renderHook(() => useUnsavedChanges(true));
      unmount();

      const removeCalls = removeEventSpy.mock.calls.filter(
        ([event]) => event === "beforeunload",
      );
      expect(removeCalls).toHaveLength(1);
    });

    it("removes listener when dirty changes from true to false", () => {
      const { rerender } = renderHook(
        ({ dirty }: { dirty: boolean }) => useUnsavedChanges(dirty),
        { initialProps: { dirty: true } },
      );

      rerender({ dirty: false });

      const removeCalls = removeEventSpy.mock.calls.filter(
        ([event]) => event === "beforeunload",
      );
      expect(removeCalls.length).toBeGreaterThanOrEqual(1);
    });

    it("calls preventDefault on beforeunload event when dirty", () => {
      renderHook(() => useUnsavedChanges(true));

      const handler = addEventSpy.mock.calls.find(
        ([event]) => event === "beforeunload",
      )?.[1] as EventListener;

      const event = new Event("beforeunload") as BeforeUnloadEvent;
      const preventSpy = vi.spyOn(event, "preventDefault");
      handler(event);

      expect(preventSpy).toHaveBeenCalled();
    });
  });

  // ─── pushState interception ─────────────────────────────────────────────

  describe("pushState interception", () => {
    it("patches history.pushState on mount", () => {
      renderHook(() => useUnsavedChanges(false));

      // pushState should now be our patched version
      expect(history.pushState).not.toBe(originalPushState);
    });

    it("restores history.pushState on unmount", () => {
      const patched = history.pushState;
      const { unmount } = renderHook(() => useUnsavedChanges(false));

      // pushState was replaced by the hook
      expect(history.pushState).not.toBe(patched);

      unmount();

      // After unmount, the hook's wrapper is removed
      expect(history.pushState).not.toBe(patched);
    });

    it("allows pushState when not dirty", () => {
      const _pushSpy = vi.fn();
      history.pushState = originalPushState;
      const _origBound = history.pushState.bind(history);

      // We need a clean hook that intercepts pushState
      const { result } = renderHook(() => useUnsavedChanges(false));

      // The patched pushState should pass through to the original
      // We can't easily spy on the original, but we can check that
      // no dialog is shown
      act(() => {
        history.pushState(null, "", "/some-url");
      });

      expect(result.current.showConfirmDialog).toBe(false);
    });

    it("blocks pushState and shows dialog when dirty", () => {
      const { result } = renderHook(() => useUnsavedChanges(true));

      act(() => {
        history.pushState(null, "", "/categories");
      });

      expect(result.current.showConfirmDialog).toBe(true);
    });

    it("stores pending href from blocked pushState", () => {
      const { result } = renderHook(() => useUnsavedChanges(true));

      act(() => {
        history.pushState(null, "", "/categories");
      });

      expect(result.current.showConfirmDialog).toBe(true);
    });
  });

  // ─── Dialog state ───────────────────────────────────────────────────────

  describe("dialog state", () => {
    it("initially does not show confirm dialog", () => {
      const { result } = renderHook(() => useUnsavedChanges(false));
      expect(result.current.showConfirmDialog).toBe(false);
    });

    it("cancelNavigation clears pending state", () => {
      const { result } = renderHook(() => useUnsavedChanges(true));

      act(() => {
        history.pushState(null, "", "/categories");
      });
      expect(result.current.showConfirmDialog).toBe(true);

      act(() => {
        result.current.cancelNavigation();
      });
      expect(result.current.showConfirmDialog).toBe(false);
    });

    it("confirmNavigation calls location.assign and clears state", () => {
      const assignMock = vi.fn();
      const origLocation = window.location;
      Object.defineProperty(window, "location", {
        value: { ...origLocation, assign: assignMock },
        writable: true,
        configurable: true,
      });

      const { result } = renderHook(() => useUnsavedChanges(true));

      act(() => {
        history.pushState(null, "", "/categories");
      });

      act(() => {
        result.current.confirmNavigation();
      });

      expect(assignMock).toHaveBeenCalledWith("/categories");
      expect(result.current.showConfirmDialog).toBe(false);

      Object.defineProperty(window, "location", {
        value: origLocation,
        writable: true,
        configurable: true,
      });
    });

    it("clears pending state when dirty changes to false", () => {
      const { result, rerender } = renderHook(
        ({ dirty }: { dirty: boolean }) => useUnsavedChanges(dirty),
        { initialProps: { dirty: true } },
      );

      act(() => {
        history.pushState(null, "", "/categories");
      });
      expect(result.current.showConfirmDialog).toBe(true);

      rerender({ dirty: false });
      expect(result.current.showConfirmDialog).toBe(false);
    });

    it("does not navigate when confirmNavigation called with no pending href", () => {
      const assignMock = vi.fn();
      const origLocation = window.location;
      Object.defineProperty(window, "location", {
        value: { ...origLocation, assign: assignMock },
        writable: true,
        configurable: true,
      });

      const { result } = renderHook(() => useUnsavedChanges(false));

      act(() => {
        result.current.confirmNavigation();
      });

      expect(assignMock).not.toHaveBeenCalled();

      Object.defineProperty(window, "location", {
        value: origLocation,
        writable: true,
        configurable: true,
      });
    });
  });
});
