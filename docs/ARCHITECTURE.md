# LyHENG VND-USD — System Architecture

## 1. Architectural Overview
`LyHENG VND-USD` is architected as an offline-first, single-codebase mobile application built with Flutter, Riverpod, and Supabase. The system is partitioned into two access levels within the same application:

```
+-------------------------------------------------------------+
|                      LyHENG VND-USD                         |
+------------------------------+------------------------------+
|         PUBLIC USER          |     ADMINISTRATOR (SECURE)   |
|   (No Registration Req.)     |     (Supabase Auth + RLS)    |
| - Instant Offline Currency   | - Realtime Rate Publishing   |
|   Exchange Calculations      | - Audit History & Rollback   |
| - Realtime Central Sync      | - Atomic DB Stored Procs     |
| - VND <-> USD Direction Swap | - Strict Row-Level Security  |
+------------------------------+------------------------------+
|                   Presentation Layer                        |
|  - Material 3 (Deep Navy Blue, Clean White, Emerald Green)  |
|  - Custom Financial Keypad & Responsive Dynamic Dashboards  |
|  - Multilingual Engine (Vietnamese, Khmer, English)         |
+-------------------------------------------------------------+
|                     State Management                        |
|  - Riverpod Notifiers & Realtime Stream Providers           |
|  - GoRouter Role-Guarded Navigation                         |
+-------------------------------------------------------------+
|                      Domain Engine                          |
|  - High-Precision Decimal & Rational Arithmetic             |
|  - Zero Binary Floating-Point Rounding Tolerance            |
+-------------------------------------------------------------+
|                   Data & Persistence Layer                  |
|  - Local SQLite Cache (sqflite) with Version Protection     |
|  - SharedPreferences for Language & Theme Preferences       |
|  - Supabase Realtime WebSocket Listener (Postgres Changes)  |
+-------------------------------------------------------------+
|                     Supabase Backend                        |
|  - PostgreSQL Database Tables (exchange_rates, admin_users) |
|  - Atomic Functions (publish_exchange_rate, restore_...)   |
|  - Strict Row-Level Security (RLS) & Security Definer Checks|
+-------------------------------------------------------------+
```

## 2. Directory Structure
```
lib/
├── app/
│   ├── app.dart               # Root MaterialApp with l10n and themes
│   └── router.dart            # Role-guarded GoRouter route configuration
├── core/
│   ├── constants/             # AppColors, AppConstants
│   ├── errors/                # AppException hierarchy
│   ├── localization/          # ARB translations & LocaleNotifier
│   ├── theme/                 # Light & Dark Material 3 themes
│   └── utils/                 # CurrencyFormatter, DateFormatter
├── data/
│   ├── local/                 # LocalDatabaseService (SQLite), PreferencesService
│   ├── models/                # ExchangeRate, ExchangeRateHistory, AdminUser
│   ├── repositories/          # ExchangeRateRepository, AuthRepository
│   └── services/              # SupabaseService, ConnectivityService
├── features/
│   ├── admin/                 # Dashboard, Edit, Preview, Profile
│   ├── authentication/        # Admin Login
│   ├── calculator/            # Calculation Engine, Custom Keypad, Main Screen
│   ├── exchange_rates/        # Rate Details Screen
│   ├── history/               # Audit History & Version Rollback
│   ├── settings/              # Language & Application Settings, About
│   └── splash/                # Splash Screen with animated branding
├── shared/
│   └── widgets/               # AppCard, AppButton, StatusBanner, AppLogo
└── main.dart                  # Application Entrypoint
```

## 3. High-Precision Financial Calculations
All currency transformations strictly utilize the `decimal` and `rational` packages:
- **Feature A (USD to VND - Customer sells USD)**:
  `VND = USD Amount × BUY RATE`
- **Feature B (VND to USD - Customer buys USD)**:
  `USD = VND Amount ÷ SELL RATE`
  Uses exact Rational math: `(amount * 100 / sellRate).round() / 100` to round to nearest cent half-up without binary float drift.
