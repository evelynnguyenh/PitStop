# PitStop Architecture

## System Overview

```
┌─────────────────┐
│   Mobile App    │
│   (Flutter)     │
└────────┬────────┘
         │
         │ HTTPS/REST
         │
┌────────▼────────┐
│   FastAPI       │
│   Backend       │
└───┬───┬───┬───┬┘
    │   │   │   │
    │   │   │   └──────┐
    │   │   │          │
    │   │   │      ┌───▼─────┐
    │   │   │      │  Redis  │
    │   │   │      └─────────┘
    │   │   │
    │   │   │      ┌──────────┐
    │   │   └──────►  Celery  │
    │   │          └──────────┘
    │   │
    │   │          ┌─────────────┐
    │   └──────────► PostgreSQL  │
    │              │  + PostGIS  │
    │              └─────────────┘
    │
    │              ┌──────────────┐
    └──────────────► Cloudflare   │
                   │  R2 + CDN    │
                   └──────────────┘
```

## Data Flow Examples

### Post Creation
```
User → Flutter App → Upload Image to R2 (presigned URL)
                  → Create Post API → PostgreSQL
                  → Update Feed Cache → Redis
```

### Nearby Search
```
User Location → Flutter App → Nearby API
                            → PostGIS Query (ST_DWithin)
                            → Return Sorted Results
```

### Random Place Finder
```
User Filters → Random API → PostgreSQL Query
                          → Weighted Random Selection
                          → Return Place Details
```

## Security

- JWT-based authentication with refresh tokens
- OAuth integration (Google, Apple)
- Presigned URLs for secure image uploads
- HTTPS enforced for all communications
- Rate limiting on API endpoints

## Scalability

**Current (MVP)**: Single backend instance, managed DB, Redis, CDN  
**Future**: Load balancer, read replicas, separate Celery workers