---
name: api-contracts-and-state
description: "Architect type-safe API client contracts, server action mutations, cache invalidation protocols, and resilient state synchronization across frontend boundaries."
version: 1.0.0
---

# API Contracts & State (`api-contracts-and-state`)

Use this skill when integrating client applications with remote endpoints, authoring Server Actions, orchestrating server-state caching (TanStack Query, SWR, RTK Query), or managing client-side stores (Zustand, URL parameters).

Connecting frontend code to backend APIs without strict contract enforcement and disciplined state topology leads to fragile UIs, stale data waterfalls, race conditions, untyped runtime crashes, and out-of-sync optimistic mutations. This skill guarantees end-to-end type safety, deterministic cache invalidation, and defensive network resilience.

---

## When to Use This Skill

- Defining TypeScript interfaces and runtime validation schemas (Zod, Valibot) for REST, GraphQL, or RPC endpoints.
- Authoring data fetching hooks, server mutations, or Next.js Server Actions with optimistic rollbacks.
- Configuring query caching, request deduplication, cache tags, or stale-while-revalidate invalidation strategies.
- Synchronizing filter, sort, pagination, or tab state with URL search parameters.
- Modeling global client state (Zustand, Jotai) for cross-component coordination.

## When NOT to Use This Skill

- Building pure presentational components, styling layouts, or authoring Tailwind classes (use `frontend-ui-components`).
- Formulating initial feature scope or high-level component trees (use `feature-spec-and-tasks`).
- Profiling memory leaks or diagnosing hydration mismatch warnings (use `ui-debugging-and-performance`).

---

## Rules of Engagement

1. **Contract First & Runtime Validation:** Never trust external network payloads implicitly. Define runtime schemas (Zod) at the system boundaries and infer TypeScript types from schemas, not vice versa.
2. **Strict State Topology (No Duplication):** Never mirror server-cached data into local `useState` or `useEffect`. If data originates from a remote server, manage it exclusively via server-state caching (TanStack Query / SWR) or URL params.
3. **Predictable Discriminated Union Results:** Public API methods and server mutations must return explicit discriminated unions (`{ success: true; data: T } | { success: false; error: AppError }`). Do not mix thrown exceptions with silent nulls.
4. **Guaranteed Optimistic Rollbacks:** Every optimistic UI update must capture a previous state snapshot before mutating the cache, roll back immediately on error, and unconditionally trigger a server revalidation on settlement.
5. **Request Cancellation & Race Prevention:** Asynchronous data-fetching operations driven by dynamic inputs (search queries, filters) must forward `AbortSignal` to cancel stale in-flight requests.

---

## Core Engineering Phases

### Phase 1: Contract & Boundary Definition

- **Schema Authoring:** Define Zod schemas that validate incoming payloads and server responses.
- **Consistent Error Semantics:** Model structured error responses incorporating machine-readable error codes and human-friendly messages:

  ```typescript
  export interface APIError {
    code: "UNAUTHORIZED" | "NOT_FOUND" | "VALIDATION_FAILED" | "INTERNAL_ERROR";
    message: string;
    details?: Record<string, string[]>;
  }

  export type APIResult<T> =
    | { success: true; data: T }
    | { success: false; error: APIError };
  ```

- **Hyrum's Law Awareness:** Do not expose raw database IDs, internal stack traces, or undocumented response fields to consumer components.

### Phase 2: State Layer Allocation

Classify every state variable into its singular authoritative storage layer:

1. **URL State (`nuqs` / `useSearchParams`):**
   - Filters, search terms, active pagination offsets, tab identifiers.
   - Requirement: Deep-linkable, shareable, and browser-back-button navigable.
2. **Server Cache Layer (TanStack Query / SWR / RSC):**
   - Remote entity collections, user profiles, dashboard statistics.
   - Requirement: Governed by `staleTime`, `gcTime`, and deterministic query keys.
3. **Global Client Store (Zustand):**
   - Persistent UI preferences, active sidebar collapse state, draft wizard buffers.
   - Requirement: Kept lean with atomic selectors to prevent unnecessary re-renders.
4. **Local Ephemeral State (`useState` / `useReducer`):**
   - Menu open/close toggles, hover states, raw input field characters prior to blur.

### Phase 3: Cache Invalidation & Query Key Hierarchy

- Structure query keys as hierarchical tuples from general to specific:
  ```typescript
  export const queryKeys = {
    all: ["tasks"] as const,
    lists: () => [...queryKeys.all, "list"] as const,
    list: (filters: TaskFilters) => [...queryKeys.lists(), filters] as const,
    details: () => [...queryKeys.all, "detail"] as const,
    detail: (id: string) => [...queryKeys.details(), id] as const,
  };
  ```
- Invalidate broad categories (`queryKeys.lists()`) on entity creation or deletion, while selectively updating specific details (`queryKeys.detail(id)`) on targeted patches.

### Phase 4: Optimistic Mutations with Automated Rollback

Follow the 3-step mutation lifecycle:

1. `onMutate`: Cancel outgoing refetches, capture the previous cache snapshot, and synchronously write the speculative update.
2. `onError`: Revert the cache to the captured snapshot and display a contextual notification.
3. `onSettled`: Invalidate the query key to ensure client-server consistency regardless of outcome.

---

## Anti-Patterns (Strictly Avoid)

- ❌ **Do NOT sync query data into `useState` using `useEffect`:**
  ```typescript
  // BAD: Creates two sources of truth and causes re-render lag
  const { data } = useQuery(...);
  const [items, setItems] = useState([]);
  useEffect(() => { if (data) setItems(data); }, [data]);
  ```
- ❌ **Do NOT author naked untyped fetch calls:**
  ```typescript
  // BAD: Untyped and vulnerable to runtime schema changes
  const res = await fetch("/api/data");
  const data = await res.json();
  ```
