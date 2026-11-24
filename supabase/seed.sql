-- Seed data for LyHENG VND-USD
-- Note: Replace '<YOUR_ADMIN_USER_UUID>' with the actual UUID created in auth.users
-- via Supabase Dashboard or CLI.

-- 1. Initial Published Exchange Rate
INSERT INTO public.exchange_rates (
    buy_rate,
    sell_rate,
    currency_base,
    currency_quote,
    version,
    updated_at,
    is_active
) VALUES (
    26300.0000,
    26500.0000,
    'USD',
    'VND',
    1,
    timezone('utc'::text, now()),
    true
)
ON CONFLICT (is_active) WHERE is_active = true
DO UPDATE SET
    buy_rate = EXCLUDED.buy_rate,
    sell_rate = EXCLUDED.sell_rate,
    version = EXCLUDED.version,
    updated_at = EXCLUDED.updated_at;

-- 2. Initial History Record
INSERT INTO public.exchange_rate_history (
    buy_rate,
    sell_rate,
    version,
    created_at,
    action_type
) VALUES (
    26300.0000,
    26500.0000,
    1,
    timezone('utc'::text, now()),
    'INITIALIZE'
);
