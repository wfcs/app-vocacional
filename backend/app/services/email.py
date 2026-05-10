"""Serviço de e-mail. Implementação atual: Resend ou console (fallback)."""
from __future__ import annotations

import logging
from abc import ABC, abstractmethod
from typing import TYPE_CHECKING, Any

import httpx

if TYPE_CHECKING:
    from app.config import Settings

logger = logging.getLogger(__name__)


class EmailService(ABC):
    """Interface — facilita troca de provider e mock em testes."""

    @abstractmethod
    async def send_result(
        self, *, to: str, lead_name: str, result_payload: dict[str, Any]
    ) -> bool:
        """Envia o e-mail de resultado. Retorna True se enviado, False se falhou."""


class ConsoleEmailService(EmailService):
    """Fallback: apenas loga. Útil em dev e em testes."""

    async def send_result(
        self, *, to: str, lead_name: str, result_payload: dict[str, Any]
    ) -> bool:
        logger.warning(
            "[ConsoleEmail] Pulando envio real. to=%s name=%s dominant_area=%s",
            to,
            lead_name,
            result_payload.get("dominant_area_code"),
        )
        return True


class ResendEmailService(EmailService):
    """Provider Resend (https://resend.com)."""

    API_URL = "https://api.resend.com/emails"

    def __init__(self, api_key: str, sender: str) -> None:
        self.api_key = api_key
        self.sender = sender

    async def send_result(
        self, *, to: str, lead_name: str, result_payload: dict[str, Any]
    ) -> bool:
        body = {
            "from": self.sender,
            "to": [to],
            "subject": f"{lead_name}, seu resultado vocacional chegou",
            "html": _render_html(lead_name, result_payload),
        }
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(
                    self.API_URL,
                    json=body,
                    headers={"Authorization": f"Bearer {self.api_key}"},
                )
                if resp.status_code >= 400:
                    logger.error("Resend falhou: %s %s", resp.status_code, resp.text)
                    return False
                return True
        except httpx.HTTPError as e:
            logger.exception("Resend erro de rede: %s", e)
            return False


def build_email_service(settings: Settings) -> EmailService:
    if settings.resend_api_key:
        return ResendEmailService(api_key=settings.resend_api_key, sender=settings.email_from)
    return ConsoleEmailService()


# ---------------------------------------------------------------------------
# Renderização HTML mínima do relatório
# ---------------------------------------------------------------------------

def _render_html(lead_name: str, payload: dict[str, Any]) -> str:
    profs = "".join(
        f"<li><strong>{p['name']}</strong> — match {p['match_score']}%</li>"
        for p in payload.get("top_professions", [])
    )
    insts = "".join(
        f"<li>{i['institution_name']} — {i['course_name']} ({i['city_name']})</li>"
        for i in payload.get("top_institutions", [])
    )
    return f"""
    <h2>Olá, {lead_name}!</h2>
    <p>Sua área dominante é <strong>{payload.get('dominant_area_name')}</strong>.</p>
    <h3>Profissões com maior afinidade</h3>
    <ol>{profs}</ol>
    <h3>Instituições recomendadas na sua cidade</h3>
    <ul>{insts or '<li>Nenhuma instituição cadastrada na sua cidade ainda.</li>'}</ul>
    <p><small>Gerado por App Vocacional.</small></p>
    """
