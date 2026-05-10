"""Constantes do domínio (RIASEC + defaults)."""
from typing import Final

RIASEC_CODES: Final[tuple[str, ...]] = (
    "REALISTIC",
    "INVESTIGATIVE",
    "ARTISTIC",
    "SOCIAL",
    "ENTERPRISING",
    "CONVENTIONAL",
)

# Quantidade default de recomendações
DEFAULT_TOP_PROFESSIONS: Final[int] = 5
DEFAULT_TOP_INSTITUTIONS: Final[int] = 5
