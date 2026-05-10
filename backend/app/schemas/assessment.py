from uuid import UUID

from pydantic import BaseModel, Field


class AssessmentStart(BaseModel):
    lead_id: UUID


class QuestionOptionOut(BaseModel):
    id: int
    label: str


class QuestionOut(BaseModel):
    id: int
    sequence: int
    statement: str
    options: list[QuestionOptionOut]


class AssessmentStartOut(BaseModel):
    assessment_id: UUID
    questions: list[QuestionOut]


class AnswerIn(BaseModel):
    question_id: int = Field(..., gt=0)
    option_id: int = Field(..., gt=0)


class AnswersBatchIn(BaseModel):
    answers: list[AnswerIn] = Field(..., min_length=1)
