-- Seed data for LyHENG VND-USD

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

-- 3. Default Admin User (Username: lyheng / Email: lyheng@lyheng.com / Password: Lyheng168)
DO $$
DECLARE
    v_admin_uuid UUID := 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
BEGIN
    -- Insert user into auth.users if not already exists
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'lyheng@lyheng.com') THEN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            role,
            aud
        ) VALUES (
            v_admin_uuid,
            '00000000-0000-0000-0000-000000000000',
            'lyheng@lyheng.com',
            crypt('Lyheng168', gen_salt('bf')),
            timezone('utc'::text, now()),
            '{"provider":"email","providers":["email"]}',
            '{"username":"lyheng"}',
            timezone('utc'::text, now()),
            timezone('utc'::text, now()),
            'authenticated',
            'authenticated'
        );

        INSERT INTO auth.identities (
            id,
            user_id,
            identity_data,
            provider,
            last_sign_in_at,
            created_at,
            updated_at
        ) VALUES (
            v_admin_uuid,
            v_admin_uuid,
            format('{"sub":"%s","email":"%s"}', v_admin_uuid::text, 'lyheng@lyheng.com')::jsonb,
            'email',
            timezone('utc'::text, now()),
            timezone('utc'::text, now()),
            timezone('utc'::text, now())
        );
    ELSE
        SELECT id INTO v_admin_uuid FROM auth.users WHERE email = 'lyheng@lyheng.com';
    END IF;

    -- Grant Admin Role in public.admin_users
    INSERT INTO public.admin_users (user_id, role)
    VALUES (v_admin_uuid, 'admin')
    ON CONFLICT (user_id) DO NOTHING;
END $$;
