---
name: feature-spec-and-tasks
description: "Transform validated requirements into technical component trees, TypeScript data contracts, state boundaries, and atomic task breakdowns before writing code."
version: 1.0.0
---

# Feature Spec & Task Breakdown (`feature-spec-and-tasks`)

Use this skill once requirements are understood (either via `frontend-discovery` or clear user specifications) and before writing production component code.

Writing code without an explicit technical blueprint leads to scope creep, tangled component props, fragile state locations, and messy pull requests. This skill produces an actionable technical spec and a clean, step-by-step checklist of atomic implementation tasks.

---

## When to Use This Skill

- A new feature, complex widget, or multi-view workflow needs to be built.
- Requirements are clear, but component hierarchy, prop contracts, or state topology are not yet decided.
- Refactoring a legacy monolithic frontend feature into modular, maintainable units.
- Breaking down large epics into small, reviewable, verifiable development milestones.

## When NOT to Use This Skill

- Small, self-contained bug fixes (e.g., misaligned CSS margin or single broken ternary).
- Requirement discovery is incomplete (use `frontend-discovery` first).
- Simple copy changes or mechanical dependency bumps.

---

## Rules of Engagement

1. **Strict Type Contracts First:** Define domain entities and component prop interfaces before assembling layouts.
2. **Explicit State Placement:** Categorize every piece of state into exactly one layer: URL search params, server-cached data, global client store, or local component state.
3. **No Kitchen-Sink Components:** Break views down into isolated container components (fetching & logic) and presentation leaf components (pure styling & props).
4. **Independent, Verifiable Tasks:** Break the execution plan into discrete tasks that take under 30 minutes each. Each task must have a binary completion criterion.

---

## Specification Phases

### Phase 1: Architectural Topology & Component Hierarchy

- **Component Tree:** Map out the tree structure, distinguishing Server Components from Client Components (`"use client"`).
- **Directory Layout:** Specify concrete file paths adhering to project conventions (e.g., feature folders vs. shared UI).

### Phase 2: Data Contracts & Interface Design

- **Entities & DTOs:** Declare TypeScript types/interfaces for raw data models.
- **Component Props:** Declare explicit prop types for every child component; avoid loose generic types like `Record<string, any>` or spreading untyped props.
- **Validation Schemas:** Declare runtime schemas (Zod/Valibot) for form inputs and server mutations.

### Phase 3: State Topology Matrix

- Map every dynamic state variable to its storage layer:
  - **URL State:** Filter tokens, active tabs, sort orders, pagination.
  - **Server Cache:** Data fetching via RSC, Server Actions, or TanStack Query.
  - **Global State:** Cross-route notifications, modal dialog triggers, active user preferences.
  - **Local State:** Open/closed toggles, hover states, raw input field buffers.

### Phase 4: Atomic Execution Breakdown

- Sequence tasks in a dependency-ordered checklist:
  1. Types, Schemas & Mock Fixtures
  2. Sub-components (Dumb / Presentational UI)
  3. State Integration, Actions & Hooks
  4. Container / Page Orchestration & State Boundaries
  5. Fallback States (Loading skeletons, Empty states, Error boundaries)
  6. Accessibility & Keyboard Navigation Verification

---

## Output Format

When invoking this skill, output the specification and task breakdown in this exact structure:

````markdown
# 📋 Technical Specification: [Feature Name]

## 1. Component Hierarchy & File Structure

```text
src/features/[feature-name]/
├── components/
│   ├── [component-a].tsx       # (Presentation leaf)
│   └── [component-b].tsx       # ("use client" interactive island)
├── types/
│   └── index.ts                # TypeScript contracts & schemas
├── hooks/                      # Custom hooks (if needed)
└── index.tsx                   # Main entry / Server container
```

## 2. Data Contracts & Type Definitions

```typescript
import { z } from "zod";

export const FilterSchema = z.object({
  categories: z.array(z.string()).default([]),
  minPrice: z.number().nonnegative().optional(),
  maxPrice: z.number().positive().optional(),
  inStockOnly: z.boolean().default(false),
});

export type FilterCriteria = z.infer<typeof FilterSchema>;

export interface FilterSidebarProps {
  availableCategories: { id: string; label: string; count: number }[];
  priceRange: { min: number; max: number };
  className?: string;
}
```

