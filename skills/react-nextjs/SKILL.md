---
name: react-nextjs
description: >
  React 19 + Next.js 15 code patterns and examples for TypeScript.
  Covers Server/Client Components, App Router conventions, React 19 features
  (use hook, actions, useOptimistic, compiler), TanStack Query, form handling
  with Zod, Zustand, error boundaries, and performance patterns.
  Use when building React components, pages, or Next.js features.
  Complements AGENTS.md — does not repeat architecture, file structure, or
  TypeScript style rules already defined there.
---

# React 19 + Next.js 15 Patterns

Refer to **AGENTS.md** for architecture (layered boundaries), file structure,
TypeScript style rules, and testing strategy. This skill provides code-level
patterns and examples.

## React 19 Features

### Compiler-Friendly Components

The React Compiler auto-optimizes pure components. Write for it:

- Keep components pure, props serializable
- Derive values during render — don't stash in state or refs
- Verify with DevTools (look for "Memo ✨" badge)
- Opt out with `"use no memo"` while refactoring problem components

```tsx
// Compiler-friendly — pure derived values
function UserCard({ user }: { user: User }) {
  const displayName = `${user.firstName} ${user.lastName}`;
  const isVIP = user.points > 1000;

  return (
    <div>
      <h2>{displayName}</h2>
      {isVIP && <Badge>VIP</Badge>}
    </div>
  );
}
```

### The `use()` Hook

Unwraps Promises and Context. Useful with Suspense and Server Components:

```tsx
import { use, Suspense } from "react";

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return <div>{user.name}</div>;
}

// Wrap in Suspense
<Suspense fallback={<Skeleton />}>
  <UserProfile userPromise={fetchUser(id)} />
</Suspense>
```

For SPA-only data fetching, prefer TanStack Query over `use()`.

### Actions & `useActionState`

Best for form submissions and simple CRUD. Don't mix with TanStack Query
mutations in the same feature — pick one approach per feature.

```tsx
// app/components/TodoForm.tsx
"use client";

import { useActionState } from "react";

async function createTodoAction(prev: ActionState, formData: FormData) {
  const text = formData.get("text") as string;
  if (!text || text.length < 3) {
    return { error: "Text must be at least 3 characters" };
  }
  await api.post("/todos", { text });
  return { error: null, success: true };
}

function TodoForm() {
  const [state, formAction, isPending] = useActionState(createTodoAction, {
    error: null,
    success: false,
  });

  return (
    <form action={formAction}>
      {state.error && <span className="error">{state.error}</span>}
      <input name="text" required />
      <button type="submit" disabled={isPending}>
        {isPending ? "Adding..." : "Add"}
      </button>
    </form>
  );
}
```

### `useOptimistic`

```tsx
// app/components/TaskList.tsx
"use client";

import { useOptimistic } from "react";

async function addTodo(formData: FormData) {
  const text = formData.get("text") as string;
  await api.post("/todos", { text });
}

function TaskList({ initialTodos }: { initialTodos: Todo[] }) {
  const [optimisticTodos, addOptimistic] = useOptimistic(
    initialTodos,
    (state, newText: string) => [
      ...state,
      { id: `temp-${Date.now()}`, text: newText, completed: false },
    ]
  );

  async function handleSubmit(formData: FormData) {
    const text = formData.get("text") as string;
    addOptimistic(text);
    await addTodo(formData);
  }

  return (
    <>
      <ul>
        {optimisticTodos.map((todo) => (
          <li
            key={todo.id}
            style={{ opacity: todo.id.startsWith("temp-") ? 0.5 : 1 }}
          >
            {todo.text}
          </li>
        ))}
      </ul>
      <form action={handleSubmit}>
        <input name="text" required />
        <button type="submit">Add</button>
      </form>
    </>
  );
}
```

### Actions vs TanStack Query — When to Use Which

