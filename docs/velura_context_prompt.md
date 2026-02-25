# Velura Project — Chat Context Prompt
# Paste this ENTIRE file at the start of a new Claude or ChatGPT conversation
# This gives the AI full context to continue guiding you exactly where we left off

---

## ABOUT ME

I am a frontend / junior full stack developer based in Islamabad, Pakistan.
I am moving to Dubai next month and actively looking for frontend or junior full stack jobs in Dubai or remote.
My strengths are React and Tailwind CSS.
I am learning full stack development — this project is my main portfolio piece.
I use AI (Claude or ChatGPT) to help me generate code, but I make sure I understand every line because interviewers will ask me to explain it.

**How I learn best:**
- Guide me step by step — don't give me 10 things at once
- Explain WHY before HOW — I want to understand decisions, not just copy code
- When something goes wrong, help me understand what happened
- I am on Windows — always use PowerShell compatible commands unless I am in Git Bash
- Keep commit messages meaningful — I care about how my GitHub looks to HRs

---

## THE PROJECT

**Name:** Velura
**Type:** Full stack ecommerce web application (fashion / clothing store)
**Purpose:** Portfolio project targeting Dubai and remote frontend / junior full stack roles
**GitHub:** https://github.com/Hizbullah3698/velura.git
**Local path:** G:\velura
**Active branch:** develop
**Deploy target:** Vercel (frontend) + Supabase Free Tier (backend)

---

## TECH STACK — FINALIZED, DO NOT SUGGEST CHANGES

- **Frontend:** Next.js 16 (App Router) + TypeScript
- **Styling:** Tailwind CSS with dark mode (dark: prefix, saved to localStorage)
- **Backend:** Supabase — PostgreSQL, Auth, Storage, RLS, RPC
- **State:** Zustand — cart only, SSR hydration safe
- **Forms:** React Hook Form + Zod
- **Animation:** Framer Motion
- **Notifications:** React Hot Toast
- **Deploy:** Vercel + Supabase Free Tier

---

## SRS DOCUMENT — FROZEN, DO NOT SUGGEST CHANGES

We spent significant time creating ShopMVP SRS v3.0 — a full Software Requirements Specification.
It was reviewed twice by GPT in both "client mode" and "supervisor mode" and declared final.

GPT verdict: "This is no longer a simple MVP. This is a portfolio-grade system design document.
If you can build even 85% of this cleanly, you'll walk into interviews with confidence."

**The SRS is frozen. Do not suggest new features or architectural changes.**

---

## KEY ARCHITECTURAL DECISIONS — READ AND FOLLOW EXACTLY

### User Roles
- **Guest** — browse products, search, filter. Cannot add to cart.
- **Shopper** — logged in. Can add to cart, checkout, view order history.
- **Admin** — logged in with admin role. Manages products, orders, analytics.

Roles stored in TWO places:
1. profiles table as Postgres enum (for UI)
2. Supabase Custom JWT Claims (for RLS — no profile table joins in policies)

### Database Tables
profiles, categories, products, cart_items, orders, order_items

### Enums
- user_role: shopper, admin
- order_status: pending, shipped, delivered, cancelled
- payment_status: simulated_pending, simulated_paid, simulated_failed, simulated_refunded

### Security — Three Layers (all three must always be in place)
1. RLS — every query checked at DB level using auth.jwt() — NO profile table joins inside policies
2. Middleware — runs on every request, calls getUser() to validate AND refresh token
3. Admin Layout Guard — server component redirects non-admins before any UI renders

### Checkout RPC — handle_checkout
- Type: SECURITY DEFINER — runs with elevated privileges, bypasses RLS intentionally
- Pattern: single atomic transaction — all or nothing
- user_id is NEVER sent from frontend — read from auth.uid() inside the function
- total_amount is ALWAYS calculated from DB prices — never trust frontend price
- Stock decremented atomically — entire transaction rolls back if stock insufficient
- Error codes: UNAUTHORIZED, INSUFFICIENT_STOCK, PRODUCT_NOT_FOUND, UNEXPECTED_ERROR

### Payment Simulation (no real Stripe in MVP)
- payment_status column on orders table
- Checkout shows 2-second processing animation
- 90% chance → simulated_paid
- 10% chance → simulated_failed → stock restored via trigger → order cancelled
- Admin can trigger simulated_refunded → stock also restored

### Cart — Zustand SSR Hydration Pattern
- Show CartSkeleton until isHydrated = true
- Hydrate from Supabase using useEffect on mount (prevents SSR mismatch errors)
- Mutation order: update Zustand first → then Supabase → rollback Zustand if Supabase fails → show error toast

### Products — Soft Delete Only
- NEVER hard delete products
- Admin sets is_active = false
- This protects order history integrity

### Pagination
- ALWAYS use LIMIT/OFFSET at database level
- NEVER slice client-side — that is fake pagination and kills performance

