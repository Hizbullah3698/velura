# CONTEXT.md — Velura Project AI Instructions
# READ THIS FILE BEFORE WRITING ANY CODE
# This file is the single source of truth for this project.
# Every decision here is final and must be followed exactly.

---

## PROJECT OVERVIEW

**Name:** Velura
**Type:** Full Stack Ecommerce Web Application (Fashion / Clothing Store)
**Purpose:** Portfolio project targeting Dubai and remote frontend / junior full stack roles
**Goal:** Demonstrate production-level full stack thinking — NOT a tutorial clone

---

## CRITICAL RULES — READ BEFORE EVERY CODE GENERATION

1. NEVER push or suggest pushing directly to `main` branch
2. NEVER trust price from frontend — total_amount is always calculated in the database
3. NEVER hard delete products — always set `is_active = false`
4. NEVER use client-side pagination — always use LIMIT/OFFSET at database level
5. NEVER import `SUPABASE_SERVICE_ROLE_KEY` in any application code — seed scripts only
6. NEVER use profile table joins inside RLS policies — always use `auth.jwt() ->> 'role'`
7. NEVER send `user_id` from frontend to checkout RPC — read from `auth.uid()` inside the function
8. ALWAYS update Zustand first, then Supabase — rollback Zustand if Supabase fails
9. ALWAYS show loading skeletons while data is fetching — never blank screens
10. ALWAYS add toast notifications for every user action (success and error)
11. ALWAYS follow the exact folder structure defined in this file
12. ALWAYS write meaningful commit messages using the prefix format defined below
13. Developer is on WINDOWS — use PowerShell compatible commands

---

## TECH STACK — FINALIZED, DO NOT CHANGE

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | Next.js App Router + TypeScript | 16.x |
| Styling | Tailwind CSS + Dark Mode | Latest |
| Backend | Supabase (PostgreSQL + Auth + Storage) | Latest |
| State | Zustand (cart only) | Latest |
| Forms | React Hook Form + Zod | Latest |
| Animation | Framer Motion | Latest |
| Notifications | React Hot Toast | Latest |
| Deploy | Vercel + Supabase Free Tier | — |

---

## REPOSITORY

```
GitHub:      https://github.com/Hizbullah3698/velura.git
Local Path:  G:\velura
Main Branch: main (production only — never push directly)
Work Branch: develop (daily work)
Feature:     feature/xxx (branch off develop for each feature)
```

---

## FOLDER STRUCTURE — EXACT, DO NOT DEVIATE

