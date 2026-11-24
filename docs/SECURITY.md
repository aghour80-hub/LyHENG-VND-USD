# Security & Threat Model — LyHENG VND-USD

## 1. Zero Trust Client Principles
- Client applications are treated as untrusted. Hiding buttons in the Flutter UI does not constitute security.
- All authorization checks are enforced inside PostgreSQL via Row Level Security (RLS) and `SECURITY DEFINER` functions with safe `search_path = public, auth, pg_temp`.

## 2. API Key Management
- The Flutter client utilizes **SUPABASE_URL** and **SUPABASE_PUBLISHABLE_KEY** (formerly known as `anon_key`).
- **NEVER** expose the Supabase `service_role` key, database password, or master credentials inside the mobile application.
- Configuration is provided through `--dart-define-from-file=config/dev.json`.
- `config/dev.json` is listed in `.gitignore` to prevent leaking keys to version control.

## 3. Administrative Authorization
To prevent privilege escalation:
1. Public signups cannot grant Admin roles.
2. A user becomes an Administrator **only** when their UUID exists in `public.admin_users`.
3. The PostgreSQL function `is_authorized_admin(UUID)` executes with `SECURITY DEFINER` and checks membership in `admin_users`.
4. Stored procedures `publish_exchange_rate` and `restore_exchange_rate` reject unauthorized callers immediately.

## 4. Race Condition & Concurrency Hardening
- Multiple administrators editing rates concurrently cannot corrupt the rate sequence.
- Publishing operations use `SELECT ... FOR UPDATE` row locks inside PostgreSQL transactions, guaranteeing strictly monotonic version increments (`v1` -> `v2` -> `v3`).
