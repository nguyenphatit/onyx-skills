---
name: frontend-testing
description: "Construct resilient frontend test suites spanning unit contracts, user-centric component interactions, mock service worker boundaries, and browser DevTools verification."
version: 1.0.0
---

# Frontend Testing (`frontend-testing`)

Use this skill when authoring unit tests, component integration tests, Mock Service Worker (MSW) network fixtures, or end-to-end browser specifications (Playwright, Cypress).

Frontend test suites fail when they test implementation details (internal state, CSS class names, private component props). This results in brittle suites that break during harmless refactors while failing to catch real bugs. This skill enforces user-centric testing, accessibility-driven queries, network boundary isolation, and complete coverage of defensive UI states.

---

## When to Use This Skill

- Authoring unit tests for business utilities, data transformations, and runtime validation schemas (Zod).
- Writing component integration tests verifying interactive user flows (React Testing Library + `user-event`).
- Intercepting and simulating network responses, latency, and server errors using Mock Service Worker (MSW).
- Verifying the mandatory 4 UI states: Loading skeleton, Empty state, Error with retry, and Success payload.
- Creating end-to-end browser tests for critical user journeys and URL parameter persistence.

## When NOT to Use This Skill

- Writing initial presentation components or styling tokens (use `frontend-ui-components`).
- Diagnosing live hydration crashes or profiling runtime memory leaks (use `ui-debugging-and-performance`).
- Performing holistic pull request architectural audits (use `code-review-and-standards`).

---

## Rules of Engagement

1. **Test User Behavior, Not Implementation Details:** Never assert against internal component state (`wrapper.state()`) or private hook properties. Test what the user observes in the rendered DOM and how the UI reacts to inputs.
2. **Query by Accessible Roles (The Priority Hierarchy):** Queries must reflect how assistive technologies and users perceive the interface:
   - 1st: `getByRole` (e.g., `getByRole("button", { name: /submit/i })`)
   - 2nd: `getByLabelText`, `getByPlaceholderText`, `getByText`
   - 3rd: `getByTestId` (only when semantic elements cannot be unambiguously selected)
   - ❌ **Prohibited:** `container.querySelector(".btn-primary")` or querying by CSS tags.
3. **Mock at the Network Layer (MSW):** Do not mock `fetch`, `axios`, or internal React hooks directly. Mock at the HTTP transport boundary with Mock Service Worker handlers to test data parsers, caching, and state transitions intact.
4. **Use `@testing-library/user-event` Exclusively:** Avoid `fireEvent`. `userEvent` accurately dispatches trusted browser events (hover, focus, keydown, keypress, keyup, change, blur) required to test complex forms and accessibility traps.
5. **Mandatory 4-State Coverage:** Every data-fetching interface must have explicit test cases verifying:
   - **Loading:** Skeleton/spinner renders on mount.
   - **Success:** Entity data populates accurately.
   - **Error:** Human-readable error message displays, and triggering the retry button initiates a refetch.
   - **Empty:** Clear message and call-to-action render when receiving empty arrays.
6. **No Arbitrary Sleep Timers:** Strictly forbid `await new Promise(r => setTimeout(r, 1000))`. Use reactive asynchronous utilities like `waitFor` or `findByRole`.

---

## The Frontend Testing Pyramid

### 1. Unit Tests (Vitest / Jest)
- **Focus:** Pure functions, state reducer logic, schema validations, math/date formatting.
- **Speed:** Instant (<5ms per test).
- **Goal:** Exhaustive edge case coverage (null, undefined, invalid formats, boundary numbers).

### 2. Component Integration Tests (Testing Library + MSW)
- **Focus:** Component subtrees, form submissions, optimistic UI feedback, keyboard navigation.
- **Speed:** Fast (<200ms per suite).
- **Goal:** Verify that components, hooks, and network client cooperate to handle user interactions correctly.

### 3. End-to-End & Browser DevTools Tests (Playwright / Chrome DevTools)
- **Focus:** Multi-page workflows, deep-linking URL synchronization, responsive layout checks.
- **Speed:** Moderate (<5s per test).
- **Goal:** Validate browser runtime execution, real cookies, and navigation boundaries.

---

## Anti-Patterns (Strictly Avoid)

- ❌ **Do NOT test component CSS classes:**
  ```typescript
  // BAD: Brittle test coupled to Tailwind implementation
  expect(button.classList.contains("bg-blue-600")).toBe(true);
  ```
- ❌ **Do NOT mock internal hook modules:**
  ```typescript
  // BAD: Bypasses hook caching logic and real integration
  vi.mock("./useTasks", () => ({ useTasks: () => ({ data: [...] }) }));
  ```
- ❌ **Do NOT maintain blind snapshot tests:**
  ```typescript
  // BAD: Developers blindly run `u` to update 2000-line snapshots without reviewing
  expect(container).toMatchSnapshot();
  ```
- ❌ **Do NOT query unassociated elements:**
  ```typescript
  // BAD: Fails if copy is tweaked
  screen.getByText("Click here");
  // GOOD: Resilient role-based query
  screen.getByRole("button", { name: /save changes/i });
  ```

---

## Output Format

When generating frontend test suites, structure the output as follows:

````markdown
### 🧪 Frontend Test Suite: [Component / Flow Name]