```
G:\velura\
  app/
    (shop)/
      layout.tsx               ← shop layout with Navbar and Footer
      page.tsx                 ← homepage: product grid, search, filters, pagination
      products/
        [slug]/
          page.tsx             ← product detail + dynamic SEO metadata
      cart/
        page.tsx
      checkout/
        page.tsx
        success/
          page.tsx
      orders/
        page.tsx
        [id]/
          page.tsx
      auth/
        login/
          page.tsx
        signup/
          page.tsx
    (admin)/
      layout.tsx               ← CRITICAL: role guard — redirect if role !== admin
      page.tsx                 ← analytics dashboard
      products/
        page.tsx
        new/
          page.tsx
        [id]/
          edit/
            page.tsx
      orders/
        page.tsx
        [id]/
          page.tsx
    api/
      auth/
        callback/
          route.ts             ← Supabase auth callback handler
    middleware.ts              ← CRITICAL: validates + refreshes token on every request

  components/
    ui/
      Button.tsx
      Input.tsx
      Badge.tsx
      Modal.tsx
      Spinner.tsx
      Skeleton.tsx
    layout/
      Navbar.tsx
      Footer.tsx
      AdminSidebar.tsx
      DarkModeToggle.tsx
    products/
      ProductCard.tsx
      ProductGrid.tsx
      CategoryFilter.tsx
      SearchBar.tsx
      PriceRangeFilter.tsx
      LowStockBadge.tsx        ← shows "Only X left" when stock <= 5
    cart/
      CartItem.tsx
      CartSummary.tsx
      CartSkeleton.tsx         ← shown while Zustand hydrates from Supabase
      InactiveProductWarning.tsx
    checkout/
      CheckoutForm.tsx
      OrderSummary.tsx
      PaymentSimulator.tsx     ← simulates payment processing animation
    admin/
      ProductTable.tsx
      OrderTable.tsx
      StatusUpdater.tsx
      AnalyticsCard.tsx

  lib/
    actions/
      cart.ts                  ← server actions for cart operations
      checkout.ts              ← server action that calls handle_checkout RPC
      products.ts              ← server actions for product queries
      orders.ts                ← server actions for order queries
    supabase/
      browser.ts               ← createBrowserClient — client components only
      server.ts                ← createServerClient — server components + actions
    validations/
      auth.ts                  ← Zod schemas for login and signup
      product.ts               ← Zod schemas for product form
      checkout.ts              ← Zod schemas for checkout form
    utils/
      slug.ts                  ← auto-generate slug from product name
      currency.ts              ← format numbers as currency (AED)
      orderStatus.ts           ← valid status transitions map
      analytics.ts             ← analytics query helpers

  store/
    cartStore.ts               ← Zustand cart store with SSR hydration

  types/
    index.ts                   ← ALL TypeScript types in one file

  supabase/
    migrations/
      001_enums.sql
      002_tables.sql
      003_indexes.sql
      004_triggers.sql
      005_rls.sql
      006_rpc.sql
    seed.sql                   ← realistic fashion product seed data

  docs/
    ShopMVP_SRS_v3.docx        ← full SRS document (source of truth)
    CONTEXT.md                 ← this file

  .env.local                   ← NEVER commit this file
  .gitignore
  next.config.ts
  package.json
  tsconfig.json
  middleware.ts
```

---

## DATABASE SCHEMA

### Enums (create first)

```sql
CREATE TYPE user_role AS ENUM ('shopper', 'admin');
CREATE TYPE order_status AS ENUM ('pending', 'shipped', 'delivered', 'cancelled');
CREATE TYPE payment_status AS ENUM ('simulated_pending', 'simulated_paid', 'simulated_failed', 'simulated_refunded');
```

### Tables

**profiles** — auto-created via trigger on signup
```sql
id          uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE
full_name   text
role        user_role NOT NULL DEFAULT 'shopper'
created_at  timestamp NOT NULL DEFAULT now()
updated_at  timestamp NOT NULL DEFAULT now()
```

**categories**
```sql
id          integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY
name        text NOT NULL UNIQUE
slug        text NOT NULL UNIQUE
created_at  timestamp NOT NULL DEFAULT now()
```

**products** — NEVER hard delete, use is_active = false
```sql
id          uuid PRIMARY KEY DEFAULT gen_random_uuid()
name        text NOT NULL
slug        text NOT NULL UNIQUE
description text
price       numeric(10,2) NOT NULL CHECK (price > 0)
stock       integer NOT NULL DEFAULT 0 CHECK (stock >= 0)
category_id integer REFERENCES categories ON DELETE SET NULL
image_url   text
is_active   boolean NOT NULL DEFAULT true
created_at  timestamp NOT NULL DEFAULT now()
updated_at  timestamp NOT NULL DEFAULT now()
```

**cart_items** — unique(user_id, product_id)
```sql
id          uuid PRIMARY KEY DEFAULT gen_random_uuid()
user_id     uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE
product_id  uuid NOT NULL REFERENCES products ON DELETE CASCADE
quantity    integer NOT NULL CHECK (quantity >= 1)
created_at  timestamp NOT NULL DEFAULT now()
UNIQUE(user_id, product_id)
```

