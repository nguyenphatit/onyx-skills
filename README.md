# Frontend Agent Skills

A modular context-engineering framework and skills system tailored specifically for frontend coding agents (Cursor, Claude Code, Windsurf, GitHub Copilot).

Instead of overloading agent context windows with sprawling, generic full-stack guidance, this repository condenses the development lifecycle into **modular, high-leverage skills** designed around modern UI architecture, type-safe data pipelines, and frontend resilience.

---

## Architecture & Skill Routing

When a task enters the development lifecycle, route it through this decision tree to load the optimal skill without polluting agent memory:

```text
Task arrives
   │
   ├── Ambiguous requirement or open-ended brief? ──────→ frontend-discovery
   │
   ├── Complex feature, new flow, or domain plan? ───────→ feature-spec-and-tasks
   │
   ├── Building visual UI, styling, or design tokens? ──→ frontend-ui-components
   │
   ├── Connecting APIs, server actions, or stores? ────→ api-contracts-and-state
   │
   ├── Writing component tests or validating flows? ────→ frontend-testing
   │
   ├── Fixing hydration bugs, renders, or race conditions? → ui-debugging-and-performance
   │
   └── Auditing PRs, security, a11y, or web vitals? ─────→ code-review-and-standards
```

---

## Skills Catalog

| Skill | Focus Area | Source Inspiration |
| :--- | :--- | :--- |
| [`frontend-discovery`](skills/frontend-discovery/SKILL.md) | Technical interview to lock scope, rendering boundaries, and edge states before writing code | Addy Osmani (`interview-me`, `idea-refine`) |
| [`feature-spec-and-tasks`](skills/feature-spec-and-tasks/SKILL.md) | Component hierarchy trees, type contracts, state topology matrix, and sub-30min task checklists | Addy Osmani (`spec-driven-development`, `planning-and-task-breakdown`) |
| [`frontend-ui-components`](skills/frontend-ui-components/SKILL.md) | Semantic design tokens, mobile-first Tailwind hygiene, WCAG 2.1 AA accessibility, defensive layouts | Addy Osmani (`frontend-ui-engineering`) |
| [`api-contracts-and-state`](skills/api-contracts-and-state/SKILL.md) | Zod schema validation boundaries, query keys, optimistic mutations with rollback, and URL state sync | Addy Osmani (`api-and-interface-design`, `source-driven-development`) |
| [`frontend-testing`](skills/frontend-testing/SKILL.md) | Role-based queries, `@testing-library/user-event`, MSW network mocking, 4-state test coverage | Addy Osmani (`test-driven-development`, `browser-testing-with-devtools`) |
| [`ui-debugging-and-performance`](skills/ui-debugging-and-performance/SKILL.md) | Stop-the-Line rule, hydration fixes, race condition prevention, re-render profiling, and Web Vitals | Addy Osmani (`debugging-and-error-recovery`, `performance-optimization`) |
| [`code-review-and-standards`](skills/code-review-and-standards/SKILL.md) | 5-axis review rubric (Correctness, Architecture, a11y, Vitals, Security), severity tiers, diffs | Addy Osmani (`code-review-and-quality`, `security-and-hardening`) |

---

## Export & Integration

### Cursor Integration
Export these skills directly to Cursor rules (`.cursor/rules/*.mdc`) using the provided sync script:

```bash
bash scripts/sync-cursor.sh /path/to/your/project
```

### Direct Agent Invocation
When prompting an AI coding agent (Claude Code, Cursor, Antigravity, Windsurf), you can activate a skill by referencing its name directly:
> *"Load `api-contracts-and-state` and help me implement an optimistic task toggle mutation with rollback."*