#### 1. MSW Network Handlers (`tests/mocks/handlers/[feature].ts`)
```typescript
import { http, HttpResponse } from "msw";

export const handlers = [
  // HTTP route handlers for success, error, and empty states
];
```

#### 2. Component Integration Test (`tests/components/[Component].test.tsx`)
```typescript
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect } from "vitest";

// Test suite testing user actions, accessibility, and defensive states
```

#### 3. Test Coverage Summary
- **Tested User Flows:** [List of covered interactions]
- **Defensive States Tested:** [Loading, Error, Empty, Success]
- **Accessibility Assertions:** [Accessible roles, keyboard navigation]
````

---

## Example Implementation

### User Request
> "Write a robust component test suite for a TaskList feature with MSW handlers, testing loading, error retry, empty states, and task completion."

### Agent Deliverable

````markdown
### 🧪 Frontend Test Suite: TaskList Component

#### 1. Network Mock Handlers (`src/features/tasks/tests/handlers.ts`)

```typescript
import { http, HttpResponse, delay } from "msw";
import { Task } from "../types";

export const mockTasks: Task[] = [
  { id: "1", title: "Review PR #42", status: "TODO", updatedAt: new Date().toISOString() },
  { id: "2", title: "Update Tailwind tokens", status: "DONE", updatedAt: new Date().toISOString() },
];

export const handlers = [
  http.get("/api/tasks", async ({ request }) => {
    const url = new URL(request.url);
    if (url.searchParams.get("simulateError") === "true") {
      return new HttpResponse(null, { status: 500, statusText: "Internal Server Error" });
    }
    if (url.searchParams.get("simulateEmpty") === "true") {
      return HttpResponse.json([]);
    }
    await delay(50);
    return HttpResponse.json(mockTasks);
  }),

  http.patch("/api/tasks/:id/status", async ({ params, request }) => {
    const body = (await request.json()) as { status: string };
    return HttpResponse.json({ id: params.id, status: body.status, updatedAt: new Date().toISOString() });
  }),
];
```

#### 2. Integration Test Suite (`src/features/tasks/tests/TaskList.test.tsx`)

```typescript
import * as React from "react";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, beforeEach } from "vitest";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { server } from "@/tests/setup/msw-server";
import { http, HttpResponse } from "msw";
import { TaskList } from "../components/TaskList";

function renderWithProviders(ui: React.ReactElement) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
    },
  });
  return {
    user: userEvent.setup(),
    ...render(<QueryClientProvider client={queryClient}>{ui}</QueryClientProvider>),
  };
}

describe("<TaskList />", () => {
  it("renders loading skeletons initially", () => {
    renderWithProviders(<TaskList />);
    expect(screen.getByRole("status", { name: /loading tasks/i })).toBeInTheDocument();
  });

  it("renders task items upon successful data fetch", async () => {
    renderWithProviders(<TaskList />);

    expect(await screen.findByRole("heading", { name: "Review PR #42" })).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: "Update Tailwind tokens" })).toBeInTheDocument();
  });

  it("renders actionable empty state when no tasks exist", async () => {
    server.use(
      http.get("/api/tasks", () => HttpResponse.json([]))
    );

    renderWithProviders(<TaskList />);

    expect(await screen.findByRole("status", { name: /no tasks found/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /create your first task/i })).toBeInTheDocument();
  });

  it("renders contextual error banner and retries successfully on user click", async () => {
    let requestCount = 0;
    server.use(
      http.get("/api/tasks", () => {
        requestCount++;
        if (requestCount === 1) {
          return new HttpResponse(null, { status: 500 });
        }
        return HttpResponse.json([
          { id: "1", title: "Recovered Task", status: "TODO", updatedAt: new Date().toISOString() },
        ]);
      })
    );

    const { user } = renderWithProviders(<TaskList />);

    // 1. Verify Error State
    const retryButton = await screen.findByRole("button", { name: /retry/i });
    expect(screen.getByRole("alert")).toHaveTextContent(/failed to fetch tasks/i);

    // 2. Click Retry Trigger
    await user.click(retryButton);

    // 3. Verify Recovery to Success State
    expect(await screen.findByRole("heading", { name: "Recovered Task" })).toBeInTheDocument();
    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
  });

  it("handles keyboard interaction to toggle task completion status", async () => {
    const { user } = renderWithProviders(<TaskList />);

    const checkbox = await screen.findByRole("checkbox", { name: /mark "Review PR #42" complete/i });
    expect(checkbox).not.toBeChecked();

    // Focus and toggle via keyboard Space
    checkbox.focus();
    expect(checkbox).toHaveFocus();
    await user.keyboard(" ");

    await waitFor(() => {
      expect(checkbox).toBeChecked();
    });
  });
});
```
````

---

## Verification & Delivery Checklist

- [ ] Tests select elements using accessible roles (`getByRole`) and user-facing text, not CSS classes or internal tags.
- [ ] User interactions are dispatched via `@testing-library/user-event` rather than `fireEvent`.
- [ ] Mock Service Worker (MSW) intercepts network traffic at the HTTP layer with zero mocking of React hooks.
- [ ] All 4 defensive states (Loading, Empty, Error with retry, Success) have dedicated test assertions.
- [ ] No arbitrary `setTimeout` or sleep loops exist in test code; all async states use `waitFor` or `findBy*`.
- [ ] Test suite executes and passes cleanly under `vitest run`.