**orders** — total_amount ALWAYS calculated in DB, NEVER from frontend
```sql
id               uuid PRIMARY KEY DEFAULT gen_random_uuid()
user_id          uuid NOT NULL REFERENCES auth.users ON DELETE RESTRICT
status           order_status NOT NULL DEFAULT 'pending'
payment_status   payment_status NOT NULL DEFAULT 'simulated_pending'
total_amount     numeric(10,2) NOT NULL
shipping_address jsonb NOT NULL CHECK (
  shipping_address ? 'full_name' AND
  shipping_address ? 'address_line' AND
  shipping_address ? 'city' AND
  shipping_address ? 'country'
)
created_at  timestamp NOT NULL DEFAULT now()
updated_at  timestamp NOT NULL DEFAULT now()
```

**order_items** — price_at_purchase is a snapshot — never changes
```sql
id                uuid PRIMARY KEY DEFAULT gen_random_uuid()
order_id          uuid NOT NULL REFERENCES orders ON DELETE RESTRICT
product_id        uuid NOT NULL REFERENCES products ON DELETE RESTRICT
quantity          integer NOT NULL CHECK (quantity >= 1)
price_at_purchase numeric(10,2) NOT NULL
created_at        timestamp NOT NULL DEFAULT now()
```

---

## INDEXES

```sql
CREATE INDEX ON products(category_id);
CREATE INDEX ON products(slug);
CREATE INDEX ON cart_items(user_id);
CREATE INDEX ON orders(user_id);
CREATE INDEX ON order_items(order_id);
```

---

## DATABASE TRIGGERS

### 1. profile_creation
Fires AFTER INSERT on auth.users. Creates profiles row with default role shopper.

### 2. jwt_claim_hook
Fires ON LOGIN. Reads role from profiles, injects into JWT as custom claim.
This keeps auth.jwt() and profiles table always in sync.

### 3. updated_at_trigger
Fires AFTER UPDATE on products and orders. Sets updated_at = now().

### 4. order_transition_guard
Fires BEFORE UPDATE on orders. Blocks invalid status transitions:
- pending → shipped ✅ | pending → cancelled ✅ | pending → delivered ❌
- shipped → delivered ✅ | shipped → anything else ❌
- delivered → anything ❌ (FINAL)
- cancelled → anything ❌ (FINAL)

### 5. stock_restore_on_cancel
Fires AFTER UPDATE on orders WHERE payment_status changes to simulated_failed or simulated_refunded.
Restores stock for all items in that order.

---

## ROW LEVEL SECURITY POLICIES

All policies use `(auth.jwt() ->> 'role')` — NEVER join the profiles table inside a policy.

```
profiles      → anyone can read | user updates own row only
categories    → anyone can read | admin full CRUD
products      → anyone reads active (is_active=true) | admin reads all | admin insert/update | NO DELETE
cart_items    → user owns all operations on own rows (auth.uid() = user_id)
orders        → shopper reads own | admin reads all | admin updates status | NO client INSERT
order_items   → shopper reads own via subquery on orders | admin reads all | NO client INSERT
```

---

## CHECKOUT RPC — handle_checkout

**Type:** SECURITY DEFINER (runs with elevated privileges, bypasses RLS intentionally)
**Pattern:** Single atomic transaction — all or nothing

**Input (from server action only):**
```typescript
{
  shipping_address: { full_name: string, address_line: string, city: string, country: string },
  items: Array<{ product_id: string, quantity: number }>
  // user_id is NEVER passed — read from auth.uid() inside the function
}
```

**Output:**
```typescript
{
  status: 'success' | 'error',
  order_id?: string,      // on success only
  code?: string,          // on error only
  product_id?: string     // only when code is INSUFFICIENT_STOCK
}
```

**Error Codes:**
- `UNAUTHORIZED` — auth.uid() returned null
- `INSUFFICIENT_STOCK` — stock ran out for a product (includes product_id)
- `PRODUCT_NOT_FOUND` — product_id invalid or is_active = false
- `UNEXPECTED_ERROR` — catch-all

**Transaction Steps:**
1. Call auth.uid() — if null return UNAUTHORIZED immediately
2. Validate all product_ids exist and are active
3. Decrement stock atomically for each item — rollback entire transaction if any item fails
4. Calculate total_amount from DB prices — NEVER use price from input
5. INSERT into orders (status=pending, payment_status=simulated_pending)
6. INSERT all order_items with price_at_purchase from current DB prices
7. Return { status: 'success', order_id }

