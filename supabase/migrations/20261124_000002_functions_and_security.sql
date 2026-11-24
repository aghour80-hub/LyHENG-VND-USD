-- Migration: 20261124_000002_functions_and_security.sql
-- Application: LyHENG VND-USD
-- RLS policies and secure atomic PostgreSQL functions

-- ====================================================================
-- 1. ENABLE ROW LEVEL SECURITY
-- ====================================================================
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exchange_rate_history ENABLE ROW LEVEL SECURITY;

-- ====================================================================
-- 2. HELPER FUNCTION: is_authorized_admin()
-- Verifies if the authenticated caller is present in admin_users
-- ====================================================================
CREATE OR REPLACE FUNCTION public.is_authorized_admin(p_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
BEGIN
    IF p_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN EXISTS (
        SELECT 1 
        FROM public.admin_users 
        WHERE user_id = p_user_id
    );
END;
$$;

-- Revoke default public execution, grant only to authenticated users
REVOKE EXECUTE ON FUNCTION public.is_authorized_admin(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_authorized_admin(UUID) TO authenticated, service_role;

-- ====================================================================
-- 3. ROW LEVEL SECURITY POLICIES
-- ====================================================================

-- 3A. exchange_rates POLICIES:
-- Public can READ active rates only
CREATE POLICY "Public users can view active exchange rates"
ON public.exchange_rates
FOR SELECT
TO public
USING (is_active = true);

-- Admins can view all rates (active or archived)
CREATE POLICY "Admins can view all exchange rates"
ON public.exchange_rates
FOR SELECT
TO authenticated
USING (public.is_authorized_admin(auth.uid()));

-- Only Admins can insert/update rates directly if needed
CREATE POLICY "Admins can modify exchange rates"
ON public.exchange_rates
FOR ALL
TO authenticated
USING (public.is_authorized_admin(auth.uid()))
WITH CHECK (public.is_authorized_admin(auth.uid()));

-- 3B. admin_users POLICIES:
-- Admins can read admin records
CREATE POLICY "Admins can view admin users"
ON public.admin_users
FOR SELECT
TO authenticated
USING (public.is_authorized_admin(auth.uid()));

-- Superadmins can manage admin records
CREATE POLICY "Superadmins can manage admin users"
ON public.admin_users
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.admin_users 
        WHERE user_id = auth.uid() AND role = 'superadmin'
    )
);

-- 3C. exchange_rate_history POLICIES:
-- Only authenticated Admins can view history
CREATE POLICY "Admins can view exchange rate history"
ON public.exchange_rate_history
FOR SELECT
TO authenticated
USING (public.is_authorized_admin(auth.uid()));

-- No public modification permitted on history

