from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


class LeadCreate(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=120)
    email: EmailStr
    city_id: int = Field(..., gt=0)
    consent_lgpd: bool = Field(..., description="Obrigatório aceitar")
    consent_marketing: bool = False


class LeadOut(BaseModel):
    id: UUID
    full_name: str
    email: str
    city_id: int
