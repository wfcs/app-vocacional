"""Configurações via env (pydantic-settings)."""
from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Supabase
    supabase_url: str = Field(..., description="URL do projeto Supabase")
    supabase_service_key: str = Field(..., description="service_role key (server-side only)")
    supabase_anon_key: str | None = None

    # E-mail
    resend_api_key: str | None = None
    email_from: str = "Vocacional <onboarding@resend.dev>"

    # Recomendação
    top_professions: int = 5
    top_institutions: int = 5

    # CORS (lista separada por vírgula)
    cors_origins: str = "http://localhost:5173,http://localhost:3000"

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    """Settings cacheadas. Usar via Depends(get_settings) em endpoints."""
    return Settings()  # type: ignore[call-arg]
