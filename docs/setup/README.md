# Setup Guide

## Backend

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# Edit .env
alembic upgrade head
uvicorn app.main:app --reload
```

Or with Docker:
```bash
docker-compose up -d
```

## Mobile

```bash
cd mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Required APIs

- Google Maps API key
- Firebase project
- Cloudflare R2 bucket
- OAuth credentials (Google, Apple)

Add credentials to `backend/.env`
