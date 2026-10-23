---
name: frontend-ui-components
description: "Build robust, accessible, and resilient frontend UI components adhering to design token hierarchies, Tailwind standards, and strict interactive states."
version: 1.0.0
---

# Frontend UI Components (`frontend-ui-components`)

Use this skill when constructing presentational components, interactive UI widgets, layouts, or atomic design elements.

Writing frontend components without strict styling conventions leads to CSS specificity leaks, arbitrary values, accessibility violations, layout shifts, and broken responsive views. This skill ensures all components conform to semantic tokens, mobile-first layouts, keyboard navigation standards, and defensive UX practices.

---

## When to Use This Skill

- Implementing presentation components, widgets, cards, dialogs, form controls, or layout scaffolds.
- Translating Figma or visual design specifications into production-grade Tailwind CSS or CSS Modules.
- Refactoring hardcoded inline styles or arbitrary CSS values into semantic design tokens.
- Enhancing existing UI elements with accessibility (WCAG AA), focus rings, and keyboard interaction traps.

## When NOT to Use This Skill

- Implementing complex backend data-fetching, server mutations, or global caching logic (use `api-contracts-and-state`).
- Diagnosing hydration mismatches, memory leaks, or rendering performance regressions (use `ui-debugging-and-performance`).
- Planning feature scope, component trees, or data contracts (use `feature-spec-and-tasks`).

---

## Rules of Engagement

1. **No Arbitrary CSS Values:** Strictly prohibit hardcoded hex codes (`bg-[#1a1a1a]`) and arbitrary measurements (`p-[13px]`). Always reference semantic design tokens (`bg-card`, `p-3`).
2. **Strict Accessibility (WCAG 2.1 AA):** Use native semantic HTML elements (`<button>`, `<dialog>`, `<nav>`) over clickable `<div>` elements. Ensure full keyboard traversal and visible focus indicators.
3. **Responsive by Default (Mobile-First):** Declare base mobile styles first, progressing through responsive breakpoints (`sm:`, `md:`, `lg:`).
4. **Defensive Layouts:** Prevent layout breaking on long dynamic strings with CSS truncation or controlled text wrapping. Always allocate reserved dimensional space for dynamic assets to eliminate Cumulative Layout Shift (CLS).

---

## Component Engineering Phases

### Phase 1: Semantic Token Alignment & Class Hygiene

- **Token Tiers:**
  - **Primitive:** Base CSS variables (`--color-blue-500: #3b82f6`).
  - **Semantic:** Intent tokens (`--bg-surface`, `--text-muted`, `--border-default`).
  - **Component Tokens:** Scoped styles referencing semantic variables.
- **Class Merging:** Always utilize a utility wrapper like `cn()` (`clsx` + `tailwind-merge`) to allow external prop overrides without class collision.
- **Mobile-First Class Ordering:** Structure utility classes logically:
  `[Layout & Box Model] -> [Typography] -> [Colors & Borders] -> [States & Breakpoints]`.

### Phase 2: Accessibility & Ergonomics (a11y)

- **Interactive Elements:** Non-anchor click targets must be `<button type="button">`. Never attach `onClick` to `div` or `span` without explicit `role="button"`, `tabIndex={0}`, and `onKeyDown` handlers.
- **Focus States:** Every interactive component must supply high-contrast focus rings using `:focus-visible` (e.g., `focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring`).
- **Touch Targets:** Interactive targets on mobile viewports must meet the minimum 44x44px touch perimeter.
- **Assistive Attributes:** Supply descriptive `aria-label`, `aria-expanded`, and `aria-haspopup` properties for dynamic flyouts, drawers, and icon-only buttons.

### Phase 3: Defensive Layout Constraints

- **Dynamic Content Clamping:** Use `truncate` or `line-clamp-N` combined with `title` or tooltip attributes for user-generated strings.
- **Visual Aspect Ratios:** Always pair dynamic visual containers with explicit aspect ratios (`aspect-video`, `aspect-square`) or placeholder backgrounds.
- **Flex/Grid Containment:** Add `min-w-0` to flex child containers to allow internal text truncation to trigger correctly.

---

## Anti-Patterns (Strictly Avoid)

- ❌ **Do NOT use inline `style={{ ... }}`** for colors, padding, margins, or positioning. Reserve inline styles exclusively for dynamic runtime coordinates.
- ❌ **Do NOT use `!important` overrides** (`!p-4`, `!bg-black`) to bypass specificity issues. Resolve the parent CSS hierarchy instead.
- ❌ **Do NOT build clickable `<div>` wrappers** without keyboard listeners, accessible roles, and focus outlines.
- ❌ **Do NOT design desktop-only components** that overflow or break viewport horizontal boundaries on small screens.

---

## Output Format

When generating UI components, format the response following this structure:

````markdown
### 🎨 Component Implementation: [Component Name]

#### File Location: `[path/to/component.tsx]`

```tsx
import * as React from "react";
import { cn } from "@/lib/utils";

export interface [ComponentName]Props extends React.HTMLAttributes<HTMLElement> {
  // Explicit component props
}

export function [ComponentName]({
  className,
  ...props
}: [ComponentName]Props) {
  return (
    <div
      className={cn(
        // Mobile-first, semantic token utility classes
        "base-classes",
        className
      )}
      {...props}
    >
      {/* Component Markup */}
    </div>
  );
}
```
````

## Design & Accessibility Notes:

Semantic Tokens Used: [Token list]

Responsive Adaptations: [Breakpoint behavior description]

Accessibility Safeguards: [Keyboard support, ARIA attributes, touch targets]

---

## Example Run

**User Prompt:**

> "Create an accessible stat badge component that displays an indicator icon, metric label, and percentage trend."

**Agent Response:**

````markdown
### 🎨 Component Implementation: StatBadge

#### File Location: `src/components/ui/stat-badge.tsx`

```tsx
import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { ArrowDownRight, ArrowUpRight, Minus } from "lucide-react";
import { cn } from "@/lib/utils";

const statBadgeVariants = cva(
  "inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
  {
    variants: {
      trend: {
        positive:
          "bg-emerald-50 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-400",
        negative:
          "bg-rose-50 text-rose-700 dark:bg-rose-950/50 dark:text-rose-400",
        neutral: "bg-muted text-muted-foreground",
      },
    },
    defaultVariants: {
      trend: "neutral",
    },
  },
);

export interface StatBadgeProps
  extends
    React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof statBadgeVariants> {
  label: string;
  value: string;
  trend?: "positive" | "negative" | "neutral";
}

export function StatBadge({
  label,
  value,
  trend = "neutral",
  className,
  ...props
}: StatBadgeProps) {
  const TrendIcon = React.useMemo(() => {
    switch (trend) {
      case "positive":
        return ArrowUpRight;
      case "negative":
        return ArrowDownRight;
      default:
        return Minus;
    }
  }, [trend]);

  return (
    <span
      className={cn(statBadgeVariants({ trend }), className)}
      aria-label={`${label}: ${value}, trend is ${trend}`}
      role="status"
      {...props}
    >
      <TrendIcon className="h-3.5 w-3.5 shrink-0" aria-hidden="true" />
      <span className="truncate max-w-[120px]">{label}</span>
      <span className="font-semibold">{value}</span>
    </span>
  );
}
```
````
