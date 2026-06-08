from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class GoogleAuthRequest(BaseModel):
    id_token: str


class AppleAuthRequest(BaseModel):
    identity_token: str
    authorization_code: str


class RefreshRequest(BaseModel):
    refresh_token: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    password: str = Field(min_length=8, max_length=128)


class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    user_id: str
    email: EmailStr
    display_name: str | None = None
    is_new_user: bool


class MessageResponse(BaseModel):
    message: str


class UserResponse(BaseModel):
    user_id: str
    email: EmailStr
    display_name: str | None = None
