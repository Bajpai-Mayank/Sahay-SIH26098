from typing import List, Optional
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Typed application settings for SAHAY-AI.
    Reads strictly from environment variables or backend/.env.
    Defaults allow the entire application and mock AI to run with zero credentials.
    """

    # APPLICATION
    APP_NAME: str = "SAHAY-AI"
    APP_ENV: str = "development"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:8080,http://localhost:5000,http://127.0.0.1:8000,http://localhost:8000"

    # DATABASE
    # Defaults to async SQLite for out-of-the-box local testing if PostgreSQL is not yet configured
    DATABASE_URL: str = "sqlite+aiosqlite:///./sahay_dev.db"

    # SUPABASE
    SUPABASE_URL: Optional[str] = None
    SUPABASE_PUBLISHABLE_KEY: Optional[str] = None
    SUPABASE_SECRET_KEY: Optional[str] = None
    # Backwards compatibility aliases
    SUPABASE_ANON_KEY: Optional[str] = None
    SUPABASE_SERVICE_ROLE_KEY: Optional[str] = None
    SUPABASE_JWT_SECRET: Optional[str] = None

    # REDIS & UPSTASH
    REDIS_URL: Optional[str] = None
    UPSTASH_REDIS_REST_URL: Optional[str] = None
    UPSTASH_REDIS_REST_TOKEN: Optional[str] = None

    # AI CONFIGURATION
    # Options: mock | gemini | ollama | huggingface
    AI_PROVIDER: str = "mock"
    AI_MODEL: str = "gemini-1.5-flash"
    AI_TIMEOUT_SECONDS: int = 30
    AI_FALLBACK_TO_MOCK: bool = True
    AI_SAFETY_STRICT: bool = True

    # GEMINI
    GEMINI_API_KEY: Optional[str] = None

    # OLLAMA
    OLLAMA_BASE_URL: str = "http://localhost:11434"

    # HUGGING FACE
    HF_TOKEN: Optional[str] = None

    # STORAGE
    STORAGE_BACKEND: str = "local"  # local | supabase
    STORAGE_PATH: str = "./storage_data"
    STORAGE_BUCKET: str = "audio-checkins"

    # SECURITY & JWT
    JWT_SECRET_KEY: str = "sahay_development_secret_key_change_in_production_32b"
    JWT_SECRET: Optional[str] = None  # Alias support
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    @property
    def cors_origins_list(self) -> List[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]

    @property
    def effective_supabase_publishable_key(self) -> Optional[str]:
        return self.SUPABASE_PUBLISHABLE_KEY or self.SUPABASE_ANON_KEY

    @property
    def effective_supabase_secret_key(self) -> Optional[str]:
        return self.SUPABASE_SECRET_KEY or self.SUPABASE_SERVICE_ROLE_KEY

    @property
    def effective_jwt_secret(self) -> str:
        return self.JWT_SECRET or self.JWT_SECRET_KEY


settings = Settings()


def get_settings() -> Settings:
    return settings
