---
name: ui-debugging-and-performance
description: "Diagnose frontend bugs, resolve SSR/RSC hydration mismatches, fix race conditions, eliminate re-render storms, and optimize Core Web Vitals (LCP, INP, CLS)."
version: 1.0.0
---

# UI Debugging & Performance (`ui-debugging-and-performance`)

Use this skill when investigating runtime errors, resolving Server-Side Rendering (SSR) hydration mismatches, debugging asynchronous race conditions, eliminating cascading re-renders, or optimizing Core Web Vitals (LCP, INP, CLS).

Frontend defects frequently stem from hidden timing hazards: state updates arriving out of order, heavy JavaScript tasks monopolizing the main thread, unconstrained containers causing visual layout shifts, and client-server rendering divergences. Guessing solutions and blindly adding `useCallback` or `suppressHydrationWarning` masks architectural debt and degrades user experience. This skill provides a scientific, metric-first methodology for diagnosing root causes and engineering permanent fixes.

---

## When to Use This Skill

- Resolving React/Next.js hydration mismatch warnings (`"Text content did not match server-rendered HTML"`).
- Diagnosing slow, unresponsive interactions or high Interaction to Next Paint (INP > 200ms).
- Eliminating Cumulative Layout Shift (CLS > 0.1) caused by dynamic elements, web fonts, or unsized images.
- Fixing asynchronous race conditions, stale closures, or state mutations on unmounted components.
- Profiling and resolving component re-render storms using React DevTools or Chrome DevTools Performance panel.
- Accelerating Largest Contentful Paint (LCP < 2.5s) and trimming JavaScript bundle sizes.

## When NOT to Use This Skill

- Constructing initial visual UI elements from design tokens (use `frontend-ui-components`).
- Drafting feature specs or architectural task breakdowns (use `feature-spec-and-tasks`).
- Creating integration test suites for existing, functioning components (use `frontend-testing`).

---

## Rules of Engagement

1. **The Stop-the-Line Rule:** When a bug or hydration error appears during development, halt new feature implementation immediately. Errors compound; fixing defects later costs 10x more time.
2. **Measure First, Optimize Second:** Never apply performance optimizations based on intuition. Gather objective profiling data (React Profiler render counts, Chrome Performance flame graphs, Web Vitals metrics) before and after changes.
3. **No Blanket Suppression:** Strictly prohibit using `suppressHydrationWarning` to silence errors unless rendering explicitly non-deterministic client-only data (e.g., relative timestamps, random seeds, or `window.localStorage`).
4. **Strict Effect Cleanup:** Every subscription, DOM listener, timer (`setInterval`/`setTimeout`), and network request inside `useEffect` must return a teardown callback or `AbortController.abort()`.
5. **Main Thread Protection (INP Budget < 50ms):** No synchronous handler should block the main thread for over 50 milliseconds. Yield control using `startTransition`, `requestAnimationFrame`, or `scheduler.yield()`.
6. **Reserve Layout Geometry (CLS Budget < 0.1):** All dynamic elements, images, embeds, and asynchronous banners must have predetermined aspect ratios or minimum dimensional envelopes to prevent layout shifts.

---

## Systematic Triage Workflow

```text
Bug / Performance Regression Detected
   │
   ├── 1. REPRODUCE ───────→ Isolate minimal reproduction path & verify reliability
   │
   ├── 2. CATEGORIZE ──────→ Hydration mismatch? Race condition? INP lag? CLS shift?
   │
   ├── 3. PROFILE ─────────→ Inspect flame chart, DOM mutations, or console diff
   │
   ├── 4. ROOT CAUSE FIX ──→ Address structural cause (not cosmetic suppression)
   │
   └── 5. VERIFY & GUARD ──→ Confirm metric recovery & add regression test
```

---

## Targeted Diagnostic Playbooks

### 1. Hydration Mismatches (SSR vs. CSR)
- **Common Causes:**
  - Browser-only APIs (`window`, `localStorage`, `navigator`) referenced during render.
  - Non-deterministic values (`Date.now()`, `Math.random()`, timezone-dependent dates).
  - Invalid HTML nesting (e.g., `<p>` containing `<div>`, `<tr>` outside `<tbody>`).
