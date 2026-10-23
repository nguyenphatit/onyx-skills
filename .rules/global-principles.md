# Global Engineering Principles for Frontend Coding Agents

This document defines the foundational engineering mindset, architectural boundaries, and operational constraints that every coding agent must strictly respect. These principles supersede model preferences and default generation behaviors.

---

## 1. Grounded Verification (Zero Assumptions)

- **Zero Hallucination on APIs:** Never guess function signatures, configuration keys, or third-party library APIs. Always verify versions and exact interfaces by inspecting `package.json`, local typings, or official documentation.
- **Inspect Before Mutating:** Inspect relevant imports, surrounding modules, and existing directory patterns before creating or modifying files. Never generate blind code assuming an unverified project structure.
- **Type Rigor:** Write strict, explicit TypeScript. Avoid `any`, suppressed type casts (`as unknown as T`), or ignored compiler errors unless explicitly instructed.

---

## 2. Minimal & Incremental Interventions

- **Preserve Existing Conventions:** Respect the repository's established code style, folder organization, and naming conventions. Avoid unsolicited reformatting or out-of-scope refactoring.
- **Atomic Execution:** Break non-trivial tasks into distinct, verifiable steps. Complete each step and ensure it builds cleanly before proceeding to the next.
- **No Dead Artifacts:** Remove unused imports, abandoned draft functions, redundant console statements, and commented-out code before finalizing responses.

---

## 3. Strict Boundary Discipline

- **Server vs. Client Isolation:** In frameworks supporting React Server Components (RSC), keep components on the Server by default. Push `"use client"` directives down to the smallest interactive leaf nodes in the DOM tree.
- **Zero Secret Leakage:** Never import, expose, or serialize private environment variables, secret keys, or internal tokens into bundles or components accessible by the client.
- **Sanitized Presentation:** Prohibit unvalidated raw HTML rendering (e.g., `dangerouslySetInnerHTML`) unless backed by an explicit, trusted sanitization pipeline (e.g., DOMPurify).

---

## 4. Defensive UX & Total State Coverage

- **Mandatory State Coverage:** Any data-driven interface must explicitly implement the complete state spectrum:
  1. **Loading State:** Layout-preserving skeletons or non-blocking indicators.
  2. **Empty State:** Actionable, clear presentation when datasets contain zero items.
  3. **Error State:** Human-readable recovery messages with a retry trigger.
  4. **Success State:** Seamless presentation of the target payload.
- **Safe Traversal:** Guard all dynamic field accesses with optional chaining (`?.`) and nullish coalescing (`??`) to avoid runtime crashes from `undefined` or partial records.
- **Layout Stability:** Always provide explicit dimensional constraints (`aspect-ratio`, reserved heights/widths) for images, videos, and asynchronously injected elements to prevent Cumulative Layout Shift (CLS).

---

## 5. Performance by Default

- **Granular Reactivity:** Do not attach monolithic state trees to presentation components requiring only a slice of data. Leverage granular store selectors to avoid cascading re-renders.
- **Lean Dependency Footprint:** Avoid importing monolithic bundles (e.g., top-level `lodash`) when single utility subpaths or native modern Web APIs suffice.
- **Non-blocking Main Thread:** Heavy transformations, intensive array filtering, and continuous calculations must be appropriately memoized (`useMemo`) or offloaded.

---

## 6. Pre-flight Verification Checklist

Before providing code deliverables, verify each item:

- [ ] Does the solution build cleanly under strict TypeScript check (`tsc --noEmit`)?
- [ ] Are all edge cases (`null`, `undefined`, empty collections, network latency) covered?
- [ ] Are CSS classes aligned with the design token system rather than arbitrary hardcoded values?
- [ ] Is there any client-server context leakage or exposed private configuration?
