"""Testes do motor de recomendação RIASEC.

Foco: funções puras (sem I/O). Os endpoints são testados em testes de integração
(a serem adicionados quando tivermos staging).
"""
from app.constants import RIASEC_CODES
from app.services.recommendation import (
    AnsweredOption,
    CourseOffer,
    ProfessionMatch,
    ProfessionVector,
    calculate_area_scores,
    dominant_area,
    rank_professions,
    select_institutions,
)


# ---------------------------------------------------------------------------
# calculate_area_scores
# ---------------------------------------------------------------------------

def test_area_scores_normalizes_to_one():
    answers = [
        AnsweredOption(option_id=1, area_code="INVESTIGATIVE", score=1.0),
        AnsweredOption(option_id=2, area_code="INVESTIGATIVE", score=1.0),
        AnsweredOption(option_id=3, area_code="REALISTIC", score=1.0),
        AnsweredOption(option_id=4, area_code="SOCIAL", score=1.0),
    ]
    scores = calculate_area_scores(answers)
    assert set(scores) == set(RIASEC_CODES)
    assert abs(sum(scores.values()) - 1.0) < 0.001
    assert scores["INVESTIGATIVE"] == 0.5
    assert scores["REALISTIC"] == 0.25
    assert scores["SOCIAL"] == 0.25
    assert scores["ARTISTIC"] == 0.0


def test_area_scores_zero_when_no_answers():
    scores = calculate_area_scores([])
    assert all(v == 0.0 for v in scores.values())
    assert set(scores) == set(RIASEC_CODES)


# ---------------------------------------------------------------------------
# dominant_area
# ---------------------------------------------------------------------------

def test_dominant_area_returns_highest():
    scores = {
        "REALISTIC": 0.10,
        "INVESTIGATIVE": 0.50,
        "ARTISTIC": 0.05,
        "SOCIAL": 0.20,
        "ENTERPRISING": 0.10,
        "CONVENTIONAL": 0.05,
    }
    assert dominant_area(scores) == "INVESTIGATIVE"


# ---------------------------------------------------------------------------
# rank_professions (cosine similarity)
# ---------------------------------------------------------------------------

def test_rank_professions_prefers_aligned_vector():
    user = {
        "REALISTIC": 0.0, "INVESTIGATIVE": 0.6, "ARTISTIC": 0.0,
        "SOCIAL": 0.0, "ENTERPRISING": 0.0, "CONVENTIONAL": 0.4,
    }
    eng = ProfessionVector(profession_id=1, weights={
        "INVESTIGATIVE": 0.5, "REALISTIC": 0.3, "CONVENTIONAL": 0.2,
    })
    artista = ProfessionVector(profession_id=2, weights={
        "ARTISTIC": 0.7, "SOCIAL": 0.3,
    })
    ranked = rank_professions(user, [eng, artista], top_n=2)
    assert ranked[0].profession_id == 1
    assert ranked[0].score > ranked[1].score
    assert 0 <= ranked[1].score <= 100


def test_rank_professions_respects_top_n():
    user = {"INVESTIGATIVE": 1.0}
    vectors = [
        ProfessionVector(profession_id=i, weights={"INVESTIGATIVE": 1.0})
        for i in range(1, 6)
    ]
    ranked = rank_professions(user, vectors, top_n=3)
    assert len(ranked) == 3


# ---------------------------------------------------------------------------
# select_institutions
# ---------------------------------------------------------------------------

def test_select_institutions_prioritizes_top_professions():
    top = [
        ProfessionMatch(profession_id=10, score=90.0),
        ProfessionMatch(profession_id=20, score=70.0),
    ]
    offers = [
        CourseOffer(institution_id=1, course_id=100, profession_id=20),
        CourseOffer(institution_id=2, course_id=200, profession_id=10),
        CourseOffer(institution_id=3, course_id=300, profession_id=10),
    ]
    selected = select_institutions(top, offers, top_n=3)
    # As 2 ofertas da profissão 10 (top) devem aparecer antes da da 20
    assert selected[0].profession_id == 10
    assert selected[1].profession_id == 10
    assert selected[2].profession_id == 20


def test_select_institutions_dedups_by_inst_and_course():
    top = [ProfessionMatch(profession_id=10, score=90.0)]
    offers = [
        CourseOffer(institution_id=1, course_id=100, profession_id=10),
        CourseOffer(institution_id=1, course_id=100, profession_id=10),  # duplicada
    ]
    selected = select_institutions(top, offers, top_n=5)
    assert len(selected) == 1


def test_select_institutions_returns_empty_when_no_offers():
    top = [ProfessionMatch(profession_id=10, score=90.0)]
    assert select_institutions(top, [], top_n=5) == []
