from functools import lru_cache
from typing import Any

import httpx
from fastapi import HTTPException, status
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token
from jose import JWTError, jwt

from app.core.config import settings


class GoogleTokenVerifier:
    def verify(self, id_token: str) -> dict[str, Any]:
        if not settings.GOOGLE_CLIENT_IDS:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Google auth is not configured",
            )

        last_error: Exception | None = None
        for client_id in settings.GOOGLE_CLIENT_IDS:
            try:
                payload = google_id_token.verify_oauth2_token(
                    id_token,
                    google_requests.Request(),
                    client_id,
                )
                if payload.get("email_verified") is False:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="Google email is not verified",
                    )
                return payload
            except HTTPException:
                raise
            except (
                Exception
            ) as exc:  # google-auth raises multiple validation exceptions
                last_error = exc

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google token",
        ) from last_error


class AppleTokenVerifier:
    jwks_url = "https://appleid.apple.com/auth/keys"

    def verify(self, identity_token: str) -> dict[str, Any]:
        if not settings.APPLE_CLIENT_ID:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Apple auth is not configured",
            )

        try:
            header = jwt.get_unverified_header(identity_token)
            key = self._find_key(header.get("kid"))
            return jwt.decode(
                identity_token,
                key,
                algorithms=["RS256"],
                audience=settings.APPLE_CLIENT_ID,
                issuer="https://appleid.apple.com",
            )
        except JWTError as exc:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid Apple token",
            ) from exc

    def _find_key(self, kid: str | None) -> dict[str, Any]:
        if not kid:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Apple token"
            )

        for key in get_apple_jwks().get("keys", []):
            if key.get("kid") == kid:
                return key
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Apple token"
        )


@lru_cache(maxsize=1)
def get_apple_jwks() -> dict[str, Any]:
    response = httpx.get(AppleTokenVerifier.jwks_url, timeout=10)
    response.raise_for_status()
    return response.json()


google_token_verifier = GoogleTokenVerifier()
apple_token_verifier = AppleTokenVerifier()
