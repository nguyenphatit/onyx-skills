---
name: code-review-and-standards
description: "Conduct comprehensive multi-axis frontend code reviews auditing correctness, architectural boundaries, accessibility compliance (WCAG AA), Core Web Vitals, and XSS/secret security."
version: 1.0.0
---

# Code Review & Standards (`code-review-and-standards`)

Use this skill when evaluating pull requests, git diffs, new component implementations, or refactors prior to merging into production branches.

A rubber-stamp code review that only checks for formatting or syntax misses critical frontend vulnerabilities: missing error and empty states, layout shifts, keyboard navigation traps, server-client context leaks, and XSS risks. This skill establishes an objective, five-axis review system that elevates engineering rigor while maintaining rapid shipping velocity.

---

## When to Use This Skill

- Conducting pre-merge audits on pull requests or diffs authored by teammates or AI agents.
- Evaluating a newly authored feature against production standards before closing an issue.
- Assessing frontend security boundaries: secret leakage, raw HTML rendering, and input sanitization.
- Verifying WCAG 2.1 AA compliance, keyboard navigation traps, and visible focus rings.
- Checking for performance regressions, memory leaks, and Core Web Vitals hazards.

## When NOT to Use This Skill

- Generating new visual UI components from design specifications (use `frontend-ui-components`).
- Formulating initial feature specs or data contracts (use `feature-spec-and-tasks`).
- Deep-diving into live hydration failures or profiling flame charts (use `ui-debugging-and-performance`).

---

## Rules of Engagement

1. **The Approval Standard (Health Over Perfection):** Approve a change when it undeniably improves overall code health, satisfies acceptance criteria, and introduces no regressions. Do not block a PR simply because it differs from your personal stylistic preference.
2. **Explicit Severity Tiers:** Tag all review comments with unambiguous severity levels:
   - 🛑 **Blocker (Must Fix):** Security flaws, correctness bugs, broken keyboard access, hydration errors, or missing error/loading states.
   - ⚠️ **Major (Should Fix):** Architectural drift, duplicate state layers, missing query cancellations, or re-render risks.
   - 💡 **Nit / Suggestion (Optional):** Minor naming tweaks, optional micro-optimizations, or non-blocking stylistic suggestions.
3. **Always Supply Concrete Diffs:** Never leave vague feedback (e.g., "Refactor this logic"). Provide the exact rationale accompanied by an explicit before/after diff showing the fix.
4. **Enforce Boundary Discipline:** Keep Server Components on the server; ensure `"use client"` is pushed to the leaf nodes. Confirm that private environment variables or secrets never leak into client bundles.

---

## The 5-Axis Frontend Review Matrix

Every pull request is systematically audited across these five dimensions:

### Axis 1: Correctness & Defensive States
- Are all four mandatory states handled (Loading skeleton, Empty state, Contextual error with retry, Success payload)?
- Are optional chains (`?.`) and nullish coalescing operators (`??`) safeguarding dynamic fields?
- Are off-by-one errors, date timezone discrepancies, or boundary values properly guarded?

### Axis 2: Architecture & State Boundaries
- Is there a single source of truth for each piece of state? (Server Cache vs. URL Search Params vs. Local)?
- Are React Server Components (RSC) kept on the server by default?
- Is `"use client"` confined to interactive leaf components?
- Are optimistic updates paired with snapshot rollback and settlement revalidation?

### Axis 3: Accessibility & Usability (WCAG 2.1 AA)
- Are native semantic elements (`<button>`, `<dialog>`, `<nav>`, `<main>`) used instead of clickable `<div>`s?
- Is every interactive element accessible via keyboard (`Tab`, `Enter`, `Space`, `Escape`)?
- Do all interactive elements display a clear `:focus-visible` indicator?
- Do icon-only buttons supply an accessible `aria-label`?
- Are mobile touch targets at least 44x44px?

### Axis 4: Performance & Core Web Vitals
- **CLS:** Do dynamic elements, skeletons, and images declare explicit dimensions (`aspect-ratio`, fixed min-heights)?
- **INP:** Are intensive computational tasks (>50ms) deferred with `startTransition` or debounced?
- **Teardowns:** Do all `useEffect` hooks tear down timers, event listeners, and subscriptions cleanly?
- **Reactivity:** Are store selectors sliced granularly to prevent cascading re-renders?

### Axis 5: Security & Data Hygiene
- **XSS:** Is unescaped HTML injection (`dangerouslySetInnerHTML`) strictly prohibited or sanitized with a verified parser (e.g., DOMPurify)?
- **Secret Leaks:** Are private API keys, backend tokens, or un-prefixed environment variables absent from client components?
- **Form Sanitization:** Are user inputs validated against schemas before sending to server actions or endpoints?

---

## Review Output Format

When conducting a code review, deliver findings structured as follows:

````markdown
# 🔍 Frontend Code Review: [PR Title / Feature]

## 1. Review Summary & Verdict
- **Verdict:** [✅ Approve | ⚠️ Approve with Suggestions | 🛑 Request Changes]
- **High-Level Assessment:** [2-3 sentence overview of the change, highlighting strengths and primary concerns]

## 2. Five-Axis Audit Matrix