## 3. State Topology Matrix

Every interactive state variable must have an explicitly declared single source of truth, operational scope, trigger mechanism, and failure fallback strategy:

| State Item         | Source of Truth                    | Scope & Layer        | Mutated By                        | Rollback / Fallback Strategy                |
| :----------------- | :--------------------------------- | :------------------- | :-------------------------------- | :------------------------------------------ |
| `searchQuery`      | URL Search Params (`?q=`)          | Global / Route-level | Debounced router push or replace  | N/A (URL-driven historical navigation)      |
| `activeFilterTags` | URL Search Params (`?tags=a,b`)    | Global / Shareable   | Filter chips toggle handlers      | Revert query parameters on cancellation     |
| `tableData`        | Server RSC / Remote Cache          | Server-managed cache | Server Action revalidation or SWR | Retain stale snapshot while refetching      |
| `selectedRowIds`   | Client Local State (`useState`)    | Component-level      | Row selection checkbox toggles    | Automatically reset on route navigation     |
| `optimisticCount`  | Optimistic Store (`useOptimistic`) | Transient UI layer   | Direct user action dispatch       | Revert to server payload on network failure |
| `isDrawerOpen`     | Client Local / Leaf State          | Ephemeral component  | Trigger button click / Escape key | Closes on unmount or backdrop click         |

---

## 4. Implementation Task Breakdown

All tasks must be organized sequentially according to dependency order. Each atomic task should be executable in under 30 minutes and accompanied by a verifiable acceptance criterion:

- [ ] **Task 1: Data Contracts, Types & Schemas**
  - Initialize the feature directory module adhering to repository structure conventions.
  - Define complete TypeScript interfaces for domain entities, DTOs, and component prop contracts.
  - Author runtime validation schemas (Zod/Valibot) for form inputs and server mutation payloads.
  - _Verification:_ Run `tsc --noEmit` and confirm zero compiler errors or warnings.

- [ ] **Task 2: Presentational Leaf Components**
  - Construct pure presentational components consuming designated design tokens or Tailwind utilities.
  - Supply static mock fixtures to verify responsive layout transitions across mobile and desktop breakpoints.
  - Implement full styling for disabled, active, hover, and `focus-visible` states.
  - _Verification:_ Inspect isolated components across viewports without active backend dependencies.

- [ ] **Task 3: State Management & Interaction Hooks**
  - Build custom hooks or granular store selectors (Zustand or URL state managers).
  - Implement two-way synchronization logic between UI interactions and URL search parameters.
  - Wire mutation handlers with optimistic UI updates and automated rollback safeguards.
  - _Verification:_ Interactions trigger immediate UI feedback, and refreshing the browser preserves deep-linked URL states.

- [ ] **Task 4: Container Orchestration & Boundary Placement**
  - Connect real data pipelines (async Server Components, route handlers, or server actions) into the parent container.
  - Place `"use client"` directives strictly at interactive leaf boundaries to preserve server rendering.
  - Enclose asynchronous data waterfalls inside dedicated `<Suspense>` boundaries.
  - _Verification:_ Data cascades correctly through props to presentation layers without client-server context leakage.

- [ ] **Task 5: Resilience & Edge States**
  - Implement layout-matched skeleton loaders that eliminate Cumulative Layout Shift (CLS).
  - Create dedicated empty-state containers featuring actionable recovery triggers (e.g., CTA buttons).
  - Wrap unstable trees in Error Boundaries featuring an inline retry mechanism.
  - _Verification:_ Simulate network throttling (Slow 3G) and synthetic HTTP 500 responses to confirm fallback stability.

- [ ] **Task 6: Accessibility (a11y) & Pre-flight Verification**
  - Validate keyboard navigation flows (`Tab`, `Shift+Tab`, `Enter`, `Escape`, and modal focus trapping).
  - Verify semantic element usage (`main`, `nav`, `button`) along with appropriate `aria-expanded` and `aria-label` attributes.
  - _Verification:_ Execute a production build (`npm run build`) and verify zero console errors or hydration warnings.
````