-- ====================================================================
-- 4. ATOMIC FUNCTION: publish_exchange_rate()
-- ====================================================================
CREATE OR REPLACE FUNCTION public.publish_exchange_rate(
    p_buy_rate NUMERIC,
    p_sell_rate NUMERIC
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_caller_id UUID;
    v_current_version BIGINT := 0;
    v_next_version BIGINT := 1;
    v_new_rate_id UUID;
    v_result jsonb;
BEGIN
    v_caller_id := auth.uid();

    -- Authorization check
    IF NOT public.is_authorized_admin(v_caller_id) THEN
        RAISE EXCEPTION 'Access denied. Caller is not an authorized administrator.';
    END IF;

    -- Validation
    IF p_buy_rate IS NULL OR p_buy_rate <= 0 THEN
        RAISE EXCEPTION 'Invalid buy_rate. Must be greater than zero.';
    END IF;

    IF p_sell_rate IS NULL OR p_sell_rate <= 0 THEN
        RAISE EXCEPTION 'Invalid sell_rate. Must be greater than zero.';
    END IF;

    -- Lock the active row to prevent concurrent race condition updates
    SELECT version INTO v_current_version
    FROM public.exchange_rates
    WHERE is_active = true
    FOR UPDATE;

    IF v_current_version IS NOT NULL THEN
        v_next_version := v_current_version + 1;
        -- Deactivate previous active rate
        UPDATE public.exchange_rates
        SET is_active = false
        WHERE is_active = true;
    END IF;

    -- Insert new active rate
    INSERT INTO public.exchange_rates (
        buy_rate,
        sell_rate,
        currency_base,
        currency_quote,
        version,
        updated_at,
        updated_by,
        is_active
    ) VALUES (
        p_buy_rate,
        p_sell_rate,
        'USD',
        'VND',
        v_next_version,
        timezone('utc'::text, now()),
        v_caller_id,
        true
    ) RETURNING id INTO v_new_rate_id;

    -- Record in audit history
    INSERT INTO public.exchange_rate_history (
        buy_rate,
        sell_rate,
        version,
        updated_by,
        created_at,
        action_type
    ) VALUES (
        p_buy_rate,
        p_sell_rate,
        v_next_version,
        v_caller_id,
        timezone('utc'::text, now()),
        'PUBLISH'
    );

    SELECT jsonb_build_object(
        'id', id,
        'buy_rate', buy_rate,
        'sell_rate', sell_rate,
        'currency_base', currency_base,
        'currency_quote', currency_quote,
        'version', version,
        'updated_at', updated_at,
        'updated_by', updated_by,
        'is_active', is_active
    ) INTO v_result
    FROM public.exchange_rates
    WHERE id = v_new_rate_id;

    RETURN v_result;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.publish_exchange_rate(NUMERIC, NUMERIC) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.publish_exchange_rate(NUMERIC, NUMERIC) TO authenticated, service_role;

-- ====================================================================
-- 5. ATOMIC FUNCTION: restore_exchange_rate()
-- ====================================================================
CREATE OR REPLACE FUNCTION public.restore_exchange_rate(
    p_history_id UUID
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
    v_caller_id UUID;
    v_target_buy NUMERIC;
    v_target_sell NUMERIC;
    v_target_version BIGINT;
    v_current_version BIGINT := 0;
    v_next_version BIGINT := 1;
    v_new_rate_id UUID;
    v_result jsonb;
BEGIN
    v_caller_id := auth.uid();

    -- Authorization check
    IF NOT public.is_authorized_admin(v_caller_id) THEN
        RAISE EXCEPTION 'Access denied. Caller is not an authorized administrator.';
    END IF;

    -- Retrieve target history record
    SELECT buy_rate, sell_rate, version
    INTO v_target_buy, v_target_sell, v_target_version
    FROM public.exchange_rate_history
    WHERE id = p_history_id;

    IF v_target_buy IS NULL THEN
        RAISE EXCEPTION 'History record with ID % not found.', p_history_id;
    END IF;

    -- Lock active rate
    SELECT version INTO v_current_version
    FROM public.exchange_rates
    WHERE is_active = true
    FOR UPDATE;

    IF v_current_version IS NOT NULL THEN
        v_next_version := v_current_version + 1;
        UPDATE public.exchange_rates
        SET is_active = false
        WHERE is_active = true;
    END IF;

    -- Insert restored rate with new incremental version
    INSERT INTO public.exchange_rates (
        buy_rate,
        sell_rate,
        currency_base,
        currency_quote,
        version,
        updated_at,
        updated_by,
        is_active
    ) VALUES (
        v_target_buy,
        v_target_sell,
        'USD',
        'VND',
        v_next_version,
        timezone('utc'::text, now()),
        v_caller_id,
        true
    ) RETURNING id INTO v_new_rate_id;

    -- Record restoration in audit history
    INSERT INTO public.exchange_rate_history (
        buy_rate,
        sell_rate,
        version,
        updated_by,
        created_at,
        action_type
    ) VALUES (
        v_target_buy,
        v_target_sell,
        v_next_version,
        v_caller_id,
        timezone('utc'::text, now()),
        'RESTORE'
    );

    SELECT jsonb_build_object(
        'id', id,
        'buy_rate', buy_rate,
        'sell_rate', sell_rate,
        'currency_base', currency_base,
        'currency_quote', currency_quote,
        'version', version,
        'updated_at', updated_at,
        'updated_by', updated_by,
        'is_active', is_active
    ) INTO v_result
    FROM public.exchange_rates
    WHERE id = v_new_rate_id;

    RETURN v_result;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.restore_exchange_rate(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.restore_exchange_rate(UUID) TO authenticated, service_role;

-- ====================================================================
-- 6. REALTIME REPLICATION ENABLEMENT
-- ====================================================================
-- Set REPLICA IDENTITY FULL to ensure all columns are broadcast on updates
ALTER TABLE public.exchange_rates REPLICA IDENTITY FULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'exchange_rates'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.exchange_rates;
    END IF;
END;
$$;