- ❌ **Do NOT perform blind optimistic updates without snapshot rollback:** If the network fails, the user is left with phantom state that diverges from the server.
- ❌ **Do NOT place server mutation logic directly in presentational buttons:** Encapsulate network mutations inside dedicated hooks or action handlers.

---

## Output Format

When generating API contracts and state integrations, format the response following this structure:

````markdown
### ⚡ API Contract & State Architecture: [Module Name]

#### 1. Schema & Contract Definitions (`types/api.ts`)

```typescript
import { z } from "zod";

// Schemas and TypeScript types
```

#### 2. Data Client & Query Keys (`lib/api-client.ts` / `hooks/use-[entity].ts`)

```typescript
// Query keys, fetchers, and custom TanStack Query hooks
```

#### 3. Mutation with Optimistic Rollback (`hooks/use-mutate-[entity].ts`)

```typescript
// Optimistic mutation with onMutate snapshot and rollback
```

#### 4. State Topology Summary

- **Authoritative Storage Layer:** [Server Cache / URL State / Local State]
- **Cache Invalidation Target:** [Keys invalidated]
- **Rollback Behavior:** [Snapshot reversion strategy]
````

---

## Example Implementation

### User Request

> "Create a type-safe task toggling mutation that updates the task status optimistically and syncs active filters to the URL."

### Agent Deliverable

````markdown
### ⚡ API Contract & State Architecture: Task Management

#### 1. Contract & Schemas (`src/features/tasks/types.ts`)

```typescript
import { z } from "zod";

export const TaskStatusSchema = z.enum(["TODO", "IN_PROGRESS", "DONE"]);
export type TaskStatus = z.infer<typeof TaskStatusSchema>;

export const TaskSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1, "Title is required"),
  status: TaskStatusSchema,
  updatedAt: z.string().datetime(),
});
export type Task = z.infer<typeof TaskSchema>;

export const TaskFilterSchema = z.object({
  status: TaskStatusSchema.optional(),
  search: z.string().default(""),
});
export type TaskFilters = z.infer<typeof TaskFilterSchema>;
```

#### 2. Query Keys & Safe Fetcher (`src/features/tasks/api/queries.ts`)

```typescript
import { useQuery } from "@tanstack/react-query";
import { Task, TaskFilters, TaskSchema } from "../types";
import { z } from "zod";

export const taskKeys = {
  all: ["tasks"] as const,
  lists: () => [...taskKeys.all, "list"] as const,
  list: (filters: TaskFilters) => [...taskKeys.lists(), filters] as const,
};

export async function fetchTasks(
  filters: TaskFilters,
  signal?: AbortSignal,
): Promise<Task[]> {
  const params = new URLSearchParams();
  if (filters.status) params.set("status", filters.status);
  if (filters.search) params.set("search", filters.search);

  const res = await fetch(`/api/tasks?${params.toString()}`, { signal });
  if (!res.ok) {
    throw new Error(`Failed to fetch tasks: ${res.statusText}`);
  }

  const raw = await res.json();
  return z.array(TaskSchema).parse(raw);
}

export function useTasks(filters: TaskFilters) {
  return useQuery({
    queryKey: taskKeys.list(filters),
    queryFn: ({ signal }) => fetchTasks(filters, signal),
    staleTime: 30 * 1000, // Consider fresh for 30 seconds
  });
}
```

#### 3. Optimistic Toggle Mutation (`src/features/tasks/api/mutations.ts`)

```typescript
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Task, TaskFilters, TaskStatus } from "../types";
import { taskKeys } from "./queries";

interface ToggleTaskInput {
  taskId: string;
  newStatus: TaskStatus;
  currentFilters: TaskFilters;
}

export function useToggleTaskStatus() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ taskId, newStatus }: ToggleTaskInput) => {
      const res = await fetch(`/api/tasks/${taskId}/status`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: newStatus }),
      });
      if (!res.ok) throw new Error("Status update failed");
      return res.json();
    },

    onMutate: async ({ taskId, newStatus, currentFilters }) => {
      const queryKey = taskKeys.list(currentFilters);

      // 1. Cancel in-flight queries so they don't overwrite optimistic update
      await queryClient.cancelQueries({ queryKey });

      // 2. Snapshot previous value
      const previousTasks = queryClient.getQueryData<Task[]>(queryKey);

      // 3. Optimistically update cache
      if (previousTasks) {
        queryClient.setQueryData<Task[]>(
          queryKey,
          previousTasks.map((task) =>
            task.id === taskId ? { ...task, status: newStatus } : task,
          ),
        );
      }

      return { previousTasks, queryKey };
    },

    onError: (_err, _variables, context) => {
      // 4. Rollback to snapshot on error
      if (context?.previousTasks) {
        queryClient.setQueryData(context.queryKey, context.previousTasks);
      }
    },

    onSettled: (_data, _error, _variables, context) => {
      // 5. Always revalidate to reconcile with server authority
      if (context?.queryKey) {
        queryClient.invalidateQueries({ queryKey: context.queryKey });
      }
    },
  });
}
```
````

---

## Verification & Delivery Checklist

- [ ] All external API responses pass through schema validation (e.g. Zod `parse` or `safeParse`).
- [ ] No remote query data is copied into local `useState` via `useEffect`.
- [ ] Query keys follow a structured, hierarchical tuple taxonomy.
- [ ] All optimistic mutations implement `onMutate` (snapshot), `onError` (rollback), and `onSettled` (invalidate).
- [ ] In-flight requests forward `AbortSignal` for cancellation upon dependency changes.
- [ ] Strict TypeScript compilation passes with zero errors (`tsc --noEmit`).