- **Resolution Strategy:**
  - Push client-only values into `useEffect` (post-mount render) or use an explicit `useSyncExternalStore` with separate server and client snapshots.
  - Correct semantic HTML parent-child relationships.

### 2. Re-render Storms & Reactivity Leaks
- **Common Causes:**
  - Creating new object/array literals or inline arrow functions inside components passed to memoized children.
  - Subscribing to monolithic global state stores without selector slicing (e.g., `useStore()` instead of `useStore(s => s.item)`).
  - Mirroring derived values in `useState` and syncing with `useEffect`.
- **Resolution Strategy:**
  - Compute derived values on the fly during render (no `useState` + `useEffect`).
  - Use granular store selectors so components re-render only when their specific slice changes.

### 3. Asynchronous Race Conditions
- **Common Causes:**
  - Fast typing in search inputs causing slow request A to resolve *after* fast request B, overwriting fresh data with stale results.
- **Resolution Strategy:**
  - Always wire `AbortController` into fetch calls within effects or TanStack Query functions.
  - Maintain a sequence/request counter or use query cancellation.

### 4. Core Web Vitals Optimization

| Metric | Target | Root Cause | Solution |
| :--- | :--- | :--- | :--- |
| **LCP** (Largest Contentful Paint) | `< 2.5s` | Heavy hero images, render-blocking CSS/fonts, client waterfall | Use `priority` / `fetchpriority="high"`, preload hero fonts, server-render critical markup |
| **INP** (Interaction to Next Paint) | `< 200ms` | Long JavaScript execution tasks (>50ms) on click/input | Break up long tasks with `startTransition`, debounce search inputs, offload heavy sorting |
| **CLS** (Cumulative Layout Shift) | `< 0.1` | Images without dimensions, dynamic ad/banner insertion, late font swaps | Apply `aspect-ratio` or `min-h-[X]`, reserve skeleton space, set `font-display: swap` with `size-adjust` |

---

## Anti-Patterns (Strictly Avoid)

- ❌ **Do NOT wrap every function in `useCallback` blindly:** If the child component is not wrapped in `React.memo`, wrapping handlers in `useCallback` adds overhead without preventing re-renders.
- ❌ **Do NOT sync props to state via `useEffect`:**
  ```typescript
  // BAD: Redundant render cycle and state desynchronization
  const [value, setValue] = useState(props.value);
  useEffect(() => setValue(props.value), [props.value]);
  // GOOD: Compute directly or use key-based reset
  const displayValue = props.value;
  ```
- ❌ **Do NOT perform heavy synchronous operations during render:**
  ```typescript
  // BAD: Blocks UI frame rendering on every state change
  const sorted = massiveArray.sort(...);
  // GOOD: Memoize with dependencies or offload
  const sorted = useMemo(() => [...massiveArray].sort(...), [massiveArray]);
  ```

---

## Output Format

When delivering debugging analyses and performance refactors, format the response as follows:

````markdown
### 🛠️ Root Cause Diagnosis & Performance Remediation

#### 1. Problem Classification & Evidence
- **Defect Category:** [Hydration Mismatch / Re-render Storm / Race Condition / INP / CLS]
- **Observed Behavior:** [Detailed description of the issue]
- **Root Cause Analysis:** [Why the bug occurs at the architectural/engine level]

#### 2. Profiling & Baseline Metrics
- **Before Metric:** [e.g., INP: 340ms | Hydration Error logged | 14 redundant renders]
- **Target Threshold:** [e.g., INP: <150ms | Zero console warnings | 1 render]

#### 3. Remediated Implementation
```tsx
// File: path/to/file.tsx
// Refactored, stabilized code with inline explanations of fixes
```

#### 4. Post-Remediation Verification
- **After Metric:** [Measured improvement]
- **Prevention Guard:** [Regression test or structural safeguard preventing reintroduction]
````

---

## Example Case Walkthrough

### Scenario
A dashboard search component throws a React hydration mismatch on user timestamps, suffers severe input lag (INP = 280ms), and experiences race conditions where old search results overwrite new ones.

### Agent Deliverable

````markdown
### 🛠️ Root Cause Diagnosis & Performance Remediation: Dashboard Search