---

## PAYMENT SIMULATION

No real Stripe. Simulated payment flow:

1. Checkout submitted → order created with payment_status = simulated_pending
2. Success page shows 2-second processing animation
3. 90% chance → payment_status = simulated_paid
4. 10% chance → payment_status = simulated_failed → stock restored via trigger → order cancelled
5. Admin can trigger simulated_refunded → stock restored via trigger

---

## ZUSTAND CART STORE

**File:** `store/cartStore.ts`

**State shape:**
```typescript
items: Array<{
  product_id: string
  name: string
  image_url: string
  price: number
  quantity: number
}>
isHydrated: boolean
```

**Critical SSR rule:**
- Show `<CartSkeleton />` until `isHydrated = true`
- Hydrate from Supabase using `useEffect` on mount
- This prevents React SSR hydration mismatch errors

**Mutation pattern (ALWAYS follow this order):**
1. Update Zustand immediately (optimistic update for instant UI)
2. Call Supabase to sync
3. If Supabase fails → rollback Zustand to previous state + show error toast

---

## SUPABASE CLIENT FILES

**lib/supabase/browser.ts** — for client components
```typescript
import { createBrowserClient } from '@supabase/ssr'
export const createClient = () => createBrowserClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

**lib/supabase/server.ts** — for server components and server actions
```typescript
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
// Export two versions:
// - read-only for server components
// - read-write for server actions (needed to refresh session cookie)
```

---

## MIDDLEWARE

**File:** `middleware.ts` (root level, not inside app/)

- Runs on EVERY request before any page loads
- Calls `supabase.auth.getUser()` — validates AND refreshes token
- DO NOT just check if cookie exists — the JWT inside could be expired
- Redirects unauthenticated users to /auth/login with return URL
- Redirects authenticated users away from /auth/login and /auth/signup

---

## ADMIN ANALYTICS QUERIES

All analytics run as server components. Never expose raw aggregation to client.

```sql
-- Total revenue (delivered orders only)
SELECT SUM(total_amount) FROM orders WHERE status = 'delivered';

-- Revenue this month
SELECT SUM(total_amount) FROM orders
WHERE created_at >= date_trunc('month', now());

-- Orders this month
SELECT COUNT(*) FROM orders
WHERE created_at >= date_trunc('month', now());

-- Top 5 products
SELECT product_id, SUM(quantity) as total_sold
FROM order_items GROUP BY product_id
ORDER BY total_sold DESC LIMIT 5;

-- Orders by status
SELECT status, COUNT(*) FROM orders GROUP BY status;

-- Out of stock
SELECT COUNT(*) FROM products WHERE stock = 0 AND is_active = true;
```

---

## ENVIRONMENT VARIABLES

**File:** `.env.local` (NEVER commit — already in .gitignore)

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

- `NEXT_PUBLIC_*` — safe to use in client and server code (RLS protects data)
- `SUPABASE_SERVICE_ROLE_KEY` — ONLY in seed scripts. NEVER import in app code.

---

## TYPESCRIPT TYPES

**File:** `types/index.ts` — ALL types in one file

```typescript
export type UserRole = 'shopper' | 'admin'
export type OrderStatus = 'pending' | 'shipped' | 'delivered' | 'cancelled'
export type PaymentStatus = 'simulated_pending' | 'simulated_paid' | 'simulated_failed' | 'simulated_refunded'

