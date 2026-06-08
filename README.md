# PitStop

A Flutter + FastAPI social map app for discovering places in Vietnam.

## Project Structure

```text
backend/      FastAPI backend, auth API, SQLAlchemy models, Alembic migrations
frontend/     Flutter app
docs/         Documentation
infra/        Infrastructure configs
```

## Prerequisites

- Docker Desktop
- Python 3.11
- Flutter SDK
- Android SDK platform-tools for physical Android testing

The Android SDK path on a typical Windows setup is:

```powershell
C:\Users\<you>\AppData\Local\Android\sdk\platform-tools\adb.exe
```

## Backend Setup

Start local Postgres:

```powershell
cd C:\Users\nguye\pitstop\PitStop
docker compose up -d postgres
```

The local database is exposed on port `5433`:

```text
postgresql://pitstop:pitstop_dev@localhost:5433/pitstop
```

Install backend dependencies:

```powershell
cd C:\Users\nguye\pitstop\PitStop\backend
..\venv\Scripts\python.exe -m pip install -r requirements.txt
```

Run migrations:

```powershell
$env:DATABASE_URL="postgresql://pitstop:pitstop_dev@localhost:5433/pitstop"
..\venv\Scripts\python.exe -m alembic upgrade head
```

Start the backend:

```powershell
$env:DATABASE_URL="postgresql://pitstop:pitstop_dev@localhost:5433/pitstop"
..\venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

Check health:

```powershell
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8000/health
```

Check auth users:

```powershell
cd C:\Users\nguye\pitstop\PitStop
docker compose exec postgres psql -U pitstop -d pitstop -c "select email,google_sub,created_at from users order by created_at desc;"
```

## Frontend Setup

Install Flutter dependencies:

```powershell
cd C:\Users\nguye\pitstop\PitStop\frontend
flutter pub get
```

Create a local Flutter env file:

```text
frontend/.env.dev
```

Example:

```text
API_BASE_URL=http://127.0.0.1:8000/api/v1
GOOGLE_SERVER_CLIENT_ID=replace-with-web-client-id.apps.googleusercontent.com
```

Run codegen when generated files are stale:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

## Run On Android Phone With USB

Use `adb reverse` so the app can reach the backend through `127.0.0.1`.

```powershell
C:\Users\nguye\AppData\Local\Android\sdk\platform-tools\adb.exe devices
C:\Users\nguye\AppData\Local\Android\sdk\platform-tools\adb.exe reverse tcp:8000 tcp:8000
```

Then run Flutter:

```powershell
cd C:\Users\nguye\pitstop\PitStop\frontend
flutter run --dart-define-from-file=.env.dev
```

To log out during testing, clear app data:

```powershell
C:\Users\nguye\AppData\Local\Android\sdk\platform-tools\adb.exe shell pm clear com.example.pitstop
```

## Run On Android Phone Over Wi-Fi

Start backend on all interfaces:

```powershell
cd C:\Users\nguye\pitstop\PitStop\backend
$env:DATABASE_URL="postgresql://pitstop:pitstop_dev@localhost:5433/pitstop"
..\venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Allow port `8000` through Windows Firewall from an Administrator PowerShell:

```powershell
New-NetFirewallRule -DisplayName "PitStop Backend 8000" -Direction Inbound -Protocol TCP -LocalPort 8000 -Action Allow
```

Find your computer LAN IP:

```powershell
Get-NetIPAddress -AddressFamily IPv4
```

Run Flutter with that IP:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_IP:8000/api/v1 --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

## Google OAuth

Create a dedicated Google Cloud project, for example `PitStop Dev`.

In Google Cloud Console:

1. Configure `APIs & Services -> OAuth consent screen`.
2. Create an Android OAuth client:
   - Package name: `com.example.pitstop`
   - SHA-1: from `frontend/android/gradlew signingReport`
3. Create a Web OAuth client.

Use the Web client ID in both places:

Backend `.env`:

```text
GOOGLE_CLIENT_IDS=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

Flutter `.env.dev`:

```text
GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

Restart the backend after changing `.env`.

## Tests

Backend:

```powershell
cd C:\Users\nguye\pitstop\PitStop\backend
..\venv\Scripts\python.exe -m pytest
```

Frontend:

```powershell
cd C:\Users\nguye\pitstop\PitStop\frontend
flutter analyze
flutter test
```

## Current Auth Behavior

- First app open after install shows the intro/onboarding screen once.
- Email signup creates an account, then returns to the sign-in screen.
- Email login authenticates and stores access/refresh tokens.
- Token refresh runs on app startup and on backend `401` responses.
- Google login is wired, but requires valid Google OAuth setup.
- Apple login is intentionally not enabled yet.
