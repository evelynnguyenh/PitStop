from datetime import datetime, timedelta, timezone
from urllib.parse import urlencode

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_random_token,
    get_password_hash,
    hash_token,
    utc_now,
    verify_password,
)
from app.models.user import PasswordResetToken, RefreshToken, User
from app.schemas.auth import AuthResponse
from app.services.email import email_service


def normalize_email(email: str) -> str:
    return email.strip().lower()


def _is_past(value: datetime) -> bool:
    if value.tzinfo is None:
        value = value.replace(tzinfo=timezone.utc)
    return value <= utc_now()


class AuthService:
    def register(
        self,
        db: Session,
        *,
        email: str,
        password: str,
        user_agent: str | None,
        ip_address: str | None,
    ) -> AuthResponse:
        normalized_email = normalize_email(email)
        existing = self.get_user_by_email(db, normalized_email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email is already registered",
            )

        user = User(email=normalized_email, hashed_password=get_password_hash(password))
        db.add(user)
        db.flush()
        return self._issue_auth_response(
            db,
            user=user,
            is_new_user=True,
            user_agent=user_agent,
            ip_address=ip_address,
        )

    def login(
        self,
        db: Session,
        *,
        email: str,
        password: str,
        user_agent: str | None,
        ip_address: str | None,
    ) -> AuthResponse:
        user = self.get_user_by_email(db, normalize_email(email))
        if (
            not user
            or not user.hashed_password
            or not verify_password(password, user.hashed_password)
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="User account is inactive"
            )
        return self._issue_auth_response(
            db,
            user=user,
            is_new_user=False,
            user_agent=user_agent,
            ip_address=ip_address,
        )

    def authenticate_google(
        self,
        db: Session,
        *,
        google_sub: str,
        email: str,
        display_name: str | None,
        user_agent: str | None,
        ip_address: str | None,
    ) -> AuthResponse:
        user = db.scalar(select(User).where(User.google_sub == google_sub))
        is_new_user = False
        normalized_email = normalize_email(email)

        if not user:
            user = self.get_user_by_email(db, normalized_email)
            if user:
                user.google_sub = google_sub
                if display_name and not user.display_name:
                    user.display_name = display_name
            else:
                user = User(
                    email=normalized_email,
                    display_name=display_name,
                    google_sub=google_sub,
                )
                db.add(user)
                db.flush()
                is_new_user = True

        return self._issue_auth_response(
            db,
            user=user,
            is_new_user=is_new_user,
            user_agent=user_agent,
            ip_address=ip_address,
        )

    def authenticate_apple(
        self,
        db: Session,
        *,
        apple_sub: str,
        email: str | None,
        user_agent: str | None,
        ip_address: str | None,
    ) -> AuthResponse:
        user = db.scalar(select(User).where(User.apple_sub == apple_sub))
        is_new_user = False

        if not user:
            if not email:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Apple email is required for first sign-in",
                )
            user = self.get_user_by_email(db, normalize_email(email))
            if user:
                user.apple_sub = apple_sub
            else:
                user = User(email=normalize_email(email), apple_sub=apple_sub)
                db.add(user)
                db.flush()
                is_new_user = True

        return self._issue_auth_response(
            db,
            user=user,
            is_new_user=is_new_user,
            user_agent=user_agent,
            ip_address=ip_address,
        )

    def refresh(
        self,
        db: Session,
        *,
        refresh_token: str,
        user_agent: str | None,
        ip_address: str | None,
    ) -> AuthResponse:
        token_hash = hash_token(refresh_token)
        stored_token = db.scalar(
            select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        )
        if (
            not stored_token
            or stored_token.revoked_at is not None
            or _is_past(stored_token.expires_at)
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token"
            )
        if not stored_token.user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="User account is inactive"
            )

        stored_token.revoked_at = utc_now()
        return self._issue_auth_response(
            db,
            user=stored_token.user,
            is_new_user=False,
            user_agent=user_agent,
            ip_address=ip_address,
        )

    def forgot_password(self, db: Session, *, email: str) -> None:
        user = self.get_user_by_email(db, normalize_email(email))
        if not user:
            return

        raw_token = create_random_token()
        reset_token = PasswordResetToken(
            user_id=user.id,
            token_hash=hash_token(raw_token),
            expires_at=utc_now()
            + timedelta(minutes=settings.PASSWORD_RESET_TOKEN_EXPIRE_MINUTES),
        )
        db.add(reset_token)
        db.flush()

        separator = "&" if "?" in settings.PASSWORD_RESET_URL_BASE else "?"
        reset_url = f"{settings.PASSWORD_RESET_URL_BASE}{separator}{urlencode({'token': raw_token})}"
        email_service.send_password_reset_email(
            to_email=user.email, reset_url=reset_url
        )

    def reset_password(self, db: Session, *, token: str, password: str) -> None:
        stored_token = db.scalar(
            select(PasswordResetToken).where(
                PasswordResetToken.token_hash == hash_token(token)
            )
        )
        if (
            not stored_token
            or stored_token.used_at is not None
            or _is_past(stored_token.expires_at)
        ):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired reset token",
            )

        stored_token.user.hashed_password = get_password_hash(password)
        stored_token.used_at = utc_now()

    def get_user_by_email(self, db: Session, email: str) -> User | None:
        return db.scalar(select(User).where(User.email == email))

    def get_user_by_id(self, db: Session, user_id: str) -> User | None:
        return db.get(User, user_id)

    def _issue_auth_response(
        self,
        db: Session,
        *,
        user: User,
        is_new_user: bool,
        user_agent: str | None,
        ip_address: str | None,
    ) -> AuthResponse:
        access_token = create_access_token(user.id)
        refresh_token = create_random_token()
        db.add(
            RefreshToken(
                user_id=user.id,
                token_hash=hash_token(refresh_token),
                expires_at=utc_now()
                + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
                user_agent=user_agent,
                ip_address=ip_address,
            )
        )
        db.commit()
        db.refresh(user)
        return AuthResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user_id=user.id,
            email=user.email,
            display_name=user.display_name,
            is_new_user=is_new_user,
        )


auth_service = AuthService()