| Scenario | Use |
|----------|-----|
| Form submission with validation | Actions |
| Button-triggered mutation | TanStack Query |
| Optimistic updates + rollback on complex cache | TanStack Query |
| SSR/RSC form flows | Actions |
| SPA with existing TanStack Query setup | TanStack Query (for consistency) |

## Next.js 15 App Router

### Server vs Client Components

Server Components are the default. Only add `"use client"` when you need
hooks, event handlers, or browser APIs. These must be separate files —
`"use client"` must be the first statement in the module.

```tsx
// app/users/page.tsx — Server Component (default)
async function UsersPage() {
  const users = await fetchUsers();
  return (
    <div>
      {users.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}
```

```tsx
// app/components/SearchInput.tsx — Client Component (separate file)
"use client";

import { useState } from "react";

function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState("");
  return (
    <input
      value={query}
      onChange={(e) => setQuery(e.target.value)}
      onKeyDown={(e) => e.key === "Enter" && onSearch(query)}
    />
  );
}
```

### Type-Safe Dynamic Routes

In Next.js 15, `params` and `searchParams` are Promises (async page props):

```tsx
// app/users/[id]/page.tsx
interface PageProps {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}

export default async function UserPage({ params, searchParams }: PageProps) {
  const { id } = await params;
  const { tab } = await searchParams;
  const user = await fetchUser(id);

  if (!user) notFound();

  return <UserProfile user={user} activeTab={tab} />;
}
```

### API Routes

```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const pageParam = request.nextUrl.searchParams.get("page") ?? "1";
  const page = Number.parseInt(pageParam, 10);

  if (!Number.isFinite(page) || page < 1) {
    return NextResponse.json({ error: "Invalid page parameter" }, { status: 400 });
  }

  const users = await fetchUsers({ page });
  return NextResponse.json(users);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const validated = userSchema.safeParse(body);

  if (!validated.success) {
    return NextResponse.json(
      { errors: validated.error.flatten() },
      { status: 400 }
    );
  }

  const user = await createUser(validated.data);
  return NextResponse.json(user, { status: 201 });
}
```

### Parallel Data Fetching with Suspense

```tsx
async function DashboardPage() {
  const [usersPromise, ordersPromise, statsPromise] = [
    fetchUsers(),
    fetchOrders(),
    fetchStats(),
  ];

  return (
    <>
      <Suspense fallback={<UsersSkeleton />}>
        <UsersPanel usersPromise={usersPromise} />
      </Suspense>
      <Suspense fallback={<OrdersSkeleton />}>
        <OrdersPanel ordersPromise={ordersPromise} />
      </Suspense>
    </>
  );
}
```

### Loading, Error, and Not Found

Each of these is a separate file in the route directory:

```tsx
// app/users/loading.tsx
export default function Loading() {
  return (
    <div className="animate-pulse space-y-3">
      {[1, 2, 3].map((i) => (
        <div key={i} className="h-20 bg-gray-200 rounded" />
      ))}
    </div>
  );
}
```

```tsx
// app/users/error.tsx
"use client";

export default function ErrorBoundary({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

```tsx
// app/users/[id]/not-found.tsx
import Link from "next/link";

export default function NotFound() {
  return (
    <div>
      <h2>User Not Found</h2>
      <Link href="/users">Back to Users</Link>
    </div>
  );
}
```

## State Management

### TanStack Query — Server State

```tsx
"use client";

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

function useUsers() {
  return useQuery({
    queryKey: ["users"],
    queryFn: fetchUsers,
    staleTime: 5 * 60 * 1000,
  });
}

function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: UpdateUserInput) => api.updateUser(data),
    onMutate: async (newData) => {
      await queryClient.cancelQueries({ queryKey: ["users"] });
      const previous = queryClient.getQueryData<User[]>(["users"]);
      queryClient.setQueryData<User[]>(["users"], (old) =>
        old?.map((u) => (u.id === newData.id ? { ...u, ...newData } : u))
      );
      return { previous };
    },
    onError: (_err, _newData, context) => {
      queryClient.setQueryData(["users"], context?.previous);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
    },
  });
}
```

### Zustand — Client State

Keep Zustand for UI-only state (sidebar, theme, modals). Server data belongs
in TanStack Query. Because `persist` middleware uses `localStorage` by default,
this store must live in a client-only module (`"use client"` or only imported
from Client Components).

```tsx
// app/stores/ui.ts — import only from Client Components
"use client";