export interface Profile { id: string; full_name: string; role: UserRole; created_at: string; updated_at: string }
export interface Category { id: number; name: string; slug: string }
export interface Product { id: string; name: string; slug: string; description: string; price: number; stock: number; category_id: number | null; image_url: string; is_active: boolean; created_at: string; updated_at: string }
export interface CartItem { id: string; user_id: string; product_id: string; quantity: number; product: Product }
export interface Order { id: string; user_id: string; status: OrderStatus; payment_status: PaymentStatus; total_amount: number; shipping_address: ShippingAddress; created_at: string; updated_at: string; order_items: OrderItem[] }
export interface OrderItem { id: string; order_id: string; product_id: string; quantity: number; price_at_purchase: number; product: Product }
export interface ShippingAddress { full_name: string; address_line: string; city: string; country: string }
export interface CheckoutFormData { full_name: string; address_line: string; city: string; country: string }
export interface ProductFormData { name: string; slug: string; description: string; price: number; stock: number; category_id: number; image?: File; is_active: boolean }
export interface RpcResponse { status: 'success' | 'error'; order_id?: string; code?: string; product_id?: string }
```

---

## PAGES — KEY BEHAVIOUR

**/ (Homepage)**
- Server component fetches initial products (12 per page)
- Search is client-side instant filter
- Category filter and price range filter update URL params
- Pagination uses LIMIT/OFFSET — never loads all products

**/(admin)/layout.tsx**
- Server component ONLY
- Reads role from session
- If role !== 'admin' → redirect to / immediately
- This runs before ANY admin UI renders

**/checkout**
- Left: shipping form (React Hook Form + Zod)
- Right: order summary (read from Zustand cart)
- On submit → server action → handle_checkout RPC
- PaymentSimulator component shows 2s processing animation
- 10% chance of simulated failure

**Cart hydration pattern:**
```typescript
// In cartStore.ts
const useCartStore = create((set) => ({
  items: [],
  isHydrated: false,
  hydrate: async (supabase) => {
    const { data } = await supabase.from('cart_items').select('*, product:products(*)')
    set({ items: data ?? [], isHydrated: true })
  }
}))

// In CartSkeleton usage:
const { isHydrated } = useCartStore()
if (!isHydrated) return <CartSkeleton />
```

---

## GIT COMMIT FORMAT

```
feat:   new feature          → feat: add product search with URL param sync
fix:    bug fix              → fix: cart quantity rollback on Supabase sync failure
chore:  setup/config         → chore: configure Supabase RLS policies
docs:   documentation        → docs: add analytics section to README
style:  UI changes only      → style: add dark mode to product card
perf:   performance          → perf: add LIMIT/OFFSET pagination to product listing
test:   tests                → test: add unit tests for orderStatus utility
```

---

## BUILD PHASE STATUS

| Phase | Task | Status |
|-------|------|--------|
| 1 | Supabase setup + all migrations + seed | ⏳ NEXT |
| 2 | Next.js setup + folder structure | ✅ Done |
| 3 | Auth + middleware | ⏳ Pending |
| 4 | Homepage + search + filter + pagination | ⏳ Pending |
| 5 | Product detail + SEO | ⏳ Pending |
| 6 | Cart + Zustand + sync | ⏳ Pending |
| 7 | Checkout + RPC + payment simulation | ⏳ Pending |
| 8 | Order history + detail | ⏳ Pending |
| 9 | Admin: products CRUD | ⏳ Pending |
| 10 | Admin: orders management | ⏳ Pending |
| 11 | Admin: analytics dashboard | ⏳ Pending |
| 12 | Skeletons + error states + empty states | ⏳ Pending |
| 13 | Lighthouse audit + accessibility fixes | ⏳ Pending |
| 14 | Loom demo video + README | ⏳ Pending |
| 15 | Deploy to Vercel | ⏳ Pending |

---

## HOW TO USE THIS FILE WITH AN AI IDE

When asking AI to generate code, always reference this file:

**Good prompts:**
- "Write 001_enums.sql based on the enums defined in CONTEXT.md"
- "Create lib/supabase/browser.ts following the pattern in CONTEXT.md"
- "Write the handle_checkout RPC following the exact transaction steps in CONTEXT.md"
- "Create the CartStore following the SSR hydration pattern in CONTEXT.md"

**Never do this:**
- "Build me the whole project"
- "Set up authentication however you think is best"
- "Design the database schema"

The architecture is already decided. AI generates code. You review and understand it. You run it.

---

*Last updated: February 2026 | Version: 3.0 | Status: Active Development*