### Admin Analytics Dashboard
- Total revenue (all time, delivered orders only)
- Revenue this month
- Orders this month
- Top 5 selling products
- Orders by status count
- Out of stock product count
- All queries run as server components — never exposed to client

### Database Triggers
1. profile_creation — auto creates profiles row on signup
2. jwt_claim_hook — injects role into JWT on login (keeps JWT and DB in sync)
3. updated_at_trigger — auto sets updated_at on products and orders
4. order_transition_guard — blocks invalid order status transitions at DB level
5. stock_restore_on_cancel — restores stock when payment_status becomes simulated_failed or simulated_refunded

### Order Status Transition Rules (enforced by trigger AND UI)
- pending → shipped or cancelled ✅ | pending → delivered ❌
- shipped → delivered ✅ | shipped → anything else ❌
- delivered → FINAL ❌
- cancelled → FINAL ❌

---

## FOLDER STRUCTURE — ALREADY CREATED ON DISK

```
G:\velura\
  app/
    (shop)/
    (admin)/
    api/auth/callback/
  components/
    ui/
    layout/
    products/
    cart/
    checkout/
    admin/
  lib/
    actions/
    supabase/
    validations/
    utils/
  store/
  types/
  supabase/
    migrations/
  docs/
    ShopMVP_SRS_v3.docx
    CONTEXT.md
    velura_context_prompt.md
```

---

## MIGRATION FILES TO CREATE

In /supabase/migrations/ in this exact order:
- 001_enums.sql
- 002_tables.sql
- 003_indexes.sql
- 004_triggers.sql
- 005_rls.sql
- 006_rpc.sql

Plus seed.sql with realistic fashion product data

---

## GIT SETUP AND HISTORY

**Branching strategy:**
```
main      ← production only. Never push directly.
develop   ← daily work branch. Currently active.
feature/x ← branch off develop for each feature.
```

**Commit message format:**
- feat: new feature
- fix: bug fix
- chore: setup and config
- docs: documentation
- style: UI only changes
- perf: performance improvements
- test: tests

**Commits already on develop:**
1. docs: add SRS v3 and initialize project structure
2. chore: initialize Next.js 16 with TypeScript and Tailwind
3. chore: install dependencies and create project folder structure
4. chore: set up project folder structure as per SRS v3
5. docs: add AI IDE context file for project guidance

---

## PACKAGES ALREADY INSTALLED

next@16.1.6, react, react-dom, @supabase/supabase-js, @supabase/ssr,
zustand, react-hook-form, zod, @hookform/resolvers,
framer-motion, react-hot-toast, typescript, tailwindcss,
@tailwindcss/postcss, eslint, eslint-config-next,
@types/node, @types/react, @types/react-dom

---

## ENVIRONMENT VARIABLES — NOT YET CREATED

Need to create .env.local in project root:
```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key (seed scripts only — never in app code)
```

---

## CRITICAL RULES — ALWAYS FOLLOW THESE

1. Never push directly to main
2. Never trust price from frontend — always calculate in DB
3. Never hard delete products — is_active = false only
4. Never use client-side pagination — always LIMIT/OFFSET at DB level
5. Never import SUPABASE_SERVICE_ROLE_KEY in app code
6. Never use profile table joins inside RLS policies
7. Never send user_id from frontend to checkout RPC
8. Always update Zustand before Supabase (optimistic updates)
9. Always show skeletons while data loads
10. Always show toast for every user action
11. Always follow the exact folder structure
12. Always use meaningful commit messages with prefix format
13. Developer is on Windows — use PowerShell compatible commands

---

## CURRENT BUILD PHASE STATUS

| Phase | Task | Status |
|-------|------|--------|
| 1 | Supabase project setup + all migrations + seed | ⏳ NEXT |
| 2 | Next.js 16 setup + folder structure + packages | ✅ Done |
| 3 | Auth — signup, login, logout, middleware | ⏳ Pending |
| 4 | Homepage — product grid, search, filter, pagination | ⏳ Pending |
| 5 | Product detail page + SEO metadata | ⏳ Pending |
| 6 | Cart — Zustand, Supabase sync, skeleton, toasts | ⏳ Pending |
| 7 | Checkout — form, RPC, payment simulation | ⏳ Pending |
| 8 | Order history + order detail | ⏳ Pending |
| 9 | Admin: product CRUD + image upload | ⏳ Pending |
| 10 | Admin: order management | ⏳ Pending |
| 11 | Admin: analytics dashboard | ⏳ Pending |
| 12 | Skeletons, error states, empty states everywhere | ⏳ Pending |
| 13 | Lighthouse audit + fixes (target 90+) | ⏳ Pending |
| 14 | Loom demo video + full README | ⏳ Pending |
| 15 | Deploy to Vercel + verify live demo | ⏳ Pending |

---

## IMMEDIATE NEXT STEP

Phase 1 — Supabase Setup.

Please guide me step by step starting from the Supabase dashboard.
Tell me exactly what to click, what to name things, and what SQL to run.
After each step wait for me to confirm before moving to the next one.