import { create } from "zustand";
import { devtools, persist } from "zustand/middleware";

interface UIState {
  sidebarOpen: boolean;
  theme: "light" | "dark";
  toggleSidebar: () => void;
  setTheme: (theme: "light" | "dark") => void;
}

export const useUIStore = create<UIState>()(
  devtools(
    persist(
      (set) => ({
        sidebarOpen: true,
        theme: "light",
        toggleSidebar: () =>
          set((state) => ({ sidebarOpen: !state.sidebarOpen })),
        setTheme: (theme) => set({ theme }),
      }),
      { name: "ui-storage" }
    )
  )
);
```

### React Hook Form + Zod — Form State

```tsx
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const userSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Invalid email"),
  age: z.preprocess(
    (val) => (val === "" || val === undefined ? undefined : Number(val)),
    z.number().min(18, "Must be 18+").optional()
  ),
});

type UserFormData = z.infer<typeof userSchema>;

function UserForm({ onSubmit }: { onSubmit: (data: UserFormData) => void }) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<UserFormData>({
    resolver: zodResolver(userSchema),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register("name")} />
      {errors.name && <span>{errors.name.message}</span>}

      <input {...register("email")} type="email" />
      {errors.email && <span>{errors.email.message}</span>}

      <input {...register("age", { valueAsNumber: true })} type="number" />
      {errors.age && <span>{errors.age.message}</span>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Saving..." : "Save"}
      </button>
    </form>
  );
}
```

## Component Patterns

### Generic List

```tsx
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item) => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}
```

### Compound Components

Use `Object.assign` to attach sub-components with correct types:

```tsx
function CardRoot({ children }: { children: React.ReactNode }) {
  return <div className="card">{children}</div>;
}

function CardHeader({ children }: { children: React.ReactNode }) {
  return <header className="card-header">{children}</header>;
}

function CardContent({ children }: { children: React.ReactNode }) {
  return <div className="card-content">{children}</div>;
}

export const Card = Object.assign(CardRoot, {
  Header: CardHeader,
  Content: CardContent,
});

// Usage
<Card>
  <Card.Header>Dashboard</Card.Header>
  <Card.Content>{/* ... */}</Card.Content>
</Card>
```

### Discriminated Union State

```tsx
type RequestState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

function DataDisplay<T>({
  state,
  render,
}: {
  state: RequestState<T>;
  render: (data: T) => React.ReactNode;
}) {
  switch (state.status) {
    case "idle":
      return null;
    case "loading":
      return <Spinner />;
    case "success":
      return <>{render(state.data)}</>;
    case "error":
      return <ErrorMessage error={state.error} />;
  }
}
```

## Performance

### Code Splitting

```tsx
import { Suspense, lazy } from "react";

const HeavyChart = lazy(() => import("./HeavyChart"));

function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart />
    </Suspense>
  );
}
```

### Memoization

With the React 19 compiler, manual `useMemo`/`useCallback`/`memo` are less
necessary. Use them only when profiling shows a measurable performance issue.

```tsx
// Expensive filter — worth memoizing
const filtered = useMemo(
  () => items.filter((item) => item.name.includes(filter)),
  [items, filter]
);

// Stable reference for child that does deep comparison
const MemoizedRow = memo(function Row({ item }: { item: Item }) {
  return <div>{item.name}</div>;
});
```

## Security

Avoid rendering raw HTML. React escapes text content by default — prefer
`{userInput}` over `dangerouslySetInnerHTML`. When raw HTML is unavoidable,
sanitize at the boundary: use `isomorphic-dompurify` (works in both Server
Components and client) or sanitize server-side before passing to the client.
