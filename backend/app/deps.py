"""Dependências injetáveis (Supabase client, serviços)."""
from functools import lru_cache

from supabase import Client, create_client

from app.config import Settings, get_settings
from app.services.email import EmailService, build_email_service


@lru_cache
def _build_supabase_client() -> Client:
    settings = get_settings()
    return create_client(settings.supabase_url, settings.supabase_service_key)


def get_supabase() -> Client:
    """Cliente Supabase com service_role (server-side, ignora RLS)."""
    return _build_supabase_client()


@lru_cache
def _build_email_service() -> EmailService:
    settings = get_settings()
    return build_email_service(settings)


def get_email_service() -> EmailService:
    return _build_email_service()


__all__ = ["Settings", "get_settings", "get_supabase", "get_email_service"]
