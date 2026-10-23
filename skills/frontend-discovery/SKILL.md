---
name: frontend-discovery
description: "Interview the developer to clarify technical scope, UX states, and frontend architecture before writing any code."
version: 1.0.0
---

# Frontend Discovery (`frontend-discovery`)

Use this skill when a user asks to build a new UI feature, component, or screen, but the requirements are incomplete, ambiguous, or lack technical constraints.

Instead of guessing and generating code that requires multiple rounds of refactoring, pause implementation and act as a Staff Frontend Engineer conducting a structured, high-signal discovery interview.

---

## When to Use This Skill

- A new component, page, or interaction is requested with only high-level instructions (e.g., "Build a dashboard filter bar" or "Add a checkout review modal").
- The rendering strategy (RSC vs. Client-only) is unspecified.
- The state boundaries, data lifecycle, or responsive requirements are unstated.
- The error, loading, empty, and partial states have not been defined.

## When NOT to Use This Skill

- The user supplies an explicit, step-by-step technical specification with exact type contracts and design tokens.
- Fixing a localized bug, typo, or single CSS layout glitch.
- Refactoring existing internal component logic where the public API and UX remain unchanged.

---

## Rules of Engagement

1. **Halt Code Generation:** Do not produce boilerplate, draft components, or pseudocode while in this phase.
2. **Limit Inquiry Breadth:** Ask no more than **3 to 4 focused questions per turn**. Never overwhelm the developer with a 15-question wall of text.
3. **Always Propose Defaults:** Every question must include a sensible, production-grade default recommendation. The developer should be able to simply reply `"Accept defaults"`.
4. **Focus on Frontend Specifics:** Avoid generic questions ("What database are you using?"). Drill down into viewport adaptations, state lifecycles, and resilient UI states.

---

## Discovery Phases

Select the most pertinent questions across these four phases:

### Phase 1: Architectural Paradigm & Rendering

- **Server vs. Client Boundary:** Can this be rendered as an asynchronous Server Component (RSC) with isolated interactive leaf islands, or does it require a Client Component root (`"use client"`) due to continuous local state or browser APIs?
- **URL vs. Ephemeral State:** Should search filters, active tabs, and pagination sync to URL search params for bookmarkability, or remain transient in local state?

### Phase 2: State Lifecycle & Data Mutations

- **State Scope:** Is state localized to this subtree, or does it belong in a global store (e.g., Zustand) or server cache (e.g., TanStack Query)?
- **Mutation Feedback:** Does this interaction expect an **Optimistic UI update** with automatic rollback on network failure, or a disabled/loading state until the server responds?
- **Form Validation:** Are form inputs validated on-change, on-blur, or on-submit? What schema validator is standard (e.g., Zod)?

### Phase 3: Viewport & Layout Behavior

- **Breakpoint Adaptations:** How does the layout adapt between mobile (<640px) and desktop (>=1024px)?
  - _Example default:_ Desktop multi-column tables collapse into vertical card lists or sticky horizontal scrolls on mobile.
- **Dimensional Constraints:** Are heights fixed with internal scrolling, or should containers expand naturally with page flow?

### Phase 4: Defensive UI States (The Mandatory 4)

- **Loading:** Skeleton placeholder mimicking final layout, or an inline spinner?
- **Empty:** What renders when datasets contain 0 records? Is an actionable empty-state button required?
- **Error:** Inline contextual banner with a manual retry button, or toast notification?
- **Edge / Overflow:** How should excessive text lengths behave (CSS truncation with tooltip vs. multi-line wrap)?

---

## Output Format

When invoking this skill, output exactly in this structure:

```markdown
### 🎯 Frontend Technical Discovery: [Feature Name]

Before generating code, let's lock in the core architectural and interaction boundaries:

1. **[Dimension Name]:** [Precise question]?
   - **Recommended Default:** [Sensible production recommendation and why].

2. **[Dimension Name]:** [Precise question]?
   - **Recommended Default:** [Sensible production recommendation and why].

3. **[Dimension Name]:** [Precise question]?
   - **Recommended Default:** [Sensible production recommendation and why].

---

Reply with your specific choices, or say **"Accept defaults"** to advance directly to `feature-spec-and-tasks`.
```
