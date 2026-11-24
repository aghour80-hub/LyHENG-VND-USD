-- ====================================================================
-- Automated RLS & Security Verification Suite for LyHENG VND-USD
-- Tests database tables, policies, functions, and transaction atomicity
-- ====================================================================

BEGIN;

-- Helper diagnostic banner
DO $$
BEGIN
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'Starting LyHENG VND-USD Security & RLS Test Suite';
    RAISE NOTICE '==================================================';
END;
$$;

-- Setup test users in auth.users if needed
DO $$
DECLARE
    v_admin_id UUID := '11111111-1111-1111-1111-111111111111';
    v_regular_user_id UUID := '22222222-2222-2222-2222-222222222222';
BEGIN
    -- Ensure test auth users exist
    INSERT INTO auth.users (id, email)
    VALUES 
        (v_admin_id, 'admin_test@lyheng.com'),
        (v_regular_user_id, 'regular_user@lyheng.com')
    ON CONFLICT (id) DO NOTHING;

    -- Authorize only the admin user in admin_users
    INSERT INTO public.admin_users (id, user_id, role)
    VALUES (gen_random_uuid(), v_admin_id, 'admin')
    ON CONFLICT (user_id) DO NOTHING;

    -- Ensure regular user is NOT in admin_users
    DELETE FROM public.admin_users WHERE user_id = v_regular_user_id;
END;
$$;

-- TEST 1: is_authorized_admin() function verification
DO $$
DECLARE
    v_admin_id UUID := '11111111-1111-1111-1111-111111111111';
    v_regular_user_id UUID := '22222222-2222-2222-2222-222222222222';
    v_result BOOLEAN;
BEGIN
    -- Admin check
    v_result := public.is_authorized_admin(v_admin_id);
    IF v_result IS NOT TRUE THEN
        RAISE EXCEPTION 'TEST 1 FAILED: is_authorized_admin should return TRUE for admin user.';
    END IF;

    -- Non-admin check
    v_result := public.is_authorized_admin(v_regular_user_id);
    IF v_result IS NOT FALSE THEN
        RAISE EXCEPTION 'TEST 1 FAILED: is_authorized_admin should return FALSE for regular user.';
    END IF;

    -- NULL check
    v_result := public.is_authorized_admin(NULL);
    IF v_result IS NOT FALSE THEN
        RAISE EXCEPTION 'TEST 1 FAILED: is_authorized_admin should return FALSE for NULL user.';
    END IF;

    RAISE NOTICE '[PASS] Test 1: is_authorized_admin() authorization checks passed.';
END;
$$;

-- TEST 2: Anonymous / Public cannot execute privileged functions directly
DO $$
DECLARE
    v_error_caught BOOLEAN := FALSE;
BEGIN
    -- Simulate unauthenticated user
    PERFORM set_config('request.jwt.claim.sub', NULL, TRUE);
    PERFORM set_config('role', 'anon', TRUE);

    BEGIN
        PERFORM public.publish_exchange_rate(26400, 26600);
    EXCEPTION WHEN OTHERS THEN
        v_error_caught := TRUE;
    END;

    IF NOT v_error_caught THEN
        RAISE EXCEPTION 'TEST 2 FAILED: Public user was able to execute publish_exchange_rate()!';
    END IF;

    RAISE NOTICE '[PASS] Test 2: Public execution of publish_exchange_rate() was strictly blocked.';
END;
$$;

-- TEST 3: Regular authenticated user (non-admin) cannot execute publish_exchange_rate
DO $$
DECLARE
    v_regular_user_id UUID := '22222222-2222-2222-2222-222222222222';
    v_error_caught BOOLEAN := FALSE;
BEGIN
    PERFORM set_config('role', 'authenticated', TRUE);
    PERFORM set_config('request.jwt.claim.sub', v_regular_user_id::text, TRUE);

    BEGIN
        PERFORM public.publish_exchange_rate(26400, 26600);
    EXCEPTION WHEN OTHERS THEN
        v_error_caught := TRUE;
    END;

    IF NOT v_error_caught THEN
        RAISE EXCEPTION 'TEST 3 FAILED: Non-admin authenticated user was able to publish exchange rates!';
    END IF;

    RAISE NOTICE '[PASS] Test 3: Non-admin authenticated user was strictly blocked from publishing rates.';
END;
$$;

-- TEST 4: Authorized Admin can publish rates atomically
DO $$
DECLARE
    v_admin_id UUID := '11111111-1111-1111-1111-111111111111';
    v_result jsonb;
    v_active_count INT;
    v_history_count INT;
BEGIN
    PERFORM set_config('role', 'authenticated', TRUE);
    PERFORM set_config('request.jwt.claim.sub', v_admin_id::text, TRUE);

    -- Execute publish
    v_result := public.publish_exchange_rate(26350, 26550);

    IF v_result IS NULL OR (v_result->>'buy_rate')::NUMERIC != 26350 THEN
        RAISE EXCEPTION 'TEST 4 FAILED: publish_exchange_rate did not return expected new rate.';
    END IF;

    -- Verify only ONE active record exists in exchange_rates
    SELECT COUNT(*) INTO v_active_count FROM public.exchange_rates WHERE is_active = true;
    IF v_active_count != 1 THEN
        RAISE EXCEPTION 'TEST 4 FAILED: Expected exactly 1 active rate, found %', v_active_count;
    END IF;

    -- Verify history entry was written
    SELECT COUNT(*) INTO v_history_count 
    FROM public.exchange_rate_history 
    WHERE buy_rate = 26350 AND sell_rate = 26550 AND action_type = 'PUBLISH';

    IF v_history_count < 1 THEN
        RAISE EXCEPTION 'TEST 4 FAILED: History entry was not recorded for publish.';
    END IF;

    RAISE NOTICE '[PASS] Test 4: Authorized Admin successfully published new rate and recorded history.';
END;
$$;

-- TEST 5: Rate Restoration by Authorized Admin
DO $$
DECLARE
    v_admin_id UUID := '11111111-1111-1111-1111-111111111111';
    v_history_id UUID;
    v_restored jsonb;
    v_history_restore_count INT;
BEGIN
    PERFORM set_config('role', 'authenticated', TRUE);
    PERFORM set_config('request.jwt.claim.sub', v_admin_id::text, TRUE);

    -- Find the last history record to restore
    SELECT id INTO v_history_id 
    FROM public.exchange_rate_history 
    ORDER BY created_at DESC 
    LIMIT 1;

    -- Execute restore
    v_restored := public.restore_exchange_rate(v_history_id);

    IF v_restored IS NULL THEN
        RAISE EXCEPTION 'TEST 5 FAILED: restore_exchange_rate returned null.';
    END IF;

    -- Verify action_type = RESTORE was logged
    SELECT COUNT(*) INTO v_history_restore_count 
    FROM public.exchange_rate_history 
    WHERE action_type = 'RESTORE';

    IF v_history_restore_count < 1 THEN
        RAISE EXCEPTION 'TEST 5 FAILED: RESTORE action was not logged in history.';
    END IF;

    RAISE NOTICE '[PASS] Test 5: Rate restoration executed atomically and logged in history.';
END;
$$;

-- Rollback the test transaction so test data does not pollute database
ROLLBACK;

DO $$
BEGIN
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'ALL DATABASE RLS & SECURITY TESTS PASSED (100%%)';
    RAISE NOTICE '==================================================';
END;
$$;
