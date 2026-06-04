from fastapi import APIRouter, Depends, Request, status
from sqlalchemy.orm import Session

from app.api.v1.dependencies.auth import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import (
    AppleAuthRequest,
    AuthResponse,
    ForgotPasswordRequest,
    GoogleAuthRequest,
    LoginRequest,
    MessageResponse,
    RefreshRequest,
    RegisterRequest,
    ResetPasswordRequest,
    UserResponse,
)
from app.services.auth import auth_service
from app.services.oauth import apple_token_verifier, google_token_verifier

router = APIRouter()


def _client_ip(request: Request) -> str | None:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",", maxsplit=1)[0].strip()
    return request.client.host if request.client else None


def _user_agent(request: Request) -> str | None:
    return request.headers.get("user-agent")


@router.post(
    "/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED
)
def register(
    body: RegisterRequest, request: Request, db: Session = Depends(get_db)
) -> AuthResponse:
    return auth_service.register(
        db,
        email=str(body.email),
        password=body.password,
        user_agent=_user_agent(request),
        ip_address=_client_ip(request),
    )


@router.post("/login", response_model=AuthResponse)
def login(
    body: LoginRequest, request: Request, db: Session = Depends(get_db)
) -> AuthResponse:
    return auth_service.login(
        db,
        email=str(body.email),
        password=body.password,
        user_agent=_user_agent(request),
        ip_address=_client_ip(request),
    )


@router.post("/google", response_model=AuthResponse)
def google_auth(
    body: GoogleAuthRequest, request: Request, db: Session = Depends(get_db)
) -> AuthResponse:
    payload = google_token_verifier.verify(body.id_token)
    return auth_service.authenticate_google(
        db,
        google_sub=str(payload["sub"]),
        email=str(payload["email"]),
        display_name=payload.get("name"),
        user_agent=_user_agent(request),
        ip_address=_client_ip(request),
    )


@router.post("/apple", response_model=AuthResponse)
def apple_auth(
    body: AppleAuthRequest, request: Request, db: Session = Depends(get_db)
) -> AuthResponse:
    payload = apple_token_verifier.verify(body.identity_token)
    return auth_service.authenticate_apple(
        db,
        apple_sub=str(payload["sub"]),
        email=payload.get("email"),
        user_agent=_user_agent(request),
        ip_address=_client_ip(request),
    )


@router.post("/refresh", response_model=AuthResponse)
def refresh(
    body: RefreshRequest, request: Request, db: Session = Depends(get_db)
) -> AuthResponse:
    return auth_service.refresh(
        db,
        refresh_token=body.refresh_token,
        user_agent=_user_agent(request),
        ip_address=_client_ip(request),
    )


@router.post("/forgot-password", response_model=MessageResponse)
def forgot_password(
    body: ForgotPasswordRequest, db: Session = Depends(get_db)
) -> MessageResponse:
    auth_service.forgot_password(db, email=str(body.email))
    db.commit()
    return MessageResponse(
        message="If the email exists, reset instructions have been sent"
    )


@router.post("/reset-password", response_model=MessageResponse)
def reset_password(
    body: ResetPasswordRequest, db: Session = Depends(get_db)
) -> MessageResponse:
    auth_service.reset_password(db, token=body.token, password=body.password)
    db.commit()
    return MessageResponse(message="Password has been reset")


@router.get("/me", response_model=UserResponse)
def me(current_user: User = Depends(get_current_user)) -> UserResponse:
    return UserResponse(
        user_id=current_user.id,
        email=current_user.email,
        display_name=current_user.display_name,
    )
