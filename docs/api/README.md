# API Endpoints

Base: `/api/v1`

## Auth
```
POST /auth/register
POST /auth/login
POST /auth/google
POST /auth/apple
POST /auth/refresh
```

## Users
```
GET    /users/me
GET    /users/{id}
GET    /users/{id}/posts
```

## Places
```
GET    /places/nearby?lat={lat}&lng={lng}&radius={km}
GET    /places/{id}
POST   /places
```

## Posts
```
GET    /posts?limit=20&cursor={cursor}
POST   /posts
PUT    /posts/{id}
DELETE /posts/{id}
```

## Random
```
POST   /random/place
```
