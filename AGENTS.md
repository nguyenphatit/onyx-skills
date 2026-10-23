# AGENTS.md

This file provides universal guidance and operational instructions to AI coding agents (Antigravity, Cursor, Windsurf, Claude Code, GitHub Copilot) operating within this repository.

> **Scope:** This configuration governs coding agents authoring, maintaining, or consuming skills within [`onyx-skills`](file:///f:/Learn/onyx-skills). Reusable assets for consumer projects are located in [`skills/`](file:///f:/Learn/onyx-skills/skills) and [`.rules/`](file:///f:/Learn/onyx-skills/.rules).

---

## Skill-Driven Execution Model

This repository operates on a **skill-first execution model**. Agents must never write generic or improvised code when a domain skill applies.

### Core Rules for Agents:
1. **Identify the Skill First:** Before generating code, specs, or reviews, evaluate the user's intent against the [Skill Routing Matrix](#intent--skill-routing-matrix).
2. **Consult the Skill Specification:** If a skill applies, you MUST read and follow its corresponding `SKILL.md` instructions completely.
3. **Never Skip Lifecycle Phases:** Follow the phased approach defined inside each skill (e.g., Discovery → Spec → Components → API & State → Tests → Triage → Review).

---

## Intent → Skill Routing Matrix

Map incoming developer requests directly to the dedicated skill:

```text
Incoming Request
   │
   ├── Ambiguous brief, missing constraints, or UX questions? ──→ frontend-discovery
   │
   ├── Complex feature planning, component tree, or task breakdown? ─→ feature-spec-and-tasks
   │
   ├── Constructing UI widgets, layouts, styling, design tokens? ──→ frontend-ui-components
   │
   ├── Integrating APIs, Server Actions, TanStack Query, URL sync? ──→ api-contracts-and-state
   │
   ├── Writing component tests, MSW handlers, testing user flows? ──→ frontend-testing
   │
   ├── Debugging hydration mismatches, race conditions, INP/CLS? ──→ ui-debugging-and-performance
   │
   └── Auditing PRs, diffs, accessibility, security, or standards? ─→ code-review-and-standards
```

| Developer Intent | Trigger Keywords | Active Skill Path |
| :--- | :--- | :--- |
| **Requirements Discovery** | "Build this new screen", "Add checkout modal", incomplete requirements | [`skills/frontend-discovery/SKILL.md`](file:///f:/Learn/onyx-skills/skills/frontend-discovery/SKILL.md) |
| **Technical Blueprinting** | "Plan feature", "Spec component hierarchy", "Break down tasks" | [`skills/feature-spec-and-tasks/SKILL.md`](file:///f:/Learn/onyx-skills/skills/feature-spec-and-tasks/SKILL.md) |
| **Visual Component Engineering** | "Create component", "Tailwind styling", "Design tokens", "a11y" | [`skills/frontend-ui-components/SKILL.md`](file:///f:/Learn/onyx-skills/skills/frontend-ui-components/SKILL.md) |
| **Data Fetching & State Sync** | "Connect endpoint", "Server Action", "Query keys", "Optimistic update" | [`skills/api-contracts-and-state/SKILL.md`](file:///f:/Learn/onyx-skills/skills/api-contracts-and-state/SKILL.md) |
| **Test Suite Construction** | "Write tests", "Test user interaction", "Mock API", "MSW handler" | [`skills/frontend-testing/SKILL.md`](file:///f:/Learn/onyx-skills/skills/frontend-testing/SKILL.md) |
| **Triage & Web Vitals** | "Hydration failed", "Slow input", "CLS layout shift", "Race condition" | [`skills/ui-debugging-and-performance/SKILL.md`](file:///f:/Learn/onyx-skills/skills/ui-debugging-and-performance/SKILL.md) |
| **PR & Security Audit** | "Review this diff", "Pre-merge audit", "Check WCAG compliance" | [`skills/code-review-and-standards/SKILL.md`](file:///f:/Learn/onyx-skills/skills/code-review-and-standards/SKILL.md) |

---

## Universal Engineering Constraints

These foundational principles supersede model defaults and must be respected at all times (see [`.rules/global-principles.md`](file:///f:/Learn/onyx-skills/.rules/global-principles.md)):

1. **Zero Assumption on APIs:** Never hallucinate props, function signatures, or third-party library methods. Verify types and imports before mutating code.
2. **Server vs. Client Isolation:** In Next.js / RSC projects, keep components on the server by default. Push `"use client"` exclusively down to the smallest interactive leaf nodes.
3. **Mandatory 4 Defensive UI States:** Every data-driven component must explicitly provide:
   - **Loading:** Layout-preserving skeletons (zero CLS).
   - **Empty:** Actionable message when arrays contain zero items.
   - **Error:** Human-readable message with an inline retry button.
   - **Success:** Fully typed presentation payload.
4. **Token-Only Styling:** Prohibit arbitrary CSS values (`p-[13px]`, `bg-[#242424]`). Use semantic design tokens and standard Tailwind utility scales (`p-3`, `bg-card`).
5. **Strict WCAG 2.1 AA:** Never create clickable `<div>` elements. Use native `<button>`, `<dialog>`, and `<nav>` with full keyboard traversability (`Tab`, `Enter`, `Escape`) and visible `:focus-visible` rings.
6. **Network Boundary Validation:** All incoming network payloads must be validated at the system boundary using runtime schemas (Zod).
7. **Clean Teardowns:** All asynchronous subscriptions, DOM listeners, timers, and fetch calls in effects must return cleanup callbacks or forward `AbortSignal`.

---

## Skill Authoring & Maintenance Standards

When adding or updating skills in `skills/<skill-name>/`:

- **Clean Naming:** Never use numeric prefixes in skill names (`name: frontend-ui-components`, NOT `name: 03-frontend-ui-components`).
- **Complete Structure:** Maintain all standard sections:
  - YAML Frontmatter (`name`, `description`, `version`)
  - `# Title (slug)`
  - `## When to Use This Skill` / `## When NOT to Use This Skill`
  - `## Rules of Engagement`
  - `## Core Engineering Phases`
  - `## Anti-Patterns (Strictly Avoid)`
  - `## Output Format`
  - `## Example Implementation`
  - `## Verification & Delivery Checklist`
- **Clickable Links:** Always format internal links with the `file://` scheme or relative paths.
