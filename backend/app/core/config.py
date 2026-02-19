from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List, Union
import os

class Settings(BaseSettings):
    PROJECT_NAME: str = "PitStop"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    BACKEND_CORS_ORIGINS: Union[str, List[str]] = "http://localhost:3000,http://localhost:8000"
    DATABASE_URL: str = ""
    REDIS_URL: str = "redis://localhost:6379/0"
    SECRET_KEY: str = ""
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    model_config = SettingsConfigDict(env_file=os.path.join(os.path.dirname(__file__), '../../.env'), env_file_encoding='utf-8')

    def __init__(self, **values):
        super().__init__(**values)
        # Parse comma-separated CORS origins
        if isinstance(self.BACKEND_CORS_ORIGINS, str):
            self.BACKEND_CORS_ORIGINS = [origin.strip() for origin in self.BACKEND_CORS_ORIGINS.split(",") if origin.strip()]

settings = Settings()
