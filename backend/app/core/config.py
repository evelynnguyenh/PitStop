import os
from typing import List, Union

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "PitStop"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    BACKEND_CORS_ORIGINS: Union[str, List[str]] = (
        "http://localhost:3000,http://localhost:8000"
    )
    DATABASE_URL: str = ""
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_USER: str = "pitstop"
    POSTGRES_PASSWORD: str = "pitstop_dev"
    POSTGRES_DB: str = "pitstop"
    POSTGRES_PORT: int = 5432
    REDIS_URL: str = "redis://localhost:6379/0"
    SECRET_KEY: str = "dev-secret-change-me"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    PASSWORD_RESET_TOKEN_EXPIRE_MINUTES: int = 30
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_IDS: Union[str, List[str]] = ""
    APPLE_CLIENT_ID: str = ""
    PASSWORD_RESET_URL_BASE: str = "http://localhost:3000/reset-password"
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_USERNAME: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM_EMAIL: str = "no-reply@pitstop.local"
    SMTP_TLS: bool | None = None
    SMTP_USE_TLS: bool = True

    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(__file__), "../../.env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    def __init__(self, **values):
        super().__init__(**values)
        # Parse comma-separated CORS origins
        if isinstance(self.BACKEND_CORS_ORIGINS, str):
            self.BACKEND_CORS_ORIGINS = [
                origin.strip()
                for origin in self.BACKEND_CORS_ORIGINS.split(",")
                if origin.strip()
            ]
        if isinstance(self.GOOGLE_CLIENT_IDS, str):
            self.GOOGLE_CLIENT_IDS = [
                client_id.strip()
                for client_id in self.GOOGLE_CLIENT_IDS.split(",")
                if client_id.strip()
            ]
        if (
            self.GOOGLE_CLIENT_ID
            and self.GOOGLE_CLIENT_ID not in self.GOOGLE_CLIENT_IDS
        ):
            self.GOOGLE_CLIENT_IDS.append(self.GOOGLE_CLIENT_ID)
        if self.SMTP_USER and not self.SMTP_USERNAME:
            self.SMTP_USERNAME = self.SMTP_USER
        if self.SMTP_TLS is not None:
            self.SMTP_USE_TLS = self.SMTP_TLS

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return (
            f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )


settings = Settings()
