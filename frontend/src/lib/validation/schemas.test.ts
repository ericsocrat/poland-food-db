import { describe, it, expect } from "vitest";
import {
  loginSchema,
  signupSchema,
  onboardingSchema,
  listSchema,
  healthProfileSchema,
  contactSchema,
  productSubmissionSchema,
  emailSchema,
  requiredStringSchema,
  passwordSchema,
} from "./schemas";

// ─── Reusable validators ────────────────────────────────────────────────────

describe("emailSchema", () => {
  it("accepts valid email", () => {
    expect(emailSchema.safeParse("user@example.com").success).toBe(true);
  });

  it("rejects invalid email", () => {
    const result = emailSchema.safeParse("not-an-email");
    expect(result.success).toBe(false);
  });

  it("rejects empty string", () => {
    expect(emailSchema.safeParse("").success).toBe(false);
  });
});

describe("requiredStringSchema", () => {
  it("accepts non-empty string", () => {
    const schema = requiredStringSchema("name");
    expect(schema.safeParse("hello").success).toBe(true);
  });

  it("rejects empty string", () => {
    const schema = requiredStringSchema("name");
    const result = schema.safeParse("");
    expect(result.success).toBe(false);
  });
});

describe("passwordSchema", () => {
  it("accepts 6+ character password", () => {
    expect(passwordSchema.safeParse("abc123").success).toBe(true);
  });

  it("rejects short password", () => {
    const result = passwordSchema.safeParse("abc");
    expect(result.success).toBe(false);
  });
});

// ─── Login schema ───────────────────────────────────────────────────────────

describe("loginSchema", () => {
  it("accepts valid login data", () => {
    const result = loginSchema.safeParse({
      email: "user@example.com",
      password: "secret",
    });
    expect(result.success).toBe(true);
  });

  it("rejects missing email", () => {
    const result = loginSchema.safeParse({ email: "", password: "secret" });
    expect(result.success).toBe(false);
  });

  it("rejects missing password", () => {
    const result = loginSchema.safeParse({
      email: "user@example.com",
      password: "",
    });
    expect(result.success).toBe(false);
  });

  it("rejects invalid email format", () => {
    const result = loginSchema.safeParse({
      email: "bad-email",
      password: "secret",
    });
    expect(result.success).toBe(false);
  });
});

// ─── Signup schema ──────────────────────────────────────────────────────────

describe("signupSchema", () => {
  it("accepts valid signup data", () => {
    const result = signupSchema.safeParse({
      email: "user@example.com",
      password: "secret123",
    });
    expect(result.success).toBe(true);
  });

  it("rejects password shorter than 6 chars", () => {
    const result = signupSchema.safeParse({
      email: "user@example.com",
      password: "abc",
    });
    expect(result.success).toBe(false);
  });
});

// ─── Onboarding schema ─────────────────────────────────────────────────────

describe("onboardingSchema", () => {
  it("accepts valid onboarding data", () => {
    const result = onboardingSchema.safeParse({
      country: "PL",
      language: "en",
    });
    expect(result.success).toBe(true);
  });

  it("rejects invalid country", () => {
    const result = onboardingSchema.safeParse({
      country: "US",
      language: "en",
    });
    expect(result.success).toBe(false);
  });

  it("defaults allergens to empty array", () => {
    const result = onboardingSchema.safeParse({
      country: "DE",
      language: "pl",
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.allergens).toEqual([]);
    }
  });
});

// ─── List schema ────────────────────────────────────────────────────────────

describe("listSchema", () => {
  it("accepts valid list", () => {
    const result = listSchema.safeParse({ name: "My List" });
    expect(result.success).toBe(true);
  });

  it("rejects empty name", () => {
    const result = listSchema.safeParse({ name: "" });
    expect(result.success).toBe(false);
  });

  it("rejects name over 100 chars", () => {
    const result = listSchema.safeParse({ name: "a".repeat(101) });
    expect(result.success).toBe(false);
  });

  it("accepts optional description", () => {
    const result = listSchema.safeParse({
      name: "List",
      description: "A description",
    });
    expect(result.success).toBe(true);
  });

  it("rejects description over 500 chars", () => {
    const result = listSchema.safeParse({
      name: "List",
      description: "a".repeat(501),
    });
    expect(result.success).toBe(false);
  });
});

// ─── Health profile schema ──────────────────────────────────────────────────

describe("healthProfileSchema", () => {
  it("accepts valid profile", () => {
    const result = healthProfileSchema.safeParse({
      name: "My Profile",
      conditions: ["diabetes"],
      sugarLimitG: 10,
    });
    expect(result.success).toBe(true);
  });

  it("rejects empty name", () => {
    const result = healthProfileSchema.safeParse({ name: "" });
    expect(result.success).toBe(false);
  });

  it("rejects negative sugar limit", () => {
    const result = healthProfileSchema.safeParse({
      name: "Profile",
      sugarLimitG: -1,
    });
    expect(result.success).toBe(false);
  });

  it("rejects sugar limit over 500", () => {
    const result = healthProfileSchema.safeParse({
      name: "Profile",
      sugarLimitG: 501,
    });
    expect(result.success).toBe(false);
  });
});

// ─── Contact schema ────────────────────────────────────────────────────────

describe("contactSchema", () => {
  it("accepts valid contact form", () => {
    const result = contactSchema.safeParse({
      email: "user@example.com",
      message: "Hello, I have a question about your app.",
    });
    expect(result.success).toBe(true);
  });

  it("rejects message under 10 chars", () => {
    const result = contactSchema.safeParse({
      email: "user@example.com",
      message: "Hi",
    });
    expect(result.success).toBe(false);
  });

  it("rejects message over 2000 chars", () => {
    const result = contactSchema.safeParse({
      email: "user@example.com",
      message: "a".repeat(2001),
    });
    expect(result.success).toBe(false);
  });
});

// ─── Product submission schema ──────────────────────────────────────────────

describe("productSubmissionSchema", () => {
  it("accepts valid 13-digit EAN", () => {
    const result = productSubmissionSchema.safeParse({
      ean: "5901234123457",
      name: "Test Product",
    });
    expect(result.success).toBe(true);
  });

  it("accepts valid 8-digit EAN", () => {
    const result = productSubmissionSchema.safeParse({
      ean: "12345678",
      name: "Test Product",
    });
    expect(result.success).toBe(true);
  });

  it("rejects invalid EAN format", () => {
    const result = productSubmissionSchema.safeParse({
      ean: "123",
      name: "Test Product",
    });
    expect(result.success).toBe(false);
  });

  it("rejects non-numeric EAN", () => {
    const result = productSubmissionSchema.safeParse({
      ean: "abcdefghijklm",
      name: "Test Product",
    });
    expect(result.success).toBe(false);
  });

  it("rejects empty product name", () => {
    const result = productSubmissionSchema.safeParse({
      ean: "5901234123457",
      name: "",
    });
    expect(result.success).toBe(false);
  });
});
