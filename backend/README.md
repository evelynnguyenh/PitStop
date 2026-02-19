# PitStop Backend

FastAPI-based backend for PitStop - A social map app for discovering places in Vietnam.

## Tech Stack

- **Framework**: FastAPI
- **Database**: PostgreSQL + PostGIS
- **ORM**: SQLAlchemy + Alembic
- **Auth**: JWT + OAuth (Google, Apple)
- **Background Jobs**: Celery + Redis
- **Storage**: Cloudflare R2 (S3-compatible)

## Project Structure

```
app/
├── api/
│   └── v1/
│       ├── endpoints/     # API endpoints
│       └── dependencies/  # Route dependencies
├── core/                  # Core configuration
├── models/                # SQLAlchemy models
├── schemas/               # Pydantic schemas
├── services/              # Business logic
├── repositories/          # Data access layer
├── db/                    # Database setup
├── tasks/                 # Celery tasks
├── utils/                 # Utility functions
└── middleware/            # Custom middleware
```

## Setup

1. Create virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create `.env` file with required environment variables (see `.env.example`)

4. Run database migrations:
   ```bash
   alembic upgrade head
   ```

5. Start the server:
   ```bash
   uvicorn app.main:app --reload
   ```

## API Documentation

Once running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Key Features

- 🔐 JWT-based authentication with refresh tokens
- 🌍 PostGIS for geospatial queries
- 📸 Presigned URL uploads to R2
- 🔄 Background job processing with Celery
- 📊 Cursor-based pagination
- ⚡ Rate limiting
- 📝 Structured logging

## Endpoints (Planned)

- `/api/v1/auth` - Authentication
- `/api/v1/users` - User management
- `/api/v1/places` - Places CRUD & nearby search
- `/api/v1/posts` - Social feed posts
- `/api/v1/reviews` - Reviews & ratings
- `/api/v1/random` - Random place finder
- `/api/v1/streak` - User streaks
