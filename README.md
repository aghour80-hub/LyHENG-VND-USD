# LyHENG VND-USD — Complete Mobile Application

A production-ready currency exchange calculator for **USD** and **VND** with real-time central synchronization and role-based administration, built using **Flutter**, **Riverpod**, and **Supabase**.

---

## Key Highlights

- **Dual Access Levels, Single Application**:
  - **Public Users**: No login required. Instant access to offline-first currency calculations, live buy/sell rates, and one-tap direction swapping.
  - **Authorized Administrators**: Secure login via Supabase Authentication and PostgreSQL Row-Level Security (RLS) to edit, preview, publish, and rollback rates.
- **Centralized Database & Real-Time Sync**:
  - Admin changes rates on their mobile device; all connected public devices receive updates immediately via Supabase Realtime WebSockets.
  - Offline devices automatically use cached rates with a stale-rate warning and sync automatically when internet connectivity returns.
- **High-Precision Financial Arithmetic**:
  - Calculations are executed using the `decimal` and `rational` libraries. Zero binary floating-point rounding errors.
  - **VND = USD × BUY RATE** (Customer sells USD to shop)
  - **USD = VND ÷ SELL RATE** (Customer buys USD from shop)
- **Multilingual Support**:
  - **Vietnamese (Tiếng Việt)** — Default
  - **Khmer (ខ្មែរ)**
  - **English**
- **Offline-First Persistence**:
  - Embedded local **SQLite** database (`sqflite`) caches active rates and audit history with version conflict protection.
- **Premium Financial Design**:
  - Material 3 theme in Deep Navy Blue (`#0F172A`), Emerald Green (`#059669`), and Coral Red (`#E11D48`).
  - Dark mode and Light mode support with a custom responsive keypad.

---

## Architecture & Technology Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.50.0 (Channel stable) |
| **Language** | Dart 3.14.0+ |
| **State Management** | Riverpod 3.x (`NotifierProvider`, `StreamProvider`) |
| **Navigation** | GoRouter (Protected route guards) |
| **Backend & Realtime** | Supabase (PostgreSQL, Auth, Realtime, RLS) |
| **Local Storage** | SQLite (`sqflite`), `shared_preferences` |
| **Financial Engine** | `decimal`, `rational` |
| **Testing** | Flutter Test, Widget Tester, Mocktail |

---

## Documentation Index

- [Architecture & Design Details](file:///docs/ARCHITECTURE.md)
- [Database Schema & Migrations](file:///docs/DATABASE.md)
- [Security & Threat Model](file:///docs/SECURITY.md)
- [Administrator User Guide](file:///docs/ADMIN_GUIDE.md)
- [Android & iOS Build Guide](file:///docs/BUILD_GUIDE.md)

---

## Getting Started

### 1. Prerequisites
- Windows 11, macOS, or Linux
- Flutter SDK 3.50.0+
- Android Studio / Android SDK 34+
- A Supabase Project (Free or Pro tier)

### 2. Configure Supabase Backend
1. In your Supabase Dashboard, open the **SQL Editor**.
2. Run the migration scripts in sequential order:
   - `supabase/migrations/20261124_000001_initial_schema.sql`
   - `supabase/migrations/20261124_000002_functions_and_security.sql`
3. Optionally run `supabase/seed.sql` to populate initial baseline exchange rates.
4. Setup your first Admin account as documented in [docs/ADMIN_GUIDE.md](file:///docs/ADMIN_GUIDE.md).

### 3. Local Environment Configuration
Copy the configuration template:
```bash
cp config/dev.json.example config/dev.json
```
Populate `config/dev.json` with your project URL and publishable key:
```json
{
  "SUPABASE_URL": "https://your-project-id.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```
*(Note: If `config/dev.json` contains placeholder values, the app automatically runs in DEMO mode with safe fallback rates).*

---

## Running the Application

To run the application on a connected device or emulator with your configuration:
```bash
flutter run --dart-define-from-file=config/dev.json
```

---

## Automated Testing

Execute the complete test suite (unit tests and widget tests):
```bash
flutter test
```

Execute static code analysis:
```bash
flutter analyze
```

---

## Build Commands

### Android APK (Debug)
```bash
flutter build apk --debug --dart-define-from-file=config/dev.json
```

### Android APK (Release)
```bash
flutter build apk --release --dart-define-from-file=config/dev.json
```

### Android App Bundle (AAB - Play Store)
```bash
flutter build appbundle --release --dart-define-from-file=config/dev.json
```

### iOS Release (Requires macOS & Xcode)
```bash
flutter build ipa --release --dart-define-from-file=config/dev.json
```

---

## Disclaimer
LyHENG VND-USD is an exchange rate calculator and reference tool only. The application does not provide money transfer or financial payment processing services.

Licensed by LyHENG. All rights reserved.
