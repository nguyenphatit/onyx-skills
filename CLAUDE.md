# CLAUDE.md

This file provides instructions and configuration for Claude Code when working in this repository.

> **Scope:** This file configures agents working within [`onyx-skills`](file:///f:/Learn/onyx-skills) itself. The reusable assets to export to consumer projects live in [`skills/`](file:///f:/Learn/onyx-skills/skills) and [`.rules/`](file:///f:/Learn/onyx-skills/.rules).

---

## Repository Overview

`onyx-skills` is a modular context-engineering framework and skills repository designed specifically for frontend coding agents. It provides standardized, battle-tested engineering playbooks for modern UI development (React, Next.js, TypeScript, Tailwind CSS, TanStack Query, Vitest, MSW, Playwright).

---

## Repository Structure

```text
skills/                   → Modular agent skills (each directory contains SKILL.md)
  ├── frontend-discovery/            → Technical scope & UX discovery interview
  ├── feature-spec-and-tasks/        → Component hierarchy, contracts & atomic task plans
  ├── frontend-ui-components/        → Accessible tokens, Tailwind hygiene & defensive layouts
  ├── api-contracts-and-state/       → Zod boundary contracts, queries & optimistic mutations
  ├── frontend-testing/              → Role queries, user-event, MSW & 4-state testing
  ├── ui-debugging-and-performance/  → Hydration fixes, race conditions & Web Vitals
  └── code-review-and-standards/     → 5-axis review matrix & pre-merge auditing
.rules/                   → Foundational guidelines
  └── global-principles.md           → Non-negotiable architectural & engineering constraints
scripts/                  → Tooling and synchronization scripts
  └── sync-cursor.sh                 → Syncs skills to Cursor rules (.cursor/rules/*.mdc)
README.md                 → Framework documentation and routing tree
```

---

## Skill Routing Lifecycle

When handling a frontend development request, map the task directly to the appropriate skill:

| Lifecycle Phase | User Intent / Trigger | Target Skill |
| :--- | :--- | :--- |
| **01. Discovery** | Ambiguous brief, open-ended component request, unstated rendering strategy | [`frontend-discovery`](skills/frontend-discovery/SKILL.md) |
| **02. Specification** | Complex feature, new route/domain flow, component hierarchy planning | [`feature-spec-and-tasks`](skills/feature-spec-and-tasks/SKILL.md) |
| **03. UI Construction** | Building visual components, styling, design tokens, Tailwind layouts | [`frontend-ui-components`](skills/frontend-ui-components/SKILL.md) |
| **04. Data & State** | Connecting APIs, Server Actions, TanStack Query, store selectors, URL sync | [`api-contracts-and-state`](skills/api-contracts-and-state/SKILL.md) |
| **05. Testing** | Writing unit tests, component specs, MSW mocks, testing user interactions | [`frontend-testing`](skills/frontend-testing/SKILL.md) |
| **06. Triage & Perf** | Hydration errors, race conditions, re-render cascades, INP/CLS optimization | [`ui-debugging-and-performance`](skills/ui-debugging-and-performance/SKILL.md) |
| **07. Review** | Auditing PRs, diffs, pre-merge checks, security, accessibility verification | [`code-review-and-standards`](skills/code-review-and-standards/SKILL.md) |

---

## Skill Authoring Conventions

When contributing or editing skills in this repository, strictly adhere to these standards:

1. **Folder & File Location:** Every skill resides in `skills/<skill-name>/SKILL.md`.
2. **YAML Frontmatter:**
   - Must include `name` (clean slug, no numeric prefixes like `01-`).
   - Must include `description` (written in third-person stating purpose and trigger condition: `"Use when..."`).
   - Must include `version: 1.0.0`.
3. **Required Document Sections:**
   - `# Title (slug)`
   - `## When to Use This Skill`
   - `## When NOT to Use This Skill` (must cross-reference alternative skills using clean slugs)
   - `## Rules of Engagement` (core non-negotiable standards)
   - `## Engineering Phases` or `## Systematic Triage Workflow`
   - `## Anti-Patterns (Strictly Avoid)`
   - `## Output Format` (exact template the agent must generate)
   - `## Example Run` / Concrete Code Walkthrough
   - `## Verification & Delivery Checklist`

---

## Core Engineering Non-Negotiables

- **Grounded Verification:** Never guess third-party APIs or configuration signatures. Verify versions and typings.
- **Strict Boundary Discipline:** Keep React Server Components (RSC) on the server; push `"use client"` down to interactive leaf nodes.
- **Mandatory 4 Defensive States:** Every data-driven UI must explicitly implement Loading, Empty, Error (with retry), and Success states.
- **Zero Arbitrary CSS Values:** Strictly use semantic design tokens and standard Tailwind utility scales (`p-4`, `bg-card`), never arbitrary brackets (`p-[13px]`, `bg-[#1a1a1a]`).
- **WCAG 2.1 AA by Default:** Interactive controls must use semantic HTML (`<button>`, `<dialog>`), support full keyboard navigation, and display high-contrast `:focus-visible` rings.

---

## Common Commands

```bash
# Export skills to Cursor rules in another repository
bash scripts/sync-cursor.sh /path/to/target-project

# Verify skill file lengths and integrity
Get-ChildItem -Recurse skills\*\SKILL.md | Select-Object FullName, Length
```
