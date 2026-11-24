# Database Architecture & Migrations — LyHENG VND-USD

## 1. Relational Schema

### Table 1: `public.admin_users`
Stores explicitly authorized Administrator accounts linked to Supabase Auth (`auth.users`).
```sql
CREATE TABLE public.admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'superadmin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_admin_users_user_id ON public.admin_users(user_id);
```

### Table 2: `public.exchange_rates`
Centralized active and historical published rates.
```sql
CREATE TABLE public.exchange_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buy_rate NUMERIC(18, 4) NOT NULL CHECK (buy_rate > 0),
    sell_rate NUMERIC(18, 4) NOT NULL CHECK (sell_rate > 0),
    currency_base TEXT NOT NULL DEFAULT 'USD',
    currency_quote TEXT NOT NULL DEFAULT 'VND',
    version BIGINT NOT NULL DEFAULT 1,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT true
);

-- Exactly ONE active rate record at any point in time
CREATE UNIQUE INDEX idx_exchange_rates_single_active 
ON public.exchange_rates (is_active) 
WHERE is_active = true;
```

### Table 3: `public.exchange_rate_history`
Immutable audit log of all changes (publish, restore, initialize).
```sql
CREATE TABLE public.exchange_rate_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buy_rate NUMERIC(18, 4) NOT NULL CHECK (buy_rate > 0),
    sell_rate NUMERIC(18, 4) NOT NULL CHECK (sell_rate > 0),
    version BIGINT NOT NULL,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    action_type TEXT NOT NULL CHECK (action_type IN ('PUBLISH', 'RESTORE', 'INITIALIZE'))
);
```

## 2. Row-Level Security (RLS) Policies
- `exchange_rates`:
  - `Public (anon)`: `SELECT` allowed only where `is_active = true`.
  - `Admins`: Full read, write access mediated by `is_authorized_admin(auth.uid())`.
- `exchange_rate_history`:
  - `Admins`: `SELECT` allowed. Modification prohibited from client-side queries.
- `admin_users`:
  - `Admins`: `SELECT` allowed.

## 3. Atomic Stored Procedures

### `publish_exchange_rate(p_buy_rate, p_sell_rate)`
- Validates caller authorization via `is_authorized_admin()`.
- Locks the current active rate row (`FOR UPDATE`) to prevent race conditions.
- Deactivates previous rate (`is_active = false`).
- Inserts new rate with `version = previous_version + 1` and `is_active = true`.
- Appends new row to `exchange_rate_history` with `action_type = 'PUBLISH'`.
- Broadcasts update via `supabase_realtime`.

### `restore_exchange_rate(p_history_id)`
- Retrieves target historical rate by UUID.
- Locks active rate and deactivates it.
- Inserts new active rate with incremented version.
- Records rollback in `exchange_rate_history` with `action_type = 'RESTORE'`.