| Axis | Status | Key Findings |
| :--- | :---: | :--- |
| **1. Correctness & Defensive States** | 🟢 / 🟡 / 🔴 | [Summary] |
| **2. Architecture & State Discipline** | 🟢 / 🟡 / 🔴 | [Summary] |
| **3. Accessibility (WCAG 2.1 AA)**   | 🟢 / 🟡 / 🔴 | [Summary] |
| **4. Performance & Core Web Vitals** | 🟢 / 🟡 / 🔴 | [Summary] |
| **5. Security & Secret Hygiene**       | 🟢 / 🟡 / 🔴 | [Summary] |

## 3. Detailed Findings & Actionable Diffs

### 🛑 [Blocker] Finding Title
- **Location:** `src/path/to/file.tsx:L42`
- **Issue:** [Description of problem]
- **Recommended Fix:**
```diff
- old buggy code
+ new resilient code
```

### ⚠️ [Major] Finding Title
- **Location:** `src/path/to/file.tsx:L88`
- **Issue:** [Description of problem]
- **Recommended Fix:**
```diff
- suboptimal pattern
+ recommended pattern
```

### 💡 [Nit] Finding Title
- **Location:** `src/path/to/file.tsx:L12`
- **Recommendation:** [Optional suggestion]

## 4. Verification Checklist Before Merge
- [ ] TypeScript compiles cleanly with zero warnings (`tsc --noEmit`).
- [ ] Unit & integration test suites pass (`vitest run`).
- [ ] Production build succeeds without hydration warnings (`npm run build`).
````

---

## Example Review Run

### Scenario
An engineer submits a PR adding a user subscription billing toggle card.

### Agent Review Output

````markdown
# 🔍 Frontend Code Review: Subscription Billing Toggle Card

## 1. Review Summary & Verdict
- **Verdict:** 🛑 **Request Changes**
- **High-Level Assessment:** The visual presentation and Tailwind token usage are well executed. However, the PR contains two critical blockers: a clickable `<div>` without keyboard navigation or ARIA semantics, and missing rollback handling on the optimistic plan update mutation.

## 2. Five-Axis Audit Matrix

| Axis | Status | Key Findings |
| :--- | :---: | :--- |
| **1. Correctness & Defensive States** | 🔴 Needs Fix | Optimistic mutation lacks rollback; network failure leaves corrupt UI state. |
| **2. Architecture & State Discipline** | 🟡 Acceptable | Props and types well defined; Server Action boundary clean. |
| **3. Accessibility (WCAG 2.1 AA)**   | 🔴 Needs Fix | Clickable `<div>` used instead of `<button>`; no keyboard focus or screen-reader cues. |
| **4. Performance & Core Web Vitals** | 🟢 Passed   | No layout shift detected; layout dimensions reserved. |
| **5. Security & Secret Hygiene**       | 🟢 Passed   | No private keys leaked; input payload typed with Zod. |

## 3. Detailed Findings & Actionable Diffs

### 🛑 [Blocker 1] Inaccessible Clickable `<div>` Used for Interactive Toggle
- **Location:** `src/features/billing/components/PlanCard.tsx:L34`
- **Issue:** The card uses an `onClick` on a `<div>` without a `button` element, `role="button"`, `tabIndex={0}`, or keyboard listener. Keyboard-only and screen reader users cannot activate the toggle.
- **Recommended Fix:**
```diff
- <div
-   className="rounded-lg border p-4 cursor-pointer hover:border-primary"
-   onClick={handleSelectPlan}
- >
-   <p className="font-semibold">{plan.name}</p>
- </div>
+ <button
+   type="button"
+   className="w-full text-left rounded-lg border p-4 transition-colors hover:border-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
+   onClick={handleSelectPlan}
+   aria-pressed={isSelected}
+ >
+   <p className="font-semibold">{plan.name}</p>
+ </button>
```

### 🛑 [Blocker 2] Optimistic Mutation Lacks Rollback Snapshot
- **Location:** `src/features/billing/hooks/useUpdatePlan.ts:L18`
- **Issue:** `onMutate` updates the cache directly without capturing `previousData`. If the network fails, the user is shown an active subscription status that was rejected by the server.
- **Recommended Fix:**
```diff
  onMutate: async (newPlan) => {
    await queryClient.cancelQueries({ queryKey: ['billing'] });
+   const previousBilling = queryClient.getQueryData(['billing']);
    queryClient.setQueryData(['billing'], (old) => ({ ...old, plan: newPlan }));
+   return { previousBilling };
  },
+ onError: (err, newPlan, context) => {
+   if (context?.previousBilling) {
+     queryClient.setQueryData(['billing'], context.previousBilling);
+   }
+ },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['billing'] });
  }
```

### 💡 [Nit] Explicit Number Formatting
- **Location:** `src/features/billing/components/PlanCard.tsx:L50`
- **Recommendation:** Use `Intl.NumberFormat` for currency rendering rather than template string interpolation (`$${plan.price}`).

## 4. Verification Checklist Before Merge
- [ ] Replace clickable `<div>` with accessible `<button type="button">`.
- [ ] Add `onError` rollback to `useUpdatePlan` mutation.
- [ ] Verify test suite passes with `vitest run`.
````

---

## Verification & Delivery Checklist

- [ ] Every finding is tagged with an explicit severity tier (`Blocker`, `Major`, `Nit`).
- [ ] All blockers provide actionable rationale accompanied by explicit before/after diffs.
- [ ] Accessibility audit verifies semantic elements, focus indicators, and keyboard traversability.
- [ ] Architecture audit verifies single source of truth and client-server boundaries.
- [ ] Security audit checks for raw unescaped HTML, client secret leakage, and input sanitization.