#### 1. Problem Classification & Evidence
- **Defect Category:** Hydration Mismatch, Asynchronous Race Condition, and INP Lag.
- **Root Causes:**
  1. `new Date().toLocaleTimeString()` was evaluated directly in render, causing server HTML (UTC) to diverge from client browser timezone.
  2. In-flight search requests lacked `AbortController`, allowing slow earlier queries to overwrite newer results.
  3. Filtering 10,000 table rows ran synchronously on every keystroke in the same render task, blocking the main thread for 180ms.

#### 2. Profiling Metrics
- **Hydration:** React error #418 logged on initial page load.
- **INP:** 280ms (Poor rating).
- **Network:** Stale requests resolving out-of-order.

#### 3. Remediated Implementation (`src/features/search/SearchPanel.tsx`)

```tsx
"use client";

import * as React from "react";
import { useQuery } from "@tanstack/react-query";

interface SearchPanelProps {
  initialSearchQuery?: string;
}

export function SearchPanel({ initialSearchQuery = "" }: SearchPanelProps) {
  const [searchTerm, setSearchTerm] = React.useState(initialSearchQuery);
  const [isPending, startTransition] = React.useTransition();
  const [formattedTime, setFormattedTime] = React.useState<string | null>(null);

  // FIX 1: Prevent hydration mismatch by setting client-specific time post-mount
  React.useEffect(() => {
    setFormattedTime(new Date().toLocaleTimeString());
  }, []);

  // FIX 2: Race condition immunity via AbortSignal passed to fetcher
  const { data: results = [], isFetching } = useQuery({
    queryKey: ["search", searchTerm],
    queryFn: async ({ signal }) => {
      if (!searchTerm) return [];
      const res = await fetch(`/api/items?q=${encodeURIComponent(searchTerm)}`, { signal });
      if (!res.ok) throw new Error("Search failed");
      return res.json();
    },
    enabled: searchTerm.length > 1,
    staleTime: 60 * 1000,
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const nextVal = e.target.value;
    // FIX 3: Preserve responsive typing (INP) by deferring search state update
    startTransition(() => {
      setSearchTerm(nextVal);
    });
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <label htmlFor="search-input" className="text-sm font-medium">
          Search Directory
        </label>
        {/* Render placeholder on server to eliminate hydration mismatch */}
        <span className="text-xs text-muted-foreground" aria-live="polite">
          {formattedTime ? `Refreshed at ${formattedTime}` : "Syncing..."}
        </span>
      </div>

      <div className="relative">
        <input
          id="search-input"
          type="search"
          onChange={handleInputChange}
          placeholder="Filter records..."
          className="w-full rounded-md border border-input px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        />
        {(isPending || isFetching) && (
          <span className="absolute right-3 top-2.5 text-xs text-muted-foreground animate-pulse">
            Searching...
          </span>
        )}
      </div>

      {/* Defensive aspect-ratio container preventing CLS during list injection */}
      <div className="min-h-[200px]">
        {results.length === 0 && searchTerm.length > 1 && !isFetching && (
          <p className="py-8 text-center text-sm text-muted-foreground">No matches found.</p>
        )}
        <ul className="divide-y divide-border">
          {results.map((item: { id: string; name: string }) => (
            <li key={item.id} className="py-2 text-sm">
              {item.name}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
```

#### 4. Post-Remediation Verification
- **Hydration:** Clean load with 0 console warnings or mismatches.
- **INP:** Reduced from 280ms to 24ms (instant input feedback via `startTransition`).
- **Network:** Fast typing cancels stale HTTP requests automatically; latest query always prevails.
````

---

## Verification & Delivery Checklist

- [ ] All SSR/CSR non-deterministic values (dates, storage, window) are isolated from initial hydration.
- [ ] No unconditional `suppressHydrationWarning` flags are present.
- [ ] Long tasks (>50ms) are chunked or deferred using `startTransition` or `requestAnimationFrame`.
- [ ] Asynchronous fetch operations forward `AbortSignal` to eliminate race conditions.
- [ ] Containers for dynamic or asynchronously loaded elements maintain explicit dimensional reservations to prevent CLS.
- [ ] Cleanups are returned for all effects with timers, subscriptions, or event listeners.
