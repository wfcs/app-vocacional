from uuid import UUID

from pydantic import BaseModel


class ProfessionRecOut(BaseModel):
    profession_id: int
    name: str
    description: str | None = None
    match_score: float
    rank: int


class InstitutionRecOut(BaseModel):
    institution_id: int
    institution_name: str
    institution_type: str
    city_name: str
    course_id: int
    course_name: str
    course_type: str
    profession_id: int | None = None
    rank: int


class ResultOut(BaseModel):
    result_id: UUID
    assessment_id: UUID
    dominant_area_code: str
    dominant_area_name: str
    area_scores: dict[str, float]
    top_professions: list[ProfessionRecOut]
    top_institutions: list[InstitutionRecOut]
    email_sent: bool
