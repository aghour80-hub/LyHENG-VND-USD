-- Migration: 20261124_000001_initial_schema.sql
-- Application: LyHENG VND-USD
-- Creates core tables: exchange_rates, admin_users, exchange_rate_history

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ====================================================================
-- TABLE 1: admin_users
-- Stores explicit admin authorization linked to Supabase auth.users
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'superadmin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Index on user_id for rapid auth verification
CREATE INDEX IF NOT EXISTS idx_admin_users_user_id ON public.admin_users(user_id);

-- ====================================================================
-- TABLE 2: exchange_rates
-- Centralized published active exchange rates
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.exchange_rates (
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

-- Ensure only ONE active rate record can exist at any time
CREATE UNIQUE INDEX IF NOT EXISTS idx_exchange_rates_single_active 
ON public.exchange_rates (is_active) 
WHERE is_active = true;

-- Additional indexes
CREATE INDEX IF NOT EXISTS idx_exchange_rates_version ON public.exchange_rates(version DESC);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_updated_at ON public.exchange_rates(updated_at DESC);

-- ====================================================================
-- TABLE 3: exchange_rate_history
-- Full audit trail of published and restored rates
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.exchange_rate_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buy_rate NUMERIC(18, 4) NOT NULL CHECK (buy_rate > 0),
    sell_rate NUMERIC(18, 4) NOT NULL CHECK (sell_rate > 0),
    version BIGINT NOT NULL,
    updated_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    action_type TEXT NOT NULL CHECK (action_type IN ('PUBLISH', 'RESTORE', 'INITIALIZE'))
);

CREATE INDEX IF NOT EXISTS idx_exchange_rate_history_version ON public.exchange_rate_history(version DESC);
CREATE INDEX IF NOT EXISTS idx_exchange_rate_history_created_at ON public.exchange_rate_history(created_at DESC);
