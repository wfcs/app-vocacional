"""Motor de recomendação RIASEC.

Funções puras (sem I/O), facilmente testáveis. Toda interação com banco
fica no router/repositório.
"""
from __future__ import annotations

import math
from collections import defaultdict
from dataclasses import dataclass

from app.constants import RIASEC_CODES


@dataclass(frozen=True)
class AnsweredOption:
    """Resposta enriquecida com a área e score da opção escolhida."""
    option_id: int
    area_code: str
    score: float


@dataclass(frozen=True)
class ProfessionVector:
    """Vetor RIASEC ponderado de uma profissão (pesos somam ~1.0)."""
    profession_id: int
    weights: dict[str, float]  # area_code -> weight


@dataclass(frozen=True)
class ProfessionMatch:
    profession_id: int
    score: float  # 0-100


# ---------------------------------------------------------------------------
# Cálculo de scores por área
# ---------------------------------------------------------------------------

def calculate_area_scores(answers: list[AnsweredOption]) -> dict[str, float]:
    """Soma scores por área e normaliza para somar 1.0.

    Retorna dict com TODAS as 6 áreas RIASEC (zero quando não pontuou).
    """
    raw: dict[str, float] = defaultdict(float)
    for a in answers:
        raw[a.area_code] += a.score

    total = sum(raw.values())
    if total == 0:
        return {code: 0.0 for code in RIASEC_CODES}

    return {code: round(raw.get(code, 0.0) / total, 4) for code in RIASEC_CODES}


def dominant_area(area_scores: dict[str, float]) -> str:
    """Retorna a área de maior pontuação (desempate alfabético)."""
    return max(area_scores.items(), key=lambda kv: (kv[1], -ord(kv[0][0])))[0]


# ---------------------------------------------------------------------------
# Match de profissões via similaridade de cosseno
# ---------------------------------------------------------------------------

def _cosine_similarity(a: dict[str, float], b: dict[str, float]) -> float:
    keys = set(a) | set(b)
    dot = sum(a.get(k, 0.0) * b.get(k, 0.0) for k in keys)
    norm_a = math.sqrt(sum(v * v for v in a.values()))
    norm_b = math.sqrt(sum(v * v for v in b.values()))
    if norm_a == 0 or norm_b == 0:
        return 0.0
    return dot / (norm_a * norm_b)


def rank_professions(
    area_scores: dict[str, float],
    profession_vectors: list[ProfessionVector],
    top_n: int = 5,
) -> list[ProfessionMatch]:
    """Ranqueia profissões por similaridade de cosseno com o vetor do usuário.

    Match score normalizado em [0, 100], arredondado em 2 casas.
    """
    matches: list[ProfessionMatch] = []
    for pv in profession_vectors:
        sim = _cosine_similarity(area_scores, pv.weights)
        matches.append(ProfessionMatch(profession_id=pv.profession_id, score=round(sim * 100, 2)))

    matches.sort(key=lambda m: (-m.score, m.profession_id))
    return matches[:top_n]


# ---------------------------------------------------------------------------
# Seleção de instituições — filtra pela cidade do lead, prioriza top profissões
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class CourseOffer:
    """Oferta de curso por uma instituição na cidade do lead."""
    institution_id: int
    course_id: int
    profession_id: int  # já resolvido via profession_courses


def select_institutions(
    top_professions: list[ProfessionMatch],
    offers_in_city: list[CourseOffer],
    top_n: int = 5,
) -> list[CourseOffer]:
    """Devolve top_n ofertas, priorizando profissões com maior match.

    Algoritmo:
    1. Indexa ofertas por profession_id.
    2. Itera top_professions na ordem de match e empilha ofertas até atingir top_n.
    3. Deduplica por (institution_id, course_id).
    """
    by_prof: dict[int, list[CourseOffer]] = defaultdict(list)
    for offer in offers_in_city:
        by_prof[offer.profession_id].append(offer)

    seen: set[tuple[int, int]] = set()
    result: list[CourseOffer] = []
    for match in top_professions:
        for offer in by_prof.get(match.profession_id, []):
            key = (offer.institution_id, offer.course_id)
            if key in seen:
                continue
            seen.add(key)
            result.append(offer)
            if len(result) >= top_n:
                return result
    return result
